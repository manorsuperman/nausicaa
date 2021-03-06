;;; -*- coding: utf-8-unix -*-
;;;
;;;Part of: Nausicaa/Scheme
;;;Contents: tests for msgcat
;;;Date: Tue May 18, 2010
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
(import (nausicaa)
  (nausicaa msgcat)
  (nausicaa checks))

(check-set-mode! 'report-failed)
(display "*** testing msgcat\n")


(parametrise ((check-test-name	'basic))

  (define it_IT (load-catalog 'it_IT))
  (define en_US (load-catalog 'en_US))

  (check
      (mc "January")
    => "January")


  (parametrise ((current-catalog it_IT))

    (check
	(mc "January")
      => "Gennaio")

    #f)

  (parametrise ((current-catalog en_GB))

    (check
	(mc "Yes")
      => "Yes")

    #f)

  (parametrise ((current-catalog en_US))

    (check
	(mc "July")
      => "July")

    #f)

  #t)


;;;; done

(check-report)

;;; end of file
;; Local Variables:
;; coding: utf-8-unix
;; End:
