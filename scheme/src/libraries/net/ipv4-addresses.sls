;;; -*- coding: utf-8-unix -*-
;;;
;;;Part of: Nausicaa/Scheme
;;;Contents: IPv4 address object type
;;;Date: Fri Jun 11, 2010
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
(library (net ipv4-addresses)
  (export

    ;; conditions
    &ipv4-address-parser-error
    make-ipv4-address-parser-error-condition
    ipv4-address-parser-error-condition?

    make-ipv4-address-parser-error-handler

    ;; lexer and parser utilities
    make-ipv4-address-lexer
    make-ipv4-address-parser
    ipv4-address-parse
    ipv4-address-prefix-parse

    ;; class
    <ipv4-address>		<ipv4-address>?
    make-<ipv4-address>
    <ipv4-address>-zeroth
    <ipv4-address>-first
    <ipv4-address>-second
    <ipv4-address>-third

    <ipv4-address>-bignum
    <ipv4-address>-string
    ;; <ipv4-address>-unspecified?
    ;; <ipv4-address>-loopback?
    ;; <ipv4-address>-multicast?
    ;; <ipv4-address>-link-local-unicast?
    ;; <ipv4-address>-global-unicast?

    <ipv4-address-prefix>	<ipv4-address-prefix>?
    <ipv4-address-prefix>-prefix-length
    <ipv4-address-prefix>-string
    )
  (import (nausicaa)
    (silex lexer)
    (net helpers ipv4-address-lexer)
    (prefix (net helpers ipv4-address-parser) parser:)
    (parser-tools lexical-token)
    (parser-tools source-location)
    )


;;;; conditions and error handlers

(define-condition &ipv4-address-parser-error
  (parent &condition))

(define make-ipv4-address-parser-error-handler
  (case-lambda
   ((who irritants)
    (make-ipv4-address-parser-error-handler who irritants make-error))
   ((who irritants condition-maker)
    (lambda (message (token <lexical-token>))
      (raise
       (condition
	(make-ipv4-address-parser-error-condition)
	(condition-maker)
	(make-who-condition who)
	(make-message-condition
	 (let (((pos <source-location>) token.location))
	   (string-append "invalid Ipv4 address input at column "
			  pos.column-string ": " message)))
	(make-irritants-condition (cons token.value irritants))))))))


;;;; lexer and parser utilities

(define-maker make-ipv4-address-lexer
  %make-ipv4-address-lexer
  ((:string	#f)
   (:port	#f)
   (:procedure	#f)))

(define (%make-ipv4-address-lexer string port proc)
  (lexer-make-lexer ipv4-address-lexer-table
		    (cond ((and string (not port) (not proc))
			   (lexer-make-IS (:string string) (:counters 'all)))
			  ((and port (not string) (not proc))
			   (lexer-make-IS (:port port) (:counters 'all)))
			  ((and proc (not string) (not port))
			   (lexer-make-IS (:procedure proc) (:counters 'all)))
			  (else
			   (syntax-violation 'make-ipv4-address-lexer
			     "invalid or missing selection of input method" #f)))))

(define (make-ipv4-address-parser who lexer irritants)
  (lambda ()
    ((parser:make-ipv4-address-parser) lexer
     (make-ipv4-address-parser-error-handler who irritants))))

(define (ipv4-address-parse the-string)
  (define who 'ipv4-address-parse)
  (define irritants (list the-string))
  (define (%error)
    (raise (condition (make-ipv4-address-parser-error-condition)
		      (make-who-condition who)
		      (make-message-condition "invalid IPv4 address string")
		      (make-irritants-condition irritants))))
  (let* ((lexer		(make-ipv4-address-lexer  (:string the-string)))
	 (parser	(make-ipv4-address-parser who lexer irritants))
	 (ell		(parser)))
    (if (= 4 (length ell))
	ell
      (%error))))

(define (ipv4-address-prefix-parse the-string)
  (define who 'ipv4-address-prefix-parse)
  (define irritants (list the-string))
  (define (%error)
    (raise (condition (make-ipv4-address-parser-error-condition)
		      (make-who-condition who)
		      (make-message-condition "invalid IPv4 address prefix string")
		      (make-irritants-condition irritants))))
  (let* ((lexer		(make-ipv4-address-lexer  (:string the-string)))
	 (parser	(make-ipv4-address-parser who lexer irritants))
	 (ell		(parser)))
    (if (= 5 (length ell))
	(let ((rell (reverse ell)))
	  (values (reverse (cdr rell)) (caar rell)))
      (%error))))


(define-class <ipv4-address>
  (protocol (lambda (make-top)
	      (lambda (addr-ell)
		(apply (make-top) #f #f addr-ell))))
  (fields (mutable cached-bignum)
	  (mutable cached-string)
	  ;; (mutable cached-unspecified?)
	  ;; (mutable cached-loopback?)
	  ;; (mutable cached-global-unicast?)
	  third second first zeroth)
  (virtual-fields bignum string
		  private?
		  loopback?
		  localhost?
		  link-local?
		  reserved?
		  test-net-1?
		  six-to-four-relay-anycast?
		  benchmark-tests?
		  test-net-2?
		  test-net-3?
		  multicast?
		  limited-broadcast?
		  )
  (nongenerative nausicaa:net:ipv4-address:<ipv4-address>))

(define (<ipv4-address>-bignum (o <ipv4-address>))
  (or o.cached-bignum
      (begin0-let ((bn (+ o.zeroth
			  (bitwise-arithmetic-shift-left o.first    8)
			  (bitwise-arithmetic-shift-left o.second   16)
			  (bitwise-arithmetic-shift-left o.third    24))))
	(set! o.cached-bignum bn))))

(define (<ipv4-address>-string (o <ipv4-address>))
  (begin0-let ((S (string-append
		   (number->string o.third ) "."
		   (number->string o.second) "."
		   (number->string o.first ) "."
		   (number->string o.zeroth))))
    (set! o.cached-string S)))

;;; --------------------------------------------------------------------

(define (<ipv4-address>-private? (o <ipv4-address>))
  (or (= 10 o.third)
      (and (= 172 o.third) (= #b00010000 (bitwise-and #b11110000 o.second)))
      (and (= 192 o.third) (= 168 o.second))))

(define (<ipv4-address>-loopback? (o <ipv4-address>))
  (= 127 o.third))

(define (<ipv4-address>-localhost? (o <ipv4-address>))
  (and (= 127 o.third)
       (=   0 o.second)
       (=   0 o.first)
       (=   1 o.zeroth)))

(define (<ipv4-address>-link-local? (o <ipv4-address>))
  (and (= 169 o.third)
       (= 254 o.second)))

(define (<ipv4-address>-reserved? (o <ipv4-address>))
  (or (and (= 192 o.third)
	   (=   0 o.second)
	   (=   0 o.first))
      (= 240 (bitwise-and #b11110000 o.third))))

(define (<ipv4-address>-test-net-1? (o <ipv4-address>))
  (and (= 192 o.third)
       (=   0 o.second)
       (=   2 o.first)))

(define (<ipv4-address>-six-to-four-relay-anycast? (o <ipv4-address>))
  (and (= 192 o.third)
       (=  88 o.second)
       (=  99 o.first)))

(define (<ipv4-address>-benchmark-tests? (o <ipv4-address>))
  (and (= 198 o.third) (= 18 (bitwise-and #b11111110 o.second))))

(define (<ipv4-address>-test-net-2? (o <ipv4-address>))
  (and (= 198 o.third)
       (=  51 o.second)
       (= 100 o.first)))

(define (<ipv4-address>-test-net-3? (o <ipv4-address>))
  (and (= 203 o.third)
       (=   0 o.second)
       (= 113 o.first)))

(define (<ipv4-address>-multicast? (o <ipv4-address>))
  (= 224 (bitwise-and #b11110000 o.third)))

(define (<ipv4-address>-limited-broadcast? (o <ipv4-address>))
  (and (= 255 o.third)
       (= 255 o.second)
       (= 255 o.first)
       (= 255 o.zeroth)))


(define-class <ipv4-address-prefix>
  (inherit <ipv4-address>)
  (protocol (lambda (make-address)
	      (lambda (addr-ell number-of-bits)
		((make-address addr-ell) number-of-bits #f))))
  (fields prefix-length
	  (mutable cached-string))
  (virtual-fields string)
  (nongenerative nausicaa:net:ipv4-address:<ipv4-address-prefix>))

(define (<ipv4-address-prefix>-string (o <ipv4-address-prefix>))
  (or o.cached-string
      (begin0-let ((S (string-append (<ipv4-address>-string o) "/"
				     (number->string o.prefix-length))))
	(set! o.cached-string S))))


;;;; done

)

;;; end of file
