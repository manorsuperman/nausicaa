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

(library (tests r6rs unicode)
  (export run-unicode-tests)
  (import (rnrs)
          (tests r6rs test))

  (define (run-unicode-tests)

    (test (char-upcase #\i) #\I)
    (test (char-downcase #\i) #\i)
    (test (char-titlecase #\i) #\I)
    (test (char-foldcase #\i) #\i)

    (test (char-upcase #\xDF) #\xDF)
    (test (char-downcase #\xDF) #\xDF)
    (test (char-titlecase #\xDF) #\xDF)
    (test (char-foldcase #\xDF) #\xDF)

    (test (char-upcase #\x3A3) #\x3A3)
    (test (char-downcase #\x3A3) #\x3C3)
    (test (char-titlecase #\x3A3) #\x3A3)
    (test (char-foldcase #\x3A3) #\x3C3)

    (test (char-upcase #\x3C2) #\x3A3)
    (test (char-downcase #\x3C2) #\x3C2)
    (test (char-titlecase #\x3C2) #\x3A3)
    (test (char-foldcase #\x3C2) #\x3C3)

    (test (char-ci<? #\z #\Z) #f)
    (test (char-ci<? #\Z #\z) #f)
    (test (char-ci<? #\a #\Z) #t)
    (test (char-ci<? #\Z #\a) #f)
    (test (char-ci<=? #\z #\Z) #t)
    (test (char-ci<=? #\Z #\z) #t)
    (test (char-ci<=? #\a #\Z) #t)
    (test (char-ci<=? #\Z #\a) #f)
    (test (char-ci=? #\z #\a) #f)
    (test (char-ci=? #\z #\Z) #t)
    (test (char-ci=? #\x3C2 #\x3C3) #t)
    (test (char-ci>? #\z #\Z) #f)
    (test (char-ci>? #\Z #\z) #f)
    (test (char-ci>? #\a #\Z) #f)
    (test (char-ci>? #\Z #\a) #t)
    (test (char-ci>=? #\Z #\z) #t)
    (test (char-ci>=? #\z #\Z) #t)
    (test (char-ci>=? #\z #\Z) #t)
    (test (char-ci>=? #\a #\z) #f)

    (test (char-alphabetic? #\a) #t)
    (test (char-alphabetic? #\1) #f)
    (test (char-numeric? #\1) #t)
    (test (char-numeric? #\a) #f)
    (test (char-whitespace? #\space) #t)
    (test (char-whitespace? #\x00A0) #t)
    (test (char-whitespace? #\a) #f)
    (test (char-upper-case? #\a) #f)
    (test (char-upper-case? #\A) #t)
    (test (char-upper-case? #\x3A3) #t)
    (test (char-lower-case? #\a) #t)
    (test (char-lower-case? #\A) #f)
    (test (char-lower-case? #\x3C3) #t)
    (test (char-lower-case? #\x00AA) #t)
    (test (char-title-case? #\a) #f)
    (test (char-title-case? #\A) #f)
    (test (char-title-case? #\I) #f)
    (test (char-title-case? #\x01C5) #t)

    (test (char-general-category #\a) 'Ll)
    (test (char-general-category #\space) 'Zs)
    (test (char-general-category #\x10FFFF) 'Cn)

    (test (string-upcase "Hi") "HI")
    (test (string-upcase "HI") "HI")
    (test (string-downcase "Hi") "hi")
    (test (string-downcase "hi") "hi")
    (test (string-foldcase "Hi") "hi")
    (test (string-foldcase "HI") "hi")
    (test (string-foldcase "hi") "hi")

    (test (string-upcase "Stra\xDF;e") "STRASSE")
    (test (string-downcase "Stra\xDF;e") "stra\xDF;e")
    (test (string-foldcase "Stra\xDF;e") "strasse")
    (test (string-downcase "STRASSE")  "strasse")

    (test (string-downcase "\x3A3;") "\x3C3;")

    (test (string-upcase "\x39E;\x391;\x39F;\x3A3;") "\x39E;\x391;\x39F;\x3A3;")
    (test (string-downcase "\x39E;\x391;\x39F;\x3A3;") "\x3BE;\x3B1;\x3BF;\x3C2;")
    (test (string-downcase "\x39E;\x391;\x39F;\x3A3;\x3A3;") "\x3BE;\x3B1;\x3BF;\x3C3;\x3C2;")
    (test (string-downcase "\x39E;\x391;\x39F;\x3A3; \x3A3;") "\x3BE;\x3B1;\x3BF;\x3C2; \x3C3;")
    (test (string-foldcase "\x39E;\x391;\x39F;\x3A3;") "\x3BE;\x3B1;\x3BF;\x3C3;")
    (test (string-upcase "\x3BE;\x3B1;\x3BF;\x3C3;") "\x39E;\x391;\x39F;\x3A3;")
    (test (string-upcase "\x3BE;\x3B1;\x3BF;\x3C2;") "\x39E;\x391;\x39F;\x3A3;")

    (test (string-titlecase "kNock KNoCK") "Knock Knock")
    (test (string-titlecase "who's there?") "Who's There?")
    (test (string-titlecase "r6rs") "R6rs") ; this example appears to be wrong in R6RS (Sept 2007 version)
    (test (string-titlecase "R6RS") "R6rs") ; this one, too

    (test (string-downcase "A\x3A3;'x") "a\x3C3;'x") ; ' is a MidLetter

    (test (string-ci<? "a" "Z") #t)
    (test (string-ci<? "A" "z") #t)
    (test (string-ci<? "Z" "a") #f)
    (test (string-ci<? "z" "A") #f)
    (test (string-ci<? "z" "Z") #f)
    (test (string-ci<? "Z" "z") #f)
    (test (string-ci>? "a" "Z") #f)
    (test (string-ci>? "A" "z") #f)
    (test (string-ci>? "Z" "a") #t)
    (test (string-ci>? "z" "A") #t)
    (test (string-ci>? "z" "Z") #f)
    (test (string-ci>? "Z" "z") #f)
    (test (string-ci=? "z" "Z") #t)
    (test (string-ci=? "z" "a") #f)
    (test (string-ci=? "Stra\xDF;e" "Strasse") #t)
    (test (string-ci=? "Stra\xDF;e" "STRASSE") #t)
    (test (string-ci=? "\x39E;\x391;\x39F;\x3A3;" "\x3BE;\x3B1;\x3BF;\x3C2;") #t)
    (test (string-ci=? "\x39E;\x391;\x39F;\x3A3;" "\x3BE;\x3B1;\x3BF;\x3C3;") #t)
    (test (string-ci<=? "a" "Z") #t)
    (test (string-ci<=? "A" "z") #t)
    (test (string-ci<=? "Z" "a") #f)
    (test (string-ci<=? "z" "A") #f)
    (test (string-ci<=? "z" "Z") #t)
    (test (string-ci<=? "Z" "z") #t)
    (test (string-ci>=? "a" "Z") #f)
    (test (string-ci>=? "A" "z") #f)
    (test (string-ci>=? "Z" "a") #t)
    (test (string-ci>=? "z" "A") #t)
    (test (string-ci>=? "z" "Z") #t)
    (test (string-ci>=? "Z" "z") #t)

    (test (string-normalize-nfd "\xE9;") "\x65;\x301;")
    (test (string-normalize-nfc "\xE9;") "\xE9;")
    (test (string-normalize-nfd "\x65;\x301;") "\x65;\x301;")
    (test (string-normalize-nfc "\x65;\x301;") "\xE9;")

    (test (string-normalize-nfkd "\xE9;") "\x65;\x301;")
    (test (string-normalize-nfkc "\xE9;") "\xE9;")
    (test (string-normalize-nfkd "\x65;\x301;") "\x65;\x301;")
    (test (string-normalize-nfkc "\x65;\x301;") "\xE9;")

    ;;
    ))
