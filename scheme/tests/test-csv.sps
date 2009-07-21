;;;
;;;Part of: Nausicaa/Scheme
;;;Contents: tests for csv
;;;Date: Mon Jul 20, 2009
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


(import (nausicaa)
  (checks)
  (silex lexer)
  (csv strings-lexer)
  (csv unquoted-data-lexer)
  (csv))

(check-set-mode! 'report-failed)
(display "*** testing csv\n")


(parameterise ((check-test-name 'strings-lexer))

  (define (tokenise/list string)
    (let* ((IS	(lexer-make-IS :string string :counters 'all))
	   (lexer	(lexer-make-lexer csv-strings-table IS)))
      (do* ((token (lexer) (lexer))
	    (ell   '()     (cons token ell)))
	  ((not token)
	   (reverse ell)))))

  (define (tokenise/string string)
    (let* ((IS	(lexer-make-IS :string string))
	   (lexer	(lexer-make-lexer csv-strings-table IS)))
      (let-values (((port the-string) (open-string-output-port)))
	(do* ((token (lexer) (lexer)))
	    ((not token)
	     (the-string))
	  (write-char token port)))))

;;;All the test strings  must end with a \" to signal  the end of string
;;;to the strings lexer.

;;; --------------------------------------------------------------------

  (check
      (tokenise/list "\"")
    => '())

  (check
      (tokenise/list "abcd\"")
    => '(#\a #\b #\c #\d))

  (check	;quoted double-quote
      (tokenise/list "ab\"\"cd\"")
    => '(#\a #\b #\" #\c #\d))

  (check	;nested string
      (tokenise/list "ab \"\"ciao\"\" cd\"")
    => '(#\a #\b #\space #\" #\c #\i #\a #\o #\" #\space #\c #\d))

  (check	;stop reading at the ending double-quote
      (tokenise/list "ab\"cd")
    => '(#\a #\b))

  (check	;end of input before end of string
      (guard (exc (else (condition-message exc)))
	(tokenise/list "abcd"))
    => "while parsing string, found end of input before closing double-quote")

;;; --------------------------------------------------------------------

  (check
      (tokenise/string "\"")
    => "")

  (check
      (tokenise/string "abcd\"")
    => "abcd")

  (check	;quoted double-quote
      (tokenise/string "ab\"\"cd\"")
    => "ab\"cd")

  (check	;nested string
      (tokenise/string "ab \"\"ciao\"\" cd\"")
    => "ab \"ciao\" cd")

  (check	;stop reading at the ending double-quote
      (tokenise/string "ab\"cd")
    => "ab")

  (check	;end of input before end of string
      (guard (exc (else (condition-message exc)))
	(tokenise/string "abcd"))
    => "while parsing string, found end of input before closing double-quote")

  )


(parameterise ((check-test-name 'unquoted-data-lexer))

  (define (tokenise string)
    (let* ((IS		(lexer-make-IS :string string :counters 'all))
	   (lexer	(lexer-make-lexer csv-unquoted-data-table IS)))
      (do* ((token (lexer) (lexer))
	    (ell   '()     (cons token ell)))
	  ((or (not token) (eq? token 'string))
	   (reverse ell)))))

;;; --------------------------------------------------------------------

  (check
      (tokenise "alpha, beta")
    => '(#\a #\l #\p #\h #\a #\, #\space #\b #\e #\t #\a))

  (check
      (tokenise "alpha\nbeta")
    => '(#\a #\l #\p #\h #\a eol #\b #\e #\t #\a))

  (check
      (tokenise "alpha\n\nbeta")
    => '(#\a #\l #\p #\h #\a eol #\b #\e #\t #\a))

  (check
      (tokenise "alpha\n\n\n\n\nbeta")
    => '(#\a #\l #\p #\h #\a eol #\b #\e #\t #\a))

  (check
      (tokenise "alpha\rbeta")
    => '(#\a #\l #\p #\h #\a eol #\b #\e #\t #\a))

  (check
      (tokenise "alpha\r\rbeta")
    => '(#\a #\l #\p #\h #\a eol #\b #\e #\t #\a))

  (check
      (tokenise "alpha\r\r\r\r\rbeta")
    => '(#\a #\l #\p #\h #\a eol #\b #\e #\t #\a))

  (check
      (tokenise "alpha\n\r\n\n\n\r\r\rbeta")
    => '(#\a #\l #\p #\h #\a eol #\b #\e #\t #\a))

;;; --------------------------------------------------------------------

  (check ;read until the string opening
      (tokenise "alpha \"beta")
    => '(#\a #\l #\p #\h #\a #\space))


)



;; (check
;;   (lambda ()
;;     (gee-csv-tokenise ","))
;;   => '(("" "")))

;; (check
;;   (lambda ()
;;     (gee-csv-tokenise ",,,"))
;;   => '(("" "" "" "")))

;; (check
;;   (lambda ()
;;     (gee-csv-tokenise "alpha,"))
;;   => '(("alpha" "")))

;; ;; ------------------------------------------------------------

;; (check
;;   (lambda ()
;;     (gee-csv-tokenise "alpha"))
;;   => '(("alpha")))

;; (check
;;   (lambda ()
;;     (gee-csv-tokenise "alpha, beta, delta, gamma"))
;;   => '(("alpha" " beta" " delta" " gamma")))

;; (check
;;   (lambda ()
;;     (gee-csv-tokenise "alpha, beta
;; delta, gamma"))
;;   => '(("alpha" " beta")("delta" " gamma")))


;;;Tokeniser: quoting tests.

;; (check
;;   (lambda ()
;;     (gee-csv-tokenise "\"alpha\""))
;;   => '(("\"alpha\"")))

;; (check
;;   (lambda ()
;;     (gee-csv-tokenise " \" alpha	\""))
;;   => '((" \" alpha	\"")))

;; (check
;;   (lambda ()
;;     (gee-csv-tokenise "\"alpha\", beta, \"gamma\""))
;;   => '(("\"alpha\"" " beta" " \"gamma\"")))

;; (check
;;   (lambda ()
;;     (gee-csv-tokenise "\"alpha\", beta, \"
;; gamma\""))
;;   => '(("\"alpha\"" " beta" " \"
;; gamma\"")))


;; (check
;;   (lambda ()
;;     (gee-csv-tokenise "\"alpha\""))
;;   => '(("\"alpha\"")))

;; (check
;;   (lambda ()
;;     (gee-csv-tokenise "\"alp\"\"ha\""))
;;   => '(("\"alp\"\"ha\"")))

;; (check
;;   (lambda ()
;;     (gee-csv-tokenise "\"alpha, beta\", \"gamma\""))
;;   => '(("\"alpha, beta\"" " \"gamma\"")))

;; 
;; ;;; tokeniser: errors

;; (check
;;   (lambda ()
;;     (gee-csv-tokenise "alpha\""))
;;   => 'misc-error
;;   #:catch-error #t)

;; (check
;;   (lambda ()
;;     (gee-csv-tokenise "\"alpha"))
;;   => 'misc-error
;;   #:catch-error #t)

;; (check
;;   (lambda ()
;;     (gee-csv-tokenise "alp\"ha"))
;;   => 'misc-error
;;   #:catch-error #t)

;; (check
;;   (lambda ()
;;     (gee-csv-tokenise "\"alpha\" a"))
;;   => 'misc-error
;;   #:catch-error #t)

;; 
;; ;;; parser: field handling

;; (check
;;   (lambda ()
;;     (gee-csv-trim "  alpha  "))
;;   => "alpha")

;; (check
;;   (lambda ()
;;     (gee-csv-trim (format #f "~/alpha~/")))
;;   => "alpha")

;; (check
;;   (lambda ()
;;     (let ((carriage-return #\cr))
;;       (gee-csv-trim (format #f "alpha~A" carriage-return))))
;;   => "alpha")

;; (check
;;   (lambda ()
;;     (gee-csv-trim "  alpha
;;  "))
;;   => "alpha")

;; ;; ------------------------------------------------------------

;; (check
;;   (lambda ()
;;     (gee-csv-remove-quotes "alpha"))
;;   => "alpha")

;; (check
;;   (lambda ()
;;     (gee-csv-remove-quotes "al\"\"pha"))
;;   => "al\"pha")

;; (check
;;   (lambda ()
;;     (gee-csv-remove-quotes "\"alpha\""))
;;   => "alpha")

;; (check
;;   (lambda ()
;;     (gee-csv-remove-quotes "\"al\"\"pha\""))
;;   => "al\"pha")

;; (check
;;   (lambda ()
;;     (gee-csv-remove-quotes "  \"al\"\"pha\"   "))
;;   => "  al\"pha   ")

;; 
;; ;;; composer: field handling

;; (check
;;   (lambda ()
;;     (gee-csv-add-quotes "  alpha   "))
;;   => "\"  alpha   \"")

;; (check
;;   (lambda ()
;;     (gee-csv-add-quotes "  alp\"ha   "))
;;   => "\"  alp\"\"ha   \"")

;; 
;; ;; composer: document building

;; (check
;;   (lambda ()
;;     (gee-csv-compose '(("alpha" "beta" "gamma")
;; 		       ("delta" "omega" "chi"))))
;;   => "alpha,beta,gamma
;; delta,omega,chi")

;; (check
;;   (lambda ()
;;     (gee-csv-compose '(("alpha" 2 "gamma")
;; 		       ("delta" 3 "chi"))))
;;   => "alpha,2,gamma
;; delta,3,chi")


;;;; done

(check-report)

;;; end of file