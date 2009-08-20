;;;
;;;Part of: Nausicaa/Scheme
;;;Contents: LALR(1) parser LR-driver
;;;Date: Tue Jul 21, 2009
;;;
;;;Abstract
;;;
;;;	This library  is a LALR(1)  parser generator written  in Scheme.
;;;	It implements an efficient algorithm for computing the lookahead
;;;	sets.  The  algorithm is the  same as used  in GNU Bison  and is
;;;	described in:
;;;
;;;	   F.  DeRemer  and  T.  Pennello.  ``Efficient  Computation  of
;;;	   LALR(1)  Look-Ahead Set''.   TOPLAS, vol.  4, no.  4, october
;;;	   1982.
;;;
;;;	As a consequence, it is not written in a fully functional style.
;;;	In fact,  much of  the code  is a direct  translation from  C to
;;;	Scheme of the Bison sources.
;;;
;;;	The library is  a port to @rnrs{6} Scheme of  Lalr-scm by .  The
;;;	original code is available at:
;;;
;;;			<http://code.google.com/p/lalr-scm/>
;;;
;;;Copyright (c) 2009 Marco Maggi
;;;Copyright (c) 2005-2008 Dominique Boucher
;;;
;;;This program is free software:  you can redistribute it and/or modify
;;;it under the terms of the  GNU General Public License as published by
;;;the Free Software Foundation, either version 3 of the License, or (at
;;;your option) any later version.
;;;
;;;This program is  distributed in the hope that it  will be useful, but
;;;WITHOUT  ANY   WARRANTY;  without   even  the  implied   warranty  of
;;;MERCHANTABILITY  or FITNESS FOR  A PARTICULAR  PURPOSE.  See  the GNU
;;;General Public License for more details.
;;;
;;;You should  have received  a copy of  the GNU General  Public License
;;;along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;;


#!r6rs
(library (lalr glr-driver)
  (export
    glr-driver

    ;; re-exports from (lalr common)
    make-source-location	source-location?
    source-location-line
    source-location-input
    source-location-column
    source-location-offset
    source-location-length

    make-lexical-token		lexical-token?
    lexical-token-value
    lexical-token-category
    lexical-token-source

    lexical-token?/end-of-input
    lexical-token?/lexer-error
    lexical-token?/special)
  (import (rnrs)
    (debugging)
    (lalr common))


;;;; helpers

(define-syntax drop/stx
  (syntax-rules ()
    ((_ ?ell ?k)
     (let loop ((ell ?ell)
		(k   ?k))
       (if (zero? k)
	   ell
	 (loop (cdr ell) (- k 1)))))))

(define-syntax receive
  (syntax-rules ()
    ((_ formals expression b b* ...)
     (call-with-values
         (lambda () expression)
       (lambda formals b b* ...)))))

(define-syntax define-inline
  (syntax-rules ()
    ((_ (?name ?arg ...) ?form0 ?form ...)
     (define-syntax ?name
       (syntax-rules ()
	 ((_ ?arg ...)
	  (begin ?form0 ?form ...)))))))


;;;; process utilities
;;
;;A "process" is  a couple of stacks, one for the  state numbers and one
;;for the  token values.   Every time a  shift action is  performed, one
;;value is  pushed on both  the stacks.  Every  time a reduce  action is
;;performed, values from both the stacks are removed and replaced with a
;;single value.
;;
;;Processes are implemented  as pairs of lists; the CAR  is the stack of
;;states, the CDR is the stack of values.
;;
;;Some  of the  following definitions  are  actually used  in the  code;
;;others are here only for reference.
;;

(define make-process cons)
(define process-states-ref car)
(define process-values-ref cdr)

(define process-top-state-ref caar)
(define process-top-value-ref cadr)
(define process-accept-value-ref caddr)

(define-inline (process-push! ?process ?state ?value)
  (let ((process ?process))
    (cons (cons ?state (process-states-ref process))
	  (cons ?value (process-values-ref process)))))


(define (glr-driver action-table goto-table reduction-table)
  (define (parser-instance true-lexer error-handler yycustom)
    (define reuse-last-token #f)
    (define results '())

    (define (main lookahead processes shifted)
      (debug "~%***main processes ~s" processes)
      (let* ((shifted*  (process->shifted lookahead (car processes)))
	     (processes (cdr processes))
	     (shifted   (append shifted shifted*)))
	(debug "main: processes ~s shifted ~s" processes shifted)
	(if (null? processes)
	    (if (null? shifted)
		results
	      (main (lexer) shifted '()))
	  (main lookahead processes shifted))))

    (define (process->shifted lookahead process)
      ;;Perform  the  actions upon  PROCESS  until  he  and its  spawned
      ;;processes  are all:  terminated  or shifted.   The  causes of  a
      ;;process  termination  are:  the  result is  accepted;  an  error
      ;;occurs.  Return the list of shifted processes.
      ;;
      (let reduce-loop ((reduced (list process))
			(shifted '()))
	(debug "process->shifted: reduced ~s, shifted ~s, results ~s" reduced shifted results)
	(if (null? reduced)
	    shifted
	  (receive (reduced* shifted*)
	      (perform-actions lookahead (car reduced))
	    (reduce-loop (append (cdr reduced) reduced*)
			 (append shifted shifted*))))))

    (define (perform-actions lookahead process)
      ;;Perform  a set of  actions on  PROCESS.  The  list of  action is
      ;;selected from the action table according to the current state of
      ;;PROCESS  and  the LOOKAHEAD  token's  category.
      ;;
      ;;Performing  the  actions   (potentially)  generates  a  list  of
      ;;processes  which  are children  of  PROCESS;  some  of them  are
      ;;generated by  a reduce action,  others are generated by  a shift
      ;;action.  An action can also cause a termination because of error
      ;;or  because its  result is  accepted and  stored in  the RESULTS
      ;;list.
      ;;
      ;;Return two values: the list  of reduced children and the list of
      ;;shifted children.
      ;;
      (debug "perform-actions: process ~s ~s actions ~s"
	     (process-states-ref process)
	     (process-values-ref process)
	     (select-actions lookahead (caar process)))
      (do ((actions-list (select-actions lookahead (process-top-state-ref process))
			 (cdr actions-list))
	   (reduced '())
	   (shifted '()))
	  ((null? actions-list)
	   (values reduced shifted))
	(let ((action (car actions-list)))
	  (cond ((eq? action '*error*) ;error, discard this process
		 (debug "action ~s error" action)
		 #f)
		((eq? action 'accept) ;accept, register result and discard this process
		 (debug "action accept ~s" (process-accept-value-ref process))
		 (set! results (cons (process-accept-value-ref process) results)))
		((>= action 0) ;shift, this children process survives
		 (debug "action ~s shift" action)
		 (set! shifted
		       (cons (process-push! process action (lexical-token-value lookahead))
			     shifted)))
		(else ;reduce, this process will stay in the PROCESS->SHIFTED loop
		 (debug "action ~s reduce" action)
		 (set! reduced
		       (cons (reduce (- action) process)
			     reduced)))))))

    (define lexer
      (let ((last-token #f))
	(lambda ()
	  (if reuse-last-token
	      (set! reuse-last-token #f)
	    (begin
	      (set! last-token (true-lexer))
	      (unless (lexical-token? last-token)
		(error-handler "expected lexical token from lexer" last-token)
		(true-lexer))))
	  (debug "~%lookahead ~s" last-token)
	  last-token)))

    (define (yypushback)
      (set! reuse-last-token #t))

    (define (reduce reduction-table-index process)

      (define (%main)
	(apply (vector-ref reduction-table reduction-table-index)
	       reduce-pop-and-push yypushback yycustom
	       (process-states-ref process)
	       (process-values-ref process)))

      (define (reduce-pop-and-push used-values goto-keyword semantic-clause-result
				   yy-stack-states yy-stack-values)
	(let* ((yy-stack-states (drop/stx yy-stack-states used-values))
	       (new-state       (goto-state goto-keyword (car yy-stack-states))))
	  (debug "reduce semantic clause result ~s" semantic-clause-result)
	  ;;This is not PROCESS-PUSH!
	  `((,new-state              . ,yy-stack-states) .
	    (,semantic-clause-result . ,yy-stack-values))))

      (define-inline (goto-state goto-keyword current-state)
	(cdr (assv goto-keyword (vector-ref goto-table current-state))))

      (%main))

    (define (select-actions lookahead state-index)
      (let* ((action-alist (vector-ref action-table state-index))
	     (pair         (assq (lexical-token-category lookahead) action-alist)))
	(if pair (cdr pair) (cdar action-alist))))

    (main (lexer) '(((0) . (#f))) '()))

  (case-lambda
   ((true-lexer error-handler)
    (parser-instance true-lexer error-handler #f))
   ((true-lexer error-handler yycustom)
    (parser-instance true-lexer error-handler yycustom))))


;;;; done

)

;;; end of file
