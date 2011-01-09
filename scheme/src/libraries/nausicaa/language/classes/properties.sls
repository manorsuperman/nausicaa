;;; -*- coding: utf-8-unix -*-
;;;
;;;Part of: Nausicaa/Scheme
;;;Contents: definition class properties infrastructure
;;;Date: Sun Jan  9, 2011
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
(library (nausicaa language classes properties)
  (export
    struct?
    struct-list-of-supers
    struct-field-specs
    struct-virtual-field-specs
    struct-method-specs
    struct-mixins
    struct-list-of-field-tags

    make-class
    class?
    (rename (struct-list-of-supers		class-list-of-supers)
	    (struct-field-specs			class-field-specs)
	    (struct-virtual-field-specs		class-virtual-field-specs)
	    (struct-method-specs		class-method-specs)
	    (struct-mixins			class-mixins)
	    (struct-list-of-field-tags		class-list-of-field-tags))

    make-label
    label?
    (rename (struct-list-of-supers		label-list-of-supers)
	    (struct-field-specs			label-field-specs)
	    (struct-virtual-field-specs		label-virtual-field-specs)
	    (struct-method-specs		label-method-specs)
	    (struct-mixins			label-mixins)
	    (struct-list-of-field-tags		label-list-of-field-tags))

    :struct-properties
    ;; :list-of-superclasses
    ;; :list-of-field-tags
    ;; :field-specs
    ;; :virtual-field-specs
    ;; :method-specs

    ;; used by DEFINE-MIXIN and the MIXINS clause
    :mixin-clauses)
  (import (rnrs)
    (only (nausicaa language syntax-utilities) define-auxiliary-syntaxes))


(define-auxiliary-syntaxes
  :struct-properties
  :mixin-clauses)


(define-record-type struct
  (nongenerative nausicaa:language:classes:properties:struct)
  (fields (immutable list-of-supers)
	  (immutable field-specs)
	  (immutable virtual-field-specs)
	  (immutable method-specs)
	  (immutable mixins)
	  (immutable list-of-field-tags)))

(define-record-type class
  (nongenerative nausicaa:language:classes:properties:class)
  (parent struct)
  (opaque #t)
  (sealed #t))

(define-record-type label
  (nongenerative nausicaa:language:classes:properties:label)
  (parent struct)
  (opaque #t)
  (sealed #t)
  (protocol (lambda (make-st)
	      (lambda ( ;;
		  list-of-supers virtual-field-specs
		  method-specs mixins list-of-field-tags)
		((make-st list-of-supers '() virtual-field-specs
			  method-specs mixins list-of-field-tags))))))


;;;; done

)

;;; end of file
