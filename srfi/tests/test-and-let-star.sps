;;;
;;;Part of: Nausicaa/SRFI
;;;Contents: tests for and-let-star
;;;Date: Thu Dec 25, 2008
;;;
;;;Abstract
;;;
;;;
;;;
;;;Copyright (c) 2008 Marco Maggi <marcomaggi@gna.org>
;;;Copyright (c) 2008 Derick Eddington
;;;
;;;Permission is hereby granted, free of charge, to any person obtaining
;;;a  copy of  this  software and  associated  documentation files  (the
;;;"Software"), to  deal in the Software  without restriction, including
;;;without limitation  the rights to use, copy,  modify, merge, publish,
;;;distribute, sublicense,  and/or sell copies  of the Software,  and to
;;;permit persons to whom the Software is furnished to do so, subject to
;;;the following conditions:
;;;
;;;The  above  copyright notice  and  this  permission  notice shall  be
;;;included in all copies or substantial portions of the Software.
;;;
;;;Except  as  contained  in  this  notice, the  name(s)  of  the  above
;;;copyright holders  shall not be  used in advertising or  otherwise to
;;;promote  the sale,  use or  other dealings  in this  Software without
;;;prior written authorization.
;;;
;;;THE  SOFTWARE IS  PROVIDED "AS  IS",  WITHOUT WARRANTY  OF ANY  KIND,
;;;EXPRESS OR  IMPLIED, INCLUDING BUT  NOT LIMITED TO THE  WARRANTIES OF
;;;MERCHANTABILITY,    FITNESS   FOR    A    PARTICULAR   PURPOSE    AND
;;;NONINFRINGEMENT.  IN NO EVENT  SHALL THE AUTHORS OR COPYRIGHT HOLDERS
;;;BE LIABLE  FOR ANY CLAIM, DAMAGES  OR OTHER LIABILITY,  WHETHER IN AN
;;;ACTION OF  CONTRACT, TORT  OR OTHERWISE, ARISING  FROM, OUT OF  OR IN
;;;CONNECTION  WITH THE SOFTWARE  OR THE  USE OR  OTHER DEALINGS  IN THE
;;;SOFTWARE.


;;;; setup

(import (r6rs)
  (rnrs eval (6))
  (srfi and-let-star))

(define testnum 0)

(define-syntax check
  (syntax-rules (=>)
    ((_ ?form => ?expected-result)
     (let ((result ?form)
	   (expected-result ?expected-result))
       (if (equal? result expected-result)
	   (begin
	     (display "test number ")
	     (display testnum)
	     (display " success")
	     (newline))
	 (begin
	   (display "test number ")
	   (display testnum)
	   (display " FAILURE expected ")
	   (display expected-result)
	   (display " got ")
	   (display result)
	   (newline)
	   (display "\t")
	   (write (quote ?form))
	   (newline)))
       (set! testnum (+ 1 testnum))))))

;; Here we use  EVAL because a syntax violation  error cannot be catched
;; by GUARD, and so it causes the program termination.
(define-syntax check-syntax-violation
  (syntax-rules ()
    ((_ ?form)
     (check
	 (guard (exc (else
;; 		      (write exc)(newline)
;; 		      (write (syntax-violation? exc))(newline)
		      (syntax-violation? exc)))
	   (eval '?form (environment '(rnrs) '(srfi and-let-star))))
       => #t))))

(newline)
(display "*** testing and-let-star ...")
(newline)


;;;; code

(check
    (and-let* ((a	#t)
	       (b	#t))
      #t)
  => #t)

(check
    (and-let* ((a	#t)
	       (b	#f))
      #t)
  => #f)

(check
    (and-let* ((a	#t)
	       (	#t))
      #t)
  => #t)

(check
    (and-let* ((a	#f)
	       (	#t))
      #t)
  => #f)

;;; --------------------------------------------------------------------

(check
    (and-let* () 1)
  => 1)

(check
    (and-let* () 1 2)
  => 2)

(check
    (and-let* () )
  => #t)

;;; --------------------------------------------------------------------

(check
    (let ((x #f))
      (and-let* (x)))
  => #f)

(check
    (let ((x 1))
      (and-let* (x)))
  => 1)

(check
    (and-let* ((x #f)) )
  => #f)

(check
    (and-let* ((x 1)) )
  => 1)

(check-syntax-violation
 (and-let* (#f
	    (x 1))))

(check
    (and-let* ( (#f) (x 1)) )
  => #f)

(check-syntax-violation
 (and-let* (2 (x 1))))

(check
    (and-let* ( (2) (x 1)) )
  => 1)

(check
    (and-let* ( (x 1) (2)) )
  => 2)

(check
    (let ((x #f))
      (and-let* (x) x))
  => #f)

(check
    (let ((x ""))
      (and-let* (x) x))
  => "")

(check
    (let ((x ""))
      (and-let* (x)))
  => "")

(check
    (let ((x 1))
      (and-let* (x)
	(+ x 1)))
  => 2)

(check
    (let ((x #f))
      (and-let* (x)
	(+ x 1)))
  => #f)

(check
    (let ((x 1))
      (and-let* (((positive? x)))
	(+ x 1)))
  => 2)

(check
    (let ((x 1))
      (and-let* (((positive? x)))
	))
  => #t)

(check
    (let ((x 0))
      (and-let* (((positive? x)))
	(+ x 1)))
  => #f)

(check
    (let ((x 1))
      (and-let* ((  (positive? x))
		 (x (+ x 1)))
	(+ x 1)))
  => 3)

;;; This next one is from the reference implementation tests but I can't
;;; see how it "must be a syntax-error" (Derick Eddington).
;; (check-syntax-violation
;;  (let ((x 1))
;;    (and-let* ((  (positive? x))
;; 	      (x (+ x 1))
;; 	      (x (+ x 1)))
;;      (+ x 1))))

(check
    (let ((x 1))
      (and-let* (x
		 ((positive? x)))
	(+ x 1)))
  => 2)

(check
    (let ((x 1))
      (and-let* (((begin x))
		 ((positive? x)))
	(+ x 1)))
  => 2)

(check
    (let ((x 0))
      (and-let* (x
		 ((positive? x)))
	(+ x 1)))
  => #f)

(check
    (let ((x #f))
      (and-let* (x
		 ((positive? x)))
	(+ x 1)))
  => #f)

(check
    (let ((x #f))
      (and-let* (((begin x))
		 ((positive? x)))
	(+ x 1)))
  => #f)

;;; --------------------------------------------------------------------

(check
    (let ((x 1))
      (and-let* (x
		 (y (- x 1))
		 (  (positive? y)))
	(/ x y)))
  => #f)

(check
    (let ((x 0))
      (and-let* (x
		 (y (- x 1))
		 (  (positive? y)))
	(/ x y)))
  => #f)

(check
    (let ((x #f))
      (and-let* (x
		 (y (- x 1))
		 (  (positive? y)))
	(/ x y)))
  => #f)

(check
    (let ((x 3))
      (and-let* (x
		 (y (- x 1))
		 (  (positive? y)))
	(/ x y)))
  => 3/2)



;;;; done

(display "*** testing and-let-star end")
(newline)
(newline)

;;; end of file
