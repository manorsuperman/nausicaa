;;; -*- coding: utf-8-unix -*-
;;;
;;;Part of: Nausicaa/Scheme
;;;Contents: submodules implementation
;;;Date: Thu Oct 14, 2010
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
(library (nausicaa submodules)
  (export submodule export prefix)
  (import (rnrs)
    (only (nausicaa language extensions)
	  define-values
	  define-auxiliary-syntaxes)
    (for (prefix (only (nausicaa language syntax-utilities)
		       unwrap
		       identifier-suffix
		       all-identifiers?
		       syntax-general-append)
		 sx.)
	 expand))


(define-auxiliary-syntaxes
  export prefix)

(define-syntax submodule
  (lambda (stx)
    (define (build-exported-name prefix bind-stx)
      (sx.syntax-general-append bind-stx prefix bind-stx))
    (syntax-case stx (export prefix)
      ((_ ?name (export ?bind0 ?bind ...) (prefix ?prefix) ?body0 ?body ...)
       (sx.all-identifiers? #'(?name ?bind0 ?bind ...))
       (with-syntax
	   (((BIND ...) (map (lambda (bind-stx)
			       (build-exported-name (sx.unwrap #'?prefix) bind-stx))
			  (sx.unwrap #'(?bind0 ?bind ...)))))
	 #'(define-values (BIND ...)
	     (let ()
	       ?body0 ?body ...
	       (values ?bind0 ?bind ...)))))

      ((?submodule ?name (export ?bind0 ?bind ...) (prefix) ?body0 ?body ...)
       #'(?submodule ?name (export ?bind0 ?bind ...) (prefix "") ?body0 ?body ...))

      ((?submodule ?name (export ?bind0 ?bind ...) ?body0 ?body ...)
       #`(?submodule ?name
		     (export ?bind0 ?bind ...)
		     (prefix #,(sx.identifier-suffix #'?name "."))
		     ?body0 ?body ...))
      )))


;;;; done

)

;;; end of file
