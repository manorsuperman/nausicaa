;;;
;;;Part of: Nausicaa/Scheme
;;;Contents: tests for the bytevector u8 library
;;;Date: Sat Jun 26, 2010
;;;
;;;Abstract
;;;
;;;
;;;
;;;Copyright (c) 2009, 2010 Marco Maggi <marco.maggi-ipsu@poste.it>
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


;;;; setup

(import (nausicaa)
  (bytevectors u8)
  (char-sets)
  (checks)
  (rnrs mutable-strings))

(check-set-mode! 'report-failed)
(display "*** testing bytevectors u8\n")

(define S string->utf8)
(define B utf8->string)


(parameterise ((check-test-name 'views))

  (check
      (subbytevector-u8* (S "ciao"))
    => (S "ciao"))

;;; --------------------------------------------------------------------

  (check
      (subbytevector-u8* (view (S "ciao")))
    => (S "ciao"))

  (check
      (subbytevector-u8* (view (S "ciao") (start 2)))
    => (S "ao"))

  (check
      (subbytevector-u8* (view (S "ciao") (start 0) (past 4)))
    => (S "ciao"))

  (check
      (subbytevector-u8* (view (S "ciao") (start 0) (past 0)))
    => '#vu8())

  (check
      (subbytevector-u8* (view (S "ciao") (start 1) (past 1)))
    => '#vu8())

  (check
      (subbytevector-u8* (view (S "ciao") (start 0) (past 1)))
    => (S "c"))

  (check
      (subbytevector-u8* (view (S "ciao") (past 2)))
    => (S "ci"))

  )


(parameterise ((check-test-name 'constructors))

  (check
      (bytevector-u8-append (S "0123"))
    => (S "0123"))

  (check
      (bytevector-u8-append (S "0123") (S "45678"))
    => (S "012345678"))

  (check
      (bytevector-u8-append '#vu8())
    => '#vu8())

  (check
      (bytevector-u8-append '#vu8() '#vu8())
    => '#vu8())

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-tabulate (lambda (idx) (+ 65 idx)) 4)
    => (S "ABCD"))

  (check
      (bytevector-u8-tabulate (lambda (x) x) 0)
    => '#vu8())

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-concatenate '((S "ciao") (S " ") (S "hello") (S " ") (S "salut")))
    => (S "ciao hello salut"))

  (check
      (bytevector-u8-concatenate '())
    => '#vu8())

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-concatenate-reverse `(,(S "ciao") ,(S " ") ,(S "hello") ,(S " ") ,(S "salut"))
					 (S " hola") 3)
    => (S "salut hello ciao ho"))

  (check
      (bytevector-u8-concatenate-reverse `(,(S "ciao") ,(S " ") ,(S "hello") ,(S " ") (S "salut"))
					 (S " hola"))
    => (S "salut hello ciao hola"))

  (check
      (bytevector-u8-concatenate-reverse `(,(S "ciao") ,(S " ") ,(S "hello") ,(S " ") ,(S "salut")))
    => (S "salut hello ciao"))

  (check
      (bytevector-u8-concatenate-reverse '())
    => '#vu8())

  )


(parameterise ((check-test-name 'predicates))

  (check
      (bytevector-u8-null? (S "ciao"))
    => #f)

  (check
      (bytevector-u8-null? '#vu8())
    => #t)

;;; --------------------------------------------------------------------

  (check
      (guard (exc ((assertion-violation? exc)
		   (condition-who exc)))
	(bytevector-u8-every 123 (S "abc")))
    => '%bytevector-u8-every)

;;; --------------------------------------------------------------------

  (check
      (let* ((str (S "aaaa")))
	(bytevector-u8-every #\a str))
    => #t)

  (check
      (let* ((str (S "aaaab")))
	(bytevector-u8-every #\a str))
    => #f)

  (check
      (let* ((str (S "aabaa")))
	(bytevector-u8-every #\a str))
    => #f)

  (check
      (let* ((str '#vu8()))
	(bytevector-u8-every #\a str))
    => #f)

;;; --------------------------------------------------------------------

  (check
      (let* ((str (S "aaaa")))
	(bytevector-u8-every (char-set #\a) str))
    => #t)

  (check
      (let* ((str (S "aaaab")))
	(bytevector-u8-every (char-set #\a) str))
    => #f)

  (check
      (let* ((str (S "aabaa")))
	(bytevector-u8-every (char-set #\a) str))
    => #f)

  (check
      (let* ((str '#vu8()))
	(bytevector-u8-every (char-set #\a) str))
    => #f)

;;; --------------------------------------------------------------------

  (check
      (let* ((str (S "aaaa")))
	(bytevector-u8-every char-alphabetic? str))
    => #t)

  (check
      (let* ((str (S "aaaa2")))
	(bytevector-u8-every char-alphabetic? str))
    => #f)

  (check
      (let* ((str (S "aa2aa")))
	(bytevector-u8-every char-alphabetic? str))
    => #f)

  (check
      (let* ((str '#vu8()))
	(bytevector-u8-every char-alphabetic? str))
    => #f)

  (check
      (let* ((str "1234"))
	(bytevector-u8-every (lambda (x) x) str))
    => #\4)

;;; --------------------------------------------------------------------

  (check
      (guard (exc ((assertion-violation? exc)
		   (condition-who exc)))
	(bytevector-u8-any 123 (S "abc")))
    => '%bytevector-u8-any)

;;; --------------------------------------------------------------------

  (check
      (let* ((str (S "ddadd")))
	(bytevector-u8-any #\a str))
    => #t)

  (check
      (let* ((str (S "dddda")))
	(bytevector-u8-any #\a str))
    => #t)

  (check
      (let* ((str (S "ddd")))
	(bytevector-u8-any #\a str))
    => #f)

  (check
      (let* ((str '#vu8()))
	(bytevector-u8-any #\a str))
    => #f)

;;; --------------------------------------------------------------------

  (check
      (let* ((str (S "dddaddd")))
	(bytevector-u8-any (char-set #\a) str))
    => #t)

  (check
      (let* ((str (S "ddda")))
	(bytevector-u8-any (char-set #\a) str))
    => #t)

  (check
      (let* ((str (S "dddd")))
	(bytevector-u8-any (char-set #\a) str))
    => #f)

  (check
      (let* ((str '#vu8()))
	(bytevector-u8-any (char-set #\a) str))
    => #f)

;;; --------------------------------------------------------------------

  (check
      (let* ((str (S "11a11")))
	(bytevector-u8-any char-alphabetic? str))
    => #t)

  (check
      (let* ((str (S "11111a")))
	(bytevector-u8-any char-alphabetic? str))
    => #t)

  (check
      (let* ((str (S "1111")))
	(bytevector-u8-any char-alphabetic? str))
    => #f)

  (check
      (let* ((str '#vu8()))
	(bytevector-u8-any char-alphabetic? str))
    => #f)

  (check
      (let* ((str (S "1234")))
	(bytevector-u8-any (lambda (x) x) str))
    => #\1)

  )


(parameterise ((check-test-name 'comparison-case-sensitive))

  (check
      (bytevector-u8-compare (S "abcdefg") (S "abcd123") values values values)
    => 4)

  (check
      (bytevector-u8-compare (S "abcdef") (S "abcd123") values values values)
    => 4)

  (check
      (bytevector-u8-compare (S "efg") (S "123") values values values)
    => 0)

  (check
      (bytevector-u8-compare '#vu8() (S "abcd") values values values)
    => 0)

  (check
      (bytevector-u8-compare (S "abcd") '#vu8() values values values)
    => 0)

  (check
      (bytevector-u8-compare (S "abcdA") (S "abcdA")
		      (lambda (idx) 'less)
		      (lambda (idx) 'equal)
		      (lambda (idx) 'greater))
    => 'equal)

  (check
      (bytevector-u8-compare (S "abcdA") (S "abcdB")
		      (lambda (idx) 'less)
		      (lambda (idx) 'equal)
		      (lambda (idx) 'greater))
    => 'less)

  (check
      (bytevector-u8-compare (S "abcdB") (S "abcdA")
		      (lambda (idx) 'less)
		      (lambda (idx) 'equal)
		      (lambda (idx) 'greater))
    => 'greater)

;;; --------------------------------------------------------------------

  (check-for-true
   (let* ((str (S "abcd")))
     (bytevector-u8= str str)))

  (check-for-true
   (bytevector-u8= (view (S "12abcd") (start 2)) (S "abcd")))

  (check-for-false
   (bytevector-u8= (S "abc") (S "abcd")))

  (check-for-false
   (bytevector-u8= (S "abcd") (S "abc")))

  (check-for-false
   (bytevector-u8= (S "ABcd") (S "abcd")))

  (check-for-false
   (bytevector-u8= (S "abcd") (S "a2cd")))

;;; --------------------------------------------------------------------

  (check-for-false
   (bytevector-u8<> (S "abcd") (S "abcd")))

  (check-for-true
   (bytevector-u8<> (S "abc") (S "abcd")))

  (check-for-true
   (bytevector-u8<> (S "abcd") (S "abc")))

  (check-for-true
   (bytevector-u8<> (S "ABcd") (S "abcd")))

  (check-for-true
   (bytevector-u8<> (S "abcd") (S "a2cd")))

;;; --------------------------------------------------------------------

  (check-for-false
   (bytevector-u8< (S "abcd") (S "abcd")))

  (check-for-true
   (bytevector-u8< (S "abc") (S "abcd")))

  (check-for-false
   (bytevector-u8< (S "abcd") (S "abc")))

  (check-for-true
   (bytevector-u8< (S "ABcd") (S "abcd")))

  (check-for-false
   (bytevector-u8< (S "abcd") (S "a2cd")))

;;; --------------------------------------------------------------------

  (check-for-true
   (bytevector-u8<= (S "abcd") (S "abcd")))

  (check-for-true
   (bytevector-u8<= (S "abc") (S "abcd")))

  (check-for-false
   (bytevector-u8<= (S "abcd") (S "abc")))

  (check-for-true
   (bytevector-u8<= (S "ABcd") (S "abcd")))

  (check-for-false
   (bytevector-u8<= (S "abcd") (S "a2cd")))

;;; --------------------------------------------------------------------

  (check-for-false
   (bytevector-u8> (S "abcd") (S "abcd")))

  (check-for-true
   (bytevector-u8> (S "abcd") (S "abc")))

  (check-for-false
   (bytevector-u8> (S "abc") (S "abcd")))

  (check-for-true
   (bytevector-u8> (S "abcd") (S "ABcd")))

  (check-for-false
   (bytevector-u8> (S "a2cd") (S "abcd")))

;;; --------------------------------------------------------------------

  (check-for-true
   (bytevector-u8>= (S "abcd") (S "abcd")))

  (check-for-true
   (bytevector-u8>= (S "abcd") (S "abc")))

  (check-for-false
   (bytevector-u8>= (S "abc") (S "abcd")))

  (check-for-true
   (bytevector-u8>= (S "abcd") (S "ABcd")))

  (check-for-false
   (bytevector-u8>= (S "a2cd") (S "abcd")))

  #f)


(parameterise ((check-test-name 'mapping))

  (check
      (let ((str (bytevector-u8-copy (S "abcd"))))
	(bytevector-u8-map! (lambda (i ch) (char-upcase ch))
			    str)
	str)
    => (S "ABCD"))

  (check
      (let ((str (bytevector-u8-copy (S "abcd"))))
	(bytevector-u8-map! (lambda (i ch-a ch-b) (if (even? i) ch-a ch-b))
			    str (S "0123"))
	str)
    => (S "a1c3"))

  (check
      (let ((str (bytevector-u8-copy '#vu8())))
	(bytevector-u8-map! (lambda (i ch) (char-upcase ch))
			    str)
	str)
    => '#vu8())

;;; --------------------------------------------------------------------

  (check
      (let ((str (bytevector-u8-copy (S "abcd"))))
	(bytevector-u8-map*! (lambda (i ch) (char-upcase ch))
			     str)
	str)
    => (S "ABCD"))

  (check
      (let ((str (bytevector-u8-copy (S "abcd"))))
	(bytevector-u8-map*! (lambda (i ch-a ch-b) (if (even? i) ch-a ch-b))
			     str (S "01234"))
	str)
    => (S "a1c3"))

  (check
      (let ((str (bytevector-u8-copy '#vu8())))
	(bytevector-u8-map*! (lambda (i ch) (char-upcase ch))
			     str)
	str)
    => '#vu8())

;;; --------------------------------------------------------------------

  (check
      (cadr (with-result
	     (bytevector-u8-for-each* (lambda (i ch) (add-result (list i ch)))
				      (S "abcd"))))
    => '((0 #\a)
	 (1 #\b)
	 (2 #\c)
	 (3 #\d)))

  (check
      (cadr (with-result
	     (bytevector-u8-for-each* (lambda (i ch-a ch-b) (add-result (list i ch-a ch-b)))
				      (S "abcd") (S "01234"))))
    => '((0 #\a #\0)
	 (1 #\b #\1)
	 (2 #\c #\2)
	 (3 #\d #\3)))

  (check
      (cadr (with-result
	     (bytevector-u8-for-each* (lambda (i ch) (add-result (list i ch)))
				      '#vu8())))
    => '())

;;; --------------------------------------------------------------------

  (check
      (subbytevector-u8-map (lambda (ch) (char-upcase ch))
			    (S "abcd"))
    => (S "ABCD"))

  (check
      (subbytevector-u8-map (lambda (ch) (char-upcase ch))
			    (view (S "abcd") (start 1) (past 3)))
    => (S "BC"))

  (check
      (subbytevector-u8-map (lambda (ch) (char-upcase ch))
			    '#vu8())
    => '#vu8())

;;; --------------------------------------------------------------------

  (check
      (let ((str (bytevector-u8-copy (S "abcd"))))
	(subbytevector-u8-map! (lambda (ch) (char-upcase ch))
			       str)
	str)
    => (S "ABCD"))

  (check
      (let ((str (bytevector-u8-copy (S "abcd"))))
	(subbytevector-u8-map! (lambda (ch) (char-upcase ch))
			       (view str (start 1) (past 3)))
	str)
    => (S "aBCd"))

  (check
      (let ((str '#vu8()))
	(subbytevector-u8-map! (lambda (ch) (char-upcase ch))
			       str)
	str)
    => '#vu8())

;;; --------------------------------------------------------------------

  (check
      (cadr (with-result
	     (subbytevector-u8-for-each add-result
					(S "abcd"))))
    => '(#\a #\b #\c #\d))

  (check
      (cadr (with-result
	     (subbytevector-u8-for-each add-result
					(view (S "abcd") (start 1) (past 3)))))
    => '(#\b #\c))

  (check
      (cadr (with-result
	     (subbytevector-u8-for-each add-result '#vu8())))
    => '())

  #f)


(parameterise ((check-test-name 'case))

  (check
      (bytevector-u8-upcase* (S "abcd"))
    => (S "ABCD"))

  (check
      (bytevector-u8-upcase* (S "123abcd"))
    => (S "123ABCD"))

  (check
      (bytevector-u8-upcase* (S "---abcd"))
    => (S "---ABCD"))

  (check
      (bytevector-u8-upcase* (S "abcd efgh"))
    => (S "ABCD EFGH"))

;;; --------------------------------------------------------------------

  (check
      (let* ((str (bytevector-u8-copy (S "abcd"))))
	(bytevector-u8-upcase*! str)
	str)
    => (S "ABCD"))

  (check
      (let* ((str (bytevector-u8-copy (S "123abcd"))))
	(bytevector-u8-upcase*! str)
	str)
    => (S "123ABCD"))

  (check
      (let* ((str (bytevector-u8-copy (S "---abcd"))))
	(bytevector-u8-upcase*! str)
	str)
    => (S "---ABCD"))

  (check
      (let* ((str (bytevector-u8-copy (S "abcd efgh"))))
	(bytevector-u8-upcase*! str)
	str)
    => (S "ABCD EFGH"))

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-downcase* (S "ABCD"))
    => (S "abcd"))

  (check
      (bytevector-u8-downcase* (S "123AbcD"))
    => (S "123abcd"))

  (check
      (bytevector-u8-downcase* (S "---aBCd"))
    => (S "---abcd"))

  (check
      (bytevector-u8-downcase* (S "abcd EFGH"))
    => (S "abcd efgh"))

;;; --------------------------------------------------------------------

  (check
      (let* ((str (bytevector-u8-copy (S "aBCd"))))
	(bytevector-u8-downcase*! str)
	str)
    => (S "abcd"))

  (check
      (let* ((str (bytevector-u8-copy (S "123ABcd"))))
	(bytevector-u8-downcase*! str)
	str)
    => (S "123abcd"))

  (check
      (let* ((str (bytevector-u8-copy (S "---aBCD"))))
	(bytevector-u8-downcase*! str)
	str)
    => (S "---abcd"))

  (check
      (let* ((str (bytevector-u8-copy (S "abCD Efgh"))))
	(bytevector-u8-downcase*! str)
	str)
    => (S "abcd efgh"))

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-titlecase* (S "abcd"))
    => (S "Abcd"))

  (check
      (bytevector-u8-titlecase* (S "123abcd"))
    => (S "123Abcd"))

  (check
      (bytevector-u8-titlecase* (S "---abcd"))
    => (S "---Abcd"))

  (check
      (bytevector-u8-titlecase* (S "abcd efgh"))
    => "Abcd Efgh")

  (check
      (bytevector-u8-titlecase* (view "greasy fried chicken" (start 2)))
    => (S "Easy Fried Chicken"))

;;; --------------------------------------------------------------------

  (check
      (let* ((str (bytevector-u8-copy (S "abcd"))))
	(bytevector-u8-titlecase*! str)
	str)
    => (S "Abcd"))

  (check
      (let* ((str (bytevector-u8-copy (S "123abcd"))))
	(bytevector-u8-titlecase*! str)
	str)
    => (S "123Abcd"))

  (check
      (let* ((str (bytevector-u8-copy (S "---abcd"))))
	(bytevector-u8-titlecase*! str)
	str)
    => (S "---Abcd"))

  (check
      (let* ((str (bytevector-u8-copy (S "abcd efgh"))))
	(bytevector-u8-titlecase*! str)
	str)
    => (S "Abcd Efgh"))

  (check
      (let ((str (bytevector-u8-copy (S "greasy fried chicken"))))
	(bytevector-u8-titlecase*! (view str (start 2)))
	str)
    => (S "grEasy Fried Chicken"))

  )


(parameterise ((check-test-name 'folding))

  (check
      (bytevector-u8-fold-left (lambda (i nil x) (cons x nil)) '() (S "abcd"))
    => '(#\d #\c #\b #\a))

  (check
      (bytevector-u8-fold-left (lambda (i nil x y) (cons (cons x y) nil)) '()
			       (S "abcd")
			       (S "ABCD"))
    => '((#\d . #\D)
	 (#\c . #\C)
	 (#\b . #\B)
	 (#\a . #\A)))

  (check
      (bytevector-u8-fold-left (lambda (i nil x) (cons x nil)) '() '#vu8())
    => '())

  (check
      (bytevector-u8-fold-left (lambda (i count c)
			  (if (char-upper-case? c)
			      (+ count 1)
			    count))
			0
			(S "ABCdefGHi"))
    => 5)

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-fold-right (lambda (i nil x) (cons x nil)) '() (S "abcd"))
    => '(#\a #\b #\c #\d))

  (check
      (bytevector-u8-fold-right (lambda (i nil x y) (cons (cons x y) nil)) '()
				(S "abcd")
				(S "ABCD"))
    => '((#\a . #\A)
	 (#\b . #\B)
	 (#\c . #\C)
	 (#\d . #\D)))

  (check
      (bytevector-u8-fold-right (lambda (i nil x) (cons x nil)) '() '#vu8())
    => '())

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-fold-left* (lambda (i nil x) (cons x nil)) '() (S "abcd"))
    => '(#\d #\c #\b #\a))

  (check
      (bytevector-u8-fold-left* (lambda (i nil x y) (cons (cons x y) nil)) '()
				(S "abcd")
				(S "ABCDE"))
    => '((#\d . #\D)
	 (#\c . #\C)
	 (#\b . #\B)
	 (#\a . #\A)))

  (check
      (bytevector-u8-fold-left* (lambda (i nil x) (cons x nil)) '() '#vu8())
    => '())

  (check
      (bytevector-u8-fold-left* (lambda (i count c)
			   (if (char-upper-case? c)
			       (+ count 1)
			     count))
			 0
			 (S "ABCdefGHi"))
    => 5)

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-fold-right* (lambda (i nil x) (cons x nil)) '() (S "abcd"))
    => '(#\a #\b #\c #\d))

  (check
      (bytevector-u8-fold-right* (lambda (i nil x y) (cons (cons x y) nil)) '()
				 (S "abcd")
				 (S "ABCDE"))
    => '((#\a . #\A)
	 (#\b . #\B)
	 (#\c . #\C)
	 (#\d . #\D)))

  (check
      (bytevector-u8-fold-right* (lambda (i nil x) (cons x nil)) '() '#vu8())
    => '())

;;; --------------------------------------------------------------------

  (check
      (subbytevector-u8-fold-left cons '() (S "abcd"))
    => '(#\d #\c #\b #\a))

  (check
      (subbytevector-u8-fold-left cons '() '#vu8())
    => '())

  (check
      (subbytevector-u8-fold-left (lambda (c count)
				    (if (char-upper-case? c)
					(+ count 1)
				      count))
				  0
				  (S "ABCdefGHi"))
    => 5)

  (check
      (let* ((str (S "abc\\de\\f\\ghi"))
	     (ans-len (subbytevector-u8-fold-left
		       (lambda (c sum)
			 (+ sum (if (char=? c #\\) 2 1)))
		       0 str))
	     (ans (make-bytevector-u8 ans-len)))
	(subbytevector-u8-fold-left
	 (lambda (c i)
	   (let ((i (if (char=? c #\\)
			(begin
			  (bytevector-u8-set! ans i #\\)
			  (+ i 1))
		      i)))
	     (bytevector-u8-set! ans i c)
	     (+ i 1)))
	 0 str)
	ans)
    => (S "abc\\\\de\\\\f\\\\ghi"))

;;; --------------------------------------------------------------------

  (check
      (subbytevector-u8-fold-right cons '() (S "abcd"))
    => '(#\a #\b #\c #\d))

  (check
      (subbytevector-u8-fold-right cons '() '#vu8())
    => '())

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-unfold null? car cdr '(#\a #\b #\c #\d))
    => (S "abcd"))

  (check
      (bytevector-u8-unfold null? car cdr '())
    => '#vu8())

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-unfold-right null? car cdr '(#\a #\b #\c #\d))
    => (S "dcba"))

  (check
      (bytevector-u8-unfold-right null? car cdr '())
    => '#vu8())

  #f)


(parameterise ((check-test-name 'selecting))

  (check
      (bytevector-u8-take (S "abcd") 2)
    => (S "ab"))

  (check
      (bytevector-u8-take '#vu8() 0)
    => '#vu8())

  (check
      (guard (exc ((assertion-violation? exc) #t))
	(bytevector-u8-take (S "abcd") 5))
    => #t)

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-take-right (S "abcd") 2)
    => (S "cd"))

  (check
      (bytevector-u8-take-right '#vu8() 0)
    => '#vu8())

  (check
      (guard (exc ((assertion-violation? exc) #t))
	(bytevector-u8-take-right (S "abcd") 5))
    => #t)

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-drop (S "abcd") 2)
    => (S "cd"))

  (check
      (bytevector-u8-drop '#vu8() 0)
    => '#vu8())

  (check
      (guard (exc ((assertion-violation? exc) #t))
	(bytevector-u8-drop (S "abcd") 5))
    => #t)

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-drop-right (S "abcd") 2)
    => (S "ab"))

  (check
      (bytevector-u8-drop-right '#vu8() 0)
    => '#vu8())

  (check
      (guard (exc ((assertion-violation? exc) #t))
	(bytevector-u8-drop-right (S "abcd") 5))
    => #t)

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-trim (S "aaabcd") #\a)
    => (S "bcd"))

  (check
      (bytevector-u8-trim (S "bcd") #\a)
    => (S "bcd"))

  (check
      (bytevector-u8-trim '#vu8() #\a)
    => '#vu8())

  (check
      (bytevector-u8-trim (S "aaabcd") (char-set #\a #\b))
    => (S "cd"))

  (check
      (bytevector-u8-trim (S "bcd") (char-set #\a #\b))
    => (S "cd"))

  (check
      (bytevector-u8-trim '#vu8() (char-set #\a #\b))
    => '#vu8())

  (check
      (bytevector-u8-trim (S "AAAbcd") char-upper-case?)
    => (S "bcd"))

  (check
      (bytevector-u8-trim (S "bcd") char-upper-case?)
    => (S "bcd"))

  (check
      (bytevector-u8-trim '#vu8() char-upper-case?)
    => '#vu8())

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-trim-right (S "bcdaaa") #\a)
    => (S "bcd"))

  (check
      (bytevector-u8-trim-right (S "bcd") #\a)
    => (S "bcd"))

  (check
      (bytevector-u8-trim-right '#vu8() #\a)
    => '#vu8())

  (check
      (bytevector-u8-trim-right (S "cdbaaa") (char-set #\a #\b))
    => (S "cd"))

  (check
      (bytevector-u8-trim-right (S "cdb") (char-set #\a #\b))
    => (S "cd"))

  (check
      (bytevector-u8-trim-right '#vu8() (char-set #\a #\b))
    => '#vu8())

  (check
      (bytevector-u8-trim-right (S "bcdAAA") char-upper-case?)
    => (S "bcd"))

  (check
      (bytevector-u8-trim-right (S "bcd") char-upper-case?)
    => (S "bcd"))

  (check
      (bytevector-u8-trim-right '#vu8() char-upper-case?)
    => '#vu8())

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-trim-both (S "aaabcdaaa") #\a)
    => (S "bcd"))

  (check
      (bytevector-u8-trim-both (S "bcd") #\a)
    => (S "bcd"))

  (check
      (bytevector-u8-trim-both '#vu8() #\a)
    => '#vu8())

  (check
      (bytevector-u8-trim-both (S "aaabcdaa") (char-set #\a #\b))
    => (S "cd"))

  (check
      (bytevector-u8-trim-both (S "bcdb") (char-set #\a #\b))
    => (S "cd"))

  (check
      (bytevector-u8-trim-both '#vu8() (char-set #\a #\b))
    => '#vu8())

  (check
      (bytevector-u8-trim-both (S "AAAbcdAAA") char-upper-case?)
    => (S "bcd"))

  (check
      (bytevector-u8-trim-both (S "bcd") char-upper-case?)
    => (S "bcd"))

  (check
      (bytevector-u8-trim-both '#vu8() char-upper-case?)
    => '#vu8())

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-pad (S "abc") 3 #\0)
    => (S "abc"))

  (check
      (bytevector-u8-pad (S "abc") 5 #\0)
    => (S "00abc"))

  (check
      (bytevector-u8-pad (S "abc") 5)
    => (S "  abc"))

  (check
      (bytevector-u8-pad (S "abc") 2 #\0)
    => (S "bc"))

  (check
      (bytevector-u8-pad (S "abc") 0 #\0)
    => '#vu8())

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-pad-right (S "abc") 3 #\0)
    => (S "abc"))

  (check
      (bytevector-u8-pad-right (S "abc") 5 #\0)
    => (S "abc00"))

  (check
      (bytevector-u8-pad-right (S "abc") 2 #\0)
    => (S "ab"))

  (check
      (bytevector-u8-pad-right (S "abc") 0 #\0)
    => '#vu8())

  #f)


(parameterise ((check-test-name 'prefix))

  (check
      (bytevector-u8-prefix-length (S "abcdefg") (S "abcd123"))
    => 4)

  (check
      (bytevector-u8-prefix-length (S "aBcdefg") (S "abcd123"))
    => 1)

  (check
      (bytevector-u8-prefix-length (S "efg") (S "123"))
    => 0)

  (check
      (bytevector-u8-prefix-length (S "a") (S "a"))
    => 1)

  (check
      (bytevector-u8-prefix-length (S "1") (S "2"))
    => 0)

  (check
      (bytevector-u8-prefix-length '#vu8() (S "abcd123"))
    => 0)

  (check
      (bytevector-u8-prefix-length (S "abcdefg") '#vu8())
    => 0)

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-suffix-length (S "efgabcd") (S "123abcd"))
    => 4)

  (check
      (bytevector-u8-suffix-length (S "efgabcd") (S "123abCd"))
    => 1)

  (check
      (bytevector-u8-suffix-length (S "efg") (S "123"))
    => 0)

  (check
      (bytevector-u8-suffix-length (S "a") (S "a"))
    => 1)

  (check
      (bytevector-u8-suffix-length (S "1") (S "2"))
    => 0)

  (check
      (bytevector-u8-suffix-length '#vu8() (S "abcd123"))
    => 0)

  (check
      (bytevector-u8-suffix-length (S "abcdefg") '#vu8())
    => 0)

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-prefix-length-ci (S "aBcdefg") (S "aBcd123"))
    => 4)

  (check
      (bytevector-u8-prefix-length-ci (S "aBcdefg") (S "abcd123"))
    => 4)

  (check
      (bytevector-u8-prefix-length-ci (S "efg") (S "123"))
    => 0)

  (check
      (bytevector-u8-prefix-length-ci (S "a") (S "a"))
    => 1)

  (check
      (bytevector-u8-prefix-length-ci (S "1") (S "2"))
    => 0)

  (check
      (bytevector-u8-prefix-length-ci '#vu8() (S "abcd123"))
    => 0)

  (check
      (bytevector-u8-prefix-length-ci (S "abcdefg") '#vu8())
    => 0)

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-suffix-length-ci (S "efgabCd") (S "123abCd"))
    => 4)

  (check
      (bytevector-u8-suffix-length-ci (S "efgabCd") (S "123abcd"))
    => 4)

  (check
      (bytevector-u8-suffix-length-ci (S "efg") (S "123"))
    => 0)

  (check
      (bytevector-u8-suffix-length-ci (S "a") (S "a"))
    => 1)

  (check
      (bytevector-u8-suffix-length-ci (S "1") (S "2"))
    => 0)

  (check
      (bytevector-u8-suffix-length-ci '#vu8() (S "abcd123"))
    => 0)

  (check
      (bytevector-u8-suffix-length-ci (S "abcdefg") '#vu8())
    => 0)

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-prefix? (S "abcd") (S "abcd123"))
    => #t)

  (check
      (bytevector-u8-prefix? (S "abcd") (S "aBcd123"))
    => #f)

  (check
      (bytevector-u8-prefix? (S "efg") (S "123"))
    => #f)

  (check
      (bytevector-u8-prefix? '#vu8() (S "123"))
    => #t)

  (check
      (bytevector-u8-prefix? (S "efg") '#vu8())
    => #f)

  (check
      (bytevector-u8-prefix? '#vu8() '#vu8())
    => #t)

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-prefix-ci? (S "aBcd") (S "aBcd123"))
    => #t)

  (check
      (bytevector-u8-prefix-ci? (S "abcd") (S "aBcd123"))
    => #t)

  (check
      (bytevector-u8-prefix-ci? (S "efg") (S "123"))
    => #f)

  (check
      (bytevector-u8-prefix-ci? '#vu8() (S "123"))
    => #t)

  (check
      (bytevector-u8-prefix-ci? (S "efg") '#vu8())
    => #f)

  (check
      (bytevector-u8-prefix-ci? '#vu8() '#vu8())
    => #t)

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-suffix? (S "abcd") (S "123abcd"))
    => #t)

  (check
      (bytevector-u8-suffix? (S "abcd") (S "123aBcd"))
    => #f)

  (check
      (bytevector-u8-suffix? (S "efg") (S "123"))
    => #f)

  (check
      (bytevector-u8-suffix? '#vu8() (S "123"))
    => #t)

  (check
      (bytevector-u8-suffix? (S "efg") '#vu8())
    => #f)

  (check
      (bytevector-u8-suffix? '#vu8() '#vu8())
    => #t)

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-suffix-ci? (S "aBcd") (S "123aBcd"))
    => #t)

  (check
      (bytevector-u8-suffix-ci? (S "abcd") (S "123aBcd"))
    => #t)

  (check
      (bytevector-u8-suffix-ci? (S "efg") (S "123"))
    => #f)

  (check
      (bytevector-u8-suffix-ci? '#vu8() (S "123"))
    => #t)

  (check
      (bytevector-u8-suffix-ci? (S "efg") '#vu8())
    => #f)

  (check
      (bytevector-u8-suffix-ci? '#vu8() '#vu8())
    => #t)

  #f)


(parameterise ((check-test-name 'searching))

  (check
      (bytevector-u8-index (S "abcd") #\b)
    => 1)

  (check
      (bytevector-u8-index (view (S "abcd") (start 1)) #\b)
    => 1)

  (check
      (bytevector-u8-index (S "abcd") #\1)
    => #f)

  (check
      (bytevector-u8-index '#vu8() #\1)
    => #f)

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-index (S "abcd") (char-set #\b #\B))
    => 1)

  (check
      (bytevector-u8-index (view (S "abcd") (start 1)) (char-set #\b #\B))
    => 1)

  (check
      (bytevector-u8-index (S "abcd") (char-set #\0 #\1))
    => #f)

  (check
      (bytevector-u8-index '#vu8() (char-set #\0 #\1))
    => #f)

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-index (S "aBcd") char-upper-case?)
    => 1)

  (check
      (bytevector-u8-index (view (S "aBcd") (start 1)) char-upper-case?)
    => 1)

  (check
      (bytevector-u8-index (S "abcd") char-upper-case?)
    => #f)

  (check
      (bytevector-u8-index '#vu8() char-upper-case?)
    => #f)

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-index-right (S "abcd") #\b)
    => 1)

  (check
      (bytevector-u8-index-right (view (S "abcd") (start 1)) #\b)
    => 1)

  (check
      (bytevector-u8-index-right (S "abcd") #\1)
    => #f)

  (check
      (bytevector-u8-index-right '#vu8() #\1)
    => #f)

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-index-right (S "abcd") (char-set #\b #\B))
    => 1)

  (check
      (bytevector-u8-index-right (view (S "abcd") (start 1)) (char-set #\b #\B))
    => 1)

  (check
      (bytevector-u8-index-right (S "abcd") (char-set #\0 #\1))
    => #f)

  (check
      (bytevector-u8-index-right '#vu8() (char-set #\0 #\1))
    => #f)

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-index-right (S "aBcd") char-upper-case?)
    => 1)

  (check
      (bytevector-u8-index-right (view (S "aBcd") (start 1)) char-upper-case?)
    => 1)

  (check
      (bytevector-u8-index-right (S "abcd") char-upper-case?)
    => #f)

  (check
      (bytevector-u8-index-right '#vu8() char-upper-case?)
    => #f)

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-skip (S "bacd") #\b)
    => 1)

  (check
      (bytevector-u8-skip (view (S "bacd") (start 1)) #\b)
    => 1)

  (check
      (bytevector-u8-skip (S "1111") #\1)
    => #f)

  (check
      (bytevector-u8-skip '#vu8() #\1)
    => #f)

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-skip (S "bacd") (char-set #\b #\B))
    => 1)

  (check
      (bytevector-u8-skip (view (S "bacd") (start 1)) (char-set #\b #\B))
    => 1)

  (check
      (bytevector-u8-skip (S "1010") (char-set #\0 #\1))
    => #f)

  (check
      (bytevector-u8-skip '#vu8() (char-set #\0 #\1))
    => #f)

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-skip (S "Bacd") char-upper-case?)
    => 1)

  (check
      (bytevector-u8-skip (view (S "Bacd") (start 1)) char-upper-case?)
    => 1)

  (check
      (bytevector-u8-skip (S "ABCD") char-upper-case?)
    => #f)

  (check
      (bytevector-u8-skip '#vu8() char-upper-case?)
    => #f)

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-skip-right (S "acdb") #\b)
    => 2)

  (check
      (bytevector-u8-skip-right (view (S "acdb") (start 1)) #\b)
    => 2)

  (check
      (bytevector-u8-skip-right (S "1111") #\1)
    => #f)

  (check
      (bytevector-u8-skip-right '#vu8() #\1)
    => #f)

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-skip-right (S "acdb") (char-set #\b #\B))
    => 2)

  (check
      (bytevector-u8-skip-right (view (S "acdb") (start 1)) (char-set #\b #\B))
    => 2)

  (check
      (bytevector-u8-skip-right (S "0101") (char-set #\0 #\1))
    => #f)

  (check
      (bytevector-u8-skip-right '#vu8() (char-set #\0 #\1))
    => #f)

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-skip-right (S "acdB") char-upper-case?)
    => 2)

  (check
      (bytevector-u8-skip-right (view (S "acdB") (start 1)) char-upper-case?)
    => 2)

  (check
      (bytevector-u8-skip-right (S "ABCD") char-upper-case?)
    => #f)

  (check
      (bytevector-u8-skip-right '#vu8() char-upper-case?)
    => #f)

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-count (S "abcbd") #\b)
    => 2)

  (check
      (bytevector-u8-count (view (S "abcd") (start 1)) #\b)
    => 1)

  (check
      (bytevector-u8-count (S "abcd") #\1)
    => 0)

  (check
      (bytevector-u8-count '#vu8() #\1)
    => 0)

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-count (S "abcBd") (char-set #\b #\B))
    => 2)

  (check
      (bytevector-u8-count (view (S "abcd") (start 1)) (char-set #\b #\B))
    => 1)

  (check
      (bytevector-u8-count (S "abcd") (char-set #\0 #\1))
    => 0)

  (check
      (bytevector-u8-count '#vu8() (char-set #\0 #\1))
    => 0)

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-count (S "aBcAd") char-upper-case?)
    => 2)

  (check
      (bytevector-u8-count (view (S "aBcd") (start 1)) char-upper-case?)
    => 1)

  (check
      (bytevector-u8-count (S "abcd") char-upper-case?)
    => 0)

  (check
      (bytevector-u8-count '#vu8() char-upper-case?)
    => 0)

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-contains (S "ciao hello salut") (S "hello"))
    => 5)

  (check
      (bytevector-u8-contains (S "ciao hello salut") (S "hola"))
    => #f)

  (check
      (bytevector-u8-contains (S "ciao hello salut") '#vu8())
    => 0)

  (check
      (bytevector-u8-contains '#vu8() (S "hello"))
    => #f)

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-contains-ci (S "ciAO HELLO saLUT") (S "hello"))
    => 5)

  (check
      (bytevector-u8-contains-ci (S "ciao hello salut") (S "HOLA"))
    => #f)

  (check
      (bytevector-u8-contains-ci (S "ciao hello salut") '#vu8())
    => 0)

  (check
      (bytevector-u8-contains-ci '#vu8() (S "hello"))
    => #f)

  #f)


(parameterise ((check-test-name 'filtering))

  (check
      (bytevector-u8-delete (S "abcbd") #\b)
    => (S "acd"))

  (check
      (bytevector-u8-delete (S "abcbd") #\0)
    => (S "abcbd"))

  (check
      (bytevector-u8-delete '#vu8() #\b)
    => '#vu8())

  (check
      (bytevector-u8-delete (S "bbb") #\b)
    => '#vu8())

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-delete (S "abcbd") (char-set #\b #\B))
    => (S "acd"))

  (check
      (bytevector-u8-delete (S "abcbd") (char-set #\0 #\1))
    => (S "abcbd"))

  (check
      (bytevector-u8-delete '#vu8() (char-set #\b #\B))
    => '#vu8())

  (check
      (bytevector-u8-delete (S "BbB") (char-set #\b #\B))
    => '#vu8())

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-delete (S "aBcBd") char-upper-case?)
    => (S "acd"))

  (check
      (bytevector-u8-delete (S "abcbd") char-upper-case?)
    => (S "abcbd"))

  (check
      (bytevector-u8-delete '#vu8() char-upper-case?)
    => '#vu8())

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-filter (S "abcbd") #\b)
    => (S "bb"))

  (check
      (bytevector-u8-filter (S "abcbd") #\0)
    => '#vu8())

  (check
      (bytevector-u8-filter '#vu8() #\b)
    => '#vu8())

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-filter (S "abcbd") (char-set #\b #\B))
    => (S "bb"))

  (check
      (bytevector-u8-filter (S "abcbd") (char-set #\0 #\1))
    => '#vu8())

  (check
      (bytevector-u8-filter '#vu8() (char-set #\b #\B))
    => '#vu8())

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-filter (S "aBcBd") char-upper-case?)
    => (S "BB"))

  (check
      (bytevector-u8-filter (S "abcbd") char-upper-case?)
    => '#vu8())

  (check
      (bytevector-u8-filter '#vu8() char-upper-case?)
    => '#vu8())

  #f)


(parameterise ((check-test-name 'lists))

  (check
      (bytevector-u8->list* (S "abcd"))
    => '(#\a #\b #\c #\d))

  (check
      (bytevector-u8->list* (view (S "abcd") (start 1) (past 3)))
    => '(#\b #\c))

  (check
      (bytevector-u8->list* '#vu8())
    => '())

;;; --------------------------------------------------------------------

  (check
      (reverse-list->bytevector-u8 '(#\a #\b #\c #\d))
    => (S "dcba"))

  (check
      (reverse-list->bytevector-u8 '())
    => '#vu8())

  #f)

;;; --------------------------------------------------------------------

(parameterise ((check-test-name 'tokenize))

  (check
      (bytevector-u8-tokenize (S "ciao hello salut")
			      (char-set #\a #\c #\e #\i #\h #\l #\o #\s #\t #\u))
    => `(,(S "ciao") ,(S "hello") ,(S "salut")))

  (check
      (bytevector-u8-tokenize '#vu8() (char-set #\a #\c #\e #\i #\h #\l #\o #\s #\t #\u))
    => '())

  (check
      (bytevector-u8-tokenize (S "ciao hello salut") (char-set))
    => '())

  (check
      (bytevector-u8-tokenize (S "Help make programs run, run, RUN!")
			      (char-set-complement (char-set #\space)
						   char-set:ascii))
    => `(,(S "Help") ,(S "make") ,(S "programs") ,(S "run,") ,(S "run,") ,(S "RUN!")))

  #f)

;;; --------------------------------------------------------------------

(parameterise ((check-test-name 'join))

  (check
      (bytevector-u8-join `(,(S "c") ,(S "i") ,(S "a") ,(S "o")) ,(S ",") 'infix)
    => (S "c,i,a,o"))

  (check
      (bytevector-u8-join `(,(S "c") ,(S "i") ,(S "a") ,(S "o")) (S ",") 'strict-infix)
    => (S "c,i,a,o"))

  (check
      (bytevector-u8-join `(,(S "c") ,(S "i") ,(S "a") ,(S "o")) (S ",") 'suffix)
    => (S "c,i,a,o,"))

  (check
      (bytevector-u8-join `(,(S "c") ,(S "i") ,(S "a") ,(S "o")) (S ",") 'prefix)
    => (S ",c,i,a,o"))

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-join '() (S ",") 'infix)
    => '#vu8())

  (check
      (guard (exc ((assertion-violation? exc)
		   #t))
	(bytevector-u8-join '() (S ",") 'strict-infix))
    => #t)

  (check
      (bytevector-u8-join '() (S ",") 'suffix)
    => '#vu8())

  (check
      (bytevector-u8-join '() (S ",") 'prefix)
    => '#vu8())

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-join `(,(S "c")) (S ",") 'infix)
    => (S "c"))

  (check
      (bytevector-u8-join `(,(S "c")) (S ",") 'strict-infix)
    => (S "c"))

  (check
      (bytevector-u8-join `(,(S "c")) ,(S ",") 'suffix)
    => (S "c,"))

  (check
      (bytevector-u8-join `(,(S "c")) (S ",") 'prefix)
    => (S ",c"))

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-join '(#vu8()) (S ",") 'infix)
    => '#vu8())

  (check
      (bytevector-u8-join '(#vu8()) (S ",") 'strict-infix)
    => '#vu8())

  (check
      (bytevector-u8-join '(#vu8()) (S ",") 'suffix)
    => (S ","))

  (check
      (bytevector-u8-join '(#vu8()) (S ",") 'prefix)
    => (S ","))

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-join `(,(S "c") ,(S "i") ,(S "a") ,(S "o")) '#vu8() 'infix)
    => (S "ciao"))

  (check
      (bytevector-u8-join `(,(S "c") ,(S "i") ,(S "a") ,(S "o")) '#vu8() 'strict-infix)
    => (S "ciao"))

  (check
      (bytevector-u8-join `(,(S "c") ,(S "i") ,(S "a") ,(S "o")) '#vu8() 'suffix)
    => (S "ciao"))

  (check
      (bytevector-u8-join `(,(S "c") ,(S "i") ,(S "a") ,(S "o")) '#vu8() 'prefix)
    => (S "ciao"))

;;; --------------------------------------------------------------------

  (check
      (bytevector-u8-join `(,(S "c") ,(S "i") ,(S "a") ,(S "o")) (S ",;;") 'infix)
    => (S "c,;;i,;;a,;;o"))

  (check
      (bytevector-u8-join `(,(S "c") ,(S "i") ,(S "a") ,(S "o")) (S ",;;") 'strict-infix)
    => (S "c,;;i,;;a,;;o"))

  (check
      (bytevector-u8-join `(,(S "c") ,(S "i") ,(S "a") ,(S "o")) (S ",;;") 'suffix)
    => (S "c,;;i,;;a,;;o,;;"))

  (check
      (bytevector-u8-join `(,(S "c") ,(S "i") ,(S "a") ,(S "o")) (S ",;;") 'prefix)
    => (S ",;;c,;;i,;;a,;;o"))

  #f)


(parameterise ((check-test-name 'xsubbytevector-u8))

  (check
      (xsubbytevector-u8 (S "ciao ") 0 5)
    => (S "ciao "))

  (check
      (xsubbytevector-u8 (S "ciao ") 0 9)
    => (S "ciao ciao"))

  (check
      (xsubbytevector-u8 (S "ciao ") -5 5)
    => (S "ciao ciao "))

  (check
      (xsubbytevector-u8 (S "ciao ") 2 4)
    => (S "ao"))

  (check
      (xsubbytevector-u8 (S "ciao ") -3 7)
    => (S "ao ciao ci"))

  (check (xsubbytevector-u8 (S "abcdef") 1 7) => (S "bcdefa"))
  (check (xsubbytevector-u8 (S "abcdef") 2 8) => (S "cdefab"))
  (check (xsubbytevector-u8 (S "abcdef") 3 9) => (S "defabc"))
  (check (xsubbytevector-u8 (S "abcdef") 4 10) => (S "efabcd"))
  (check (xsubbytevector-u8 (S "abcdef") 5 11) => (S "fabcde"))

  (check (xsubbytevector-u8 (S "abcdef") -1 5) => (S "fabcde"))
  (check (xsubbytevector-u8 (S "abcdef") -2 4) => (S "efabcd"))
  (check (xsubbytevector-u8 (S "abcdef") -3 3) => (S "defabc"))
  (check (xsubbytevector-u8 (S "abcdef") -4 2) => (S "cdefab"))
  (check (xsubbytevector-u8 (S "abcdef") -5 1) => (S "bcdefa"))

  (check
      (xsubbytevector-u8 (S "ciao ") 3 3)
    => '#vu8())

  (check
      (guard (exc ((assertion-violation? exc)
		   #t))
	(xsubbytevector-u8 '#vu8() 0 5))
    => #t)

;;; --------------------------------------------------------------------

  (check
      (let ((result (bytevector-u8-copy (S "01234"))))
	(bytevector-u8-xcopy! result (S "ciao ") 0 5)
	result)
    => (S "ciao "))

  (check
      (let ((result (bytevector-u8-copy (S "012345678"))))
	(bytevector-u8-xcopy! result (S "ciao ") 0 9)
	result)
    => (S "ciao ciao"))

  (check
      (let ((result (bytevector-u8-copy (S "0123456789"))))
	(bytevector-u8-xcopy! result (S "ciao ") -5 5)
	result)
    => (S "ciao ciao "))

  (check
      (let ((result (bytevector-u8-copy (S "01"))))
	(bytevector-u8-xcopy! result (S "ciao ") 2 4)
	result)
    => (S "ao"))

  (check
      (let ((result (bytevector-u8-copy (S "0123456789"))))
	(bytevector-u8-xcopy! result (S "ciao ") -3 7)
	result)
    => (S "ao ciao ci"))

  (check
      (guard (exc ((assertion-violation? exc) #t))
	  (bytevector-u8-xcopy! '#vu8() '#vu8() 0 5))
    => #t)

  #f)


(parameterise ((check-test-name 'filling))

  (check
      (let* ((str (bytevector-u8-copy (S "abcd"))))
	(bytevector-u8-fill*! str #\b)
	str)
    => (S "bbbb"))

  (check
      (let* ((str (bytevector-u8-copy (S "accd"))))
	(bytevector-u8-fill*! (view str (start 1) (past 3)) #\b)
	str)
    => (S "abbd"))

  (check
      (let* ((str (bytevector-u8-copy '#vu8())))
	(bytevector-u8-fill*! (view str (start 0) (past 0)) #\b)
	str)
    => '#vu8())

  #f)


(parameterise ((check-test-name 'reverse))

  (check
      (bytevector-u8-reverse (S "abcd"))
    => (S "dcba"))

  (check
      (bytevector-u8-reverse '#vu8())
    => '#vu8())

;;; --------------------------------------------------------------------

  (check
      (let* ((str (bytevector-u8-copy (S "abcd"))))
	(bytevector-u8-reverse! str)
	str)
    => (S "dcba"))

  (check
      (let* ((str (bytevector-u8-copy '#vu8())))
	(bytevector-u8-reverse! str)
	str)
    => '#vu8())

  #f)


(parameterise ((check-test-name 'replace))

  (check
      (bytevector-u8-replace (S "abcd") (S "1234"))
    => (S "1234"))

  (check
      (bytevector-u8-replace (view (S "abcd") (start 2) (past 2)) (S "1234"))
    => (S "ab1234cd"))

  (check
      (bytevector-u8-replace (view (S "abcd") (start 2) (past 2)) '#vu8())
    => (S "abcd"))

  (check
      (bytevector-u8-replace (view (S "abcd") (start 1) (past 3)) (S "1234"))
    => (S "a1234d"))

  (check
      (bytevector-u8-replace (view (S "abcd") (start 0) (past 3)) (S "1234"))
    => (S "1234d"))

  (check
      (bytevector-u8-replace (view (S "abcd") (start 1) (past 4)) (S "1234"))
    => (S "a1234"))

  #f)


(parameterise ((check-test-name 'mutating))

  (check
      (let* ((str (bytevector-u8-copy (S "12"))))
	;; not enough room in destination bytevector-u8
	(guard (exc ((assertion-violation? exc) #t))
	  (bytevector-u8-copy*! (view str (start 3))
				(view (S "abcd") (past 2)))))
    => #t)

  (check
      ;; whole bytevector-u8 copy
      (let* ((str (bytevector-u8-copy (S "123"))))
	(bytevector-u8-copy*! str (S "abc"))
	str)
    => (S "abc"))

  (check
      ;; zero-elements bytevector-u8 copy
      (let* ((str (bytevector-u8-copy (S "123"))))
	(bytevector-u8-copy*! str (view (S "abc") (start 2) (past 2)))
	str)
    => (S "123"))

  (check
      ;; one-element bytevector-u8 copy
      (let* ((str (bytevector-u8-copy (S "123"))))
	(bytevector-u8-copy*! str (view (S "abc") (start 1) (past 2)))
	str)
    => (S "b23"))

  (check
      ;; two-elements bytevector-u8 copy
      (let* ((str (bytevector-u8-copy (S "12"))))
	(bytevector-u8-copy*! str (view (S "abcd") (past 2)))
	str)
    => (S "ab"))

  (check
      (let ((str '#vu8()))
	(bytevector-u8-copy*! str (view (S "abcd") (start 0) (past 0)))
	str)
    => '#vu8())

  (check
      ;; over the same bytevector-u8, full
      (let* ((str (bytevector-u8-copy (S "0123456789"))))
	(bytevector-u8-copy*! str str)
	str)
    => (S "0123456789"))

  (check
      ;; over the same bytevector-u8, in place
      (let* ((str (bytevector-u8-copy (S "0123456789"))))
	(bytevector-u8-copy*! (view str (start 5)) (view str (start 5)))
	str)
    => (S "0123456789"))

  (check
      ;; over the same bytevector-u8, backwards
      (let* ((str (bytevector-u8-copy (S "0123456789"))))
	(bytevector-u8-copy*! (view str (start 2))
			      (view str (start 4) (past 8)))
	str)
    => (S "0145676789"))

  (check
      ;; over the same bytevector-u8, backwards
      (let* ((str (bytevector-u8-copy (S "0123456789"))))
	(bytevector-u8-copy*! (view str (start 0))
			      (view str (start 4) (past 8)))
	str)
    => (S "4567456789"))

  (check
      ;; over the same bytevector-u8, forwards
      (let* ((str (bytevector-u8-copy (S "0123456789"))))
	(bytevector-u8-copy*! (view str (start 4))
			      (view str (start 2) (past 6)))
	str)
    => (S "0123234589"))

  (check
      ;; over the same bytevector-u8, forwards
      (let* ((str (bytevector-u8-copy (S "0123456789"))))
	(bytevector-u8-copy*! (view str (start 6))
			      (view str (start 2) (past 6)))
	str)
    => (S "0123452345"))

;;; --------------------------------------------------------------------

  (check
      (let* ((str (bytevector-u8-copy (S "12"))))
	;; not enough room in destination bytevector-u8
	;;(bytevector-u8-reverse-copy*! (str 3) (view '#(#\a #\b #\c #\d) (past 2)))
	(guard (exc ((assertion-violation? exc) #t))
	  (bytevector-u8-reverse-copy*! (view str (start 3))
					(view (S "abcd") (past 2)))))
    => #t)

  (check
      ;; whole bytevector-u8 copy
      (let* ((str (bytevector-u8-copy (S "123"))))
	(bytevector-u8-reverse-copy*! str (S "abc"))
	str)
    => (S "cba"))

  (check
      ;; zero-elements bytevector-u8 copy
      (let* ((str (bytevector-u8-copy (S "123"))))
	(bytevector-u8-reverse-copy*! str (view (S "abc") (start 2) (past 2)))
	str)
    => (S "123"))

  (check
      ;; one-element bytevector-u8 copy
      (let* ((str (bytevector-u8-copy (S "123"))))
	(bytevector-u8-reverse-copy*! str (view (S "abc") (start 1) (past 2)))
	str)
    => (S "b23"))

  (check
      ;; two-elements bytevector-u8 copy
      (let* ((str (bytevector-u8-copy (S "12"))))
	(bytevector-u8-reverse-copy*! str (view "abcd" (past 2)))
	str)
    => (S "ba"))

  (check
      (let ((str '#vu8()))
	(bytevector-u8-reverse-copy*! str (view (S "abcd") (start 0) (past 0)))
	str)
    => '#vu8())

  (check
      ;; over the same bytevector-u8, full
      (let* ((str (bytevector-u8-copy (S "0123456789"))))
	(bytevector-u8-reverse-copy*! str str)
	str)
    => (S "9876543210"))

  (check
      ;; over the same bytevector-u8
      (let* ((str (bytevector-u8-copy (S "0123456789"))))
	(bytevector-u8-reverse-copy*! (view str (start 5))
				      (view str (start 5)))
	str)
    => (S "0123498765"))

  (check
      ;; over the same bytevector-u8, backwards
      (let* ((str (bytevector-u8-copy (S "0123456789"))))
	(bytevector-u8-reverse-copy*! (view str (start 2))
				      (view str (start 4) (past 8)))
	str)
    => (S "0176546789"))

  (check
      ;; over the same bytevector-u8, backwards
      (let* ((str (bytevector-u8-copy (S "0123456789"))))
	(bytevector-u8-reverse-copy*! (view str (start 0))
				      (view str (start 4) (past 8)))
	str)
    => (S "7654456789"))

  (check
      ;; over the same bytevector-u8, forwards
      (let* ((str (bytevector-u8-copy (S "0123456789"))))
	(bytevector-u8-reverse-copy*! (view str (start 4))
				      (view str (start 2) (past 6)))
	str)
    => (S "0123543289"))

  (check
      ;; over the same bytevector-u8, forwards
      (let* ((str (bytevector-u8-copy (S "0123456789"))))
	(bytevector-u8-reverse-copy*! (view str (start 6))
				      (view str (start 2) (past 6)))
	str)
    => (S "0123455432"))

;;; --------------------------------------------------------------------

  (check
      (let ((str (bytevector-u8-copy (S "012345"))))
	(bytevector-u8-swap! str 2 4)
	str)
    => (S "014325"))

  (check
      (let ((str (bytevector-u8-copy (S "012345"))))
	(bytevector-u8-swap! str 2 2)
	str)
    => (S "012345"))

  (check
      (guard (exc ((assertion-violation? exc) #t))
	(bytevector-u8-swap! '#vu8() 0 1))
    => #t)

  #f)


;;;; done

(check-report)

;;; end of file
