;;; -*- coding: utf-8-unix -*-
;;;
;;;Part of: Nausicaa/Nettle
;;;Contents: tests for Hogweed platform libraries loading
;;;Date: Thu Jan  7, 2010
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


(import (nausicaa)
  (foreign crypto hogweed platform)
  (foreign crypto nettle sizeof)
  (checks))

(check-set-mode! 'report-failed)
(display "*** testing Hogweed platform\n")


(parametrise ((check-test-name	'basic))

  (check
      #f
    => #f)

  #t)


;;;; done

(check-report)

;;; end of file
