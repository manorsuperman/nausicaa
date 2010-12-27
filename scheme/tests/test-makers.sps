;;; -*- coding: utf-8 -*-
;;;
;;;Part of: Nausicaa/Scheme
;;;Contents: test file for makers
;;;Date: Sat May 22, 2010
;;;
;;;Abstract
;;;
;;;
;;;
;;;Copyright (c) 2010 Marco Maggi <marco.maggi-ipsu@poste.it>
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
(import (nausicaa)
  (rnrs eval)
  (nausicaa makers)
  (prefix (makers-lib) lib.)	;this is in the tests directory
  (nausicaa checks)
  (nausicaa language sentinel))

(check-set-mode! 'report-failed)
(display "*** testing makers\n")


(parametrise ((check-test-name	'base))

  (define-auxiliary-syntax :alpha :beta :gamma)

  (let ((v 2))	;variable arguments, no fixed arguments

    (define-maker doit
      list ((:alpha	1)
	    (:beta	2)
	    (:gamma	(+ 1 v))))

    (check
	(doit)
      => '(1 2 3))

    (check
    	(doit (:alpha 10))
      => '(10 2 3))

    (check
    	(doit (:beta 20))
      => '(1 20 3))

    (check
    	(doit (:gamma 30))
      => '(1 2 30))

    (check
    	(doit (:alpha	10)
	      (:beta	20))
      => '(10 20 3))

    (check
    	(doit (:alpha	10)
	      (:gamma	30))
      => '(10 2 30))

    (check
    	(doit (:gamma	30)
	      (:beta	20))
      => '(1 20 30))

    (check
    	(doit (:alpha	10)
	      (:beta	20)
	      (:gamma	30))
      => '(10 20 30))

    (check
	(let ((b 7))
	  (doit (:beta	(+ 6 (* 2 b)))
		(:alpha	(+ 2 8))))
      => '(10 20 3))

    (check
	(doit (:beta 10 20 30 40))
      => '(1 (10 20 30 40) 3))

    #f)

;;; --------------------------------------------------------------------

  (let ()	;no variable arguments, yes fixed arguments

    (define S "ciao")

    (define-maker doit
      (list (string-ref S 2) #\b)
      ((:alpha	1)
       (:beta	2)
       (:gamma	3)))

    (check
	(doit)
      => '(#\a #\b 1 2 3))

    (check
    	(doit (:alpha 10))
      => '(#\a #\b 10 2 3))

    (check
    	(doit (:beta 20))
      => '(#\a #\b 1 20 3))

    (check
    	(doit (:gamma 30))
      => '(#\a #\b 1 2 30))

    (check
    	(doit (:alpha	10)
	      (:beta	20))
      => '(#\a #\b 10 20 3))

    (check
    	(doit (:alpha	10)
	      (:gamma	30))
      => '(#\a #\b 10 2 30))

    (check
    	(doit (:gamma	30)
	      (:beta	20))
      => '(#\a #\b 1 20 30))

    (check
    	(doit (:alpha	10)
	      (:beta	20)
	      (:gamma	30))
      => '(#\a #\b 10 20 30))

    (check
	(let ((b 7))
	  (doit (:beta	(+ 6 (* 2 b)))
		(:alpha	(+ 2 8))))
      => '(#\a #\b 10 20 3))

    #f)

;;; --------------------------------------------------------------------

  (let ()	;yes variable arguments, no fixed arguments

    (define-maker (doit a b)
      list
      ((:alpha	1)
       (:beta	2)
       (:gamma	3)))

    (check
	(doit #\a #\b)
      => '(#\a #\b 1 2 3))

    (check
    	(doit #\a #\b
	      (:alpha 10))
      => '(#\a #\b 10 2 3))

    (check
    	(doit #\a #\b
	      (:beta 20))
      => '(#\a #\b 1 20 3))

    (check
    	(doit #\a #\b
	      (:gamma 30))
      => '(#\a #\b 1 2 30))

    (check
    	(doit #\a #\b
	      (:alpha	10)
	      (:beta	20))
      => '(#\a #\b 10 20 3))

    (check
    	(doit #\a #\b
	      (:alpha	10)
	      (:gamma	30))
      => '(#\a #\b 10 2 30))

    (check
    	(doit #\a #\b
	      (:gamma	30)
	      (:beta	20))
      => '(#\a #\b 1 20 30))

    (check
    	(doit #\a #\b
	      (:alpha	10)
	      (:beta	20)
	      (:gamma	30))
      => '(#\a #\b 10 20 30))

    (check
	(let ((b 7))
	  (doit #\a #\b
		(:beta	(+ 6 (* 2 b)))
		(:alpha	(+ 2 8))))
      => '(#\a #\b 10 20 3))

    #f)

;;; --------------------------------------------------------------------

  (let ()	;yes variable arguments, yes fixed arguments

    (define-maker (doit a b)
      (list #\a #\b)
      ((:alpha	1)
       (:beta	2)
       (:gamma	3)))

    (check
	(doit #\p #\q)
      => '(#\a #\b #\p #\q 1 2 3))

    (check
    	(doit #\p #\q
	      (:alpha 10))
      => '(#\a #\b #\p #\q 10 2 3))

    (check
    	(doit #\p #\q
	      (:beta 20))
      => '(#\a #\b #\p #\q 1 20 3))

    (check
    	(doit #\p #\q
	      (:gamma 30))
      => '(#\a #\b #\p #\q 1 2 30))

    (check
    	(doit #\p #\q
	      (:alpha	10)
	      (:beta	20))
      => '(#\a #\b #\p #\q 10 20 3))

    (check
    	(doit #\p #\q
	      (:alpha	10)
	      (:gamma	30))
      => '(#\a #\b #\p #\q 10 2 30))

    (check
    	(doit #\p #\q
	      (:gamma	30)
	      (:beta	20))
      => '(#\a #\b #\p #\q 1 20 30))

    (check
    	(doit #\p #\q
	      (:alpha	10)
	      (:beta	20)
	      (:gamma	30))
      => '(#\a #\b #\p #\q 10 20 30))

    (check
	(let ((b 7))
	  (doit #\p #\q
		(:beta	(+ 6 (* 2 b)))
		(:alpha	(+ 2 8))))
      => '(#\a #\b #\p #\q 10 20 3))

    #f)

  #t)


(parametrise ((check-test-name	'defaults))

  (define-auxiliary-syntax :alpha)
  (define-auxiliary-syntax :beta)
  (define-auxiliary-syntax :gamma)

  (let ()	;optional arguments with side effects

    (define g
      (let ((counter 0))
	(lambda ()
	  (set! counter (+ 1 counter))
	  counter)))

    (define default2 (- (/ 9 3) 1))

    (define-maker doit
      list ((:alpha	1)
	    (:beta	default2)
	    (:gamma	(g))))

    (check
	(doit)
      => '(1 2 1))

    (check
    	(doit (:alpha 10))
      => '(10 2 2))

    (check
    	(doit (:beta 20))
      => '(1 20 3))

    (check
    	(doit (:gamma 30))
      => '(1 2 30))

    #f)

;;; --------------------------------------------------------------------

  (let ()	;detecting ungiven argument

    (define-maker doit
      subdoit ((:alpha	1)
	       (:beta	2)
	       (:gamma	sentinel)))

    (define-syntax subdoit
      (lambda (stx)
	(syntax-case stx ()
	  ((_ ?alpha ?beta ?gamma)
	   (and (identifier? #'?gamma) (free-identifier=? #'?gamma #'sentinel))
	   #'(list ?alpha ?beta 3))
	  ((_ ?alpha ?beta ?gamma)
	   #'(list ?alpha ?beta ?gamma))
	  )))

    (check
	(doit)
      => '(1 2 3))

    (check
    	(doit (:alpha 10))
      => '(10 2 3))

    (check
    	(doit (:beta 20))
      => '(1 20 3))

    (check
    	(doit (:gamma 30))
      => '(1 2 30))

    #f)

;;; --------------------------------------------------------------------

  (let ()	;unpacking multiple argument values

    (define-maker doit
      subdoit ((:alpha	1)
	       (:beta	2)
	       (:gamma	3)))

    (define-syntax subdoit
      (lambda (stx)
	(syntax-case stx (list)
	  ((_ ?alpha (list ?beta0 ...) ?gamma)
	   #'(list ?alpha ?beta0 ... ?gamma))
	  ((_ ?alpha ?beta ?gamma)
	   #'(list ?alpha ?beta ?gamma))
	  )))

    (check
	(doit (:alpha 10)
	      (:beta #\a #\b #\c)
	      (:gamma 30))
      => '(10 #\a #\b #\c 30))

    (check
	(doit (:alpha 10)
	      (:beta #\a)
	      (:gamma 30))
      => '(10 #\a 30))

    #f)

  #t)


(parametrise ((check-test-name	'options))

  (define-auxiliary-syntax alpha)
  (define-auxiliary-syntax beta)
  (define-auxiliary-syntax gamma)

  (let ()	;mandatory clause
    (define-maker doit
      list ((alpha	1)
	    (beta	2 (mandatory))
	    (gamma	3)))

    (check (doit (beta 20))	=> '(1 20 3))

    #f)

  (let ()	;optional clause
    (define-maker doit
      list ((alpha	1 (optional))
	    (beta	2)
	    (gamma	3)))

    (check (doit (beta 20))	=> '(1 20 3))
    #f)

  (let ()	;clause to be used along
    (define-maker doit
      list ((alpha	1 (with beta))
	    (beta	2)
	    (gamma	3)))

    (check (doit (alpha 10) (beta 20))	=> '(10 20 3))
    #f)

  (let ()	;mutually exclusive clauses
    (define-maker doit
      list ((alpha	1 (without beta))
	    (beta	2)
	    (gamma	3)))

    (check (doit (alpha 10))	=> '(10 2 3))
    #f)

  (let ()	;cross mutually exclusive clauses
    (define-maker doit
      list ((alpha	1 (without beta))
	    (beta	2 (without alpha))
	    (gamma	3)))

    (check (doit (alpha 10))	=> '(10 2 3))
    (check (doit (beta  20))	=> '(1 20 3))
    #f)

  #t)


(parametrise ((check-test-name	'library))

;;; these tests make use of the makers from (makers-lib)

  (check
      (lib.doit1)
    => '(1 2 3))

  (check
      (lib.doit1 (lib.:alpha 10))
    => '(10 2 3))

  (check
      (lib.doit1 (lib.:beta 20))
    => '(1 20 3))

  (check
      (lib.doit1 (lib.:gamma 30))
    => '(1 2 30))

  (check
      (lib.doit1 (lib.:alpha	10)
		 (lib.:beta	20))
    => '(10 20 3))

  (check
      (lib.doit1 (lib.:alpha	10)
		 (lib.:gamma	30))
    => '(10 2 30))

  (check
      (lib.doit1 (lib.:gamma	30)
		 (lib.:beta	20))
    => '(1 20 30))

  (check
      (lib.doit1 (lib.:alpha	10)
		 (lib.:beta	20)
		 (lib.:gamma	30))
    => '(10 20 30))

  (check
      (let ((b 7))
	(lib.doit1 (lib.:beta	(+ 6 (* 2 b)))
		   (lib.:alpha	(+ 2 8))))
    => '(10 20 3))

;;; --------------------------------------------------------------------

  (check
      (lib.doit2)
    => '(#\a #\b 1 2 3))

  (check
      (lib.doit2 (lib.:alpha 10))
    => '(#\a #\b 10 2 3))

  (check
      (lib.doit2 (lib.:beta 20))
    => '(#\a #\b 1 20 3))

  (check
      (lib.doit2 (lib.:gamma 30))
    => '(#\a #\b 1 2 30))

  (check
      (lib.doit2 (lib.:alpha	10)
		 (lib.:beta	20))
    => '(#\a #\b 10 20 3))

  (check
      (lib.doit2 (lib.:alpha	10)
		 (lib.:gamma	30))
    => '(#\a #\b 10 2 30))

  (check
      (lib.doit2 (lib.:gamma	30)
		 (lib.:beta	20))
    => '(#\a #\b 1 20 30))

  (check
      (lib.doit2 (lib.:alpha	10)
		 (lib.:beta	20)
		 (lib.:gamma	30))
    => '(#\a #\b 10 20 30))

  (check
      (let ((b 7))
	(lib.doit2 (lib.:beta	(+ 6 (* 2 b)))
		   (lib.:alpha	(+ 2 8))))
    => '(#\a #\b 10 20 3))

;;; --------------------------------------------------------------------

  (check
      (lib.doit3 #\a #\b)
    => '(#\a #\b 1 2 3))

  (check
      (lib.doit3 #\a #\b
		 (lib.:alpha 10))
    => '(#\a #\b 10 2 3))

  (check
      (lib.doit3 #\a #\b
		 (lib.:beta 20))
    => '(#\a #\b 1 20 3))

  (check
      (lib.doit3 #\a #\b
		 (lib.:gamma 30))
    => '(#\a #\b 1 2 30))

  (check
      (lib.doit3 #\a #\b
		 (lib.:alpha	10)
		 (lib.:beta	20))
    => '(#\a #\b 10 20 3))

  (check
      (lib.doit3 #\a #\b
		 (lib.:alpha	10)
		 (lib.:gamma	30))
    => '(#\a #\b 10 2 30))

  (check
      (lib.doit3 #\a #\b
		 (lib.:gamma	30)
		 (lib.:beta	20))
    => '(#\a #\b 1 20 30))

  (check
      (lib.doit3 #\a #\b
		 (lib.:alpha	10)
		 (lib.:beta	20)
		 (lib.:gamma	30))
    => '(#\a #\b 10 20 30))

  (check
      (let ((b 7))
	(lib.doit3 #\a #\b
		   (lib.:beta	(+ 6 (* 2 b)))
		   (lib.:alpha	(+ 2 8))))
    => '(#\a #\b 10 20 3))

;;; --------------------------------------------------------------------

  (check
      (lib.doit4 #\p #\q)
    => '(#\a #\b #\p #\q 1 2 3))

  (check
      (lib.doit4 #\p #\q
		 (lib.:alpha 10))
    => '(#\a #\b #\p #\q 10 2 3))

  (check
      (lib.doit4 #\p #\q
		 (lib.:beta 20))
    => '(#\a #\b #\p #\q 1 20 3))

  (check
      (lib.doit4 #\p #\q
		 (lib.:gamma 30))
    => '(#\a #\b #\p #\q 1 2 30))

  (check
      (lib.doit4 #\p #\q
		 (lib.:alpha	10)
		 (lib.:beta	20))
    => '(#\a #\b #\p #\q 10 20 3))

  (check
      (lib.doit4 #\p #\q
		 (lib.:alpha	10)
		 (lib.:gamma	30))
    => '(#\a #\b #\p #\q 10 2 30))

  (check
      (lib.doit4 #\p #\q
		 (lib.:gamma	30)
		 (lib.:beta	20))
    => '(#\a #\b #\p #\q 1 20 30))

  (check
      (lib.doit4 #\p #\q
		 (lib.:alpha	10)
		 (lib.:beta	20)
		 (lib.:gamma	30))
    => '(#\a #\b #\p #\q 10 20 30))

  (check
      (let ((b 7))
	(lib.doit4 #\p #\q
		   (lib.:beta	(+ 6 (* 2 b)))
		   (lib.:alpha	(+ 2 8))))
    => '(#\a #\b #\p #\q 10 20 3))

  #t)


(parametrise ((check-test-name	'definition-errors))

  (check
      (guard (E ((syntax-violation? E)
		 (condition-message E))
		(else
		 (write E)(newline)
		 #f))
	(eval '(let ()
		 (define-maker 123
		   list
		   ((alpha	1)
		    (beta	2)
		    (gamma	3)))
		 'bad)
	      (environment '(rnrs) '(makers))))
    => "expected identifier as maker name in maker definition")

  (check
      (guard (E ((syntax-violation? E)
		 (condition-message E))
		(else
		 (write E)(newline)
		 #f))
	(eval '(let ()
		 (define-maker (doit 123)
		   list
		   ((alpha	1)
		    (beta	2)
		    (gamma	3)))
		 'bad)
	      (environment '(rnrs) '(makers))))
    => "expected identifiers as positional argument names")

  (check	;unknown clause
      (guard (E ((syntax-violation? E)
		 (condition-message E))
		(else
		 (write E)(newline)
		 #f))
	(eval '(let ()
		 (define-maker doit
		   list
		   ((alpha	1)
		    (beta	2)
		    (gamma	3)))
		 (doit (ciao 9)))
	      (environment '(rnrs) '(makers))))
    => "unrecognised argument keyword, expected one among: alpha, beta, gamma")

  #t)


(parametrise ((check-test-name	'use-errors))

  (check	;invalid clause
      (guard (E ((syntax-violation? E)
		 (condition-message E))
		(else
		 (write E)(newline)
		 #f))
	(eval '(let ()
		 (define-maker doit
		   list
		   ((alpha	1)
		    (beta	2)
		    (gamma	3)))
		 (doit #(alpha 9)))
	      (environment '(rnrs) '(makers))))
    => "expected pair as maker clause")

  (check	;invalid clause
      (guard (E ((syntax-violation? E)
		 (condition-message E))
		(else
		 (write E)(newline)
		 #f))
	(eval '(let ()
		 (define-maker doit
		   list
		   ((alpha	1)
		    (beta	2)
		    (gamma	3)))
		 (doit (123 9)))
	      (environment '(rnrs) '(makers))))
    => "expected identifier as first element of maker clause")

  (check	;invalid clause
      (guard (E ((syntax-violation? E)
		 (condition-message E))
		(else
		 (write E)(newline)
		 #f))
	(eval '(let ()
		 (define-maker doit
		   list
		   ((alpha	1)
		    (beta	2)
		    (gamma	3)))
		 (doit (alpha)))
	      (environment '(rnrs) '(makers))))
    => "expected list of two or more values as maker clause")

  (check	;clause used multiple times
      (guard (E ((syntax-violation? E)
		 (list (condition-message E) (syntax-violation-subform E)))
		(else
		 (write E)(newline)
		 #f))
	(eval '(let ()
		 (define-maker doit
		   list ((alpha	1)
			 (beta	2)
			 (gamma	3)))
		 (doit (alpha 10) (alpha 11)))
	      (environment '(rnrs) '(makers))))
    => '("maker clause used multiple times" alpha))


  #t)


(parametrise ((check-test-name	'option-errors))

  (check	;missing mandatory clause
      (guard (E ((syntax-violation? E)
		 (list (condition-message E) (syntax-violation-subform E)))
		(else
		 (write E)(newline)
		 #f))
	(eval '(let ()
		 (define-maker doit
		   list ((alpha	1 (mandatory))
			 (beta	2)
			 (gamma	3)))
		 (doit (beta 20)))
	      (environment '(rnrs) '(makers))))
    => '("missing mandatory maker clause" alpha))

  (check	;missing clause to be used along
      (guard (E ((syntax-violation? E)
		 (list (condition-message E) (syntax-violation-subform E)))
		(else
		 (write E)(newline)
		 #f))
	(eval '(let ()
		 (define-maker doit
		   list ((alpha	1 (with beta))
			 (beta	2)
			 (gamma	3)))
		 (doit (alpha 20)))
	      (environment '(rnrs) '(makers))))
    => '("maker clause \"alpha\" used without companion clause" beta))

  (check	;clause used along with mutually exclusive clause
      (guard (E ((syntax-violation? E)
		 (list (condition-message E) (syntax-violation-subform E)))
		(else
		 (write E)(newline)
		 #f))
	(eval '(let ()
		 (define-maker doit
		   list ((alpha	1 (without beta))
			 (beta	2)
			 (gamma	3)))
		 (doit (alpha 20) (beta 30)))
	      (environment '(rnrs) '(makers))))
    => '("maker clause \"alpha\" used with mutually exclusive clause" beta))

  (check	;keyword declared in its own list of companion clauses
      (guard (E ((syntax-violation? E)
		 (list (condition-message E) (syntax-violation-subform E)))
		(else
		 (write E)(newline)
		 #f))
	(eval '(define-maker doit
		 list ((alpha	1 (with alpha))
		       (beta	2)
		       (gamma	3)))
	      (environment '(rnrs) '(makers))))
    => '("maker clause keyword used in its own list of companion clauses" alpha))

  (check	;keyword declared in its own list of mutually exclusive clauses
      (guard (E ((syntax-violation? E)
		 (list (condition-message E) (syntax-violation-subform E)))
		(else
		 (write E)(newline)
		 #f))
	(eval '(define-maker doit
		 list ((alpha	1 (without alpha))
		       (beta	2)
		       (gamma	3)))
	      (environment '(rnrs) '(makers))))
    => '("maker clause keyword used in its own list of mutually exclusive clauses" alpha))

  (check	;same keywords in both companion clauses and mutually exclusive clauses
      (guard (E ((syntax-violation? E)
		 (list (condition-message E) (syntax-violation-subform E)))
		(else
		 (write E)(newline)
		 #f))
	(eval '(define-maker doit
		 list ((alpha	1 (without beta) (with beta))
		       (beta	2)
		       (gamma	3)))
	      (environment '(rnrs) '(makers))))
    => '("maker clause includes the same keywords in both companion clauses and mutually exclusive clauses" (beta)))

  (check	;same keywords in both companion clauses and mutually exclusive clauses
      (guard (E ((syntax-violation? E)
		 (list (condition-message E) (syntax-violation-subform E)))
		(else
		 (write E)(newline)
		 #f))
	(eval '(define-maker doit
		 list ((alpha	1 (without beta gamma) (with beta gamma))
		       (beta	2)
		       (gamma	3)))
	      (environment '(rnrs) '(makers))))
    => '("maker clause includes the same keywords in both companion clauses and mutually exclusive clauses" (beta gamma)))

  (check	;unknown option in "with" clauses
      (guard (E ((syntax-violation? E)
		 (list (condition-message E) (syntax-violation-subform E)))
		(else
		 (write E)(newline)
		 #f))
	(eval '(define-maker doit
		 list ((alpha	1 (with beta delta gamma))
		       (beta	2)
		       (gamma	3)))
	      (environment '(rnrs) '(makers))))
    => '("unknown keyword in list of companion clauses" delta))

  (check	;unknown option in "without" clauses
      (guard (E ((syntax-violation? E)
		 (list (condition-message E) (syntax-violation-subform E)))
		(else
		 (write E)(newline)
		 #f))
	(eval '(define-maker doit
		 list ((alpha	1 (without beta delta gamma))
		       (beta	2)
		       (gamma	3)))
	      (environment '(rnrs) '(makers))))
    => '("unknown keyword in list of mutually exclusive clauses" delta))

  #t)


;;;; done

(check-report)

;;; end of file
