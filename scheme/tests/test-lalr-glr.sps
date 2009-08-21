;;;
;;;Part of: Nausicaa/Scheme
;;;Contents: tests for (lalr), miscellaneous stuff
;;;Date: Thu Aug  6, 2009
;;;
;;;Abstract
;;;
;;;	Miscellaneous tests for (lalr), GLR driver.
;;;
;;;Copyright (c) 2009 Marco Maggi <marcomaggi@gna.org>
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


(import (nausicaa)
  (lalr)
  (sentinel)
  (checks))

(check-set-mode! 'report-failed)
(display "*** testing lalr GLR driver \n")


;;;; helpers

(define eoi-token
  (make-lexical-token '*eoi* #f (eof-object)))

(define (make-lexer list-of-tokens)
  ;;Return a lexer closure  drawing tokens from the list LIST-OF-TOKENS.
  ;;When the list is empty, return the EOI-TOKEN.
  ;;
  (lambda ()
    (if (null? list-of-tokens)
	eoi-token
      (begin0
	  (car list-of-tokens)
	(set! list-of-tokens (cdr list-of-tokens))))))

(define (make-error-handler yycustom)
  ;;Return  an error  handler closure  that calls  YYCUSTOM with  a pair
  ;;describing the offending token.  To just return the pair invoke as:
  ;;
  ;;	(make-error-handler (lambda x x))
  ;;
  (lambda (message token)
    (yycustom `(error-handler . ,(lexical-token-value token)))))

(define (debug:print-tables doit? terminals non-terminals)
  (when doit?
    (let ((port (current-output-port)))
      (lalr-parser :output-port port
		   :expect #f
		   :parser-type 'glr
		   :terminals terminals
		   :rules non-terminals)
      (newline port)
      (newline port))))


(parameterise ((check-test-name 'basics))

;;;Test very basic grammars.

  (define (error-handler message token)
    (cons message (lexical-token-value token)))

  (define (doit-1 . tokens)
    ;;A grammar that only accept a single terminal as input.
    (let* ((lexer		(make-lexer tokens))
	   (make-parser		(lalr-parser :output-value #t
					     :parser-type 'glr
					     :expect #f
					     :terminals '(A)
					     :rules '((e (A) : $1))))
           (parser		(make-parser)))
      (parser lexer error-handler)))

  (define (doit-2 . tokens)
    ;;A grammar that only accept a single terminal or the EOI.
    (let* ((lexer		(make-lexer tokens))
	   (make-parser		(lalr-parser :output-value #t
					     :parser-type 'glr
					     :expect 0
					     :terminals '(A)
					     :rules '((e (A) : $1
							 ()  : 0))))
           (parser		(make-parser)))
      (parser lexer error-handler)))

  (define (doit-3 . tokens)
    ;;A grammar that accepts fixed sequences of a single terminal or the
    ;;EOI.
    (let* ((lexer		(make-lexer tokens))
	   (make-parser		(lalr-parser :output-value #t
					     :parser-type 'glr
					     :expect #f
					     :terminals '(A)
					     :rules '((e (A)     : (list $1)
							 (A A)   : (list $1 $2)
							 (A A A) : (list $1 $2 $3)
							 ()      : 0))))
           (parser		(make-parser)))
      (parser lexer error-handler)))

  (define (doit-4 . tokens)
    ;;A grammar accepting a sequence  of equal tokens.  The return value
    ;;is the value of the last parsed token.
    (let* ((lexer		(make-lexer tokens))
	   (make-parser		(lalr-parser :output-value #t
					     :parser-type 'glr
					     :expect #f
					     :terminals '(A)
					     :rules '((e (e A) : $2
							 (A)   : $1
							 ()    : 0))))
           (parser		(make-parser)))
      (parser lexer error-handler)))

  (define (doit-5 . tokens)
    ;;A grammar accepting a sequence  of equal tokens.  The return value
    ;;is the list of values.
    (let* ((lexer		(make-lexer tokens))
	   (make-parser		(lalr-parser :output-value #t
					     :parser-type 'glr
					     :expect #f
					     :terminals '(A)
					     :rules '((e (e A) : (cons $2 $1)
							 (A)   : (list $1)
							 ()    : (list 0)))))
           (parser		(make-parser)))
      (parser lexer error-handler)))

  (debug:print-tables #f
		      '(A)
		      '((e (A)     : (list $1)
			   (A A)   : (list $1 $2)
			   (A A A) : (list $1 $2 $3)
			   ()      : 0)))

;;; --------------------------------------------------------------------

  (check
      (doit-1 (make-lexical-token 'A #f 1))
    => '(1))

  (check
      (doit-1)
    => `())

  (check
    ;;Parse correctly the first A  and reduce it.  The second A triggers
    ;;an  error which  empties  the  stack and  consumes  all the  input
    ;;tokens.  Finally, an unexpected end-of-input error is returned.
      (doit-1 (make-lexical-token 'A #f 1)
	      (make-lexical-token 'A #f 2)
	      (make-lexical-token 'A #f 3))
    => `())

;;; --------------------------------------------------------------------

  (check
      (parameterise ((debugging #f))
	(doit-2))
    => '(0))

  (check
      (doit-2 (make-lexical-token 'A #f 1))
    => '(1))

  (check
    ;;Parse correctly the first A  and reduce it.  The second A triggers
    ;;an  error which  empties  the  stack and  consumes  all the  input
    ;;tokens.  Finally, an unexpected end-of-input error is returned.
      (parameterise ((debugging #f))
	(doit-2 (make-lexical-token 'A #f 1)
		(make-lexical-token 'A #f 2)
		(make-lexical-token 'A #f 3)))
    => `())

;;; --------------------------------------------------------------------

  (check
    (parameterise ((debugging #f))
      (doit-3 (make-lexical-token 'A #f 1)))
    => '((1)))

  (check
      (doit-3 (make-lexical-token 'A #f 1)
	      (make-lexical-token 'A #f 2))
    => '((1 2)))

  (check
      (doit-3 (make-lexical-token 'A #f 1)
	      (make-lexical-token 'A #f 2)
	      (make-lexical-token 'A #f 3))
    => '((1 2 3)))

  (check
      (doit-3)
    => '(0))

;;; --------------------------------------------------------------------

  (check
      (doit-4)
    => '(0))

  (check
      ;;Two  results because there  is a  shift/reduce conflict,  so two
      ;;processes are generated.
      (doit-4 (make-lexical-token 'A #f 1))
    => '(1 1))

  (check
      ;;Two  results because there  is a  shift/reduce conflict,  so two
      ;;processes are generated.  Notice that the rules:
      ;;
      ;;  (e A) (A)
      ;;
      ;;generate only one conflict when the second "A" comes.  The third
      ;;"A" comes when the state is inside the rule "(e A)", so there is
      ;;no conflict.
      ;;
      (doit-4 (make-lexical-token 'A #f 1)
	      (make-lexical-token 'A #f 2)
	      (make-lexical-token 'A #f 3))
    => '(3 3))

;;; --------------------------------------------------------------------

  (check
      (doit-5)
    => '((0)))

  (check
      (doit-5 (make-lexical-token 'A #f 1))
    => '((1 0)
	 (1)))

  (check
      (doit-5 (make-lexical-token 'A #f 1)
	      (make-lexical-token 'A #f 2))
    => '((2 1 0)
	 (2 1)))

  (check
      (doit-5 (make-lexical-token 'A #f 1)
	      (make-lexical-token 'A #f 2)
	      (make-lexical-token 'A #f 3))
    => '((3 2 1 0)
	 (3 2 1)))

  #t)


(parameterise ((check-test-name 'script-expression))

;;;This is the grammar of the (lalr) documentation in Texinfo format.

  (define terminals
    '(N O C T
	(left: A)
	(left: M)
	(nonassoc: U)))

  (define non-terminals
    '((script	(lines)		: (reverse $1))

      (lines	(lines line)	: (cons $2 $1)
		(line)		: (list $1))

      (line	(T)		: #\newline
		(E T)		: $1
		(error T)	: (list 'error-clause $2))

      (E	(N)		: $1
		(E A E)		: ($2 $1 $3)
		(E M E)		: ($2 $1 $3)
		(A E (prec: U))	: ($1 $2)
		(O E C)		: $2)))

  (define (doit . tokens)
    (let* ((lexer	(make-lexer tokens))
	   (make-parser (lalr-parser :output-value #t :expect #f
				     :parser-type 'glr
				     :terminals terminals
				     :rules non-terminals))
           (parser	(make-parser)))
      (parser lexer (make-error-handler (lambda x x)))))

  (debug:print-tables #f terminals non-terminals)

;;; --------------------------------------------------------------------
;;; Correct input.

  (check
      (parameterise ((debugging #f))
	(doit (make-lexical-token 'T #f #\newline)))
    => '((#\newline)))

  (check	;correct input
      (doit (make-lexical-token 'N #f 1)
	    (make-lexical-token 'T #f #\newline))
    => '((1)))

  (check	;correct input
      (doit  (make-lexical-token 'N #f 1)
	     (make-lexical-token 'A #f +)
	     (make-lexical-token 'N #f 2)
	     (make-lexical-token 'T #f #\newline))
    => '((3)))

  (check	 ;correct input
      (doit (make-lexical-token 'N #f 1)
	    (make-lexical-token 'A #f +)
	    (make-lexical-token 'N #f 2)
	    (make-lexical-token 'M #f *)
	    (make-lexical-token 'N #f 3)
	    (make-lexical-token 'T #f #\newline))
    => '((9)
	 (7)))

  (check
      (doit (make-lexical-token 'N #f 10)
	    (make-lexical-token 'M #f *)
	    (make-lexical-token 'N #f 2)
	    (make-lexical-token 'A #f +)
	    (make-lexical-token 'N #f 3)
	    (make-lexical-token 'T #f #\newline))
    => '((23)))

  (check	;correct input
      (doit  (make-lexical-token 'O #f #\()
	     (make-lexical-token 'N #f 1)
	     (make-lexical-token 'A #f +)
	     (make-lexical-token 'N #f 2)
	     (make-lexical-token 'C #f #\))
	     (make-lexical-token 'M #f *)
	     (make-lexical-token 'N #f 3)
	     (make-lexical-token 'T #f #\newline))
    => '((9)))

  (check  	;correct input
    (parameterise ((debugging #f))
      (doit (make-lexical-token 'O #f #\()
	    (make-lexical-token 'N #f 1)
	    (make-lexical-token 'A #f +)
	    (make-lexical-token 'N #f 2)
	    (make-lexical-token 'C #f #\))
	    (make-lexical-token 'M #f *)
	    (make-lexical-token 'N #f 3)
	    (make-lexical-token 'T #f #\newline)
	    (make-lexical-token 'N #f 4)
	    (make-lexical-token 'M #f /)
	    (make-lexical-token 'N #f 5)
	    (make-lexical-token 'T #f #\newline)))
    => '((9 4/5)))

  #t)


;;;; done

(check-report)

;;; end of file