;;;
;;;Part of: Nausicaa/POSIX
;;;Contents: interface to file functions
;;;Date: Sat Jan  3, 2009
;;;
;;;Abstract
;;;
;;;
;;;
;;;Copyright (c) 2009 Marco Maggi <marcomaggi@gna.org>
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


(library (foreign glibc file)
  (export
    tempnam		tempnam-function
    mkdtemp		mkdtemp-function

    utimes		utimes-function
    lutimes		lutimes-function
    futimes		futimes-function)
  (import (rnrs)
    (foreign glibc file primitives))


;;;; temporary files

(define-parametrised tempnam directory prefix)
(define-parametrised mkdtemp template)

;;;; file times

(define-parametrised utimes pathname
  access-time-sec access-time-usec
  modification-time-sec modification-time-usec)

(define-parametrised lutimes pathname
  access-time-sec access-time-usec
  modification-time-sec modification-time-usec)

(define-parametrised futimes fd
  access-time-sec access-time-usec
  modification-time-sec modification-time-usec)


;;;; done

)

;;; end of file
