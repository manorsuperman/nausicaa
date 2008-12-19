;;;
;;;Part of: Nausicaa/Uriel
;;;Contents: compatibility memory functions for Ypsilon
;;;Date: Tue Dec 16, 2008
;;;Time-stamp: <2008-12-18 17:27:44 marco>
;;;
;;;Abstract
;;;
;;;
;;;
;;;Copyright (c) 2008 Marco Maggi <marcomaggi@gna.org>
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

(library (uriel memory compat)
  (export

    platform-free			platform-malloc
    platform-calloc			platform-realloc

    memset				memmove
    memcpy				memcmp

    ;;pointers
    pointer?
    integer->pointer			pointer->integer

    ;;peekers
    pointer-ref-c-signed-char		pointer-ref-c-unsigned-char
    pointer-ref-c-signed-short		pointer-ref-c-unsigned-short
    pointer-ref-c-signed-int		pointer-ref-c-unsigned-int
    pointer-ref-c-signed-long		pointer-ref-c-unsigned-long
    pointer-ref-c-signed-long-long	pointer-ref-c-unsigned-long-long
    pointer-ref-c-float			pointer-ref-c-double
    pointer-ref-c-pointer

    ;;pokers
    pointer-set-c-char!			pointer-set-c-short!
    pointer-set-c-int!			pointer-set-c-long!
    pointer-set-c-long-long!		pointer-set-c-float!
    pointer-set-c-double!		pointer-set-c-pointer!)
  (import (core)
    (uriel ffi sizeof))


;;;; pointers

(define-record-type pointer
  (fields (immutable value)))

(define (integer->pointer value)
  (unless (integer? value)
    (assertion-violation 'integer->pointer
      "expected integer value" value))
  (make-pointer value))

(define (pointer->integer pointer)
  (unless (pointer? pointer)
    (assertion-violation 'pointer->integer
      "expected pointer value" pointer))
  (pointer-value pointer))


;;;; foreign functions

(define self (load-shared-object ""))

(define platform-free
  (let ((f (lookup-shared-object self 'free)))
    (lambda (pointer)
      (stdcall-shared-object->void f (pointer->integer pointer)))))

(define platform-malloc
  (let ((f (lookup-shared-object self 'malloc)))
    (lambda (number-of-bytes)
      (integer->pointer
       (stdcall-shared-object->intptr f number-of-bytes)))))

(define platform-realloc
  (let ((f (lookup-shared-object self 'realloc)))
    (lambda (pointer new-size)
      (integer->pointer
       (stdcall-shared-object->intptr f
				      (pointer->integer pointer)
				      new-size)))))

(define platform-calloc
  (let ((f (lookup-shared-object self 'calloc)))
    (lambda (count element-size)
      (integer->pointer
       (stdcall-shared-object->intptr f count element-size)))))

(define memset
  (let ((f (lookup-shared-object self 'memset)))
    (lambda (pointer byte-value number-of-bytes)
      (integer->pointer
       (stdcall-shared-object->intptr f
				      (pointer->integer pointer)
				      byte-value
				      number-of-bytes)))))

(define memmove
  (let ((f (lookup-shared-object self 'memmove)))
    (lambda (dst src number-of-bytes)
      (integer->pointer
       (stdcall-shared-object->intptr f
				      (pointer->integer dst)
				      (pointer->integer src)
				      number-of-bytes)))))

(define memcpy
  (let ((f (lookup-shared-object self 'memcpy)))
    (lambda (dst src number-of-bytes)
      (integer->pointer
       (stdcall-shared-object->intptr f
				      (pointer->integer dst)
				      (pointer->integer src)
				      number-of-bytes)))))

(define memcmp
  (let ((f (lookup-shared-object self 'memcmp)))
    (lambda (a b number-of-bytes)
      (integer->pointer
       (stdcall-shared-object->int f
				   (pointer->integer a)
				   (pointer->integer b)
				   number-of-bytes)))))



;;;; peekers

;;We have to  make the peekers work even when  the position is negative.
;;The  procedure MAKE-BYTEVECTOR-MAPPING accepts  2 arguments:  an exact
;;integer  representing  the memory  address,  the  number  of bytes  to
;;consider part of the bytevector.  We precompute the address+offset and
;;use the  resulting address as first  byte of the  bytevector; then the
;;size of the bytevector is just the size of the data we have to access.

(define (pointer-ref-c-signed-char pointer position)
  (bytevector-s8-ref
   (make-bytevector-mapping (+ position (pointer-value pointer))
			    sizeof-char)
   0))

(define (pointer-ref-c-unsigned-char pointer position)
  (bytevector-u8-ref
   (make-bytevector-mapping (+ position (pointer-value pointer))
			    sizeof-char)
   0))

;;; --------------------------------------------------------------------

(define (pointer-ref-c-signed-short pointer position)
  (bytevector-c-short-ref
   (make-bytevector-mapping (+ position (pointer-value pointer))
			    sizeof-short)
   0))

(define (pointer-ref-c-unsigned-short pointer position)
  (bytevector-c-unsigned-short-ref
   (make-bytevector-mapping (+ position (pointer-value pointer))
			    sizeof-short)
   0))

;;; --------------------------------------------------------------------

(define (pointer-ref-c-signed-int pointer position)
  (bytevector-c-int-ref
   (make-bytevector-mapping (+ position (pointer-value pointer))
			    sizeof-int)
   0))

(define (pointer-ref-c-unsigned-int pointer position)
  (bytevector-c-unsigned-int-ref
   (make-bytevector-mapping (+ position (pointer-value pointer))
			    sizeof-int)
   0))

;;; --------------------------------------------------------------------

(define (pointer-ref-c-signed-long pointer position)
  (bytevector-c-long-ref
   (make-bytevector-mapping (+ position (pointer-value pointer))
			    sizeof-long)
   0))

(define (pointer-ref-c-unsigned-long pointer position)
  (bytevector-c-unsigned-long-ref
   (make-bytevector-mapping (+ position (pointer-value pointer))
			    sizeof-long)
   0))

;;; --------------------------------------------------------------------

(define (pointer-ref-c-signed-long-long pointer position)
  (bytevector-s64-ref
   (make-bytevector-mapping (+ position (pointer-value pointer))
			    8)
   0 (native-endianness)))

(define (pointer-ref-c-unsigned-long-long pointer position)
  (bytevector-u64-ref
   (make-bytevector-mapping (+ position (pointer-value pointer))
			    8)
   0 (native-endianness)))

;;; --------------------------------------------------------------------

(define (pointer-ref-c-float pointer position)
  (bytevector-ieee-single-ref
   (make-bytevector-mapping (+ position (pointer-value pointer))
			    sizeof-float)
   0 (native-endianness)))

(define (pointer-ref-c-double pointer position)
  (bytevector-ieee-double-ref
   (make-bytevector-mapping (+ position (pointer-value pointer))
			    sizeof-double)
   0 (native-endianness)))

;;; --------------------------------------------------------------------

(define (pointer-ref-c-pointer pointer position)
  (integer->pointer
   (bytevector-c-void*-ref
    (make-bytevector-mapping (+ position (pointer-value pointer))
			     sizeof-pointer)
    0)))


;;;; pokers

;;We have  to make the pokers  work even when the  position is negative.
;;The  procedure MAKE-BYTEVECTOR-MAPPING accepts  2 arguments:  an exact
;;integer  representing  the memory  address,  the  number  of bytes  to
;;consider part of the bytevector.  We precompute the address+offset and
;;use the  resulting address as first  byte of the  bytevector; then the
;;size of the bytevector is just the size of the data we have to access.

(define (pointer-set-c-char! pointer position value)
  (bytevector-u8-set!
   (make-bytevector-mapping (+ position (pointer-value pointer))
			    sizeof-char)
   0 value))

(define (pointer-set-c-short! pointer position value)
  (bytevector-c-short-set!
   (make-bytevector-mapping (+ position (pointer-value pointer))
			    sizeof-short)
   0 value))

(define (pointer-set-c-int! pointer position value)
  (bytevector-c-int-set!
   (make-bytevector-mapping (+ position (pointer-value pointer))
			    sizeof-int)
   0 value))

(define (pointer-set-c-long! pointer position value)
  (bytevector-c-long-set!
   (make-bytevector-mapping (+ position (pointer-value pointer))
			    sizeof-long)
   0 value))

(define (pointer-set-c-long-long! pointer position value)
  (bytevector-s64-set!
   (make-bytevector-mapping (+ position (pointer-value pointer))
			    sizeof-long-long)
   0 value (native-endianness)))

(define (pointer-set-c-float! pointer position value)
  (bytevector-ieee-single-set!
   (make-bytevector-mapping (+ position (pointer-value pointer))
			    sizeof-float)
   0 value (native-endianness)))

(define (pointer-set-c-double! pointer position value)
  (bytevector-ieee-double-set!
   (make-bytevector-mapping (+ position (pointer-value pointer))
			    sizeof-double)
   0 value (native-endianness)))

(define (pointer-set-c-pointer! pointer position value)
  (bytevector-c-void*-set!
   (make-bytevector-mapping (+ position (pointer-value pointer))
			    sizeof-pointer)
   0 (pointer-value value)))


;;;; done

)

;;; end of file