;;; -*- coding: utf-8 -*-
;;;
;;;Part of: Nausicaa/Scheme
;;;Contents: compatibility library for Ypsilon
;;;Date: Sun Dec 26, 2010
;;;
;;;Abstract
;;;
;;;
;;;
;;;Copyright (c) 2010 Marco Maggi <marco.maggi-ipsu@poste.it>
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
(library (nausicaa language compat)
  (export
    * rational-valued? max
    (rename (lookup-process-environment get-environment-variable)
	    (process-environment->alist get-environment-variables)))
  (import (except (rnrs) * max)
    (prefix (only (rnrs) * max) rnrs.)
    (for (only (core) lookup-process-environment process-environment->alist) expand run))

  (define max
    (case-lambda
     ((n)
      n)
     ((n m)
      (cond ((nan? n)	+nan.0)
	    ((nan? m)	+nan.0)
	    (else	(rnrs.max n m))))
     ((n m . args)
      (max n (apply max m args)))))

  (define *
    (case-lambda
     (()	1)
     ((n)	n)
     ((n m)
      (cond ((nan? n)	+nan.0)
	    ((nan? m)	+nan.0)
	    (else	(rnrs.* n m))))
     ((n m . args)
      (* n (apply * m args)))))
  )

;;; end of file
