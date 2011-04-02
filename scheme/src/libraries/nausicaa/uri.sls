;;; -*- coding: utf-8-unix -*-
;;;
;;;Part of: Nausicaa/Scheme
;;;Contents: URI handling
;;;Date: Wed Jun  2, 2010
;;;
;;;Abstract
;;;
;;;
;;;
;;;Copyright (c) 2010, 2011 Marco Maggi <marco.maggi-ipsu@poste.it>
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
(library (nausicaa uri)
  (export
    <uri> <relative-ref>

    ;; auxiliary syntaxes
    source-bytevector

    ;; conditions
    &parser-error
    make-parser-error-condition			parser-error-condition?
    condition-parser-error/offset)
  (import (nausicaa)
    (nausicaa uri conditions)
    (prefix (nausicaa uri low) low.))


;;;; helpers

(define-auxiliary-syntaxes
  source-bytevector)

(define-inline (integer->ascii-hex n)
  (if (<= 0 n 9)
      (+ 48 n)	      ;48 = #\0
    (+ 65 (- n 10)))) ;65 = #\A


(define-class <uri>
  (nongenerative nausicaa:uri:<uri>)

  (maker ()
	 (source-bytevector	#f))

  (protocol
   (lambda (make-top)
     (lambda (source-bytevector)
       (let-values (((scheme authority userinfo host-type host port path-type path query fragment)
		     (low.parse-uri (open-bytevector-input-port source-bytevector))))
	 (unless scheme
	   (raise (condition (make-parser-error-condition 0)
			     (make-who-condition 'make-<uri>)
			     (make-message-condition "missing mandatory scheme component in URI")
			     (make-irritants-condition (list source-bytevector)))))
	 ((make-top) scheme authority
	  (and userinfo (low.percent-decode userinfo))
	  host-type (if (eq? host-type 'reg-name)
			(low.percent-decode host)
		      host)
	  port path-type (map (lambda (p)
				(low.percent-decode p))
			   path)
	  (and query (low.percent-decode query))
	  (and fragment (low.percent-decode fragment)))))))

   (fields (mutable scheme)
	   (mutable authority)
	   (mutable userinfo)
	   (mutable host-type)
	   (mutable host)
	   (mutable port)
	   (mutable path-type)
	   (mutable path)
	   (mutable query)
	   (mutable fragment))

  (virtual-fields (immutable string)
		  (immutable bytevector)))


(define (<uri>-string (o <uri>))
  (low.to-string o.bytevector))

(define (<uri>-bytevector (o <uri>))
  (define who '<uri>-bytevector)
  (receive (port getter)
      (open-bytevector-output-port)
    (define-inline (%put-bv ?thing)
      (put-bytevector port ?thing))
    (define-inline (%put-u8 ?thing)
      (put-u8 port ?thing))

    (%put-bv o.scheme)
    (%put-u8 58) ;58 = #\:

    (let ((authority (receive (authority-port authority-getter)
			 (open-bytevector-output-port)
		       (define-inline (%put-bv ?thing)
			 (put-bytevector authority-port ?thing))
		       (define-inline (%put-u8 ?thing)
			 (put-u8 authority-port ?thing))
		       (when o.userinfo
			 (%put-bv (low.percent-encode o.userinfo))
			 (%put-u8 64)) ;64 = #\@
		       (case o.host-type
			 ((reg-name)
			  (%put-bv (low.percent-encode o.host)))
			 ((ipv4-address)
			  (%put-bv (car o.host)))
			 ((ipv6-address)
			  (%put-u8 91) ;91 = #\[
			  (%put-bv (car o.host))
			  (%put-u8 93)) ;93 = #\]
			 ((ipvfuture)
			  (%put-u8 91)	;91 = #\[
			  (%put-u8 118) ;118 = #\v
			  (%put-u8 (integer->ascii-hex (car o.host)))
			  (%put-bv (cdr o.host))
			  (%put-u8 93)) ;93 = #\]
			 (else
			  (assertion-violation who "invalid host type" o o.host-type)))
		       (when o.port
			 (%put-u8 58) ;58 = #\:
			 (%put-bv o.port))
		       (authority-getter))))
      (when (or (not (zero? (bytevector-length authority)))
		(memq o.path-type '(path-abempty path-empty)))
	(%put-u8 47) ;47 = #\/
	(%put-u8 47) ;47 = #\/
	(%put-bv authority)))

    (unless (null? o.path)
      (let ((first	(car o.path))
	    (rest	(cdr o.path)))
	(case o.path-type
	  ((path-abempty path-absolute)
	   (%put-u8 47) ;47 = /
	   (%put-bv first))
	  ((path-rootless)
	   (%put-bv first))
	  (else
	   (assertion-violation who "invalid path type" o o.path-type)))
	(for-each (lambda (bv)
		    (%put-u8 47) ;47 = /
		    (%put-bv bv))
	  rest)))

    (when o.query
      (%put-u8 63) ;63 = ?
      (%put-bv (low.percent-encode o.query)))

    (when o.fragment
      (%put-u8 35) ;35 = #
      (%put-bv (low.percent-encode o.fragment)))

    (getter)))


(define-class <relative-ref>
  (nongenerative nausicaa:uri:<relative-ref>)

  (maker ()
	 (source-bytevector	#f))

  (protocol
   (lambda (make-top)
     (lambda (source-bytevector)
       (let-values (((authority userinfo host-type host port path-type path query fragment)
		     (low.parse-relative-ref (open-bytevector-input-port source-bytevector))))
	 ((make-top) authority
	  (and userinfo (low.percent-decode userinfo))
	  host-type (if (eq? host-type 'reg-name)
			(low.percent-decode host)
		      host)
	  port path-type (map (lambda (p)
				(low.percent-decode p))
			   path)
	  (and query (low.percent-decode query))
	  (and fragment (low.percent-decode fragment)))))))

   (fields (mutable authority)
	   (mutable userinfo)
	   (mutable host-type)
	   (mutable host)
	   (mutable port)
	   (mutable path-type)
	   (mutable path)
	   (mutable query)
	   (mutable fragment))

  (virtual-fields (immutable string)
		  (immutable bytevector)))


(define (<relative-ref>-string (o <relative-ref>))
  (low.to-string o.bytevector))

(define (<relative-ref>-bytevector (o <relative-ref>))
  (define who '<relative-ref>-bytevector)
  (receive (port getter)
      (open-bytevector-output-port)
    (define-inline (%put-bv ?thing)
      (put-bytevector port ?thing))
    (define-inline (%put-u8 ?thing)
      (put-u8 port ?thing))

    (let ((authority (receive (authority-port authority-getter)
			 (open-bytevector-output-port)
		       (define-inline (%put-bv ?thing)
			 (put-bytevector authority-port ?thing))
		       (define-inline (%put-u8 ?thing)
			 (put-u8 authority-port ?thing))
		       (when o.userinfo
			 (%put-bv (low.percent-encode o.userinfo))
			 (%put-u8 64)) ;64 = #\@
		       (case o.host-type
			 ((reg-name)
			  (%put-bv (low.percent-encode o.host)))
			 ((ipv4-address)
			  (%put-bv (car o.host)))
			 ((ipv6-address)
			  (%put-u8 91) ;91 = #\[
			  (%put-bv (car o.host))
			  (%put-u8 93)) ;93 = #\]
			 ((ipvfuture)
			  (%put-u8 91)	;91 = #\[
			  (%put-u8 118) ;118 = #\v
			  (%put-u8 (integer->ascii-hex (car o.host)))
			  (%put-bv (cdr o.host))
			  (%put-u8 93)) ;93 = #\]
			 (else
			  (assertion-violation who "invalid host type" o o.host-type)))
		       (when o.port
			 (%put-u8 58) ;58 = #\:
			 (%put-bv o.port))
		       (authority-getter))))
      (when (or (not (zero? (bytevector-length authority)))
		(memq o.path-type '(path-abempty path-empty)))
	(%put-u8 47) ;47 = #\/
	(%put-u8 47) ;47 = #\/
	(%put-bv authority)))

    (unless (null? o.path)
      (let ((first	(car o.path))
	    (rest	(cdr o.path)))
	(case o.path-type
	  ((path-abempty path-absolute)
	   (%put-u8 47) ;47 = /
	   (%put-bv first))
	  ((path-noscheme)
	   (%put-bv first))
	  (else
	   (assertion-violation who "invalid path type" o o.path-type)))
	(for-each (lambda (bv)
		    (%put-u8 47) ;47 = /
		    (%put-bv bv))
	  rest)))

    (when o.query
      (%put-u8 63) ;63 = ?
      (%put-bv (low.percent-encode o.query)))

    (when o.fragment
      (%put-u8 35) ;35 = #
      (%put-bv (low.percent-encode o.fragment)))

    (getter)))


;;;; done

)

;;; end of file
