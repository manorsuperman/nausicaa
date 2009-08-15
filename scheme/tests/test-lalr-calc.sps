;;;
;;;Part of: Nausicaa/Scheme
;;;Contents: tests for (lalr), calulator example
;;;Date: Thu Jul 16, 2009
;;;
;;;Abstract
;;;
;;;	Simple  calculator in  Scheme.  This  file holds  tests  for the
;;;	calculator example in the original distribution of Lalr-scm.
;;;
;;;	  The lexer and parser libraries used in this file are generated
;;;	by the script "make-lalr-calc.sps".
;;;
;;;Copyright (c) 2009 Marco Maggi <marcomaggi@gna.org>
;;;Copyright (c) 2004 Dominique Boucher
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
  (silex lexer)
  (calc-parser)
  (calc-parser-helper)
  (calc-parser-lexer)
  (checks))

(check-set-mode! 'report-failed)
(display "*** testing lalr calculator\n")

(define (error-handler message token)
  (error #f
    (if (not (lexical-token? token))
	message
      (let* ((position	(lexical-token-source token))
	     (line	(source-location-line position))
	     (column	(source-location-column position)))
	(string-append message
		       " line " (if line (number->string line) "unknown")
		       " column " (if column (number->string column) "unknown"))))
    token))


(parameterise ((check-test-name	'expressions))

  (define (doit string)
    (let* ((IS		(lexer-make-IS :string string :counters 'all))
	   (lexer	(lexer-make-lexer calc-parser-lexer-table IS))
	   (parser	(make-calc-parser)))
      (parameterise ((table-of-variables    (make-eq-hashtable))
		     (evaluated-expressions '()))
	(let ((v (parser lexer error-handler #f)))
	  `((return-value ,v)
	    (expressions  ,(evaluated-expressions)))))))

  (check
      (doit "1\n")
    => '((return-value 1)
	 (expressions  (1))))

  (check
      (doit "-1\n")
    => '((return-value -1)
	 (expressions  (-1))))

  (check
      (doit "1 + 2 + 4 * 3 \n a = 2 \n a * 3 \n")
    => '((return-value 6)
	 (expressions  (6 15))))

  (check
      (doit "sin(1.2)\n")
    => `((return-value ,(sin 1.2))
	 (expressions  (,(sin 1.2)))))

  (check
      (doit "atan(1.2, 0.5)\n")
    => `((return-value ,(atan 1.2 0.5))
	 (expressions  (,(atan 1.2 0.5)))))

  )


(parameterise ((check-test-name	'retval))

  (define (doit string)
    (let* ((IS		(lexer-make-IS :string string :counters 'all))
	   (lexer	(lexer-make-lexer calc-parser-lexer-table IS))
	   (parser	(make-calc-parser)))
      (parameterise ((table-of-variables    (make-eq-hashtable))
		     (evaluated-expressions '()))
	(parser lexer error-handler #f))))

;;; integers

  (check (doit "1\n")	=> 1)
  (check (doit "-1\n")	=> -1)
  (check (doit "+1\n")	=> 1)

;;; reals

  (check (doit "1.1\n")		=> 1.1)
  (check (doit "-1.1\n")	=> -1.1)
  (check (doit "+1.1\n")	=> 1.1)
  (check (doit "1.1e10\n")	=> 1.1e10)
  (check (doit "1.1E10\n")	=> 1.1e10)
  (check (doit "1.1e-10\n")	=> 1.1e-10)
  (check (doit "1.1E-10\n")	=> 1.1e-10)
  (check (doit "1e10\n")	=> 1e10)
  (check (doit "1E10\n")	=> 1e10)
  (check (doit "1e-10\n")	=> 1e-10)
  (check (doit "1E-10\n")	=> 1e-10)

  (check (doit ".0\n")		=> 0.0)
  (check (doit "-.0\n")		=> -0.0)
  (check (doit "0.\n")		=> 0.0)

;;; complexes

  (check (doit "1i\n")		(=> =) +1i)
  (check (doit "-1i\n")		(=> =) -1i)
  (check (doit "+1.1i\n")	(=> =) +1.1i)
  (check (doit "-1.1i\n")	(=> =) -1.1i)
  (check (doit "+.1i\n")	(=> =) +0.1i)
  (check (doit "-.1i\n")	(=> =) -0.1i)

;;; nan and infinity

  (check (doit "+nan.0\n")	=> +nan.0)
  (check (doit "-nan.0\n")	=> +nan.0)
  (check (doit "+inf.0\n")	=> +inf.0)
  (check (doit "-inf.0\n")	=> -inf.0)

;;; arithmetic operators

  (check (doit "1+2\n")		=> 3)
  (check (doit "1+2+3\n")	=> 6)
  (check (doit "1+2-3\n")	=> 0)
  (check (doit "1+(2+3)\n")	=> 6)
  (check (doit "1+(2-3)\n")	=> 0)

  (check (doit "1*1\n")		=> 1)
  (check (doit "1*2*3\n")	=> 6)
  (check (doit "1*2/3\n")	=> 2/3)
  (check (doit "1*(2*3)\n")	=> 6)
  (check (doit "1*(2/3)\n")	=> 2/3)

  (check (doit "7\\3\n")	=> 2)
  (check (doit "1%3\n")		=> 1)
  (check (doit "1^3\n")		=> 1)

;;; functions

  (check (doit "sin(1.1)\n")		=> (sin 1.1))
  (check (doit "cos(sin(1.1))\n")	=> (cos (sin 1.1)))
  (check (doit "cos(sin(1.1)+4)\n")	=> (cos (+ (sin 1.1) 4)))
  (check (doit "atan(1.1, 2)\n")	=> (atan 1.1 2))

  (check (doit "list(1, 2, 3, 4)\n")	=> (list 1 2 3 4))

  (check (doit "list(1+2, sin(2), 3, 4)\n")	=> (list 3 (sin 2) 3 4))

  (check (doit "1 < 3\n")	=> (<  1 3))
  (check (doit "1 > 3\n")	=> (>  1 3))
  (check (doit "1 <= 3\n")	=> (<= 1 3))
  (check (doit "1 >= 3\n")	=> (>= 1 3))
  (check (doit "1 == 3\n")	=> (=  1 3))

;;; --------------------------------------------------------------------

  (check
      (guard (exc (else (condition-message exc)))
	(doit "1 +\n"))
    => "syntax error, unexpected token line 1 column 4")

  (check
      (guard (exc (else (condition-message exc)))
	(doit "1 +"))
    => "unexpected end of input line 1 column 4")

  (check
      (guard (exc (else (condition-message exc)))
	(doit "1 + =\n"))
    => "syntax error, unexpected token line 1 column 5")

  )


;;;; done

(check-report)

;;; end of file
