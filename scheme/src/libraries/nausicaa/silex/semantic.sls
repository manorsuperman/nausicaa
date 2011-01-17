;;;
;;;Part of: Nausicaa/Scheme
;;;Contents: semantic action bindings for SILex
;;;Date: Mon Jan 17, 2011
;;;
;;;Abstract
;;;
;;;	This library  exports bindings used  in the semantic  actions of
;;;	the lexer tables of SILex itself.
;;;
;;;Copyright (c) 2001 Danny Dube' <dube@iro.umontreal.ca>
;;;
;;;Original code  by Danny Dube'.   Port to R6RS Scheme  and integration
;;;into Nausicaa by Marco Maggi.
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
(library (nausicaa silex semantic)
  (export
    ;; token record
    :tok		:tok-make
    tok?		make-tok
    get-tok-type	get-tok-line
    get-tok-column	get-tok-lexeme
    get-tok-attr	get-tok-2nd-attr

    ;; fonctions auxilliaires du lexer
    parse-escaped-char
    parse-spec-char		parse-digits-char
    parse-hex-digits-char	parse-quoted-char
    parse-ordinary-char		extract-id
    parse-id			parse-id-ref
    parse-power-m		parse-power-m-inf
    parse-power-m-n

    ;; constants
    eof-tok			hblank-tok
    vblank-tok			pipe-tok
    question-tok		plus-tok
    star-tok			lpar-tok
    rpar-tok			dot-tok
    lbrack-tok			lbrack-rbrack-tok
    lbrack-caret-tok		lbrack-minus-tok
    subst-tok			power-tok
    doublequote-tok		char-tok
    caret-tok			dollar-tok
    <<EOF>>-tok			<<ERROR>>-tok
    percent-percent-tok		id-tok
    rbrack-tok			minus-tok
    illegal-tok			class-tok
    string-tok			number-of-tokens
    newline-ch			tab-ch
    dollar-ch			minus-ch
    rbrack-ch			caret-ch
    dot-class			default-action
    default-<<EOF>>-action	default-<<ERROR>>-action
    )
  (import (rnrs)
    (only (nausicaa language extensions)
	  define-constant))


;;; Fonctions de manipulation des tokens

(define-record-type (:tok :tok-make tok?)
  (nongenerative nausicaa:silex::tok)
  (fields (immutable type		get-tok-type)
	  (immutable line		get-tok-line)
	  (immutable column		get-tok-column)
	  (immutable lexeme		get-tok-lexeme)
	  (immutable attr		get-tok-attr)
	  (immutable second-attr	get-tok-2nd-attr)))

(define (make-tok tok-type lexeme line column . attr)
  (cond ((null? attr)
	 (:tok-make tok-type line column lexeme #f         #f))
	((null? (cdr attr))
	 (:tok-make tok-type line column lexeme (car attr) #f))
	(else
	 (:tok-make tok-type line column lexeme (car attr) (cadr attr)))))


;;;; module util.scm
;;
;;Quelques definitions de constantes
;;

(define-constant eof-tok              0)
(define-constant hblank-tok           1)
(define-constant vblank-tok           2)
(define-constant pipe-tok             3)
(define-constant question-tok         4)
(define-constant plus-tok             5)
(define-constant star-tok             6)
(define-constant lpar-tok             7)
(define-constant rpar-tok             8)
(define-constant dot-tok              9)
(define-constant lbrack-tok          10)
(define-constant lbrack-rbrack-tok   11)
(define-constant lbrack-caret-tok    12)
(define-constant lbrack-minus-tok    13)
(define-constant subst-tok           14)
(define-constant power-tok           15)
(define-constant doublequote-tok     16)
(define-constant char-tok            17)
(define-constant caret-tok           18)
(define-constant dollar-tok          19)
(define-constant <<EOF>>-tok         20)
(define-constant <<ERROR>>-tok       21)
(define-constant percent-percent-tok 22)
(define-constant id-tok              23)
(define-constant rbrack-tok          24)
(define-constant minus-tok           25)
(define-constant illegal-tok         26)
; Tokens agreges
(define-constant class-tok           27)
(define-constant string-tok          28)

(define-constant number-of-tokens 29)

(define-constant newline-ch   (char->integer #\newline))
(define-constant tab-ch       (char->integer #\	))
(define-constant dollar-ch    (char->integer #\$))
(define-constant minus-ch     (char->integer #\-))
(define-constant rbrack-ch    (char->integer #\]))
(define-constant caret-ch     (char->integer #\^))

(define-constant dot-class
  (list (cons 'inf- (- newline-ch 1))
	(cons (+ newline-ch 1) 'inf+)))

(define-constant default-action
  "        (yycontinue)\n")

(define-constant default-<<EOF>>-action
  (string-append "       (eof-object)" "\n"))

(define-constant default-<<ERROR>>-action
  "       (assertion-violation #f \"invalid token\")\n")


;;;; module lexparser.scm
;;
;;Fonctions auxilliaires du lexer.
;;

(define (parse-spec-char lexeme line column)
  (make-tok char-tok lexeme line column newline-ch))

(define (parse-digits-char lexeme line column)
  (let* ((num (substring lexeme 1 (string-length lexeme)))
	 (n (string->number num)))
    (make-tok char-tok lexeme line column n)))

(define (parse-hex-digits-char lexeme line column)
  (let ((n (string->number lexeme)))
    (make-tok char-tok lexeme line column n)))

(define (parse-quoted-char lexeme line column)
  ;;This is the  original function to parse "escaped"  characters in the
  ;;string; escaped characters are the ones quoted with a backslash.
  ;;
  (let ((c (string-ref lexeme 1)))
    (make-tok char-tok lexeme line column (char->integer c))))

(define (parse-escaped-char lexeme ch line column)
  ;;This function was added to parse escaped characters in R6RS strings.
  ;;
  (make-tok char-tok lexeme line column (char->integer ch)))

(define (parse-ordinary-char lexeme line column)
  (let ((c (string-ref lexeme 0)))
    (make-tok char-tok lexeme line column (char->integer c))))

(define (extract-id s)
  (let ((len (string-length s)))
    (substring s 1 (- len 1))))

(define (parse-id lexeme line column)
  (make-tok id-tok lexeme line column (string-downcase lexeme) lexeme))

(define (parse-id-ref lexeme line column)
  (let* ((orig-name (extract-id lexeme))
	 (name (string-downcase orig-name)))
    (make-tok subst-tok lexeme line column name orig-name)))

(define (parse-power-m lexeme line column)
  (let* ((len    (string-length lexeme))
	 (substr (substring lexeme 1 (- len 1)))
	 (m      (string->number substr))
	 (range  (cons m m)))
    (make-tok power-tok lexeme line column range)))

(define (parse-power-m-inf lexeme line column)
  (let* ((len (string-length lexeme))
	 (substr (substring lexeme 1 (- len 2)))
	 (m (string->number substr))
	 (range (cons m 'inf)))
    (make-tok power-tok lexeme line column range)))

(define (parse-power-m-n lexeme line column)
  (let ((len (string-length lexeme)))
    (let loop ((comma 2))
      (if (char=? (string-ref lexeme comma) #\,)
	  (let* ((sub1  (substring lexeme 1 comma))
		 (sub2  (substring lexeme (+ comma 1) (- len 1)))
		 (m     (string->number sub1))
		 (n     (string->number sub2))
		 (range (cons m n)))
	    (make-tok power-tok lexeme line column range))
	(loop (+ comma 1))))))


;;;; done

)

;;; end of file
