;;;
;;;Part of: Nausicaa/SRFI
;;;Contents: tests for the helper functions of FORMAT
;;;Date: Thu Jan  8, 2009
;;;
;;;Abstract
;;;
;;;
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



;;;; setup

(import (rnrs)
  (lang-lib)
  (check-lib)
  (only (srfi strings)
	string-index))

(check-set-mode! 'report-failed)



(define (localised-decimal-separator)
  ".")

(define (compose-with-digits digits pre-str frac-str exp-str)
  (let ((frac-len (string-length frac-str)))
    (cond

     ((< frac-len digits)
      (string-append pre-str
		     (localised-decimal-separator)
		     frac-str
		     (make-string (- digits frac-len) #\0)
		     exp-str))

     ((= frac-len digits)
      (string-append pre-str
		     (localised-decimal-separator)
		     frac-str
		     exp-str))

     (else
      (let* ((first-part	(substring frac-str 0 digits))
	     (last-part		(substring frac-str digits frac-len))
	     (temp-str		(number->string
				 ;;ROUND is defined  by R6RS to round to
				 ;;the nearest even inexact integer when
				 ;;the  argument is halfway  between two
				 ;;integers.
				 (round (string->number
					 (string-append
					  first-part
					  (localised-decimal-separator)
					  last-part)))))
	     (dot-pos	(string-index  temp-str #\.))
	     (carry?	(and (> dot-pos digits)
			     (> (round (string->number
					(string-append "0." frac-str)))
				0)))
	     (new-frac	(substring temp-str 0 digits)))
	(string-append (if carry?
			   (number->string (+ 1 (string->number pre-str)))
			 pre-str)
		       (localised-decimal-separator)
		       new-frac
		       exp-str))))))

;;; --------------------------------------------------------------------

(check
    (compose-with-digits 5 "12" "456" "e789")
  => "12.45600e789")

(check
    (compose-with-digits 5 "12" "456" "")
  => "12.45600")

(check
    (compose-with-digits 5 "" "456" "e789")
  => ".45600e789")

(check
    (compose-with-digits 5 "12" "" "e789")
  => "12.00000e789")

(check
    (compose-with-digits 5 "12" "456" "")
  => "12.45600")

;;; --------------------------------------------------------------------
;;; rounding

(check
    (compose-with-digits 1 "12" "44" "")
  => "12.4")

(check
    (compose-with-digits 1 "12" "46" "")
  => "12.5")

;;When 5 is the last digit: the number is rounded with the last digit in
;;the result being the nearest even.
(check
    (compose-with-digits 1 "12" "45" "")
  => "12.4")

(check
    (compose-with-digits 1 "12" "451" "")
  => "12.5")

(check
    (compose-with-digits 1 "12" "454" "")
  => "12.5")

(check
    (compose-with-digits 1 "12" "456" "")
  => "12.5")

;;Not so weird if you think of it!
(check
    (compose-with-digits 1 "12" "449" "")
  => "12.4")

;;Rounding 55 is done to the nearest even which is 60.
(check
    (compose-with-digits 2 "12" "455" "")
  => "12.46")

;;Rounding a string of 5 is done like this:
;;
;; 12.455555 -> 12.45556 -> 12.4556 -> 12.456 -> 12.46 -> 12.5
;;
(check
    (compose-with-digits 1 "12" "455" "")
  => "12.5")

(check
    (compose-with-digits 1 "12" "4555" "")
  => "12.5")

(check
    (compose-with-digits 1 "12" "4555" "")
  => "12.5")

(check
    (compose-with-digits 1 "12" "45555" "")
  => "12.5")

;;; --------------------------------------------------------------------

(check
    (compose-with-digits 0 "12" "456789" "")
  => "12.")

;;Rounding 12.456789  to 1  digit in the  fractional part is  like doing
;;these steps:
;;
;; 12.456789 -> 12.45679 -> 12.4568 -> 12.457 -> 12.46 -> 12.5
;;
(check
    (compose-with-digits 1 "12" "456789" "")
  => "12.5")

(check
    (compose-with-digits 2 "12" "456789" "")
  => "12.46")

(check
    (compose-with-digits 3 "12" "456789" "")
  => "12.457")

(check
    (compose-with-digits 4 "12" "456789" "")
  => "12.4568")

(check
    (compose-with-digits 5 "12" "456789" "")
  => "12.45679")

(check
    (compose-with-digits 6 "12" "456789" "")
  => "12.456789")


;;;; rounding

;;;The following is to test a  problem in Ikarus up to checkout 1742 (at
;;;least).

(check
    (list (number->string (round (string->number "0.5")))
	  (string->number "0.5")
	  (round (string->number "0.5")))
  => '("0.0" 0.5 0.0))

(check
    (list (number->string (round (string->number "1.5")))
	  (string->number "1.5")
	  (round (string->number "1.5")))
  => '("2.0" 1.5 2.0))

(check
    (list (number->string (round (string->number "2.5")))
	  (string->number "2.5")
	  (round (string->number "2.5")))
  => '("2.0" 2.5 2.0))

(check
    (list (number->string (round (string->number "3.5")))
	  (string->number "3.5")
	  (round (string->number "3.5")))
  => '("4.0" 3.5 4.0))

(check
    (list (number->string (round (string->number "4.5")))
	  (string->number "4.5")
	  (round (string->number "4.5")))
  => '("4.0" 4.5 4.0))

(check
    (list (number->string (round (string->number "5.5")))
	  (string->number "5.5")
	  (round (string->number "5.5")))
  => '("6.0" 5.5 6.0))

(check
    (list (number->string (round (string->number "6.5")))
	  (string->number "6.5")
	  (round (string->number "6.5")))
  => '("6.0" 6.5 6.0))

(check
    (list (number->string (round (string->number "7.5")))
	  (string->number "7.5")
	  (round (string->number "7.5")))
  => '("8.0" 7.5 8.0))

(check
    (list (number->string (round (string->number "8.5")))
	  (string->number "8.5")
	  (round (string->number "8.5")))
  => '("8.0" 8.5 8.0))

(check
    (list (number->string (round (string->number "9.5")))
	  (string->number "9.5")
	  (round (string->number "9.5")))
  => '("10.0" 9.5 10.0))



;;;; done

(check-report)

;;; end of file
