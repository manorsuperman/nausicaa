;;;
;;;Part of: Uriel libraries for R6RS Scheme
;;;Contents: foreign function interface extensions
;;;Date: Tue Nov 18, 2008
;;;
;;;Abstract
;;;
;;;	This is the core of the "(uriel ffi)" library.
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


;;;; Setup.

(library (uriel ffi)
  (export

    ;;shared object access
    open-shared-object
    shared-object			self-shared-object

    ;;interface functions
    primitive-make-c-function		primitive-make-c-function/with-errno
    make-c-function			make-c-function/with-errno
    define-c-function			define-c-function/with-errno

    ;;foreign struct accessors
    define-c-struct-accessors
    define-c-struct-getter		define-c-struct-setter)

  (import (r6rs)
    (uriel ffi compat))



;;;; dynamic loading

(define (open-shared-object library-name)
  (primitive-open-shared-object (if (symbol? library-name)
				    (symbol->string library-name)
				  library-name)))



;;;; function interface

(define-syntax make-c-function
  (lambda (use-stx)
    ;;*WARNING* This function MUST be in  the body of the macro.  Do not
    ;;factorise it out.
    (define (quote-if-predefined-type arg-stx)
      (if (memq (syntax->datum arg-stx)
		'(void
		  char schar signed-char uchar unsigned-char
		  int signed-int ssize_t uint unsigned unsigned-int size_t
		  long signed-long ulong unsigned-long float double
		  pointer void* char* FILE* callback))
	  (list (syntax quote) arg-stx)
	arg-stx))
    (syntax-case use-stx ()
      ((_ ?ret-type ?funcname (?arg-type0 ?arg-type ...))
       (with-syntax
	   ((ret	(quote-if-predefined-type (syntax ?ret-type)))
	    (args	(cons (syntax list)
			      (map quote-if-predefined-type
				(syntax (?arg-type0 ?arg-type ...))))))
	 (syntax
	  (primitive-make-c-function ret '?funcname args)))))))

(define-syntax make-c-function/with-errno
  (lambda (use-stx)
    ;;*WARNING* This function MUST be in  the body of the macro.  Do not
    ;;factorise it out.
    (define (quote-if-predefined-type arg-stx)
      (if (memq (syntax->datum arg-stx)
		'(void
		  char schar signed-char uchar unsigned-char
		  int signed-int ssize_t uint unsigned unsigned-int size_t
		  long signed-long ulong unsigned-long float double
		  pointer void* char* FILE* callback))
	  (list (syntax quote) arg-stx)
	arg-stx))
    (syntax-case use-stx ()
      ((_ ?ret-type ?funcname (?arg-type0 ?arg-type ...))
       (with-syntax
	   ((ret	(quote-if-predefined-type (syntax ?ret-type)))
	    (args	(cons (syntax list)
			      (map quote-if-predefined-type
				(syntax (?arg-type0 ?arg-type ...))))))
	 (syntax
	  (primitive-make-c-function/with-errno ret '?funcname args)))))))

(define-syntax define-c-function
  (syntax-rules ()
    ((_ ?name (?ret-type ?funcname (?arg-type0 ?arg-type ...)))
     (define ?name
       (make-c-function
	?ret-type ?funcname (?arg-type0 ?arg-type ...))))))

(define-syntax define-c-function/with-errno
  (syntax-rules ()
    ((_ ?name (?ret-type ?funcname (?arg-type0 ?arg-type ...)))
     (define ?name
       (make-c-function/with-errno
	?ret-type ?funcname (?arg-type0 ?arg-type ...))))))



;;;; foreign structures accessors

(define-syntax define-c-struct-accessors
  (syntax-rules ()
    ((_ ?setter-name ?getter-name ?field-offset ?foreign-type-setter ?foreign-type-getter)
     (begin
       (define-syntax ?setter-name
	 (syntax-rules ()
	   ((_ struct-pointer value)
	    (?foreign-type-setter struct-pointer ?field-offset value))))
       (define-syntax ?getter-name
	 (syntax-rules ()
	   ((_ struct-pointer)
	    (?foreign-type-getter struct-pointer ?field-offset))))))))

(define-syntax define-c-struct-getter
  (syntax-rules ()
    ((_ ?getter-name ?field-offset ?foreign-type-getter)
     (define-syntax ?getter-name
       (syntax-rules ()
	 ((_ struct-pointer)
	  (?foreign-type-getter struct-pointer ?field-offset)))))))

(define-syntax define-c-struct-setter
  (syntax-rules ()
    ((_ ?setter-name ?field-offset ?foreign-type-setter)
     (define-syntax ?setter-name
       (syntax-rules ()
	 ((_ struct-pointer value)
	  (?foreign-type-setter struct-pointer ?field-offset value)))))))



;;;; done

)

;;; end of file
