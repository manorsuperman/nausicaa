;;;
;;;Part of: Nausicaa/Sceme
;;;Contents: tests for ffi library
;;;Date: Tue Nov 18, 2008
;;;
;;;Abstract
;;;
;;;
;;;
;;;Copyright (c) 2008-2011 Marco Maggi <marco.maggi-ipsu@poste.it>
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
  (nausicaa ffi)
  (nausicaa ffi memory)
  (nausicaa ffi cstrings)
  (nausicaa ffi errno)
  (nausicaa ffi clang type-translation)
  (nausicaa checks))

(cond-expand ((or larceny petite) (exit)) (else #f))

(check-set-mode! 'report-failed)
(display "*** testing FFI core\n")

(define-shared-object ffitest-lib 'libnausicaa-ffitest1.0.so)


(parametrise ((check-test-name	'open-shared))

  (check
      (shared-object? (open-shared-object 'libc.so.6))
    => #t)

  (check
      (guard (E ((shared-object-opening-error-condition? E)
;;;		 (write (condition-message E))(newline)
		 (list (condition-library-name E)
		       (condition-who E))))
	(open-shared-object 'ciao))
    => '("ciao" open-shared-object))

  #t)


(parametrise ((check-test-name	'lookup))

  (check
      (pointer? (lookup-shared-object libc-shared-object 'printf))
    => #t)

  (check
      (guard (E ((shared-object-lookup-error-condition? E)
;;;		 (write (condition-message E))(newline)
		 (list (condition-shared-object E)
		       (condition-foreign-symbol E)
		       (condition-who E))))
	(lookup-shared-object libc-shared-object 'ciao))
    => `(,libc-shared-object "ciao" lookup-shared-object))

  #t)


(parameterize ((check-test-name	'conditions)
	       (debugging	#f))

;;; --------------------------------------------------------------------
;;; This is used to raise a ENOENT errno error.

  (define-c-functions/with-errno libc-shared-object
    (primitive-chdir	(int chdir (char*))))

  (define (chdir directory-pathname)
    (with-compensations
      (receive (result errno)
	  (primitive-chdir (string->cstring/c directory-pathname))
	(unless (= 0 result)
	  (raise-errno-error 'chdir errno directory-pathname))
	result)))

;;; --------------------------------------------------------------------
;;; This is used to raise a EINVAL errno error.

  (define-c-functions/with-errno libc-shared-object
    (platform-pread	(int pread (int void* int int))))

  (define-syntax temp-failure-retry-minus-one
    (syntax-rules ()
      ((_ ?funcname (?primitive ?arg ...) ?irritants)
       (let loop ()
	 (receive (result errno)
	     (?primitive ?arg ...)
	   (when (= -1 result)
	     (when (= EINTR errno)
	       (loop))
	     (raise-errno-error (quote ?funcname) errno ?irritants))
	   result)))))

  (define-syntax do-pread-or-pwrite
    (syntax-rules ()
      ((_ ?funcname ?primitive ?fd ?pointer ?number-of-bytes ?offset)
       (temp-failure-retry-minus-one
	?funcname
	(?primitive ?fd ?pointer ?number-of-bytes ?offset)
	?fd))))

  (define (primitive-pread fd pointer number-of-bytes offset)
    (do-pread-or-pwrite primitive-pread
			platform-pread fd pointer number-of-bytes offset))

;;; --------------------------------------------------------------------
;;; This is used to raise a ENOEXEC errno error.

  (define-c-functions/with-errno libc-shared-object
    (platform-execv	(int execv (char* pointer))))

  (define (primitive-execv pathname args)
    (with-compensations
      (receive (result errno)
	  (platform-execv (string->cstring/c pathname)
			  (strings->argv args malloc-block/c))
	(when (= -1 result)
	  (raise-errno-error 'primitive-execv errno (list pathname args))))))

  (define primitive-execv-function
    (make-parameter primitive-execv
      (lambda (func)
	(unless (procedure? func)
	  (assertion-violation 'primitive-execv-function
	    "expected procedure as value for the PRIMITIVE-EXECV-FUNCTION parameter"
	    func))
	func)))

  (define (execv pathname args)
    ((primitive-execv-function) pathname args))

;;; --------------------------------------------------------------------
;;; This is used to raise a ENOTDIR errno error.

  (define-c-functions/with-errno libc-shared-object
    (platform-opendir	(pointer opendir (char*))))

  (define (primitive-opendir pathname)
    (with-compensations
      (receive (result errno)
	  (platform-opendir (string->cstring/c pathname))
	(when (pointer-null? result)
	  (raise-errno-error 'primitive-opendir errno pathname))
	result)))

  (define primitive-opendir-function
    (make-parameter primitive-opendir
      (lambda (func)
	(unless (procedure? func)
	  (assertion-violation 'primitive-opendir-function
	    "expected procedure as value for the PRIMITIVE-OPENDIR-FUNCTION parameter"
	    func))
	func)))

  (define (opendir pathname)
    ((primitive-opendir-function) pathname))

;;;If the raised exception has the expected "errno" value, it means that
;;;the foreign function call was performed correctly.

  (check
      (let ((dirname '/scrappy/dappy/doo))
	(guard (E (else
		   ;;(debug-print-condition "condition" E)
		   (list (errno-condition? E)
			 (condition-who E)
			 (errno-symbolic-value E))))
	  (chdir dirname)))
    => '(#t chdir ENOENT))

  (check
      (guard (E (else
		 (list (errno-condition? E)
		       (condition-who E)
		       (errno-symbolic-value E)
		       )))
	(primitive-pread 0 (integer->pointer 1234) 10 -10))
    => '(#t primitive-pread EINVAL))

  (check
      (let ((pathname '/etc/passwd))
  	(guard (E (else
		   (list (errno-condition? E)
			 (condition-who E)
			 (errno-symbolic-value E)
			 )))
  	  (execv pathname '())))
    => '(#t primitive-execv EACCES))

  (check
      (let ((pathname '/etc/passwd))
  	(guard (E ((errno-condition? E)
		   (list (condition-who E)
			 (errno-symbolic-value E))))
  	  (opendir pathname)))
    => '(primitive-opendir ENOTDIR))

  #t)


(parametrise ((check-test-name	'callouts-basic))

  (define-c-functions ffitest-lib
    (callout_int8	(int8_t nausicaa_ffitest_callout_int8 (int int8_t int)))
    (callout_int16	(int16_t nausicaa_ffitest_callout_int16 (int int16_t int)))
    (callout_int32	(int32_t nausicaa_ffitest_callout_int32 (int int32_t int)))
    (callout_int64	(int64_t nausicaa_ffitest_callout_int64 (int int64_t int)))
    (callout_char	(char nausicaa_ffitest_callout_char (int char int)))
    (callout_uchar	(unsigned-char nausicaa_ffitest_callout_uchar (int unsigned-char int)))
    (callout_short	(signed-short nausicaa_ffitest_callout_short (int signed-short int)))
    (callout_ushort	(unsigned-short nausicaa_ffitest_callout_ushort (int unsigned-short int)))
    (callout_int	(int nausicaa_ffitest_callout_int (int int int)))
    (callout_uint	(unsigned-int nausicaa_ffitest_callout_uint (int unsigned-int int)))
    (callout_long	(long nausicaa_ffitest_callout_long (int long int)))
    (callout_ulong	(unsigned-long nausicaa_ffitest_callout_ulong (int unsigned-long int)))
    (callout_llong	(long-long nausicaa_ffitest_callout_llong (int long-long int)))
    (callout_ullong	(unsigned-long-long nausicaa_ffitest_callout_ullong (int unsigned-long-long int)))
    (callout_float	(float nausicaa_ffitest_callout_float (int float int)))
    (callout_double	(double nausicaa_ffitest_callout_double (int double int)))
    (callout_pointer	(void* nausicaa_ffitest_callout_pointer (int void* int))))

  (check (callout_int8 1 2 3) => 2)
  (check (callout_int16 1 2 3) => 2)
  (check (callout_int32 1 2 3) => 2)
  (check (callout_int64 1 2 3) => 2)
  (check (integer->char (callout_char  1 (char->integer #\a) 3)) => #\a)
  (check (integer->char (callout_uchar 1 (char->integer #\a) 3)) => #\a)
  (check (callout_short 1 2 3) => 2)
  (check (callout_ushort 1 2 3) => 2)
  (check (callout_int 1 2 3) => 2)
  (check (callout_uint 1 2 3) => 2)
  (check (callout_long 1 2 3) => 2)
  (check (callout_ulong 1 2 3) => 2)
  (check (callout_llong 1 2 3) => 2)
  (check (callout_ullong 1 2 3) => 2)
  (check (callout_float 1 2.3 3) (=> (lambda (a b) (< (abs (- a b)) 1e-6))) 2.3)
  (check (callout_double 1 2.3 3) => 2.3)
  (check (pointer->integer (callout_pointer 1 (integer->pointer 2) 3)) => 2)

  #t)


(parametrise ((check-test-name	'callouts-with-errno))

  (define-c-functions/with-errno ffitest-lib
    (callout_int8	(int8_t nausicaa_ffitest_callout_int8 (int int8_t int)))
    (callout_int16	(int16_t nausicaa_ffitest_callout_int16 (int int16_t int)))
    (callout_int32	(int32_t nausicaa_ffitest_callout_int32 (int int32_t int)))
    (callout_int64	(int64_t nausicaa_ffitest_callout_int64 (int int64_t int)))
    (callout_uint8	(int8_t nausicaa_ffitest_callout_uint8 (int int8_t int)))
    (callout_uint16	(int16_t nausicaa_ffitest_callout_uint16 (int int16_t int)))
    (callout_uint32	(int32_t nausicaa_ffitest_callout_uint32 (int int32_t int)))
    (callout_uint64	(int64_t nausicaa_ffitest_callout_uint64 (int int64_t int)))
    (callout_char	(char nausicaa_ffitest_callout_char (int char int)))
    (callout_uchar	(unsigned-char nausicaa_ffitest_callout_uchar (int unsigned-char int)))
    (callout_short	(signed-short nausicaa_ffitest_callout_short (int signed-short int)))
    (callout_ushort	(unsigned-short nausicaa_ffitest_callout_ushort (int unsigned-short int)))
    (callout_int	(int nausicaa_ffitest_callout_int (int int int)))
    (callout_uint	(unsigned-int nausicaa_ffitest_callout_uint (int unsigned-int int)))
    (callout_long	(long nausicaa_ffitest_callout_long (int long int)))
    (callout_ulong	(unsigned-long nausicaa_ffitest_callout_ulong (int unsigned-long int)))
    (callout_llong	(long-long nausicaa_ffitest_callout_llong (int long-long int)))
    (callout_ullong	(unsigned-long-long nausicaa_ffitest_callout_ullong (int unsigned-long-long int)))
    (callout_float	(float nausicaa_ffitest_callout_float (int float int)))
    (callout_double	(double nausicaa_ffitest_callout_double (int double int)))
    (callout_pointer	(void* nausicaa_ffitest_callout_pointer (int void* int))))

  (check (let-values (((ret errno) (callout_int8  1 2 3))) (list ret errno)) => '(2 1))
  (check (let-values (((ret errno) (callout_int16 1 2 3))) (list ret errno)) => '(2 1))
  (check (let-values (((ret errno) (callout_int32 1 2 3))) (list ret errno)) => '(2 1))
  (check (let-values (((ret errno) (callout_int64 1 2 3))) (list ret errno)) => '(2 1))

  (check (let-values (((ret errno) (callout_uint8  1 2 3))) (list ret errno)) => '(2 1))
  (check (let-values (((ret errno) (callout_uint16 1 2 3))) (list ret errno)) => '(2 1))
  (check (let-values (((ret errno) (callout_uint32 1 2 3))) (list ret errno)) => '(2 1))
  (check (let-values (((ret errno) (callout_uint64 1 2 3))) (list ret errno)) => '(2 1))

  (check
      (let-values (((ret errno) (callout_char  1 (char->integer #\a) 3)))
	(list (integer->char ret) errno))
    => '(#\a 1))

  (check
      (let-values (((ret errno) (callout_uchar 1 (char->integer #\a) 3)))
	(list (integer->char ret) errno))
    => '(#\a 1))

  (check (let-values (((ret errno) (callout_short  1 2 3))) (list ret errno)) => '(2 1))
  (check (let-values (((ret errno) (callout_ushort 1 2 3))) (list ret errno)) => '(2 1))
  (check (let-values (((ret errno) (callout_int    1 2 3))) (list ret errno)) => '(2 1))
  (check (let-values (((ret errno) (callout_uint   1 2 3))) (list ret errno)) => '(2 1))
  (check (let-values (((ret errno) (callout_long   1 2 3))) (list ret errno)) => '(2 1))
  (check (let-values (((ret errno) (callout_ulong  1 2 3))) (list ret errno)) => '(2 1))
  (check (let-values (((ret errno) (callout_llong  1 2 3))) (list ret errno)) => '(2 1))
  (check (let-values (((ret errno) (callout_ullong 1 2 3))) (list ret errno)) => '(2 1))

  (check
      (let-values (((ret errno) (callout_float 1 2.3 3)))
	(list ret errno))
    (=> (lambda (a b)
	  (and (< (abs (- (car a) (car b))) 1e-6)
	       (= (cadr a) (cadr b)))))
    '(2.3 1))

  (check
      (let-values (((ret errno) (callout_double 1 2.3 3)))
	(list ret errno))
    => '(2.3 1))

  (check
      (let-values (((ret errno) (callout_pointer 1 (integer->pointer 2) 3)))
	(list (pointer->integer ret) errno))
    => '(2 1))

  #t)


(parametrise ((check-test-name	'callouts-pointers))

  (define-c-callouts
    (callout_int8
     (int8_t (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_int8) (int int8_t int)))
    (callout_int16
     (int16_t (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_int16) (int int16_t int)))
    (callout_int32
     (int32_t (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_int32) (int int32_t int)))
    (callout_int64
     (int64_t (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_int64) (int int64_t int)))
    (callout_uint8
     (uint8_t (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_uint8) (int uint8_t int)))
    (callout_uint16
     (uint16_t (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_uint16) (int uint16_t int)))
    (callout_uint32
     (uint32_t (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_uint32) (int uint32_t int)))
    (callout_uint64
     (uint64_t (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_uint64) (int uint64_t int)))
    (callout_char
     (char (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_char) (int char int)))
    (callout_uchar
     (unsigned-char (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_uchar)
		    (int unsigned-char int)))
    (callout_short
     (signed-short (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_short)
		   (int signed-short int)))
    (callout_ushort
     (unsigned-short (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_ushort)
		     (int unsigned-short int)))
    (callout_int
     (int (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_int) (int int int)))
    (callout_uint
     (unsigned-int (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_uint)
		   (int unsigned-int int)))
    (callout_long
     (long (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_long) (int long int)))
    (callout_ulong
     (unsigned-long (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_ulong)
		    (int unsigned-long int)))
    (callout_llong
     (long-long (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_llong) (int long-long int)))
    (callout_ullong
     (unsigned-long-long (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_ullong)
			 (int unsigned-long-long int)))
    (callout_float
     (float (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_float) (int float int)))
    (callout_double
     (double (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_double) (int double int)))
    (callout_pointer
     (void* (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_pointer) (int void* int))))

  (check (callout_int8 1 2 3) => 2)
  (check (callout_int16 1 2 3) => 2)
  (check (callout_int32 1 2 3) => 2)
  (check (callout_int64 1 2 3) => 2)
  (check (callout_uint8 1 2 3) => 2)
  (check (callout_uint16 1 2 3) => 2)
  (check (callout_uint32 1 2 3) => 2)
  (check (callout_uint64 1 2 3) => 2)
  (check (integer->char (callout_char  1 (char->integer #\a) 3)) => #\a)
  (check (integer->char (callout_uchar 1 (char->integer #\a) 3)) => #\a)
  (check (callout_short 1 2 3) => 2)
  (check (callout_ushort 1 2 3) => 2)
  (check (callout_int 1 2 3) => 2)
  (check (callout_uint 1 2 3) => 2)
  (check (callout_long 1 2 3) => 2)
  (check (callout_ulong 1 2 3) => 2)
  (check (callout_llong 1 2 3) => 2)
  (check (callout_ullong 1 2 3) => 2)
  (check (callout_float 1 2.3 3) (=> (lambda (a b) (< (abs (- a b)) 1e-6))) 2.3)
  (check (callout_double 1 2.3 3) => 2.3)
  (check (pointer->integer (callout_pointer 1 (integer->pointer 2) 3)) => 2)

  #t)


(parametrise ((check-test-name	'callouts-pointers-with-errno))

  (define-c-callouts/with-errno
    (callout_int8
     (int8_t (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_int8) (int int8_t int)))
    (callout_int16
     (int16_t (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_int16) (int int16_t int)))
    (callout_int32
     (int32_t (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_int32) (int int32_t int)))
    (callout_int64
     (int64_t (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_int64) (int int64_t int)))
    (callout_uint8
     (uint8_t (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_uint8) (int uint8_t int)))
    (callout_uint16
     (uint16_t (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_uint16) (int uint16_t int)))
    (callout_uint32
     (uint32_t (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_uint32) (int uint32_t int)))
    (callout_uint64
     (uint64_t (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_uint64) (int uint64_t int)))
    (callout_char
     (char (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_char) (int char int)))
    (callout_uchar
     (unsigned-char (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_uchar)
		    (int unsigned-char int)))
    (callout_short
     (signed-short (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_short)
		   (int signed-short int)))
    (callout_ushort
     (unsigned-short (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_ushort)
		     (int unsigned-short int)))
    (callout_int
     (int (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_int) (int int int)))
    (callout_uint
     (unsigned-int (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_uint)
		   (int unsigned-int int)))
    (callout_long
     (long (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_long) (int long int)))
    (callout_ulong
     (unsigned-long (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_ulong)
		    (int unsigned-long int)))
    (callout_llong
     (long-long (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_llong) (int long-long int)))
    (callout_ullong
     (unsigned-long-long (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_ullong)
			 (int unsigned-long-long int)))
    (callout_float
     (float (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_float) (int float int)))
    (callout_double
     (double (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_double) (int double int)))
    (callout_pointer
     (void* (lookup-shared-object ffitest-lib 'nausicaa_ffitest_callout_pointer) (int void* int))))

  (check (let-values (((ret errno) (callout_int8  1 2 3))) (list ret errno)) => '(2 1))
  (check (let-values (((ret errno) (callout_int16 1 2 3))) (list ret errno)) => '(2 1))
  (check (let-values (((ret errno) (callout_int32 1 2 3))) (list ret errno)) => '(2 1))
  (check (let-values (((ret errno) (callout_int64 1 2 3))) (list ret errno)) => '(2 1))

  (check (let-values (((ret errno) (callout_uint8  1 2 3))) (list ret errno)) => '(2 1))
  (check (let-values (((ret errno) (callout_uint16 1 2 3))) (list ret errno)) => '(2 1))
  (check (let-values (((ret errno) (callout_uint32 1 2 3))) (list ret errno)) => '(2 1))
  (check (let-values (((ret errno) (callout_uint64 1 2 3))) (list ret errno)) => '(2 1))

  (check
      (let-values (((ret errno) (callout_char  1 (char->integer #\a) 3)))
	(list (integer->char ret) errno))
    => '(#\a 1))

  (check
      (let-values (((ret errno) (callout_uchar 1 (char->integer #\a) 3)))
	(list (integer->char ret) errno))
    => '(#\a 1))

  (check (let-values (((ret errno) (callout_short  1 2 3))) (list ret errno)) => '(2 1))
  (check (let-values (((ret errno) (callout_ushort 1 2 3))) (list ret errno)) => '(2 1))
  (check (let-values (((ret errno) (callout_int    1 2 3))) (list ret errno)) => '(2 1))
  (check (let-values (((ret errno) (callout_uint   1 2 3))) (list ret errno)) => '(2 1))
  (check (let-values (((ret errno) (callout_long   1 2 3))) (list ret errno)) => '(2 1))
  (check (let-values (((ret errno) (callout_ulong  1 2 3))) (list ret errno)) => '(2 1))
  (check (let-values (((ret errno) (callout_llong  1 2 3))) (list ret errno)) => '(2 1))
  (check (let-values (((ret errno) (callout_ullong 1 2 3))) (list ret errno)) => '(2 1))

  (check
      (let-values (((ret errno) (callout_float 1 2.3 3)))
	(list ret errno))
    (=> (lambda (a b)
	  (and (< (abs (- (car a) (car b))) 1e-6)
	       (= (cadr a) (cadr b)))))
    '(2.3 1))

  (check
      (let-values (((ret errno) (callout_double 1 2.3 3)))
	(list ret errno))
    => '(2.3 1))

  (check
      (let-values (((ret errno) (callout_pointer 1 (integer->pointer 2) 3)))
	(list (pointer->integer ret) errno))
    => '(2 1))

  #t)


(parametrise ((check-test-name	'callback))

  (define-c-functions ffitest-lib
    (callback_int8	(int8_t nausicaa_ffitest_callback_int8 (callback int int8_t int)))
    (callback_int16	(int16_t nausicaa_ffitest_callback_int16 (callback int int16_t int)))
    (callback_int32	(int32_t nausicaa_ffitest_callback_int32 (callback int int32_t int)))
    (callback_int64	(int64_t nausicaa_ffitest_callback_int64 (callback int int64_t int)))
    (callback_uint8	(uint8_t nausicaa_ffitest_callback_uint8 (callback int uint8_t int)))
    (callback_uint16	(uint16_t nausicaa_ffitest_callback_uint16 (callback int uint16_t int)))
    (callback_uint32	(uint32_t nausicaa_ffitest_callback_uint32 (callback int uint32_t int)))
    (callback_uint64	(uint64_t nausicaa_ffitest_callback_uint64 (callback int uint64_t int)))
    (callback_char	(char nausicaa_ffitest_callback_char (callback int char int)))
    (callback_uchar	(unsigned-char nausicaa_ffitest_callback_uchar (callback int unsigned-char int)))
    (callback_short	(short nausicaa_ffitest_callback_short (callback int short int)))
    (callback_ushort	(unsigned-short nausicaa_ffitest_callback_ushort
					(callback int unsigned-short int)))
    (callback_int	(unsigned nausicaa_ffitest_callback_int (callback int int int)))
    (callback_uint	(unsigned nausicaa_ffitest_callback_uint (callback int unsigned-int int)))
    (callback_long	(long nausicaa_ffitest_callback_long (callback int long int)))
    (callback_ulong	(unsigned-long nausicaa_ffitest_callback_ulong (callback int unsigned-long int)))
    (callback_llong	(long-long nausicaa_ffitest_callback_llong (callback int long-long int)))
    (callback_ullong	(unsigned-long-long nausicaa_ffitest_callback_ullong
					    (callback int unsigned-long-long int)))
    (callback_float	(float nausicaa_ffitest_callback_float (callback int float int)))
    (callback_double	(double nausicaa_ffitest_callback_double (callback int double int)))
    (callback_pointer	(void* nausicaa_ffitest_callback_pointer (callback int void* int))))

  (check
      (let* ((fn (lambda (a b c) (+ a b c)))
	     (cb (make-c-callback* int8_t fn (int int8_t int))))
	(begin0
	    (callback_int8 cb 1 2 3)
	  (free-c-callback cb)))
    => (+ 1 2 3))

  (check
      (let* ((fn (lambda (a b c) (+ a b c)))
	     (cb (make-c-callback* int16_t fn (int int16_t int))))
	(begin0
	    (callback_int16 cb 1 2 3)
	  (free-c-callback cb)))
    => (+ 1 2 3))

  (check
      (let* ((fn (lambda (a b c) (+ a b c)))
	     (cb (make-c-callback* int32_t fn (int int32_t int))))
	(begin0
	    (callback_int32 cb 1 2 3)
	  (free-c-callback cb)))
    => (+ 1 2 3))

  (check
      (let* ((fn (lambda (a b c) (+ a b c)))
	     (cb (make-c-callback* int64_t fn (int int64_t int))))
	(begin0
	    (callback_int64 cb 1 2 3)
	  (free-c-callback cb)))
    => (+ 1 2 3))

  (check
      (let* ((fn (lambda (a b c) (+ a b c)))
	     (cb (make-c-callback* uint8_t fn (int uint8_t int))))
	(begin0
	    (callback_uint8 cb 1 2 3)
	  (free-c-callback cb)))
    => (+ 1 2 3))

  (check
      (let* ((fn (lambda (a b c) (+ a b c)))
	     (cb (make-c-callback* uint16_t fn (int uint16_t int))))
	(begin0
	    (callback_uint16 cb 1 2 3)
	  (free-c-callback cb)))
    => (+ 1 2 3))

  (check
      (let* ((fn (lambda (a b c) (+ a b c)))
	     (cb (make-c-callback* uint32_t fn (int uint32_t int))))
	(begin0
	    (callback_uint32 cb 1 2 3)
	  (free-c-callback cb)))
    => (+ 1 2 3))

  (check
      (let* ((fn (lambda (a b c) (+ a b c)))
	     (cb (make-c-callback* uint64_t fn (int uint64_t int))))
	(begin0
	    (callback_uint64 cb 1 2 3)
	  (free-c-callback cb)))
    => (+ 1 2 3))

  (check
      (let* ((fn (lambda (a b c) (+ a b c)))
	     (cb (make-c-callback* short fn (int short int))))
	(begin0
	    (callback_short cb 1 2 3)
	  (free-c-callback cb)))
    => (+ 1 2 3))

  (check
      (let* ((fn (lambda (a b c) (+ a b c)))
	     (cb (make-c-callback* ushort fn (int ushort int))))
	(begin0
	    (callback_ushort cb 1 2 3)
	  (free-c-callback cb)))
    => (+ 1 2 3))

  (check
      (let* ((fn (lambda (a b c) (+ a b c)))
	     (cb (make-c-callback* int fn (int int int))))
	(begin0
	    (callback_int cb 1 2 3)
	  (free-c-callback cb)))
    => (+ 1 2 3))

  (check
      (let* ((fn (lambda (a b c) (+ a b c)))
	     (cb (make-c-callback* uint fn (int uint int))))
	(begin0
	    (callback_uint cb 1 2 3)
	  (free-c-callback cb)))
    => (+ 1 2 3))

  (check
      (let* ((fn (lambda (a b c) (+ a b c)))
	     (cb (make-c-callback* long fn (int long int))))
	(begin0
	    (callback_long cb 1 2 3)
	  (free-c-callback cb)))
    => (+ 1 2 3))

  (check
      (let* ((fn (lambda (a b c) (+ a b c)))
	     (cb (make-c-callback* ulong fn (int ulong int))))
	(begin0
	    (callback_ulong cb 1 2 3)
	  (free-c-callback cb)))
    => (+ 1 2 3))

  (check
      (let* ((fn (lambda (a b c) (+ a b c)))
	     (cb (make-c-callback* llong fn (int llong int))))
	(begin0
	    (callback_llong cb 1 2 3)
	  (free-c-callback cb)))
    => (+ 1 2 3))

  (check
      (let* ((fn (lambda (a b c) (+ a b c)))
	     (cb (make-c-callback* ullong fn (int ullong int))))
	(begin0
	    (callback_ullong cb 1 2 3)
	  (free-c-callback cb)))
    => (+ 1 2 3))

  (check
      (let* ((fn (lambda (a b c) (+ a b c)))
	     (cb (make-c-callback* char fn (int char int))))
	(begin0
	    (callback_char cb 1 2 3)
	  (free-c-callback cb)))
    => (+ 1 2 3))

  (check
      (let* ((fn (lambda (a b c) (+ a b c)))
	     (cb (make-c-callback* uchar fn (int uchar int))))
	(begin0
	    (callback_uchar cb 1 2 3)
	  (free-c-callback cb)))
    => (+ 1 2 3))

  (check
      (let* ((fn (lambda (a b c) (+ a b c)))
	     (cb (make-c-callback* float fn (int float int))))
	(begin0
	    (callback_float cb 1 2.3 3)
	  (free-c-callback cb)))
    (=> (lambda (a b)
	  (< (abs (- a b)) 1e-6)))
    (+ 1 2.3 3))

  (check
      (let* ((fn (lambda (a b c) (+ a b c)))
	     (cb (make-c-callback* double fn (int double int))))
	(begin0
	    (callback_double cb 1 2.3 3)
	  (free-c-callback cb)))
    => (+ 1 2.3 3))

  (check
      (let* ((fn (lambda (a b c) (pointer-add (pointer-add b a) c)))
	     (cb (make-c-callback* void* fn (int void* int))))
	(begin0
	    (pointer->integer (callback_pointer cb 1 (integer->pointer 2) 3))
	  (free-c-callback cb)))
    => (+ 1 2 3))

  #t)


;;;; done

(check-report)

;;; end of file
