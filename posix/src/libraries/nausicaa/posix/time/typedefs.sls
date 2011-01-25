;;; -*- coding: utf-8-unix -*-
;;;
;;;Part of: Nausicaa/POSIX
;;;Contents: type definitions for time structures
;;;Date: Tue Jan 25, 2011
;;;
;;;Abstract
;;;
;;;
;;;
;;;Copyright (C) 2011 Marco Maggi <marco.maggi-ipsu@poste.it>
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
(library (nausicaa posix time typedefs)
  (export
    pointer: wrapper: mirror: malloc:
    pointer-to-tms <struct-tms> <tms>)
  (import (nausicaa)
    (nausicaa language sentinel)
    (nausicaa language makers)
    (nausicaa ffi)
    (nausicaa posix clang type-translation)
    (nausicaa posix shared-object)
    (nausicaa posix sizeof))

(define-auxiliary-syntaxes
  pointer: wrapper: mirror: malloc:)


;;;; label interface to "struct tms" pointers

(define-c-functions libnausicaa-posix
  (pointer-to-tms-tms_utime		(double nausicaa_posix_tms_utime_ref (void*)))
  (pointer-to-tms-tms_stime		(double nausicaa_posix_tms_stime_ref (void*)))
  (pointer-to-tms-tms_cutime		(double nausicaa_posix_tms_cutime_ref (void*)))
  (pointer-to-tms-tms_cstime		(double nausicaa_posix_tms_cstime_ref (void*)))
  (pointer-to-tms-tms_utime-set!	(void nausicaa_posix_tms_utime_set (void* double)))
  (pointer-to-tms-tms_stime-set!	(void nausicaa_posix_tms_stime_set (void* double)))
  (pointer-to-tms-tms_cutime-set!	(void nausicaa_posix_tms_cutime_set (void* double)))
  (pointer-to-tms-tms_cstime-set!	(void nausicaa_posix_tms_cstime_set (void* double))))

(define-label pointer-to-tms
  (custom-maker make-pointer-to-tms)
  (virtual-fields (mutable tms_stime)
		  (mutable tms_utime)
		  (mutable tms_cutime)
		  (mutable tms_cstime)))

(define-maker make-pointer-to-tms
  %make-pointer-to-tms
  ((pointer:	sentinel	(without wrapper: mirror:))
   (wrapper:	sentinel	(without pointer: mirror:))
   (mirror:	sentinel	(without pointer: wrapper:))
   (malloc:	sentinel	(mandatory))))

(define-syntax %make-pointer-to-tms
  (syntax-rules (sentinel)
    ((_ ?pointer sentinel sentinel ?malloc)
     (tms-pointer->tms-pointer ?pointer ?malloc))
    ((_ sentinel ?wrapper sentinel ?malloc)
     (tms-wrapper->tms-pointer ?wrapper ?malloc))
    ((_ sentinel sentinel ?mirror ?malloc)
     (tms-mirror->tms-pointer ?mirror ?malloc))))

(define (tms-pointer->tms-pointer (src pointer-to-tms) malloc)
  (let (((dst pointer-to-tms) (malloc (c-sizeof struct-tms))))
    (set! dst.tms_stime  src.tms_stime)
    (set! dst.tms_utime  src.tms_utime)
    (set! dst.tms_cstime src.tms_cstime)
    (set! dst.tms_cutime src.tms_cutime)
    dst))

(define (tms-wrapper->tms-pointer (wrapper <struct-tms>) malloc)
  (let (((pointer pointer-to-tms) (malloc (c-sizeof struct-tms))))
    (set! pointer.tms_stime  wrapper.tms_stime)
    (set! pointer.tms_utime  wrapper.tms_utime)
    (set! pointer.tms_cstime wrapper.tms_cstime)
    (set! pointer.tms_cutime wrapper.tms_cutime)
    pointer))

(define (tms-mirror->tms-pointer (mirror <tms>) malloc)
  (let (((pointer pointer-to-tms) (malloc (c-sizeof struct-tms))))
    (set! pointer.tms_stime  mirror.stime)
    (set! pointer.tms_utime  mirror.utime)
    (set! pointer.tms_cstime mirror.cstime)
    (set! pointer.tms_cutime mirror.cutime)
    pointer))


;;;; class wrapper for "struct tms" pointers

(define-class <struct-tms>
  (nongenerative nausicaa:posix:<struct-tms>)
  (maker ()
	 (pointer:	sentinel	(without wrapper: mirror:))
	 (wrapper:	sentinel	(without pointer: mirror:))
	 (mirror:	sentinel	(without pointer: wrapper:))
	 (malloc:	sentinel	(mandatory)))
  (maker-transformer <struct-tms>-maker)
  (fields (immutable pointer))
  (virtual-fields (mutable tms_utime)
		  (mutable tms_stime)
		  (mutable tms_cutime)
		  (mutable tms_cstime)))

(define-syntax <struct-tms>-maker
  (syntax-rules (sentinel)
    ((_ ?constructor ?pointer sentinel sentinel ?malloc)
     (tms-pointer->tms-wrapper ?constructor ?pointer ?malloc))
    ((_ ?constructor sentinel ?wrapper sentinel ?malloc)
     (tms-wrapper->tms-wrapper ?constructor ?wrapper ?malloc))
    ((_ ?constructor sentinel sentinel ?mirror ?malloc)
     (tms-mirror->tms-wrapper  ?constructor ?mirror ?malloc))))

(define (tms-pointer->tms-wrapper constructor (pointer pointer-to-tms) malloc)
  (let (((wrapper <struct-tms>) (constructor (malloc (c-sizeof struct-tms)))))
    (set! wrapper.tms_stime  pointer.tms_stime)
    (set! wrapper.tms_utime  pointer.tms_utime)
    (set! wrapper.tms_cstime pointer.tms_cstime)
    (set! wrapper.tms_cutime pointer.tms_cutime)
    wrapper))

(define (tms-wrapper->tms-wrapper constructor (src <struct-tms>) malloc)
  (let (((dst <struct-tms>) (constructor (malloc (c-sizeof struct-tms)))))
    (set! dst.tms_stime  src.tms_stime)
    (set! dst.tms_utime  src.tms_utime)
    (set! dst.tms_cstime src.tms_cstime)
    (set! dst.tms_cutime src.tms_cutime)
    dst))

(define (tms-mirror->tms-wrapper constructor (mirror <tms>) malloc)
  (let (((wrapper <struct-tms>) (constructor (malloc (c-sizeof struct-tms)))))
    (set! wrapper.tms_stime  mirror.stime)
    (set! wrapper.tms_utime  mirror.utime)
    (set! wrapper.tms_cstime mirror.cstime)
    (set! wrapper.tms_cutime mirror.cutime)
    wrapper))

(define-syntax <struct-tms>-tms_utime
  (syntax-rules ()
    ((_ ?pointer)
     (pointer-to-tms-tms_utime (<struct-tms>-pointer ?pointer)))))

(define-syntax <struct-tms>-tms_utime-set!
  (syntax-rules ()
    ((_ ?pointer ?value)
     (pointer-to-tms-tms_utime-set! (<struct-tms>-pointer ?pointer) ?value))))

(define-syntax <struct-tms>-tms_stime
  (syntax-rules ()
    ((_ ?pointer)
     (pointer-to-tms-tms_stime (<struct-tms>-pointer ?pointer)))))

(define-syntax <struct-tms>-tms_stime-set!
  (syntax-rules ()
    ((_ ?pointer ?value)
     (pointer-to-tms-tms_stime-set! (<struct-tms>-pointer ?pointer) ?value))))

(define-syntax <struct-tms>-tms_cutime
  (syntax-rules ()
    ((_ ?pointer)
     (pointer-to-tms-tms_cutime (<struct-tms>-pointer ?pointer)))))

(define-syntax <struct-tms>-tms_cutime-set!
  (syntax-rules ()
    ((_ ?pointer ?value)
     (pointer-to-tms-tms_cutime-set! (<struct-tms>-pointer ?pointer) ?value))))

(define-syntax <struct-tms>-tms_cstime
  (syntax-rules ()
    ((_ ?pointer)
     (pointer-to-tms-tms_cstime (<struct-tms>-pointer ?pointer)))))

(define-syntax <struct-tms>-tms_cstime-set!
  (syntax-rules ()
    ((_ ?pointer ?value)
     (pointer-to-tms-tms_cstime-set! (<struct-tms>-pointer ?pointer) ?value))))


;;;; class mirror for "struct tms"

(define-class <tms>
  (nongenerative nausicaa:posix:<tms>)
  (maker ()
	 (pointer:	sentinel	(without wrapper: mirror:))
	 (wrapper:	sentinel	(without pointer: mirror:))
	 (mirror:	sentinel	(without pointer: wrapper:)))
  (maker-transformer <tms>-maker)
  (fields (mutable utime)
	  (mutable stime)
	  (mutable cutime)
	  (mutable cstime)))

(define-syntax <tms>-maker
  (syntax-rules (sentinel)
    ((_ ?constructor ?pointer sentinel sentinel)
     (tms-pointer->tms-mirror ?constructor ?pointer))
    ((_ ?constructor sentinel ?wrapper sentinel)
     (tms-wrapper->tms-mirror ?constructor ?wrapper))
    ((_ ?constructor sentinel sentinel ?mirror)
     (tms-mirror->tms-mirror  ?constructor ?mirror))))

(define (tms-pointer->tms-mirror constructor (pointer pointer-to-tms))
  (constructor pointer.tms_stime
	       pointer.tms_utime
	       pointer.tms_cstime
	       pointer.tms_cutime))

(define (tms-wrapper->tms-mirror constructor (wrapper <struct-tms>))
  (constructor wrapper.tms_stime
	       wrapper.tms_utime
	       wrapper.tms_cstime
	       wrapper.tms_cutime))

(define (tms-mirror->tms-mirror constructor (mirror <tms>))
  (constructor mirror.stime
	       mirror.utime
	       mirror.cstime
	       mirror.cutime))


;;;; done

)

;;; end of file
