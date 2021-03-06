;;;
;;;Part of: Nausicaa/Scheme
;;;Contents: rebuild the CSV lexer tables
;;;Date: Tue Jul 21, 2009
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

#!r6rs
(import (rnrs)
  (nausicaa silex))

(lex (input-file: "unquoted-data.l")
     (output-file: "unquoted-data-lexer.sls")
     (library-spec: '(nausicaa csv unquoted-data-lexer))
     (table-name: 'csv-unquoted-data-table)
     (counters: 'all))

(lex (input-file: "unquoted-data-comma.l")
     (output-file: "unquoted-data-comma-lexer.sls")
     (library-spec: '(nausicaa csv unquoted-data-comma-lexer))
     (table-name: 'csv-unquoted-data-table/comma)
     (counters: 'all))

(lex (input-file: "strings.l")
     (output-file: "strings-lexer.sls")
     (library-spec: '(nausicaa csv strings-lexer))
     (table-name: 'csv-strings-table)
     (counters: 'all))


;;; end of file
