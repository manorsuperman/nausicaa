;;; -*- coding: utf-8-unix -*-
;;;
;;;Part of: Nausicaa/Scheme
;;;Contents: extensions for <mempool>
;;;Date: Tue Oct 13, 2009
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


(library (foreign memory mempool extensions)
  (export <mempool*>)
  (import (rnrs)
    (records)
    (foreign memory pointers)
    (for (foreign memory mempool types) expand))

  (define (%mempool-free-size pool)
    (with-record-fields (((pointer pointer-free size) <mempool> pool))
      (- size (pointer-diff pointer-free pointer))))

  (define-record-extension <mempool*>
    (parent <mempool>)
    (fields (free-size %mempool-free-size #f))))

;;; end of file