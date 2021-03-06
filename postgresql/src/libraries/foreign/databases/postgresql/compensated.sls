;;; -*- coding: utf-8-unix -*-
;;;
;;;Part of: Nausicaa/PostgreSQL
;;;Contents: compensated constructors
;;;Date: Fri Feb 12, 2010
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


(library (foreign databases postgresql compensated)
  (export
    connect-db/c
    connect-start/c

    exec-script/c			exec-parametrised-query/c
    prepare-statement/c			describe-prepared-statement/c
    exec-prepared-statement/c

    connection-get-result/c
    connection-get-cancel-handler/c

    describe-portal/c			describe-portal/send/c
    )
  (import (rnrs)
    (language-extensions)
    (compensations)
    (prefix (foreign databases postgresql) pg:))


(define (connect-db/c info)
  (letrec ((conn (compensate
		     (pg:connect-db info)
		   (with
		    (pg:connect-finish conn)))))
    conn))

(define (connect-start/c info)
  (letrec ((conn (compensate
		     (pg:connect-start info)
		   (with
		    (pg:connect-finish conn)))))
    conn))


;;;; synchronous query execution

(define (exec-script/c conn query)
  (letrec ((result (compensate
		       (pg:exec-script conn query)
		     (with
		      (pg:clear-result result)))))
    result))

(define (exec-parametrised-query/c conn query parms textual-result?)
  (letrec ((result (compensate
		       (pg:exec-parametrised-query conn query parms textual-result?)
		     (with
		      (pg:clear-result result)))))
    result))

(define prepare-statement/c
  (case-lambda
   ((conn stmt-name query-string number-of-parms)
    (prepare-statement/c conn stmt-name query-string number-of-parms #f))
   ((conn stmt-name query-string number-of-parms parms-oid)
    (letrec ((result (compensate
			 (pg:prepare-statement conn stmt-name query-string number-of-parms parms-oid)
		       (with
			(pg:clear-result result)))))
      result))))

(define (describe-prepared-statement/c conn stmt-name)
  (letrec ((result (compensate
		       (pg:describe-prepared-statement conn stmt-name)
		     (with
		      (pg:clear-result result)))))
    result))

(define (exec-prepared-statement/c conn stmt-name parms textual-result?)
  (letrec ((result (compensate
		       (pg:exec-prepared-statement conn stmt-name parms textual-result?)
		     (with
		      (pg:clear-result result)))))
    result))


;;;; asynchronous query execution

(define (connection-get-result/c conn)
  (begin0-let ((result (pg:connection-get-result conn)))
    (when result
      (push-compensation
       (pg:clear-result result)))))


;;;; SQL command cancellation

(define (connection-get-cancel-handler/c conn)
  (letrec ((cancel (compensate
		       (pg:connection-get-cancel-handler conn)
		     (with
		      (pg:free-cancel-handler cancel)))))
    cancel))


(define (describe-portal/c conn portal-name)
  (letrec ((result (compensate
		       (pg:describe-portal conn portal-name)
		     (with
		      (pg:clear-result result)))))
    result))

(define (describe-portal/send/c conn portal-name)
  (letrec ((result (compensate
		       (pg:describe-portal/send conn portal-name)
		     (with
		      (pg:clear-result result)))))
    result))



;;;; done

)

;;; end of file
