;;; -*- coding: utf-8-unix -*-
;;;
;;;Part of: Nausicaa
;;;Contents: foreign library inspection generation
;;;Date: Wed Nov 25, 2009
;;;
;;;Abstract
;;;
;;;
;;;
;;;Copyright (c) 2009, 2010 Marco Maggi <marco.maggi-ipsu@poste.it>
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


(library (ffi inspector-maker)
  (export

    ;; main control
    sizeof-lib			sizeof-lib-write
    sizeof-lib-exports
    autoconf-lib		autoconf-lib-write
    define-shared-object
    structs-lib-write

    class-uid

    ;; inspection
    define-c-defines		define-c-string-defines
    define-c-enumeration	define-c-type-alias
    define-c-type		define-c-struct)
  (import (nausicaa)
    (formations)
    (times-and-dates)
    (strings))


;;;; helpers

(define (hat->at str)
  ;;GNU Autoconf  wants symbols enclosed  in "@...@", but we  cannot use
  ;;#\@  in R6RS symbols.   So, to  be able  to use  quasiquotation when
  ;;composing the body of Scheme libraries: we build Scheme symbols with
  ;;#\^  characters in place  of #\@;  convert the  S-expression library
  ;;body into  a string; use  this function to  map #\^ to  #\@; finally
  ;;write the body to a file.
  ;;
  (string-map (lambda (idx ch)
		(if (char=? #\^ ch)
		    #\@
		  ch))
	      str))

(define (dot->underscore str)
  (string-map (lambda (idx ch)
		(if (char=? #\. ch)
		    #\_
		  ch))
	      str))

(define (dash->underscore str)
  (string-map (lambda (idx ch)
		(if (char=? #\- ch)
		    #\_
		  ch))
	      str))


;;;; Autoconf and Scheme libraries

(define class-uid
  (make-parameter "nausicaa:default:"
    (lambda (uid)
      (cond ((string? uid)
	     uid)
	    ((symbol? uid)
	     (symbol->string uid))
	    (else
	     (assertion-violation 'class-uid "expected string or symbol as class UID prefix" uid))))))

(define $autoconf-library	"")
(define $sizeof-library		'())
(define $sizeof-lib-exports	'())
(define $structs-library	'())
(define $structs-lib-exports	'())

(define (autoconf-lib str)
  ;;Append STR  to the current Autoconf  library; add a new  line at the
  ;;end.
  ;;
  (set! $autoconf-library (string-append $autoconf-library str "\n")))

(define-syntax sizeof-lib
  (syntax-rules ()
    ((_ ?sexp0 ?sexp ...)
     (%sizeof-lib (quote (?sexp0 ?sexp ...))))))

(define (%sizeof-lib sexp)
  ;;Append an S-expression to the end of the current sizeof library.
  ;;
  (set! $sizeof-library (append $sizeof-library sexp)))

(define (%structs-lib sexp)
  ;;Append an S-expression to the end of the current structs library.
  ;;
  (set! $structs-library (append $structs-library sexp)))

(define-syntax sizeof-lib-exports
  (syntax-rules ()
    ((_ ?symbol0 ?symbol ...)
     (%sizeof-lib-exports (quote ?symbol0) (quote ?symbol) ...))))

(define (%sizeof-lib-exports . ell)
  ;;Add a list of symbols to the list of exports in the sizeof library.
  ;;
  (set! $sizeof-lib-exports (append $sizeof-lib-exports ell)))

(define (%structs-lib-exports . ell)
  ;;Add a list of symbols to the list of exports in the structs library.
  ;;
  (set! $structs-lib-exports (append $structs-lib-exports ell)))

(define (autoconf-lib-write filename libname macro-name)
  ;;Write  to  the  specified  FILENAME  the contents  of  the  Autoconf
  ;;library.  LIBNAME must  be the library specification and  it is used
  ;;only as a comment.
  ;;
  (let ((port (transcoded-port (open-file-output-port filename (file-options no-fail))
			       (make-transcoder (utf-8-codec)))))
    (format port "dnl ~a --\n" libname)
    (display $autoconf-license port)
    (display (string-append "\nAC_DEFUN([" (symbol->string/maybe macro-name) "],[\n\n") port)
    (display $autoconf-library port)
    (display "\n\n])\n\n\ndnl end of file\n" port)
    (close-port port)))

(define (sizeof-lib-write filename libname)
  ;;Write to  the specified FILENAME  the contents of the  sizeof Scheme
  ;;library.  LIBNAME must be the library specification.
  ;;
  (let ((libout `(library ,libname
		   (export ,@$sizeof-lib-exports)
		   (import (rnrs)
		     (ffi)
		     (ffi sizeof))
		   ,@$sizeof-library)))
    (let ((strout (call-with-string-output-port
		      (lambda (port)
			(pretty-print libout port)))))
      (set! strout (hat->at strout))
      (let ((port (transcoded-port (open-file-output-port filename (file-options no-fail))
				   (make-transcoder (utf-8-codec)))))

	(format port ";;; ~s --\n" libname)
	(display $sizeof-license port)
	(display "\n\n" port)
	(display strout port)
	(display "\n\n;;; end of file\n" port)
	(close-port port)))))

(define (structs-lib-write filename structs-libname sizeof-libname)
  ;;Write to the  specified FILENAME the contents of  the structs Scheme
  ;;library.   STRUCTS-LIBNAME   must  be  the   library  specification.
  ;;SIZEOF-LIBNAME  must be  the  specification of  the sizeof  library,
  ;;which is imported.
  ;;
  (let ((libout `(library ,structs-libname
		   (export ,@$structs-lib-exports)
		   (import (nausicaa)
		     (ffi)
		     ,sizeof-libname)
		   ,@$structs-library)))
    (let ((strout (call-with-string-output-port
		      (lambda (port)
			(pretty-print libout port)))))
      (set! strout (hat->at strout))
      (let ((port (transcoded-port (open-file-output-port filename (file-options no-fail))
				   (make-transcoder (utf-8-codec)))))

	(format port ";;; ~s --\n" structs-libname)
	(display $structs-license port)
	(display "\n\n" port)
	(display strout port)
	(display "\n\n;;; end of file\n" port)
	(close-port port)))))


;;;; shared library

(define-syntax define-shared-object
  (syntax-rules ()
    ((_ ?name ?default-library-name)
     (%define-shared-object (quote ?name) (quote ?default-library-name)))))

(define (%define-shared-object name default-library-name)
  (let* ((name		(symbol->string name))
	 (upname	(dash->underscore (string-upcase name)))
	 (dnname	(string-downcase name))
	 (tiname	(string-titlecase name))
	 (varname	(format "~a_SHARED_OBJECT" upname))
	 (varname-sym	(string->symbol varname)))
    (autoconf-lib (format "NAU_DS_WITH_OPTION([~a],[~a-shared-object],[~a],
  [~a shared library file],[select ~a shared library file])"
		    varname dnname default-library-name tiname tiname))
    ;;FIXME This will fail with Ikarus up to revision 1870.  Use Mosh!.
    (let ((at-symbol (string->symbol (format "\"^~a^\"" varname))))
      (%sizeof-lib `((define ,varname-sym ,at-symbol)))
      (%sizeof-lib-exports varname-sym))))


;;;; enumerations

(define-syntax define-c-enumeration
  ;;Register in  the output libraries  a set of enumerated  C constants.
  ;;Example:
  ;;
  ;;  (define-c-enumeration lib_type
  ;;    LIB_VALUE_ZERO LIB_VALUE_ONE LIB_VALUE_TWO)
  ;;
  (syntax-rules ()
    ((_ ?enum-name ?string-typedef ?symbol-name0 ?symbol-name ...)
     (%register-enumeration (quote ?enum-name) ?string-typedef
			    (quote (?symbol-name0 ?symbol-name ...))))))

(define (%register-enumeration enum-name string-typedef symbol-names)
  (%register-type enum-name 'signed-int string-typedef)
  (autoconf-lib (format "\ndnl enum ~a" enum-name))
  (for-each (lambda (symbol)
	      (autoconf-lib (format "NAUSICAA_ENUM_VALUE([~a])" symbol))
	      (let ((at-symbol (string->symbol (format "^VALUEOF_~a^"
						 (symbol->string symbol)))))
		(%sizeof-lib `((define ,symbol ,at-symbol)))
		(%sizeof-lib-exports symbol)))
    symbol-names))


;;;; C preprocessor symbols

(define-syntax define-c-defines
  ;;Register in the output libraries  a set of C preprocessor constants.
  ;;Example:
  ;;
  ;;  (define-c-defines "seek whence values"
  ;;    SEEK_SET SEEK_CUR SEEK_END)
  ;;
  (syntax-rules ()
    ((_ ?description ?symbol-name0 ?symbol-name ...)
     (%register-preprocessor-symbols ?description (quote (?symbol-name0 ?symbol-name ...))))))

(define (%register-preprocessor-symbols description symbol-names)
  (autoconf-lib (format "\ndnl Preprocessor symbols: ~a" description))
  (for-each (lambda (symbol)
	      (autoconf-lib (format "NAUSICAA_DEFINE_VALUE([~a])" symbol))
	      (let ((at-symbol (string->symbol (format "^VALUEOF_~a^" (symbol->string symbol)))))
		(%sizeof-lib `((define ,symbol ,at-symbol)))
		(%sizeof-lib-exports symbol)))
    symbol-names))

;;; --------------------------------------------------------------------

(define-syntax define-c-string-defines
  ;;Register  in the  output libraries  a set  of C  preprocessor string
  ;;literals.
  ;;
  (syntax-rules ()
    ((_ ?description ?symbol-name0 ?symbol-name ...)
     (%register-string-preprocessor-symbols ?description (quote (?symbol-name0 ?symbol-name ...))))))

(define (%register-string-preprocessor-symbols description symbol-names)
  (autoconf-lib (format "\ndnl String preprocessor symbols: ~a" description))
  (for-each (lambda (symbol)
	      (autoconf-lib (format "NAUSICAA_STRING_TEST([~a],[~a])" symbol symbol))
	      (let ((at-symbol (string->symbol (format "\"^STRINGOF_~a^\""
						 (symbol->string symbol)))))
		(%sizeof-lib `((define ,symbol ,at-symbol)))
		(%sizeof-lib-exports symbol)))
    symbol-names))


;;;; C type aliases

(define-syntax define-c-type-alias
  (syntax-rules ()
    ((_ ?alias ?type)
     (%register-type-alias (quote ?alias) (quote ?type)))))

(define (%register-type-alias alias type)
  (%sizeof-lib `((define ,alias (quote ,type))))
  (%sizeof-lib-exports alias))


;;;; C type inspection

(define-syntax define-c-type
  (syntax-rules ()
    ((_ ?name ?type-category)
     (%register-type (quote ?name) (quote ?type-category) (symbol->string (quote ?name))))
    ((_ ?name ?type-category ?type-string)
     (%register-type (quote ?name) (quote ?type-category) ?type-string))))

(define (%register-type name type-category string-typedef)
  (let* ((keyword		(string-upcase (symbol->string name)))
	 (ac-symbol-typeof		(string->symbol (format "^TYPEOF_~a^"		keyword)))
	 (ac-symbol-sizeof		(string->symbol (format "^SIZEOF_~a^"		keyword)))
	 (ac-symbol-alignof	(string->symbol (format "^ALIGNOF_~a^"		keyword)))
	 (ac-symbol-strideof	(string->symbol (format "^STRIDEOF_~a^"		keyword)))
	 (ac-symbol-accessor	(string->symbol (format "^GETTEROF_~a^"		keyword)))
	 (ac-symbol-mutator	(string->symbol (format "^SETTEROF_~a^"		keyword)))
	 (name-typeof		name)
	 (name-sizeof		(string->symbol (format "sizeof-~s"		name)))
	 (name-alignof		(string->symbol (format "alignof-~s"		name)))
	 (name-strideof		(string->symbol (format "strideof-~s"		name)))
	 (pointer-accessor	(string->symbol (format "pointer-ref-c-~s"	name)))
	 (pointer-mutator	(string->symbol (format "pointer-set-c-~s!"	name)))
	 (array-sizeof		(string->symbol (format "sizeof-~a-array"	name)))
	 (array-accessor	(string->symbol (format "array-ref-c-~s"	name)))
	 (array-mutator		(string->symbol (format "array-set-c-~s!"	name))))
    (autoconf-lib (format "NAUSICAA_INSPECT_TYPE([~a],[~a],[~a],[#f])"
		    keyword string-typedef type-category))
    (%sizeof-lib `((define ,name-typeof		(quote ,ac-symbol-typeof))
		   (define ,name-sizeof		,ac-symbol-sizeof)
		   (define ,name-alignof	,ac-symbol-alignof)
		   (define ,name-strideof	,ac-symbol-strideof)
		   (define ,pointer-accessor	,ac-symbol-accessor)
		   (define ,pointer-mutator	,ac-symbol-mutator)
		   (define-syntax ,array-sizeof
		     (syntax-rules ()
		       ((_ ?number-of-elements)
			(* ,name-sizeof ?number-of-elements))))
		   (define-syntax ,array-accessor
		     (syntax-rules ()
		       ((_ ?pointer ?index)
			(,pointer-accessor ?pointer (* ?index ,name-strideof)))))
		   (define-syntax ,array-mutator
		     (syntax-rules ()
		       ((_ ?pointer ?index ?value)
			(,pointer-mutator  ?pointer (* ?index ,name-strideof) ?value))))))
    (%sizeof-lib-exports name-typeof
			 name-sizeof name-alignof name-strideof
			 pointer-accessor pointer-mutator
			 array-sizeof
			 array-accessor array-mutator)))


;;;; C struct type inspection

(define-syntax define-c-struct
  (syntax-rules ()
    ((_ ?name ?type-string
	(?field-type-category ?field-name)
	...)
     (%register-struct-type (quote ?name) (quote ?type-string)
			    (quote (?field-name ...))
			    (quote (?field-type-category ...))))))

(define (%register-struct-type struct-name struct-string-typedef field-names field-type-categories)
  (autoconf-lib (format "\ndnl Struct inspection: ~a" struct-name))
  (let* ((struct-keyword (string-upcase (symbol->string struct-name)))
	 (class-name	(format "<struct-~a>" struct-name))
	 (class-type	(string->symbol class-name))
	 (struct-uid	(string->symbol (string-append (class-uid) ":" class-name))))

    ;;Output the data structure inspection stuff.
    ;;
    (let ((ac-symbol-sizeof	(string->symbol (format "^SIZEOF_~a^"	struct-keyword)))
	  (ac-symbol-alignof	(string->symbol (format "^ALIGNOF_~a^"	struct-keyword)))
	  (ac-symbol-strideof	(string->symbol (format "^STRIDEOF_~a^"	struct-keyword)))
	  (name-typeof		struct-name)
	  (name-sizeof		(string->symbol (format "sizeof-~s"	struct-name)))
	  (name-alignof		(string->symbol (format "alignof-~s"	struct-name)))
	  (name-strideof	(string->symbol (format "strideof-~s"	struct-name)))
	  (array-struct-sizeof	 (string->symbol (format "sizeof-~a-array" struct-name)))
	  (array-struct-accessor (string->symbol (format "array-ref-c-~a" struct-name))))
      (autoconf-lib (format "NAUSICAA_INSPECT_STRUCT_TYPE([~a],[~a],[#f])"
		      struct-keyword struct-string-typedef))
      (%sizeof-lib `((define ,name-sizeof	,ac-symbol-sizeof)
		     (define ,name-alignof	,ac-symbol-alignof)
		     (define ,name-strideof	,ac-symbol-strideof)
		     (define-syntax ,array-struct-sizeof
		       (syntax-rules ()
			 ((_ ?number-of-elements)
			  (* ,name-strideof ?number-of-elements))))
		     (define-syntax ,array-struct-accessor
		       (syntax-rules ()
			 ((_ ?pointer ?index)
			  (pointer-add ?pointer (* ?index ,name-strideof)))))))
      (%sizeof-lib-exports name-sizeof name-alignof name-strideof
			   array-struct-sizeof array-struct-accessor)
      (%structs-lib-exports class-type))

    ;;Output the field inspection stuff.
    ;;
    (let ((class-fields  '())
	  (class-methods '()))
      (for-each
	  (lambda (field-name field-type-category)
	    (let* ((field-keyword	(dot->underscore (string-upcase (symbol->string field-name))))
		   (name-field-accessor	(string->symbol
					 (format "struct-~a-~a-ref"  struct-name field-name)))
		   (name-field-mutator	(string->symbol
					 (format "struct-~a-~a-set!" struct-name field-name)))
		   (class-field-accessor (string->symbol
					  (format "~a-~a"      class-type field-name)))
		   (class-field-mutator	 (string->symbol
					  (format "~a-~a-set!" class-type field-name)))
		   (ac-symbol-field-offset	(string->symbol
						 (format "^OFFSETOF_~a_~a^" struct-keyword field-keyword)))
		   (ac-symbol-field-accessor (string->symbol
					      (format "^GETTEROF_~a_~a^" struct-keyword field-keyword)))
		   (ac-symbol-field-mutator (string->symbol
					     (format "^SETTEROF_~a_~a^" struct-keyword field-keyword))))
	      (if (eq? 'embedded field-type-category)
		  (begin
		    (autoconf-lib (format "NAUSICAA_INSPECT_FIELD_TYPE_POINTER([~a],[~a],[~a])"
				    (format "~a_~a" struct-keyword field-keyword)
				    struct-string-typedef field-name))
		    (%sizeof-lib `((define-c-struct-field-pointer-accessor
				     ,name-field-accessor ,ac-symbol-field-offset)))
		    (%sizeof-lib-exports name-field-accessor)
		    (set-cons! class-fields
			       `(immutable ,field-name ,name-field-accessor))
		    (set-cons! class-methods
			       `((define (,class-field-accessor (o <c-struct>))
				   (,name-field-accessor o.pointer))))
		    )
		(begin
		  (autoconf-lib (format "NAUSICAA_INSPECT_FIELD_TYPE([~a],[~a],[~a],[~a])"
				  (format "~a_~a" struct-keyword field-keyword)
				  struct-string-typedef field-name field-type-category))
		  (%sizeof-lib `((define-c-struct-accessor-and-mutator
				   ,name-field-mutator ,name-field-accessor
				   ,ac-symbol-field-offset
				   ,ac-symbol-field-mutator ,ac-symbol-field-accessor)))
		  (%sizeof-lib-exports name-field-mutator name-field-accessor)
		  (set-cons! class-fields
			     `(mutable ,field-name
				       ,class-field-accessor
				       ,class-field-mutator))
		  (set-cons! class-methods
			     `(define (,class-field-accessor (o <c-struct>))
				(,name-field-accessor o.pointer)))
		  (set-cons! class-methods
			     `(define (,class-field-mutator  (o <c-struct>) new-value)
				(,name-field-mutator  o.pointer new-value)))
		  ))))
	field-names field-type-categories)
      (%structs-lib `((define-class ,class-type
			(parent <c-struct>)
			(virtual-fields ,@class-fields)
			(protocol (lambda (make-c-struct)
				    (lambda (pointer)
				      ((make-c-struct pointer)))))
			(nongenerative ,struct-uid))
		      ,@class-methods
		      )))))


;;;; license notices

(define $date
  (current-date))

(define $sizeof-license
  (string-append ";;;
;;;Part of: Nausicaa
;;;Contents: foreign library inspection generation
;;;Date: " (date->string $date "~a ~b ~e, ~Y") "
;;;
;;;Abstract
;;;
;;;
;;;
;;;Copyright (c) " (date->string $date "~Y") " Marco Maggi <marco.maggi-ipsu@poste.it>
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
"))

(define $structs-license
  (string-append ";;;
;;;Part of: Nausicaa
;;;Contents: foreign library structs fields identifier accessors
;;;Date: " (date->string $date "~a ~b ~e, ~Y") "
;;;
;;;Abstract
;;;
;;;
;;;
;;;Copyright (c) " (date->string $date "~Y") " Marco Maggi <marco.maggi-ipsu@poste.it>
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
"))

(define $autoconf-license
  (string-append "dnl
dnl Part of: Nausicaa
dnl Contents: foreign library inspection generation
dnl Date: " (date->string $date "~a ~b ~e, ~Y") "
dnl
dnl Abstract
dnl
dnl
dnl
dnl Copyright (c) " (date->string $date "~Y") " Marco Maggi <marco.maggi-ipsu@poste.it>
dnl
dnl This program is free software:  you can redistribute it and/or modify
dnl it under the terms of the  GNU General Public License as published by
dnl the Free Software Foundation, either version 3 of the License, or (at
dnl your option) any later version.
dnl
dnl This program is  distributed in the hope that it  will be useful, but
dnl WITHOUT  ANY   WARRANTY;  without   even  the  implied   warranty  of
dnl MERCHANTABILITY  or FITNESS FOR  A PARTICULAR  PURPOSE.  See  the GNU
dnl General Public License for more details.
dnl
dnl You should  have received  a copy of  the GNU General  Public License
dnl along with this program.  If not, see <http://www.gnu.org/licenses/>.
dnl
"))


;;;; done

)

;;; end of file
