;;; -*- coding: utf-8-unix -*-
;;;
;;;Part of: Nausicaa/Scheme
;;;Contents: tests for IPv6 address object
;;;Date: Wed Jun  9, 2010
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


(import (nausicaa)
  (net ipv6-addresses)
  (silex lexer)
  (parser-tools lexical-token)
  (parser-tools source-location)
  (net helpers ipv6-address-lexer)
  (prefix (net helpers ipv6-address-parser) parser:)
  (checks))

(check-set-mode! 'report-failed)
(display "*** testing net IPv6 address\n")


(parametrise ((check-test-name	'lexing))

  (define (tokenise-address string)
    (let* ((IS		(lexer-make-IS (:string string) (:counters 'all)))
	   (lexer	(lexer-make-lexer ipv6-address-lexer-table IS))
	   (out		'()))
      (define (push-token! (T <lexical-token>))
	(set-cons! out (cons T.category T.value)))
      (do ((token (lexer) (lexer)))
	  ((<lexical-token>?/special token)
	   (push-token! token)
	   (reverse out))
;;;(write token)(newline)
	(push-token! token))
      ))

  (define eoi `(*eoi* . ,(eof-object)))

;;; --------------------------------------------------------------------

  (check
      (tokenise-address "1:2:3:4:5:6:7:8")
    => `((NUMBER . "1")
	 (COLON  . #\:)
	 (NUMBER . "2")
	 (COLON  . #\:)
	 (NUMBER . "3")
	 (COLON  . #\:)
	 (NUMBER . "4")
	 (COLON  . #\:)
	 (NUMBER . "5")
	 (COLON  . #\:)
	 (NUMBER . "6")
	 (COLON  . #\:)
	 (NUMBER . "7")
	 (COLON  . #\:)
	 (NUMBER . "8")
	 ,eoi))

  (check
      (tokenise-address "F:Zciao")
    => '((NUMBER . "F")
	 (COLON  . #\:)
	 (*lexer-error* . "Zciao")))

;;; --------------------------------------------------------------------

  (check
      (tokenise-address "1")
    => `((NUMBER . "1")
	 ,eoi))

  (check
      (tokenise-address "10")
    => `((NUMBER . "10")
	 ,eoi))

  (check
      (tokenise-address "100")
    => `((NUMBER . "100")
	 ,eoi))

  (check
      (tokenise-address "190")
    => `((NUMBER . "190")
	 ,eoi))

  (check
      (tokenise-address "210")
    => `((NUMBER . "210")
	 ,eoi))

  (check
      (tokenise-address "250")
    => `((NUMBER . "250")
	 ,eoi))

  (check
      (tokenise-address "255")
    => `((NUMBER . "255")
	 ,eoi))

  (check
      (tokenise-address "256")
    => `((NUMBER . "256")
	 ,eoi))

  (check
      (tokenise-address "1:2:3:4:5.6.7.8")
    => `((NUMBER . "1")
	 (COLON  . #\:)
	 (NUMBER . "2")
	 (COLON  . #\:)
	 (NUMBER . "3")
	 (COLON  . #\:)
	 (NUMBER . "4")
	 (COLON  . #\:)
	 (NUMBER . "5")
	 (DOT    . #\.)
	 (NUMBER . "6")
	 (DOT    . #\.)
	 (NUMBER . "7")
	 (DOT    . #\.)
	 (NUMBER . "8")
	 ,eoi))

  (check
      (tokenise-address "a:b:c:d:5.6.7.8")
    => `((NUMBER . "a")
	 (COLON  . #\:)
	 (NUMBER . "b")
	 (COLON  . #\:)
	 (NUMBER . "c")
	 (COLON  . #\:)
	 (NUMBER . "d")
	 (COLON  . #\:)
	 (NUMBER . "5")
	 (DOT    . #\.)
	 (NUMBER . "6")
	 (DOT    . #\.)
	 (NUMBER . "7")
	 (DOT    . #\.)
	 (NUMBER . "8")
	 ,eoi))

  #t)


(parametrise ((check-test-name	'parsing))

  (define-condition &parser-error
    (parent &assertion))

  (define (make-ipv6-address-parser-error-handler who string)
    (lambda (message (token <lexical-token>))
      (raise
       (condition
	(make-parser-error-condition)
	(make-who-condition who)
	(make-message-condition
	 (let (((pos <source-location>) token.location))
	   (string-append "invalid IPv6 address input at column "
	 		  pos.column-string ": " message)))
	(make-irritants-condition (list string token.value))))))

  (define (parse-address string)
    (let* ((IS		(lexer-make-IS (:string string) (:counters 'all)))
	   (lexer	(lexer-make-lexer ipv6-address-lexer-table IS))
	   (parser	(parser:make-ipv6-address-parser)))
      (parser lexer (make-ipv6-address-parser-error-handler 'parse-address string))))

;;; --------------------------------------------------------------------
;;; plain addresses

  (check
      (parse-address "1:2:3:4:5:6:7:8")
    => '(1 2 3 4 5 6 7 8))

;;; --------------------------------------------------------------------
;;; compressed format (omitting zeros)

  (check
      (parse-address "::1")
    => '(#f 1))

  (check
      (parse-address "1::")
    => '(1 #f))

  (check
      (parse-address "1::2")
    => '(1 #f 2))

  (check
      (parse-address "1:2::3")
    => '(1 2 #f 3))

  (check
      (parse-address "1::2:3")
    => '(1 #f 2 3))

  (check
      (parse-address "1:2::3:4")
    => '(1 2 #f 3 4))

  (check
      (parse-address "1:2:3::4:5:6")
    => '(1 2 3 #f 4 5 6))

;;; --------------------------------------------------------------------
;;; IPv4 tail address

  (check
      (parse-address "::192.168.99.1")
    => '(#f #xC0A8 #x6301))

  (check
      (parse-address "1:2:3:4:172.30.67.254")
    => '(1 2 3 4 #xac1e #x43fe))

  (check
      (parse-address "1:2:3:4::172.30.67.254")
    => '(1 2 3 4 #f #xac1e #x43fe))

  (check
      (parse-address "::1:2:3:4:172.30.67.254")
    => '(#f 1 2 3 4 #xac1e #x43fe))

  (check
      (parse-address "1:2::3:4:172.30.67.254")
    => '(1 2 #f 3 4 #xac1e #x43fe))

  (check
      (parse-address "::ffff:192.168.99.1")
    => '(#f #xFFFF #xC0A8 #x6301))

;;; --------------------------------------------------------------------
;;; prefix, compressed format (omitting zeros)

  (check
      (parse-address "::1/60")
    => '(#f 1 (60)))

  (check
      (parse-address "1::/60")
    => '(1 #f (60)))

  (check
      (parse-address "1::2/60")
    => '(1 #f 2 (60)))

  (check
      (parse-address "1:2::3/60")
    => '(1 2 #f 3 (60)))

  (check
      (parse-address "1::2:3/60")
    => '(1 #f 2 3 (60)))

  (check
      (parse-address "1:2::3:4/60")
    => '(1 2 #f 3 4 (60)))

  (check
      (parse-address "1:2:3::4:5:6/60")
    => '(1 2 3 #f 4 5 6 (60)))

;;; --------------------------------------------------------------------
;;; prefix, IPv4 tail address

  (check
      (parse-address "::192.168.99.1/60")
    => '(#f #xC0A8 #x6301 (60)))

  (check
      (parse-address "1:2:3:4:172.30.67.254/60")
    => '(1 2 3 4 #xac1e #x43fe (60)))

  (check
      (parse-address "1:2:3:4::172.30.67.254/60")
    => '(1 2 3 4 #f #xac1e #x43fe (60)))

  (check
      (parse-address "::1:2:3:4:172.30.67.254/60")
    => '(#f 1 2 3 4 #xac1e #x43fe (60)))

  (check
      (parse-address "1:2::3:4:172.30.67.254/60")
    => '(1 2 #f 3 4 #xac1e #x43fe (60)))

  (check
      (parse-address "::ffff:192.168.99.1/60")
    => '(#f #xFFFF #xC0A8 #x6301 (60)))

;;; --------------------------------------------------------------------
;;; errors

  (check
      (guard (E ((parser-error-condition? E)
;;;(display (condition-message E))(newline)
		 #t)
		(else #f))
	(parse-address "1,"))
    => #t)

  (check
      (guard (E ((parser-error-condition? E)
;;;(display (condition-message E))(newline)
		 #t)
		(else #f))
	(parse-address "1::2::3"))
    => #t)

  (check
      (guard (E ((parser-error-condition? E)
;;;(display (condition-message E))(newline)
		 #t)
		(else #f))
	(parse-address "1::2::"))
    => #t)

  (check
      (guard (E ((parser-error-condition? E)
;;;(display (condition-message E))(newline)
		 #t)
		(else #f))
	(parse-address "::2::3"))
    => #t)

  #t)


(parametrise ((check-test-name	'utilities))

  (check
      (call-with-values
	  (lambda ()
	    (ipv6-address-parsed-list-split '(1 2 3 4 5)))
	list)
    => '((1 2 3 4 5) #f))

  (check
      (call-with-values
	  (lambda ()
	    (ipv6-address-parsed-list-split '(1 2 3 4 5 (60))))
	list)
    => '((1 2 3 4 5) 60))

  (check
      (call-with-values
	  (lambda ()
	    (ipv6-address-parsed-list-split '(1 (60))))
	list)
    => '((1) 60))

;;; --------------------------------------------------------------------

  (check
      (ipv6-address-parsed-list-expand '(1 2 3 4 5 6 7 8))
    => '(1 2 3 4 5 6 7 8))

  (check
      (ipv6-address-parsed-list-expand '(#f 2 3 4 5 6 7 8))
    => '(0 2 3 4 5 6 7 8))

  (check
      (ipv6-address-parsed-list-expand '(1 2 3 #f 5 6 7 8))
    => '(1 2 3 0 5 6 7 8))

  (check
      (ipv6-address-parsed-list-expand '(1 2 3 4 5 6 7 #f))
    => '(1 2 3 4 5 6 7 0))

  (check
      (ipv6-address-parsed-list-expand '(1 2 #f 6 7 8))
    => '(1 2 0 0 0 6 7 8))

  (check
      (ipv6-address-parsed-list-expand '(#f 4 5 6 7 8))
    => '(0 0 0 4 5 6 7 8))

  (check
      (ipv6-address-parsed-list-expand '(1 2 3 4 5 #f))
    => '(1 2 3 4 5 0 0 0))

  (check
      (ipv6-address-parsed-list-expand '(1 2 3 4 5 6 7 8 9))
    => #f)

  (check
      (ipv6-address-parsed-list-expand '(1 2 3 4 5 6 7 8 #f))
    => #f)

;;; --------------------------------------------------------------------

  (check
      (ipv6-address-parsed-list-validate-prefix 60 '(1 2 3 4 0 0 0 0))
    => #t)

  (check
      (ipv6-address-parsed-list-validate-prefix (* 16 7) '(1 2 3 4 0 0 0 0))
    => #t)

  (check
      (ipv6-address-parsed-list-validate-prefix (* 16 2) '(1 2 3 4 0 0 0 0))
    => #f)

;;; --------------------------------------------------------------------

  (check
      (ipv6-address-parse "1:2:3:4:5:6:7:8")
    => '(1 2 3 4 5 6 7 8))

  (check
      (ipv6-address-parse "1:2:3::7:8")
    => '(1 2 3 0 0 0 7 8))

  (check
      (guard (E ((ipv6-address-parser-error-condition? E)
;;;(display (condition-message E))(newline)
		 #t)
		(else #f))
	(ipv6-address-parse "1,"))
    => #t)

  (check
      (guard (E ((ipv6-address-parser-error-condition? E)
;;;(display (condition-message E))(newline)
		 #t)
		(else #f))
	(ipv6-address-parse "1::2::3"))
    => #t)

  (check
      (guard (E ((ipv6-address-parser-error-condition? E)
;;;(display (condition-message E))(newline)
		 #t)
		(else #f))
	(ipv6-address-parse "1::2::"))
    => #t)

  (check
      (guard (E ((ipv6-address-parser-error-condition? E)
;;;(display (condition-message E))(newline)
		 #t)
		(else #f))
	(ipv6-address-parse "::2::3"))
    => #t)

  (check
      (guard (E ((ipv6-address-parser-error-condition? E)
;;;(display (condition-message E))(newline)
		 #t)
		(else #f))
	(ipv6-address-parse "2::3::/40"))
    => #t)

;;; --------------------------------------------------------------------

  (let ()

    (define-inline (doit str)
      (receive (addr len)
	  (ipv6-address-prefix-parse str)
	(list addr len)))

    (check
	(doit "1:2:3:4:0:0:0:0/80")
      => '((1 2 3 4 0 0 0 0) 80))

    (check
	(doit "1:2:3::/40")
      => '((1 2 3 0 0 0 0 0) 40))

    (check
	(guard (E ((ipv6-address-parser-error-condition? E)
;;;(display (condition-message E))(newline)
		   #t)
		  (else #f))
	  (doit "1,"))
      => #t)

    (check
	(guard (E ((ipv6-address-parser-error-condition? E)
;;;(display (condition-message E))(newline)
		   #t)
		  (else #f))
	  (doit "1::2::3"))
      => #t)

    (check
	(guard (E ((ipv6-address-parser-error-condition? E)
;;;(display (condition-message E))(newline)
		   #t)
		  (else #f))
	  (doit "1::2::"))
      => #t)

    (check
	(guard (E ((ipv6-address-parser-error-condition? E)
;;;(display (condition-message E))(newline)
		   #t)
		  (else #f))
	  (doit "::2::3"))
      => #t)

    #f)

  #t)


(parametrise ((check-test-name	'class))

  (check
      (let (((o <ipv6-address>) (make <ipv6-address> (ipv6-address-parse "1:2:3:4:5:6:7:8"))))
	(list o.seventh o.sixth o.fifth o.fourth
	      o.third o.second o.first o.zeroth))
    => '(1 2 3 4 5 6 7 8))

  (check
      (let (((o <ipv6-address>) (make <ipv6-address> (ipv6-address-parse "1:2:3::7:8"))))
	(list o.seventh o.sixth o.fifth o.fourth
	      o.third o.second o.first o.zeroth))
    => '(1 2 3 0 0 0 7 8))

  (check
      (let (((o <ipv6-address>) (make <ipv6-address> (ipv6-address-parse "1:2:3:4:5:6:7:8"))))
	o.bignum)
    => #x00010002000300040005000600070008)

  (check
      (let (((o <ipv6-address>) (make <ipv6-address> (ipv6-address-parse "1:2:3:4:5:6:7:8"))))
	o.string)
    => "1:2:3:4:5:6:7:8")

;;; --------------------------------------------------------------------

  (check
      (let (((o <ipv6-address>)
	     (make <ipv6-address> (ipv6-address-parse "::0"))))
	o.unspecified?)
    => #t)

  (check
      (let (((o <ipv6-address>)
	     (make <ipv6-address> (ipv6-address-parse "::1"))))
	o.unspecified?)
    => #f)

  (check
      (let (((o <ipv6-address>)
	     (make <ipv6-address> (ipv6-address-parse "::0"))))
	o.loopback?)
    => #f)

  (check
      (let (((o <ipv6-address>)
	     (make <ipv6-address> (ipv6-address-parse "::1"))))
	o.loopback?)
    => #t)

  (check
      (let (((o <ipv6-address>)
	     (make <ipv6-address> (ipv6-address-parse "FF00::"))))
	o.multicast?)
    => #t)

  (check
      (let (((o <ipv6-address>)
	     (make <ipv6-address> (ipv6-address-parse "::1"))))
	o.multicast?)
    => #f)

  (check
      (let (((o <ipv6-address>)
	     (make <ipv6-address> (ipv6-address-parse "FE80::"))))
	o.link-local-unicast?)
    => #t)

  (check
      (let (((o <ipv6-address>)
	     (make <ipv6-address> (ipv6-address-parse "::1"))))
	o.link-local-unicast?)
    => #f)

  (check
      (let (((o <ipv6-address>)
	     (make <ipv6-address> (ipv6-address-parse "FF80::"))))
	o.global-unicast?)
    => #f)

  (check
      (let (((o <ipv6-address>)
	     (make <ipv6-address> (ipv6-address-parse "1:2::"))))
	o.global-unicast?)
    => #t)

;;; --------------------------------------------------------------------

  (check
      (let (((o <ipv6-address-prefix>)
	     (receive (addr len)
		 (ipv6-address-prefix-parse "1:2:3:4::/55")
	       (make <ipv6-address-prefix> addr len))))
	(list o.seventh o.sixth o.fifth o.fourth
	      o.third o.second o.first o.zeroth
	      o.prefix-length))
    => '(1 2 3 4 0 0 0 0 55))

  (check
      (let (((o <ipv6-address-prefix>)
	     (receive (addr len)
		 (ipv6-address-prefix-parse "1:2:3:4::/50")
	       (make <ipv6-address-prefix> addr len))))
	o.string)
    => "1:2:3:4:0:0:0:0/50")

  #t)


;;;; done

(check-report)

;;; end of file
