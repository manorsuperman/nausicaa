;;; -*- coding: utf-8-unix -*-
;;;
;;;Part of: Nausicaa/PostgreSQL
;;;Contents: compound library, high-level API
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


(library (foreign databases postgresql)
  (export

    OID_MAX
    PG_DIAG_SEVERITY
    PG_DIAG_SQLSTATE
    PG_DIAG_MESSAGE_PRIMARY
    PG_DIAG_MESSAGE_DETAIL
    PG_DIAG_MESSAGE_HINT
    PG_DIAG_STATEMENT_POSITION
    PG_DIAG_INTERNAL_POSITION
    PG_DIAG_INTERNAL_QUERY
    PG_DIAG_CONTEXT
    PG_DIAG_SOURCE_FILE
    PG_DIAG_SOURCE_LINE
    PG_DIAG_SOURCE_FUNCTION
    PG_COPYRES_ATTRS
    PG_COPYRES_TUPLES
    PG_COPYRES_EVENTS
    PG_COPYRES_NOTICEHOOKS

    CONNECTION_OK
    CONNECTION_BAD
    CONNECTION_STARTED
    CONNECTION_MADE
    CONNECTION_AWAITING_RESPONSE
    CONNECTION_AUTH_OK
    CONNECTION_SETENV
    CONNECTION_SSL_STARTUP
    CONNECTION_NEEDED

    PGRES_POLLING_FAILED
    PGRES_POLLING_READING
    PGRES_POLLING_WRITING
    PGRES_POLLING_OK
    PGRES_POLLING_ACTIVE

    PGRES_EMPTY_QUERY
    PGRES_COMMAND_OK
    PGRES_TUPLES_OK
    PGRES_COPY_OUT
    PGRES_COPY_IN
    PGRES_BAD_RESPONSE
    PGRES_NONFATAL_ERROR
    PGRES_FATAL_ERROR

    PQTRANS_IDLE
    PQTRANS_ACTIVE
    PQTRANS_INTRANS
    PQTRANS_INERROR
    PQTRANS_UNKNOWN

    PQERRORS_TERSE
    PQERRORS_DEFAULT
    PQERRORS_VERBOSE

;;; --------------------------------------------------------------------

    <connection>		<connection-rtd>
    <connection>?
    pointer-><connection>	<connection>->pointer

    <fd>			<fd>?
    integer-><fd>		<fd>->integer

    pid				pid?
    integer->pid		pid->integer

    <connect-option>		<connect-option-rtd>
    make-<connect-option>	<connect-option>?
    <connect-option>-keyword
    <connect-option>-envvar
    <connect-option>-compiled
    <connect-option>-val
    <connect-option>-label
    <connect-option>-dispchar
    <connect-option>-dispsize

    pointer-><connect-option>

;;; --------------------------------------------------------------------

    enum-polling-status		polling-status
    polling-status->value	value->polling-status

    enum-connection-status	connection-status
    connection-status->value	value->connection-status

    enum-transaction-status		transaction-status
    transaction-status->value		value->transaction-status

;;; --------------------------------------------------------------------

    connect-start			;; PQconnectStart
    connect-poll			;; PQconnectPoll
    connect-db				;; PQconnectdb
    set-db-login			;; PQsetdbLogin
    set-db				;; PQsetdb
    finish				;; PQfinish

    reset-start				;; PQresetStart
    reset-poll				;; PQresetPoll
    reset				;; PQreset

    status				;; PQstatus
    status/ok?
    status/bad?
    status/started?
    status/made?
    status/awaiting-response?
    status/auth-ok?
    status/setenv?
    status/ssl-startup?
    status/needed?

    connection-defaults			;; PQconndefaults
    connection-info-parse		;; PQconninfoParse

    connection-database			;; PQdb
    connection-user			;; PQuser
    connection-password			;; PQpass
    connection-host			;; PQhost
    connection-port			;; PQport
    connection-tty			;; PQtty
    connection-options			;; PQoptions
    connection-socket			;; PQsocket
    connection-transaction-status	;; PQtransactionStatus
    connection-parameter-status		;; PQparameterStatus
    connection-protocol-version		;; PQprotocolVersion
    connection-server-version		;; PQserverVersion
    connection-error-message		;; PQerrorMessage
    connection-backend-pid		;; PQbackendPID
    connection-needs-password		;; PQconnectionNeedsPassword
    connection-used-password		;; PQconnectionUsedPassword
    connection-get-ssl			;; PQgetssl

    set-non-blocking			;; PQsetnonblocking

    )
  (import (rnrs)
    (foreign databases postgresql typedefs)
    (foreign databases postgresql enumerations)
    (foreign databases postgresql conditions)
    (foreign databases postgresql primitives)
    (foreign databases postgresql sizeof)))

;;; end of file
