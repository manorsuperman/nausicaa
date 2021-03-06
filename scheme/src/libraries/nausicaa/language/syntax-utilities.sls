;;; -*- coding: utf-8-unix -*-
;;;
;;;Part of: Nausicaa/Scheme
;;;Contents: helper functions for expand time processing
;;;Date: Wed May 26, 2010
;;;
;;;Abstract
;;;
;;;
;;;
;;;Copyright (c) 2010, 2011 Marco Maggi <marco.maggi-ipsu@poste.it>
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
(library (nausicaa language syntax-utilities)
  (export

    ;; wrapping
    unwrap				unwrap-options
    syntax->vector			syntax->list

    ;; inspection
    quoted-syntax-object?		syntax=?

    ;; identifiers handling
    all-identifiers?			duplicate-identifiers?
    delete-duplicate-identifiers	identifier-memq
    symbol-identifier=?			identifier-subst
    case-identifier

    ;; common identifier names constructor
    identifier->string			string->identifier
    identifier-prefix			identifier-suffix
    syntax-maker-identifier		syntax-predicate-identifier
    syntax-accessor-identifier		syntax-mutator-identifier
    syntax-dot-notation-identifier	(rename (syntax-accessor-identifier
						 syntax-method-identifier))
    string-general-append		syntax-general-append
    with-implicits

    ;; clauses helpers
    validate-list-of-clauses		validate-definition-clauses
    filter-clauses			discard-clauses)
  (import (rnrs)
    (for (only (rnrs base) quote quasiquote) (meta -1))
    (for (only (rnrs syntax-case) syntax quasisyntax) (meta -1)))


(define-enumeration enum-unwrap-options
  (keep-general-quoted)
  unwrap-options)

(define unwrap
  (case-lambda
   ((stx)
    (unwrap stx (unwrap-options)))
   ((stx options)
    ;;Given   a  syntax  object   STX  decompose   it  and   return  the
    ;;corresponding S-expression  holding datums and  identifiers.  Take
    ;;care of returning a proper list  when the input is a syntax object
    ;;holding a proper list.
    ;;
    ;;This functions also  provides a workaround for bugs  in Ikarus and
    ;;Mosh,  which expand syntax  objects holding  a list  into IMproper
    ;;lists.
    ;;
    ;;Aaron Hsu contributed the  SYNTAX->LIST function through a post on
    ;;comp.lang.scheme: it was used as starting point for this function.
    ;;
    (syntax-case stx ()
      (()
       '())
      ((?car . ?cdr)
       (and (enum-set-member? 'keep-general-quoted options)
	    (identifier? #'?car)
	    (or (free-identifier=? #'?car #'quote)
		(free-identifier=? #'?car #'quasiquote)
		(free-identifier=? #'?car #'syntax)
		(free-identifier=? #'?car #'quasisyntax)))
       (syntax (?car . ?cdr)))
      ((?car . ?cdr)
       (cons (unwrap (syntax ?car))
	     (unwrap (syntax ?cdr))))
      (#(?item ...)
       (list->vector (unwrap (syntax (?item ...)))))
      (?atom
       (identifier? (syntax ?atom))
       (syntax ?atom))
      (?atom
       (syntax->datum (syntax ?atom)))))))

(define (syntax->vector stx)
  (syntax-case stx ()
    (#(?v ...)
     (list->vector (syntax->list #'(?v ...) '())))
    (_
     (syntax-violation 'syntax->vector "expected vector input form" (syntax->datum stx)))))

(define syntax->list
  (case-lambda
   ((stx)
    (syntax->list stx '()))
   ((stx tail)
    ;;Given a  syntax object  STX holding a  list, return a  proper list
    ;;holding  the component  syntax objects.   TAIL must  be null  or a
    ;;proper list which will become the tail of the returned list.
    ;;
    (syntax-case stx ()
      ((?car . ?cdr)
       ;;Yes, it  is not tail recursive;  "they" say it  is efficient this
       ;;way.
       (cons #'?car (syntax->list #'?cdr tail)))
      (()
       tail)))))


(define (quoted-syntax-object? stx)
  ;;Given a syntax object: return true if  it is a list whose car is one
  ;;among   QUOTE,  QUASIQUOTE,   SYNTAX,   QUASISYNTAX;  return   false
  ;;otherwise.
  ;;
  (syntax-case stx ()
    ((?car . ?cdr)
     (and (identifier? #'?car)
	  (or (free-identifier=? #'?car #'quote)
	      (free-identifier=? #'?car #'quasiquote)
	      (free-identifier=? #'?car #'syntax)
	      (free-identifier=? #'?car #'quasisyntax)))
     #t)
    (_ #f)))

(define (syntax=? stx1 stx2)
  (define (%syntax=? stx1 stx2)
    (cond ((and (identifier? stx1) (identifier? stx2))
	   (free-identifier=? stx1 stx2))
	  ((and (pair? stx1) (pair? stx2))
	   (and (syntax=? (car stx1) (car stx1))
		(syntax=? (cdr stx1) (cdr stx1))))
	  ((and (vector? stx1) (vector? stx2))
	   (let ((len1 (vector-length stx1)))
	     (and (= len1 (vector-length stx2))
		  (let loop ((i 0))
		    (or (= i len1)
			(and (syntax=? (vector-ref stx1 i) (vector-ref stx2 i))
			     (loop (+ 1 i)))))
	       #f)))
	  (else
	   (equal? stx1 stx2))))
  (%syntax=? (unwrap stx1 (enum-unwrap-options keep-general-quoted))
	     (unwrap stx2 (enum-unwrap-options keep-general-quoted))))


(define (all-identifiers? stx)
  ;;Given  a syntax  object: return  true if  it is  null or  a  list of
  ;;identifiers; return false otherwise.
  ;;
  (syntax-case stx ()
    ((?car . ?cdr)
     (identifier? #'?car)
     (all-identifiers? #'?cdr))
    (()		#t)
    (_		#f)))

(define duplicate-identifiers?
  ;;Recursive  function.   Search  the   list  of  identifiers  STX  for
  ;;duplicate  identifiers; at  the  first duplicate  found, return  it;
  ;;return false if no duplications are found.
  ;;
  (case-lambda
   ((stx)
    (duplicate-identifiers? stx bound-identifier=?))
   ((stx identifier=)
    (syntax-case stx ()
      (() #f)
      ((?car . ?cdr)
       (let loop ((first #'?car)
		  (rest  #'?cdr))
	 (syntax-case rest ()
	   (()
	    (duplicate-identifiers? #'?cdr))
	   ((?car . ?cdr)
	    (if (identifier= first #'?car)
		first
	      (loop first #'?cdr))))))))))

;;Old version.
;;
;; (define duplicate-identifiers?
;;   (case-lambda
;;    ((ell/stx)
;;     (duplicate-identifiers? ell/stx bound-identifier=?))
;;    ((ell/stx identifier=)
;;     (if (null? ell/stx)
;; 	#f
;;       (let loop ((x  (car ell/stx))
;; 		 (ls (cdr ell/stx)))
;; 	(if (null? ls)
;; 	    (duplicate-identifiers? (cdr ell/stx) identifier=)
;; 	  (if (identifier= x (car ls))
;; 	      x
;; 	    (loop x (cdr ls)))))))))

(define (delete-duplicate-identifiers ids)
  ;;Given the  list of identifiers IDS remove  the duplicate identifiers
  ;;and return a proper list of unique identifiers.
  ;;
  (let clean-tail ((ids ids))
    (if (null? ids)
	'()
      (let ((head (car ids)))
	(cons head (clean-tail (remp (lambda (id)
				       (free-identifier=? id head))
				 (cdr ids))))))))

(define (identifier-memq identifier list-of-syntax-objects)
  ;;Given  a   list  of   syntax  objects  search   for  one   which  is
  ;;FREE-IDENTIFIER=? to IDENTIFIER and return the sublist starting with
  ;;it; return false if IDENTIFIER is not present.
  ;;
  (assert (identifier? identifier))
  (cond ((null? list-of-syntax-objects)
	 #f)
	((let ((stx (car list-of-syntax-objects)))
	   (and (identifier? stx) (free-identifier=? identifier stx)))
	 list-of-syntax-objects)
	(else
	 (identifier-memq identifier (cdr list-of-syntax-objects)))))

(define (symbol-identifier=? id1 id2)
  (assert (identifier? id1))
  (assert (identifier? id2))
  (eq? (syntax->datum id1) (syntax->datum id2)))

(define (identifier-subst src-ids dst-ids stx)
  (define (%subst stx src dst)
    (syntax-case stx ()

      ((?car . ?cdr)
       (and (identifier? #'?car)
	    (or (free-identifier=? #'?car #'quote)
		(free-identifier=? #'?car #'quasiquote)
		(free-identifier=? #'?car #'syntax)
		(free-identifier=? #'?car #'quasisyntax)))
       #'(?car . ?cdr))

      ((?car . ?cdr)
       (identifier? #'?car)
       (cons (if (free-identifier=? src #'?car) dst #'?car)
	     (%subst #'?cdr src dst)))

      ((?car . ?cdr)
       (cons (%subst #'?car src dst) (%subst #'?cdr src dst)))

      (#(?item ...)
       (list->vector (%subst #'(?item ...) src dst)))

      (_ stx)))

  ;;We assume that it is more likely that the ALIST holds a single pair.
  (fold-left %subst
	     stx
	     (unwrap src-ids)
	     (unwrap dst-ids)))

(define-syntax case-identifier
  (syntax-rules (else)
    ((_ ?keyword ((?id ...) ?body0 ?body ...) ... (else ?else0 ?else ...))
     (let ((keyword ?keyword))
       (cond ((identifier-memq keyword (list #'?id ...))
	      ?body0 ?body ...)
	     ...
	     (else
	      ?else0 ?else ...))))
    ((_ ?keyword ((?id ...) ?body0 ?body ...) ...)
     (let ((keyword ?keyword))
       (cond ((identifier-memq keyword (list #'?id ...))
	      ?body0 ?body ...)
	     ...)))
    ))


(define (string-general-append arg . args)
  (let ((args (cons arg args)))
    (let-values (((port getter) (open-string-output-port)))
      (let loop ((args args))
	(if (null? args)
	    (getter)
	  (let ((thing (car args)))
	    (cond ((identifier? thing)
		   (display (identifier->string thing) port))
		  ((or (symbol? thing) (string? thing))
		   (display thing port))
		  (else
		   (assertion-violation 'string-general-append
		     "expected identifier, symbol or string" thing)))
	    (loop (cdr args))))))))

(define (syntax-general-append ctx arg . args)
  (assert (identifier? ctx))
  (datum->syntax ctx (string->symbol (apply string-general-append arg args))))

(define-syntax identifier->string
  (syntax-rules ()
    ((_ ?identifier)
     (symbol->string (syntax->datum ?identifier)))))

(define-syntax string->identifier
  (syntax-rules ()
    ((_ ?context-identifier ?string)
     (datum->syntax ?context-identifier (string->symbol ?string)))))

(define (identifier-prefix prefix identifier)
  (string->identifier identifier (string-general-append prefix identifier)))

(define (identifier-suffix identifier suffix)
  (string->identifier identifier (string-general-append identifier suffix)))

(define (syntax-maker-identifier type-identifier)
  (identifier-prefix "make-" type-identifier))

(define (syntax-predicate-identifier type-identifier)
  (identifier-suffix type-identifier "?"))

(define (syntax-accessor-identifier type-identifier field-identifier)
  (string->identifier type-identifier
		      (string-general-append type-identifier "-" field-identifier)))

(define (syntax-mutator-identifier type-identifier field-identifier)
  (string->identifier type-identifier
		      (string-general-append type-identifier "-" field-identifier "-set!")))

(define (syntax-dot-notation-identifier variable-identifier field-identifier)
  (string->identifier variable-identifier
		      (string-general-append variable-identifier "." field-identifier)))

(define-syntax with-implicits
  (syntax-rules ()
    ((_ ((?context-identifier ?symbol ...)) . ?body)
     (with-syntax ((?symbol (datum->syntax ?context-identifier (quote ?symbol)))
		   ...)
       . ?body))
    ((_ ((?context-identifier ?symbol ...) . ?rest) . ?body)
     (with-syntax ((?symbol (datum->syntax ?context-identifier (quote ?symbol)))
		   ...)
       (with-implicits ?rest . ?body)))
    ))


(define (validate-list-of-clauses clauses synner)
  ;;Scan the unwrapped  syntax object CLAUSES expecting a  list with the
  ;;format:
  ;;
  ;;    ((<identifier> <thing> ...) ...)
  ;;
  ;;SYNNER must be a closure used to raise a syntax violation if a parse
  ;;error occurs; it must accept  two arguments: the message string, the
  ;;invalid subform.
  ;;
  (unless (or (null? clauses) (list? clauses))
    (synner "expected possibly empty list of clauses" clauses))
  (for-each
      (lambda (clause)
	(unless (list? clause)
	  (synner "expected list as clause" clause))
	(unless (identifier? (car clause))
	  (synner "expected identifier as first clause element" (car clause))))
    clauses))

(define (filter-clauses keyword-identifier clauses)
  ;;Given a list of clauses with the format:
  ;;
  ;;    ((<identifier> <thing> ...) ...)
  ;;
  ;;look  for the ones  having KEYWORD-IDENTIFIER  as car  (according to
  ;;FREE-IDENTIFIER=?) and return the selected clauses in a list; return
  ;;the empty list if no matching clause is found.
  ;;
  (assert (identifier? keyword-identifier))
  (let next-clause ((clauses  clauses)
		    (selected '()))
    (if (null? clauses)
	(reverse selected) ;it is important to keep the order
	(next-clause (cdr clauses)
		     (if (free-identifier=? keyword-identifier (caar clauses))
			 (cons (car clauses) selected)
		       selected)))))

(define (discard-clauses keyword-identifier clauses)
  ;;Given a list of clauses with the format:
  ;;
  ;;    ((<identifier> <thing> ...) ...)
  ;;
  ;;look  for the ones  having KEYWORD-IDENTIFIER  as car  (according to
  ;;FREE-IDENTIFIER=?) and discard them; return all the other clauses in
  ;;a   list;  return   the  empty   list  if   all  the   clauses  have
  ;;KEYWORD-IDENTIFIER as car.
  ;;
  (assert (identifier? keyword-identifier))
  (let next-clause ((clauses  clauses)
		    (selected '()))
    (if (null? clauses)
	(reverse selected) ;it is important to keep the order
	(next-clause (cdr clauses)
		     (if (free-identifier=? keyword-identifier (caar clauses))
			 selected
		       (cons (car clauses) selected))))))


(define (validate-definition-clauses mandatory-keywords optional-keywords
				     at-most-once-keywords exclusive-keywords-sets
				     clauses synner)
  ;;Scan the unwrapped  syntax object CLAUSES expecting a  list with the
  ;;format:
  ;;
  ;;    ((<identifier> <thing> ...) ...)
  ;;
  ;;then verify that the <keyword  identifier> syntax objects are in the
  ;;list of identifiers MANDATORY-KEYWORDS or in the list of identifiers
  ;;OPTIONAL-KEYWORDS; any order is allowed.
  ;;
  ;;Identifiers in  MANDATORY-KEYWORDS must appear at least  once in the
  ;;clauses;  identifiers in AT-MOST-ONCE-KEYWORDS  must appear  at most
  ;;once; identifiers  in OPTIONAL-KEYWORDS can appear  zero or multiple
  ;;times.
  ;;
  ;;EXCLUSIVE-KEYWORDS-SETS  is  a list  of  lists,  each sublist  holds
  ;;identifiers; the identifiers in each sublist are mutually exclusive:
  ;;at most one can appear in CLAUSES.
  ;;
  ;;SYNNER must  be the closure  used to raise  a syntax violation  if a
  ;;parse  error  occurs; it  must  accept  two  arguments: the  message
  ;;string, the invalid subform.
  ;;

  (define (%identifiers-join-for-message identifiers)
    ;;Given  a possibly  empty list  of  identifiers, join  them into  a
    ;;string with a  comma as separator; return the  string.  To be used
    ;;to build error messages involving the list of identifiers.
    ;;
    (let ((keys (map symbol->string (map syntax->datum identifiers))))
      (if (null? keys)
	  ""
	(call-with-values
	    (lambda ()
	      (open-string-output-port))
	  (lambda (port getter)
	    (display (syntax->datum (car keys)) port)
	    (let loop ((keys (cdr keys)))
	      (if (null? keys)
		  (getter)
		(begin
		  (display ", " port)
		  (display (syntax->datum (car keys)) port)
		  (loop (cdr keys))))))))))


  (validate-list-of-clauses clauses synner)

  ;;Check that the keyword of each clause is in MANDATORY-KEYWORDS or in
  ;;OPTIONAL-KEYWORDS.
  (for-each
      (lambda (clause)
	(let ((key (car clause)))
	  (unless (or (identifier-memq key mandatory-keywords)
		      (identifier-memq key optional-keywords))
	    (synner (string-append
		     "unrecognised clause keyword \""
		     (identifier->string (car clause))
		     "\", expected one among: "
		     (%identifiers-join-for-message (append mandatory-keywords optional-keywords)))
		    clause))))
    clauses)

  ;;Check the mandatory keywords.
  (for-each (lambda (mandatory-key)
	      (unless (find (lambda (clause)
			      (free-identifier=? mandatory-key (car clause)))
			    clauses)
		(synner (string-append "missing mandatory clause "
				       (symbol->string (syntax->datum mandatory-key)))
			mandatory-key)))
    mandatory-keywords)

  ;;Check the keywords which must appear at most once.
  (for-each
      (lambda (once-key)
	(let* ((err-clauses (filter (lambda (clause)
				      (free-identifier=? once-key (car clause)))
			      clauses))
	       (count (length err-clauses)))
	  (unless (or (zero? count) (= 1 count))
	    (synner (string-append "clause " (symbol->string (syntax->datum once-key))
				   " given multiple times")
		    err-clauses))))
    at-most-once-keywords)

  ;;Check mutually exclusive keywords.
  (for-each (lambda (mutually-exclusive-ids)
	      (let ((err (filter (lambda (clause) clause)
			   (map (lambda (e)
				  (exists (lambda (clause)
					    (and (free-identifier=? e (car clause))
						 clause))
					  clauses))
			     mutually-exclusive-ids))))
		(when (< 1 (length err))
		  (synner "mutually exclusive clauses" err))))
    exclusive-keywords-sets))


;;;; done

)

;;; end of file
