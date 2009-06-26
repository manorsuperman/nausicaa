;;;Copyright (c) 2008, 2009 Marco Maggi <marcomaggi@gna.org>
;;;Copyright (c) 2004-2008 Yoshikatsu Fujita. All rights reserved.
;;;Copyright (c) 2004-2008 LittleWing Company Limited. All rights reserved.
;;;
;;;Redistribution and  use in source  and binary forms, with  or without
;;;modification,  are permitted provided  that the  following conditions
;;;are met:
;;;
;;;1. Redistributions  of source  code must  retain the  above copyright
;;;   notice, this list of conditions and the following disclaimer.
;;;
;;;2. Redistributions in binary form  must reproduce the above copyright
;;;   notice, this  list of conditions  and the following  disclaimer in
;;;   the  documentation  and/or   other  materials  provided  with  the
;;;   distribution.
;;;
;;;3. Neither the name of the  authors nor the names of its contributors
;;;   may  be used  to endorse  or  promote products  derived from  this
;;;   software without specific prior written permission.
;;;
;;;THIS SOFTWARE  IS PROVIDED BY THE COPYRIGHT  HOLDERS AND CONTRIBUTORS
;;;"AS IS"  AND ANY  EXPRESS OR IMPLIED  WARRANTIES, INCLUDING,  BUT NOT
;;;LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
;;;A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
;;;OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;;;SPECIAL,  EXEMPLARY,  OR CONSEQUENTIAL  DAMAGES  (INCLUDING, BUT  NOT
;;;LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
;;;DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
;;;THEORY OF  LIABILITY, WHETHER IN CONTRACT, STRICT  LIABILITY, OR TORT
;;;(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
;;;OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


;;;; setup

(library (foreign ffi compat)
  (export

    ;;shared object loading
    shared-object primitive-open-shared-object self-shared-object

    ;;interface functions
    primitive-make-c-function primitive-make-c-function/with-errno

    errno)
  (import (rename (core)
		  (shared-object-errno errno))
    (ypsilon ffi)
    (foreign ffi sizeof)
    (foreign memory))


;;;; dynamic loading

(define self-shared-object (load-shared-object ""))

(define shared-object
  (make-parameter self-shared-object))

;;In case of error this raises an exception automatically.
(define primitive-open-shared-object load-shared-object)



;;;; value normalisation: scheme -> c language

;;;The following mapping functions  are normalisators from Scheme values
;;;to values usable by the C language interface functions.

(define (assert-int value)
  (if (and (integer? value)
	   (exact? value))
      value
    (assertion-violation 'assert-int
      "expected exact integer as function argument" value)))

;; (define (assert-float value)
;;   (if (flonum? value)
;;       (flonum->float value)
;;     (assertion-violation 'assert-float
;;       "expected flonum as function argument" value)))

(define (assert-double value)
  (if (flonum? value)
      value
    (assertion-violation 'assert-double
      "expected flonum as function argument" value)))

(define (assert-string value)
  (if (string? value)
      value
    (assertion-violation 'assert-string
      "expected string as function argument" value)))

(define (assert-bytevector value)
  (if (bytevector? value)
      value
    (assertion-violation 'assert-bytevector
      "expected bytevector as function argument" value)))

(define (assert-pointer p)
  (if (pointer? p)
      (pointer->integer p)
    (assertion-violation 'assert-pointer
      "expected pointer as function argument" p)))

(define (assert-closure value)
  (if (procedure? value)
      value
    (assertion-violation 'assert-closure
      "expected procedure as function argument" value)))


;;;; values normalisation: Foreign -> Ypsilon

;;;This mapping function normalises  the C type identifiers supported by
;;;Nausicaa  to  the  identifiers  supported by  Ypsilon.   Notice  that
;;;currently there is no support for "char".
;;;
;;;Care  must  be  taken  in  selecting  types,  because:
;;;
;;;* Selecting "void*" as Ypsilon  type will cause Ypsilon to allocate a
;;;  bytevector and use as value.
;;;
;;;* Selecting "char*" as Ypsilon  type will cause Ypsilon to allocate a
;;;  string and use it as value.
;;;
(define (external->internal type)
  (case type
    ((void)
     'void)
    ((char schar signed-char uchar unsigned-char)
     'int)
    ((int signed-int ssize_t)
     'int)
    ((uint unsigned unsigned-int)
     'unsigned-int)
    ((size_t)
     'size_t)
    ((long signed-long)
     'long)
    ((ulong unsigned-long)
     'unsigned-long)
    ((double)
     'double)
    ((float)
     'float)
    ((pointer void* char* FILE*)
     'void*)
    ((callback)
     'void*)
    (else
     (assertion-violation 'external->internal
       "unknown C language type identifier" type))))

(define (select-retval-type-mapper ret-type)
  (if (eq? ret-type 'void*)
      integer->pointer
    (lambda (x) x)))

(define (select-argument-type-mapper arg-type)
  (case (external->internal arg-type)
    ((void)
     (lambda (x) x))
    ((int unsigned-int size_t long unsigned-long)
     assert-int)
;;     ((float)
;;      assert-float)
    ((double float)
     assert-double)
    ((callback)
     assert-closure)
    ((void*)
     assert-pointer)
    (else
     (assertion-violation 'select-type-mapper
       "unknown C language type identifier used for function argument" arg-type))))


;;;; interface functions, no errno

(define (primitive-make-c-function ret-type funcname arg-types)
  (let* ((ret-type		(external->internal ret-type))
	 (arg-types		(if (equal? '(void) arg-types)
				    '()
				  (map external->internal arg-types)))
	 (address		(lookup-shared-object (shared-object) funcname))
	 (closure		(make-cdecl-callout ret-type arg-types address))
	 (retval-mapper		(select-retval-type-mapper ret-type))
	 (argument-mappers	(map select-argument-type-mapper arg-types)))
    (case (length argument-mappers)
      ((0)	(lambda ()
		  (retval-mapper (closure))))
      ((1)	(let ((mapper (car argument-mappers)))
		  (lambda (arg)
		    (retval-mapper (closure (mapper arg))))))
      ((2)	(let ((mapper1 (car argument-mappers))
		      (mapper2 (cadr argument-mappers)))
		  (lambda (arg1 arg2)
		    (retval-mapper (closure (mapper1 arg1)
					    (mapper2 arg2))))))
      ((3)	(let ((mapper1 (car argument-mappers))
		      (mapper2 (cadr argument-mappers))
		      (mapper3 (caddr argument-mappers)))
		  (lambda (arg1 arg2 arg3)
		    (retval-mapper (closure (mapper1 arg1)
					    (mapper2 arg2)
					    (mapper3 arg3))))))
      ((4)	(let ((mapper1 (car argument-mappers))
		      (mapper2 (cadr argument-mappers))
		      (mapper3 (caddr argument-mappers))
		      (mapper4 (cadddr argument-mappers)))
		  (lambda (arg1 arg2 arg3 arg4)
		    (retval-mapper (closure (mapper1 arg1)
					    (mapper2 arg2)
					    (mapper3 arg3)
					    (mapper4 arg4))))))
      (else	(lambda args
		  (if (= (length args) (length argument-mappers))
		      (retval-mapper (apply closure (map (lambda (m a) (m a))
						      argument-mappers args)))
		    (assertion-violation funcname
		      (string-append "wrong number of arguments, expected "
				     (number->string (length argument-mappers)))
		      args)))))))


;;;; interface functions, with errno

(define (primitive-make-c-function/with-errno ret-type funcname arg-types)
  (let* ((ret-type		(external->internal ret-type))
	 (arg-types		(if (equal? '(void) arg-types)
				    '()
				  (map external->internal arg-types)))
	 (address		(lookup-shared-object (shared-object) funcname))
	 (closure		(make-cdecl-callout ret-type arg-types address))
	 (retval-mapper		(select-retval-type-mapper ret-type))
	 (argument-mappers	(map select-argument-type-mapper arg-types)))
    (case (length argument-mappers)
      ;;We have to use LET* here  to enforce the order of evaluation: we
      ;;want  to gather  the "errno"  value AFTER  the  foreign function
      ;;call.
      ((0)	(lambda ()
		  (let* ((retval	(begin
					  (errno 0)
					  (closure)))
			 (errval	(errno)))
			 (values retval errval))))
      ((1)	(let ((mapper (car argument-mappers)))
		  (lambda (arg)
		    (let* ((retval	(begin
					  (errno 0)
					  (retval-mapper (closure (mapper arg)))))
			   (errval	(errno)))
		      (values retval errval)))))
      ((2)	(let ((mapper1 (car argument-mappers))
		      (mapper2 (cadr argument-mappers)))
		  (lambda (arg1 arg2)
		    (let* ((retval	(begin
					  (errno 0)
					  (retval-mapper (closure (mapper1 arg1)
								  (mapper2 arg2)))))
			   (errval	(errno)))
			   (values retval errval)))))
      ((3)	(let ((mapper1 (car argument-mappers))
		      (mapper2 (cadr argument-mappers))
		      (mapper3 (caddr argument-mappers)))
		  (lambda (arg1 arg2 arg3)
		    (let* ((retval	(begin
					  (errno 0)
					  (retval-mapper (closure (mapper1 arg1)
								  (mapper2 arg2)
								  (mapper3 arg3)))))
			   (errval	(errno)))
			   (values retval errval)))))
      ((4)	(let ((mapper1 (car argument-mappers))
		      (mapper2 (cadr argument-mappers))
		      (mapper3 (caddr argument-mappers))
		      (mapper4 (cadddr argument-mappers)))
		  (lambda (arg1 arg2 arg3 arg4)
		    (let* ((retval	(begin
					  (errno 0)
					  (retval-mapper (closure (mapper1 arg1)
								  (mapper2 arg2)
								  (mapper3 arg3)
								  (mapper4 arg4)))))
			   (errval	(errno)))
			   (values retval errval)))))
      (else	(lambda args
		  (if (= (length args) (length argument-mappers))
		      (let* ((retval	(begin
					  (errno 0)
					  (retval-mapper
					   (apply closure
						  (map (lambda (m a) (m a))
						    argument-mappers args)))))
			     (errval	(errno)))
			(values retval errval))
		    (assertion-violation funcname
		      (string-append "wrong number of arguments, expected "
				     (number->string (length argument-mappers)))
		      args)))))))


;;;; done

)

;;; end of file