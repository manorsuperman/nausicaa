;; 
;; Part of: Uriel libraries for Ikarus
;; Contents: Common Lisp style macros
;; Date: Sun Nov  9, 2008
;; 
;; Abstract
;; 
;; 
;; 
;; Copyright (c) 2008 Marco Maggi
;; 
;; This  program  is free  software:  you  can redistribute  it
;; and/or modify it  under the terms of the  GNU General Public
;; License as published by the Free Software Foundation, either
;; version  3 of  the License,  or (at  your option)  any later
;; version.
;; 
;; This  program is  distributed in  the hope  that it  will be
;; useful, but  WITHOUT ANY WARRANTY; without  even the implied
;; warranty  of  MERCHANTABILITY or  FITNESS  FOR A  PARTICULAR
;; PURPOSE.   See  the  GNU  General Public  License  for  more
;; details.
;; 
;; You should  have received a  copy of the GNU  General Public
;; License   along   with    this   program.    If   not,   see
;; <http://www.gnu.org/licenses/>.
;; 

;;page
;; ------------------------------------------------------------
;; Setup.
;; ------------------------------------------------------------

(library (ice-9 define-macro)
	 (export define-macro defmacro)
	 (import (rnrs))

;; ------------------------------------------------------------

;;page
;; ------------------------------------------------------------
;; Code.
;; ------------------------------------------------------------

(define-syntax define-macro
  (lambda (incoming)
    (syntax-case incoming ()
      ((_ (?name ?arg ...) ?form ...)
       (syntax
	(define-macro ?name (lambda (?arg ...) ?form ...))))
      ((_ ?name ?func)
       (syntax
	(define-syntax ?name
	  (lambda (x)
	    (syntax-case x ()
	      ((kwd . rest)
	       (datum->syntax #'kwd (apply ?func (cdr (syntax->datum x)))))))))))))

(define-syntax defmacro
  (syntax-rules ()
    ((_ ?name (?arg ...) ?form ...)
     (define-macro (?name ?arg ...) ?form ...))))

;; ------------------------------------------------------------

;;page
;; ------------------------------------------------------------
;; Done.
;; ------------------------------------------------------------

) ;; end of library form

;;; end of file
