;;; -*- coding: utf-8-unix -*-
;;;
;;;Part of: Nausicaa/UUID
;;;Contents: platform bindings for OSSP UUID bindings
;;;Date: Tue Oct 27, 2009
;;;
;;;Abstract
;;;
;;;
;;;
;;;Copyright (c) 2009 Marco Maggi <marco.maggi-ipsu@poste.it>
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


(library (foreign uuid platform)
  (export

    ;; UUID object handling
    uuid_create
    uuid_destroy
    uuid_clone

    ;; UUID generation
    uuid_load
    uuid_make

    ;; UUID comparison
    uuid_isnil
    uuid_compare

    ;; UUID import/export
    uuid_import
    uuid_export

    ;; library utilities
    uuid_error
    uuid_version)
  (import (rnrs)
    (foreign ffi)
    (foreign uuid shared-object)
    (foreign uuid sizeof))


(define uuid_t**		'pointer)
(define uuid_t*			'pointer)
(define int*			'pointer)
(define size_t*			'pointer)

(define-c-functions ossp-uuid-shared-object

;;; UUID object handling

  (uuid_create
   (uuid_rc_t uuid_create (uuid_t**)))

  (uuid_destroy
   (uuid_rc_t uuid_destroy (uuid_t*)))

  (uuid_clone
   (uuid_rc_t uuid_clone (uuid_t* uuid_t**)))

;;; UUID generation

  (uuid_load
   (uuid_rc_t uuid_load (uuid_t* char*)))

;;; UUID comparison

  (uuid_isnil
   (uuid_rc_t uuid_isnil (uuid_t* int*)))

  (uuid_compare
   (uuid_rc_t uuid_compare (uuid_t* uuid_t* int*)))

;;; UUID import/export

  (uuid_import
   (uuid_rc_t uuid_import (uuid_t* uuid_fmt_t void* size_t)))

  (uuid_export
   (uuid_rc_t uuid_export (uuid_t* uuid_fmt_t void* size_t*)))

;;; library utilities

  (uuid_error
   (char* uuid_error (uuid_rc_t)))

  (uuid_version
   (unsigned-long uuid_version (void))))

;; Variadic functions are not supported by the FFI.
;;
(define uuid_make
  (let ((arg-2	(make-c-function* ossp-uuid-shared-object
				  uuid_rc_t uuid_make (uuid_t* unsigned-int)))
	(arg-4	(make-c-function* ossp-uuid-shared-object
				  uuid_rc_t uuid_make (uuid_t* unsigned-int uuid_t* char*))))
    (case-lambda
     ((*id mode)
      (arg-2 *id mode))
     ((*id mode uuid name)
      (arg-4 *id mode uuid name)))))


;;;; done

)

;;; end of file
