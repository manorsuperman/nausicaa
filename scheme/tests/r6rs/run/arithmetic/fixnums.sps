;;;Copyright (c) 2008 Matthew Flatt
;;;
;;;This library is free software;  you can redistribute it and/or modify
;;;it  under the  terms of  the GNU  Library General  Public  License as
;;;published by  the Free Software  Foundation; either version 2  of the
;;;License, or (at your option) any later version.
;;;
;;;This library is  distributed in the hope that it  will be useful, but
;;;WITHOUT  ANY   WARRANTY;  without   even  the  implied   warranty  of
;;;MERCHANTABILITY  or FITNESS FOR  A PARTICULAR  PURPOSE.  See  the GNU
;;;Library General Public License for more details.
;;;
;;;You should  have received  a copy of  the GNU Library  General Public
;;;License along with  this library; if not, write  to the Free Software
;;;Foundation,  Inc.,  51  Franklin  Street,  Fifth  Floor,  Boston,  MA
;;;02110-1301 USA.

#!r6rs
(import (tests r6rs arithmetic fixnums)
        (tests r6rs test)
        (rnrs io simple))
(display "Running tests for (rnrs arithmetic fixnums)\n")
(run-arithmetic-fixnums-tests)
(report-test-results)