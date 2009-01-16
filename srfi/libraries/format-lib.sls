;;;"format.scm" Common LISP text output formatter for SLIB.
;;;
;;;Written 1992-1994 by Dirk Lutzebaeck. Authors of the original version
;;;(<1.4) were Ken Dickey and Aubrey Jaffer.  Assimilated into Guile May
;;;1999.  Ported to R6RS Scheme and Nausicaa by Marco Maggi.
;;;
;;;Copyright (c) 2009 Marco Maggi <marcomaggi@gna.org>
;;;Copyright (c) 1992-1994 Dirk Lutzebaeck <lutzeb@cs.tu-berlin.de>
;;;
;;;Permission is hereby granted, free of charge, to any person obtaining
;;;a  copy of  this  software and  associated  documentation files  (the
;;;"Software"), to  deal in the Software  without restriction, including
;;;without limitation  the rights to use, copy,  modify, merge, publish,
;;;distribute, sublicense,  and/or sell copies  of the Software,  and to
;;;permit persons to whom the Software is furnished to do so, subject to
;;;the following conditions:
;;;
;;;The  above  copyright notice  and  this  permission  notice shall  be
;;;included in all copies or substantial portions of the Software.
;;;
;;;Except  as  contained  in  this  notice, the  name(s)  of  the  above
;;;copyright holders  shall not be  used in advertising or  otherwise to
;;;promote  the sale,  use or  other dealings  in this  Software without
;;;prior written authorization.
;;;
;;;THE  SOFTWARE IS  PROVIDED "AS  IS",  WITHOUT WARRANTY  OF ANY  KIND,
;;;EXPRESS OR  IMPLIED, INCLUDING BUT  NOT LIMITED TO THE  WARRANTIES OF
;;;MERCHANTABILITY,    FITNESS   FOR    A    PARTICULAR   PURPOSE    AND
;;;NONINFRINGEMENT.  IN NO EVENT  SHALL THE AUTHORS OR COPYRIGHT HOLDERS
;;;BE LIABLE  FOR ANY CLAIM, DAMAGES  OR OTHER LIABILITY,  WHETHER IN AN
;;;ACTION OF  CONTRACT, TORT  OR OTHERWISE, ARISING  FROM, OUT OF  OR IN
;;;CONNECTION  WITH THE SOFTWARE  OR THE  USE OR  OTHER DEALINGS  IN THE
;;;SOFTWARE.



#!r6rs
(library (format-lib)
  (export
    format format-output-column)
  (import (rename (rnrs)
		  (infinite? rnrs:infinite?)
		  (nan? rnrs:nan?))
    (only (rnrs r5rs)
	  remainder
	  quotient)
    (only (rnrs mutable-strings)
	  string-set!)
    (format-lib compat)
    (lang-lib))


;;;; constants

;;The default character prefixing the exponent value in "~e" printing.
(define default-exponential-char #\E)

(define ascii-non-printable-charnames
  '#("nul" "soh" "stx" "etx" "eot" "enq" "ack" "bel"
     "bs"  "ht"  "nl"  "vt"  "np"  "cr"  "so"  "si"
     "dle" "dc1" "dc2" "dc3" "dc4" "nak" "syn" "etb"
     "can" "em"  "sub" "esc" "fs"  "gs"  "rs"  "us" "space"))

(define parameter-characters
  '(#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9 #\- #\+ #\v #\# #\'))

(define space-char-integer (char->integer #\space))
(define zero-char-integer	(char->integer #\0))

;;Roman numerals (from dorai@cs.rice.edu).
(define roman-alist
  '((1000 #\M) (500 #\D) (100 #\C) (50 #\L)
    (10 #\X) (5 #\V) (1 #\I)))

(define roman-boundary-values
  '(100 100 10 10 1 1 #f))

;;Cardinals & ordinals (from dorai@cs.rice.edu).
(define cardinal-ones-list
  '(#f
    "one"	"two"		"three"
    "four"	"five"		"six"
    "seven"	"eight"		"nine"
    "ten"	"eleven"	"twelve"
    "thirteen"	"fourteen"	"fifteen"
    "sixteen"	"seventeen"	"eighteen"
    "nineteen"))

(define cardinal-tens-list
  '(#f
    #f		"twenty"	"thirty"
    "forty"	"fifty"		"sixty"
    "seventy"	"eighty"	"ninety"))

(define cardinal-thousand-block-list
  '(""
    " thousand"		" million"		" billion"
    " trillion"		" quadrillion"		" quintillion"
    " sextillion"	" septillion"		" octillion"
    " nonillion"	" decillion"		" undecillion"
    " duodecillion"	" tredecillion"		" quattuordecillion"
    " quindecillion"	" sexdecillion"		" septendecillion"
    " octodecillion"	" novemdecillion"	" vigintillion"))

(define ordinal-ones-list
  '(#f
    "first"		"second"		"third"
    "fourth"		"fifth"			"sixth"
    "seventh"		"eighth"		"ninth"
    "tenth"		"eleventh"		"twelfth"
    "thirteenth"	"fourteenth"		"fifteenth"
    "sixteenth"		"seventeenth"		"eighteenth"
    "nineteenth"))

(define ordinal-tens-list
  '(#f
    #f			"twentieth"		"thirtieth"
    "fortieth"		"fiftieth"		"sixtieth"
    "seventieth"	"eightieth"		"ninetieth"))



;;;; porting and miscellaneous helpers

;;R6RS states that FINITE?, INFINITE? and NAN? reject complex numbers.
(define (infinite? num)
  (or (rnrs:infinite? (real-part num))
      (rnrs:infinite? (imag-part num))))
(define (nan? num)
  (or (rnrs:nan? (real-part num))
      (rnrs:nan? (imag-part num))))

(define-syntax increment!
  (syntax-rules ()
    ((_ ?varname ?step)
     (set! ?varname (+ ?varname ?step)))
    ((_ ?varname)
     (set! ?varname (+ ?varname 1)))))

;;Return the  first K  elements from the  list ELL; this  function comes
;;from SRFI lists.
(define (take ell k)
  (let loop ((ell ell)
	     (k   k))
    (if (zero? k)
	'()
      (cons (car ell)
	    (loop (cdr ell) (- k 1))))))

;;Return true if S1 is the prefix in S2.
(define (string-prefix? s1 s2)
  (or (eq? s1 s2)
      (let ((len1 (string-length s1)))
	(and (<= len1 (string-length s2))
	     (string=? s1 (substring s2 0 len1))))))

;;Return the index of CH in STR.
(define (string-index str ch)
  (let ((len (string-length str)))
    (do ((i 0 (+ 1 i)))
	((or (= i len) (char=? ch (string-ref str i)))
	 (if (= i len) #f i)))))

;;Return the index of CH in STR starting from the end.
(define (string-index-right str ch)
  (do ((i (- (string-length str) 1) (- i 1)))
      ((or (< i 0) (char=? ch (string-ref str i)))
       (if (< i 0) #f i))))

(define (string-count-tabs str)
  (let ((len (string-length str)))
    (do ((i 0 (+ 1 i))
	 (count 0))
	((= i len)
	 count)
      (when (char=? #\tab (string-ref str i))
	(increment! count)))))

;;Convert a string to its  representation with the first alphabetic char
;;capitalised.   We iterate  over  the chars  rather  than extracting  a
;;substring so that we can apply CHAR-ALPHABETIC?.
;;
;;Some  profiling is  needed to  understand if  an  implementation using
;;SUBSTRING is more efficient with a given Scheme implementation.
;;
;;Usage examples:
;;
;; "hello"	-> "Hello"
;; "hELLO"	-> "Hello"
;; "*hello"	-> "*Hello"
;; "hello you"	-> "Hello you"
;;
(define (string-titlecase/first str)
  (let ((cap-str		(string-copy str))
	(non-first-alpha	#f)
	(str-len		(string-length str)))
    (do ((i 0 (+ i 1)))
	((= i str-len)
	 cap-str)
      (let ((c (string-ref str i)))
	(when (char-alphabetic? c)
	  (if non-first-alpha
	      (string-set! cap-str i (char-downcase c))
	    (begin
	      (set! non-first-alpha #t)
	      (string-set! cap-str i (char-upcase c)))))))))

;;Return the string representation of  the integer NUM in the RADIX.  It
;;extends R6RS  NUMBER->STRING to support any  radix, not only  2, 8, 10
;;and 16.
(define (number->string/radix num radix)
  (unless (and (integer? num) (exact? num))
    (assertion-violation 'number->string
      "only integers can be converted to a base different from 10"
      num))
  (unless (and (integer? radix) (exact? radix) (positive? radix))
    (assertion-violation 'number->string
      "the radix has to be a strictly positive exact integer"
      radix))
  (case radix
    ((2 8 10 16)
     (number->string num radix))
    (else
     (let loop ((num num)
		(res '()))
       (if (< num radix)
	   (apply string-append (number->string num) res)
	 (loop (exact (floor (inexact (/ num radix))))
	       (cons (number->string (remainder num radix)) res)))))))



;;;; escape sequence parameter handling

;;Extract an  escape sequence  parameter from a  list of  parameters and
;;return it.
(define (format:par parameters number-of-parameters
		    index default parameter-name)
  (if (<= number-of-parameters index)
      default
    (let ((par (list-ref parameters index)))
      (if par
	  (if parameter-name
	      (if (< par 0)
		  (assertion-violation 'format:par
		    (string-append "parameter "
				   (string-upcase parameter-name)
				   " for escape sequence ~s must be a positive integer")
		    par)
		par)
	    par)
	default))))



;;;; output column handling

(define (port-column port)
  0)

(define format-output-column
  (make-parameter #f
    (lambda (obj)
      (unless (or (not obj) (and (integer? obj)
				 (exact? obj)
				 (not (negative? obj))))
	(assertion-violation 'format-output-column
	  "invalid value for FORMAT-OUTPUT-COLUMN parameter, expected integer or #f"
	  obj))
      obj)))

(define (increment-output-column delta)
  (and-let* ((column (format-output-column)))
    (format-output-column (+ delta column))))

;;To be  invoked after printing STR  to the destination  port.  Scan the
;;string for  the last newline  and tabulations, then adjust  the output
;;column accordingly.  Notice  that what matters is the  last newline in
;;the string.
;;
;;A tabulation is defined to be 8 characters.
;;
;;Examples:
;;
;;  "ciao"		-> increment by 4
;;  "one\ntwo"		-> set to 3
;;  "ciao\nmamma\n"	-> set to 0
;;  "\t"		-> increment by 8
;;  "A\t"		-> increment by 1+8 = stringlen+8-1
;;  "A\t\t"		-> increment by 1+2*8 = stringlen+2*8-2
;;  "ciao\nmamma\t"	-> increment by 5+8
;;
(define (adjust-output-column-from-string str)
  (let* ((idx	(string-index-right str #\newline))
	 (str	(if idx
		    (begin
		      (format-output-column 0)
		      (substring str (+ 1 idx) (string-length str)))
		  str))
	 (len	(string-length str))
	 (tabs	(string-count-tabs str)))
    (format-output-column (+ len (- (* 8 tabs) tabs)))))


;;;; incipit

(define (format arg0 . args)

  ;;Current format output port.
  (define destination-port #f)

  ;;Current format output TTY column.
  (define format:output-col 0)

  ;;Flush output at end of formatting.
  (define format:flush-output #f)

  (define format:case-conversion #f)

  ;;Current format string parsing position.
  (define format:pos 0)

  ;;Current   format  argument   position   this  is   global  for   error
  ;;presentation.
  (define format:arg-pos 0)

  ;;When  FORMAT:READ-PROOF  is  true,  FORMAT:OBJ->STR will  wrap  result
  ;;strings starting with "#<" in an extra pair of double quotes.
  (define format:read-proof #f)


;;;; helpers, dispatching arguments

;;Notice that  rewriting this  implementation with CASE-LAMBDA  does not
;;bring true advantage.
(define (format:dispatch-arguments arg0 args)

  (define (invalid-string irritant)
    (assertion-violation 'format
      "invalid format string" irritant))

  (let*-values
      (((sarg)		(string? arg0))
       ((format-string)	(cond (sarg
			       arg0)
			      ((null? args)
			       (invalid-string arg0))
			      (else
			       (let ((s (car args)))
				 (unless (string? s)
				   (invalid-string s))
				 s))))
       ((port getter)	(cond (sarg
			       (open-string-output-port))
			      ((boolean? arg0)
			       (if arg0
				   (values (current-output-port) #f)
				 (open-string-output-port)))
			      ((output-port? arg0)
			       (values arg0 #f))
			      ((number? arg0)
			       (values (current-error-port) #f))
			      (else
			       (assertion-violation 'format
				 "invalid destination" arg0))))
       ((arglist)	(if sarg args (cdr args))))

    (set! destination-port port)
    (let ((arg-pos (format:format format-string arglist))
	  (arg-len (length arglist)))
      (cond ((> arg-pos arg-len)
	     (error 'format
	       "missing argument" (- arg-pos arg-len)))
	    (format:flush-output
	     (flush-output-port port)))
      (and getter (getter)))))


;;;; helpers, output to destination

;;Print  a single  character with  case conversion.   Update  the output
;;column.
(define (format:print-char ch)
  (if format:case-conversion
      (display (format:case-conversion (string ch)) destination-port)
    (write-char ch destination-port))
  (if (char=? ch #\newline)
      (format-output-column 0)
    (increment-output-column 1)))

;;Print a string with case conversion.  Update the output column.
(define (format:print-string str)
  (display (if format:case-conversion
	       (format:case-conversion str)
	     str)
	   destination-port)
  (adjust-output-column-from-string str))

;;Print a substring.  Update the output column.
(define (format:print-substring str i n)
  (let ((str (substring str i n)))
    (display str destination-port)
    (adjust-output-column-from-string str)))

;;Print a string filled with the same char.  Update the output column.
(define (format:print-fill-chars n ch)
  (let ((str (make-string n ch)))
    (format:print-string str)
    (adjust-output-column-from-string str)))



;;;; helpers, any object to string

;;Print any object with padding  chars.  It is the implementation of the
;;"~s" and "~a" escape sequences.
;;
;;USE-WRITE decides whether to use WRITE or DISPLAY.
;;
;;PAD-LEFT decides whether padding (if any) is to the left or right.
;;
(define (format:out-obj-padded pad-left obj use-write parameters)

  (define (obj->str obj use-write)
    (let ((res (call-with-string-output-port
		   (lambda (port) ((if use-write write display)
				   obj port)))))
      (if (and format:read-proof (string-prefix? "#<" res))
	  (call-with-string-output-port
	      (lambda (port) (write res port)))
	res)))

  (if (null? parameters)
      (format:print-string (obj->str obj use-write))
    (let ((l (length parameters)))
      (let ((minwidth	(format:par parameters l 0 0 "minwidth"))
	    (padinc	(format:par parameters l 1 1 "padinc"))
	    (minpad	(format:par parameters l 2 0 "minpad"))
	    (padchar	(integer->char
			 (format:par parameters l 3 space-char-integer #f)))
	    (objstr	(obj->str obj use-write)))

	(define (print-padding)
	  (do ((objstr-len (string-length objstr))
	       (i minpad (+ i padinc)))
	      ((>= (+ objstr-len i) minwidth)
	       (format:print-fill-chars i padchar))))

	(cond (pad-left	(print-padding)
			(format:print-string objstr))
	      (else	(format:print-string objstr)
			(print-padding)))))))



;;;; helpers, character to string

;;Convert a character into a slashified string as done by WRITE.
(define (format:char->str ch)
  (let ((ich (char->integer ch)))
    (string-append "#\\"
		   (cond
		    ((char=? ch #\newline)
		     "newline")
		    ((and (>= ich 0) (<= ich 32))
		     (vector-ref ascii-non-printable-charnames ich))
		    ((= ich 127)
		     "del")
		    ((>= ich 128) ; octal representation
		     (number->string ich 8))
		    (else
		     (string ch))))))


;;;; helpers, integer numbers to string

;;Print a padded integer number.
(define (format:out-num-padded modifier number pars radix)
  (when (not (integer? number))
    (assertion-violation 'format:out-num-padded
      "number argument not an integer"
      number))
  ;;We need  the STRING-DOWNCASE because Ikarus converts  hex numbers to
  ;;string in uppercase, but the specs for "~x" are to yield a lowercase
  ;;number.
  (let ((numstr (string-downcase (number->string/radix number radix))))
    (if (and (null? pars) (not modifier))
	(format:print-string numstr)
      (let ((l		(length pars))
	    (numstr-len (string-length numstr)))
	(let ((mincol		(format:par pars l 0 #f "mincol"))
	      (padchar		(integer->char
				 (format:par pars l 1 space-char-integer #f)))
	      (commachar	(integer->char
				 (format:par pars l 2 (char->integer #\,) #f)))
	      (commawidth	(format:par pars l 3 3 "commawidth")))
	  (when mincol
	    (let ((numlen numstr-len)) ; calc. the output len of number
	      (when (and (memq modifier '(at colon-at))
			 (>= number 0))
		(set! numlen (+ numlen 1)))
	      (when (memq modifier '(colon colon-at))
		(set! numlen (+ (quotient (- numstr-len
					     (if (< number 0) 2 1))
					  commawidth)
				numlen)))
	      (when (> mincol numlen)
		(format:print-fill-chars (- mincol numlen) padchar))))
	  (when (and (memq modifier '(at colon-at))
		     (>= number 0))
	    (format:print-char #\+))
	  (if (memq modifier '(colon colon-at)) ; insert comma character
	      (let ((start (remainder numstr-len commawidth))
		    (ns (if (< number 0) 1 0)))
		(format:print-substring numstr 0 start)
		(do ((i start (+ i commawidth)))
		    ((>= i numstr-len))
		  (when (> i ns)
		    (format:print-char commachar))
		  (format:print-substring numstr i (+ i commawidth))))
	    (format:print-string numstr)))))))


;;;; helpers, integer numbers to roman string

;;Return  the old  roman string  representation of  a  strictly positive
;;integer number.
(define (format:num->old-roman n)
  (unless (and (integer? n) (>= n 1))
    (error 'format:num->old-roman
      "only strictly positive integers can be romanized" n))
  (let loop ((n n)
	     (romans roman-alist)
	     (s '()))
    (if (null? romans)
	(list->string (reverse s))
      (let ((roman-val (caar romans))
	    (roman-dgt (cadar romans)))
	(do ((q (quotient n roman-val) (- q 1))
	     (s s (cons roman-dgt s)))
	    ((= q 0)
	     (loop (remainder n roman-val) (cdr romans) s)))))))

;;Return the roman string representation of a positive integer number.
(define (format:num->roman n)
  (unless (and (integer? n) (> n 0))
    (error 'format:num->roman
      "only positive integers can be romanized" n))
  (let loop ((n n)
	     (romans roman-alist)
	     (boundaries roman-boundary-values)
	     (s '()))
    (if (null? romans)
	(list->string (reverse s))
      (let ((roman-val (caar romans))
	    (roman-dgt (cadar romans))
	    (bdry (car boundaries)))
	(let loop2 ((q (quotient n roman-val))
		    (r (remainder n roman-val))
		    (s s))
	  (if (= q 0)
	      (if (and bdry (>= r (- roman-val bdry)))
		  (loop (remainder r bdry) (cdr romans)
			(cdr boundaries)
			(cons roman-dgt
			      (append
			       (cdr (assv bdry romans))
			       s)))
		(loop r (cdr romans) (cdr boundaries) s))
	    (loop2 (- q 1) r (cons roman-dgt s))))))))



;;;; helpers, integer numbers to word strings

;;This  procedure  is inspired  by  the  Bruno  Haible's CLisp  function
;;FORMAT-SMALL-CARDINAL, which  converts numbers in the range  1 to 999,
;;and is used for converting each thousand-block in a larger number
(define (format:num->cardinal999 n)
  (let* ((hundreds	(quotient  n 100))
	 (tens+ones	(remainder n 100))
	 (tens		(quotient  tens+ones 10))
	 (ones		(remainder tens+ones 10)))
    (append
     (if (> hundreds 0)
	 (append
	  (string->list
	   (list-ref cardinal-ones-list hundreds))
	  (string->list" hundred")
	  (if (> tens+ones 0) '(#\space) '()))
       '())
     (if (< tens+ones 20)
	 (if (> tens+ones 0)
	     (string->list
	      (list-ref cardinal-ones-list tens+ones))
	   '())
       (append
	(string->list
	 (list-ref cardinal-tens-list tens))
	(if (> ones 0)
	    (cons #\-
		  (string->list
		   (list-ref cardinal-ones-list ones)))
	  '()))))))

;;Return the  string representation of an integer  number using cardinal
;;words.
(define (format:num->cardinal n)
  (cond
   ((not (integer? n))
    (error 'format:num->cardinal
	"only integers can be converted to English cardinals"
	n))
   ((= n 0)
    "zero")
   ((< n 0)
    (string-append "minus " (format:num->cardinal (- n))))
   (else
    (let ((power3-word-limit (length cardinal-thousand-block-list)))
      (let loop ((n n)
		 (power3 0)
		 (s '()))
	(if (= n 0)
	    (list->string s)
	  (let ((n-before-block (quotient  n 1000))
		(n-after-block  (remainder n 1000)))
	    (loop n-before-block
		  (+ power3 1)
		  (if (> n-after-block 0)
		      (append
		       (if (> n-before-block 0)
			   (string->list ", ") '())
		       (format:num->cardinal999 n-after-block)
		       (if (< power3 power3-word-limit)
			   (string->list
			    (list-ref
			     cardinal-thousand-block-list
			     power3))
			 (append
			  (string->list " times ten to the ")
			  (string->list
			   (format:num->ordinal
			    (* power3 3)))
			  (string->list " power")))
		       s)
		    s)))))))))

;;Return the  string representation of  an integer number  using ordinal
;;words.
(define (format:num->ordinal n)
  (cond
   ((not (integer? n))
    (error 'format:num->ordinal
	"only integers can be converted to English ordinals"
	n))
   ((= n 0)
    "zeroth")
   ((< n 0)
    (string-append "minus " (format:num->ordinal (- n))))
   (else
    (let ((hundreds	(quotient  n 100))
	  (tens+ones	(remainder n 100)))
      (string-append
       (if (> hundreds 0)
	   (string-append
	    (format:num->cardinal (* hundreds 100))
	    (if (= tens+ones 0) "th" " "))
	 "")
       (if (= tens+ones 0) ""
	 (if (< tens+ones 20)
	     (list-ref ordinal-ones-list tens+ones)
	   (let ((tens (quotient tens+ones 10))
		 (ones (remainder tens+ones 10)))
	     (if (= ones 0)
		 (list-ref ordinal-tens-list tens)
	       (string-append
		(list-ref cardinal-tens-list tens)
		"-"
		(list-ref ordinal-ones-list ones)))))))))))



;;;; helpers, special numbers

;;Print the string representation of infinity and not-a-number.
;;
;;Infinity  and not-a-number  are  always printed  exactly as  "+inf.0",
;;"-inf.0" or "+nan.0", suitably justified in their field.  We insist on
;;printing this exact form so that the numbers can be read back in.
;;
(define (format:print-inf-nan number width decimals expdigits
			      overflow-char pad-char)
  (let* ((str		(if (string? number)
			    number
			  (number->string number)))
	 (len		(string-length str))
	 (dot		(string-index str #\.))
	 (digits	(+ (or decimals 0)
			   (if expdigits (+ expdigits 2) 0))))
    (if (and width overflow-char (< width len))
	(format:print-fill-chars width (integer->char overflow-char))
      (let* ((leftpad	(if width
			    (max (- width (max len (+ dot 1 digits))) 0)
			  0))
	     (rightpad	(if width
			    (max (- width leftpad len) 0)
			  0))
	     (pad-char	(integer->char (or pad-char space-char-integer))))
	(format:print-fill-chars leftpad pad-char)
	(format:print-string str)
	(format:print-fill-chars rightpad pad-char)))))


;;;; flonum string representations parsing variables

;;The mantissa buffer.   It is filled with the  string representation of
;;the mantissa of  a flonum.  If the flonum  is "12.345e67", this buffer
;;is filled with "12345".
;;
;;Notice:  the  dot  is  not  stored  in the  buffer;  its  position  is
;;registered in MANTISSA-DOT-INDEX.
;;
;;Notice: the sign  (positive or negative) is not  stored in the buffer;
;;it is registered as boolean in MANTISSA-IS-POSITIVE.
;;
(define mantissa-buffer #f)

;;Number of allocated bytes in MANTISSA-BUFFER.
(define mantissa-max-length 400)

;;The length of the string in  MANTISSA-BUFFER.  It is also the index of
;;the first *unused* byte in MANTISSA-BUFFER buffer.
;;
(define mantissa-length 0)

;;The zero-based index of the  digit in MANTISSA-BUFFER that comes right
;;after the dot.
;;
;;If  the flonum  is "12.345e67",  the  mantissa buffer  is filled  with
;;"12345" and this variable is set to 2, so '3' is the digit right after
;;the dot.
;;
(define mantissa-dot-index #f)

;;Set to #t if the mantissa is positive, to #f otherwise.
(define mantissa-is-positive #t)

;;; --------------------------------------------------------------------

;;The  exponent buffer.  filled  with the  string representation  of the
;;exponent.  If  the flonum is  "12.345e67", this buffer is  filled with
;;"67".
;;
;;Notice: the sign  (positive or negative) is not  stored in the buffer,
;;rather it is marked by EXPONENT-IS-POSITIVE.
;;
(define exponent-buffer #f)

;;Number of bytes allocated in EXPONENT-BUFFER.
(define exponent-max-length 10)

;;The length of  the string in EXPONENT-BUFFER. It is  also the index of
;;the first *unused* byte in the EXPONENT-BUFFER buffer.
(define exponent-length 0)

;;Set to #t if the exponent is positive, to #f otherwise.
(define exponent-is-positive #t)

;;; --------------------------------------------------------------------

;;Reset  the flonum  variables  to  values suitable  for  a new  parsing
;;action.
(define (initialise-flonum-variables)
  (unless mantissa-buffer
    (set! mantissa-buffer (make-string mantissa-max-length)))
  (set! mantissa-length		0)
  (set! mantissa-is-positive	#t)
  (set! mantissa-dot-index	#f)

  (unless exponent-buffer
    (set! exponent-buffer (make-string exponent-max-length)))
  (set! exponent-is-positive	#t)
  (set! exponent-length		0))

(define-syntax mantissa-set!
  (syntax-rules ()
    ((_ ?idx ?char)
     (string-set! mantissa-buffer ?idx ?char))))

(define-syntax mantissa-ref
  (syntax-rules ()
    ((_ ?idx)
     (string-ref mantissa-buffer ?idx))))

(define-syntax mantissa-digit-set!
  (syntax-rules ()
    ((_ ?idx ?digit)
     (mantissa-set! ?idx (integer->char (+ ?digit zero-char-integer))))))

(define-syntax mantissa-digit-ref
  (syntax-rules ()
    ((_ ?idx)
     (- (char->integer (mantissa-ref ?idx)) zero-char-integer))))

(define-syntax exponent-set!
  (syntax-rules ()
    ((_ ?idx ?char)
     (string-set! exponent-buffer ?idx ?char))))

(define-syntax exponent-ref
  (syntax-rules ()
    ((_ ?idx)
     (string-ref exponent-buffer ?idx))))

(define-syntax exponent-digit-set!
  (syntax-rules ()
    ((_ ?idx ?digit)
     (exponent-set! ?idx (integer->char (+ ?digit zero-char-integer))))))

(define-syntax exponent-digit-ref
  (syntax-rules ()
    ((_ ?idx)
     (- (char->integer (exponent-ref ?idx)) zero-char-integer))))


;;;; helpers, miscellaneous stuff for floating point numbers
;;
;;See the documentation of  FORMAT:PARSE-FLONUM below for more details on
;;flonums handling.

(define (validate-flonum-argument number caller-function)
  (when (not (or (and (number? number) (real? number))
		 (string? number)))
    (error caller-function
      "argument is not a real number or a number string representation"
      number)))

;;Return  an  integer  number  representing  the current  value  of  the
;;exponent buffer.
(define (exponent-buffer->integer)
  (if (= exponent-length 0)
      0
    (do ((i 0 (+ i 1))
	 (n 0))
	((= i exponent-length)
	 (if exponent-is-positive
	     n
	   (- n)))
      (set! n (+ (* n 10)
		 (exponent-digit-ref i))))))

;;Store an integer number into the exponent buffer EXPONENT-BUFFER, update
;;EXPONENT-LENGTH and EXPONENT-IS-POSITIVE  accordingly.
(define (integer->exponent-buffer en)
  (unless (integer? en)
    (error 'integer->exponent-buffer
      "invalid value for floating point number exponent"
      en))
  (set! exponent-length 0)
  (set! exponent-is-positive (>= en 0))
  (let* ((en-str (number->string en))
	 (en-len (string-length en-str)))
    (do ((i 0 (+ i 1)))
	((= i en-len))
      (let ((ch (string-ref en-str i)))
	(when (char-numeric? ch)
	  (exponent-set! exponent-length ch)
	  (increment! exponent-length 1))))))

;;Fill   the  mantissa   buffer  with   zeros,   update  MANTISSA-LENGTH
;;accordingly but not MANTISSA-DOT-INDEX.  Examples:
;;
;;  (set! mantissa-buffer "123")
;;  (mantissa-zfill #t 3)
;;  mantissa-buffer => "000123"
;;
;;  (set! mantissa-buffer "123")
;;  (mantissa-zfill #f 3)
;;  mantissa-buffer => "123000"
;;
(define (mantissa-zfill left? n)
  (when (> (+ n mantissa-length) mantissa-max-length) ; from the left or right
    ;;If this happens we have to enlarge MANTISSA-MAX-LENGTH.
    (error 'mantissa-zfill "flonum too long to format"))
  (increment! mantissa-length n)
  (if left?
      (do ((i mantissa-length (- i 1))) ; fill n 0s to left
	  ((< i 0))
	(mantissa-set! i (if (< i n)
			     #\0
			   (mantissa-ref (- i n)))))
    (do ((i (- mantissa-length n) (+ i 1))) ; fill n 0s to the right
	((= i mantissa-length))
      (mantissa-set! i #\0))))

(define-syntax mantissa-prepend-zeros
  (syntax-rules ()
    ((_ ?number-of-zeros)
     (mantissa-zfill #t ?number-of-zeros))))

(define-syntax mantissa-append-zeros
  (syntax-rules ()
    ((_ ?number-of-zeros)
     (mantissa-zfill #f ?number-of-zeros))))

;;Shift  left  current  by  N  positions  the  mantissa  buffer,  update
;;MANTISSA-LENGTH accordingly but not MANTISSA-DOT-INDEX.
;;
;;It is used to remove leading zeros from the mantissa buffer:
;;
;;  "000123" -> "123"
;;
(define (mantissa-shift-left n)
  (when (> n mantissa-length)
    (error 'mantissa-shift-left
      "internal error in mantissa-shift-left"
      n mantissa-length))
  (do ((i n (+ i 1)))
      ((= i mantissa-length)
       (increment! mantissa-length (- n)))
    (mantissa-set! (- i n) (mantissa-ref i))))

;;Print to the destination the mantissa part of the number.
;;
;;If MODIFIER is true: the plus sign is output.
;;
;;If ADD-LEADING-ZERO? is true: a  leading zero is output if the integer
;;part of the mantissa is zero ("0.123"), else it is not (".123").
;;
(define (mantissa-print modifier add-leading-zero?)
  (if mantissa-is-positive
      (when (eq? modifier 'at)
	(format:print-char #\+))
    (format:print-char #\-))
  (if (= 0 mantissa-dot-index)
      (when add-leading-zero?
	(format:print-char #\0))
    (format:print-substring mantissa-buffer 0 mantissa-dot-index));integer part
  (format:print-char #\.)
  (format:print-substring mantissa-buffer mantissa-dot-index mantissa-length));fractional part

;;Print to the destination  the exponent-start character followed by the
;;exponent string.
;;
;;The EDIGITS argument is the requested minimum width of the digits part
;;of  the  exponent, exponent-start  char  and  sign  excluded.  If  the
;;current string in EXPONENT-BUFFER is shorter than EDIGITS: padding zeros
;;are  output before  the digits.   If EDIGITS  is #f:  the  exponent is
;;output without padding.
;;
;;The EXPCH argument selects the exponent-start character.  It should be
;;#\e or #\E, but can be #f to select DEFAULT-EXPONENTIAL-CHAR.
;;
(define (exponent-print edigits expch)
  (format:print-char (if expch
		       (integer->char expch)
		     default-exponential-char))
  (format:print-char (if exponent-is-positive #\+ #\-))
  (when edigits
    (when (< exponent-length edigits)
      (format:print-fill-chars (- edigits exponent-length) #\0)))
  (format:print-substring exponent-buffer 0 exponent-length))

;;Strip trailing zeros  but one from the mantissa  buffer.  The mantissa
;;buffer  is  "updated"  by   mutating  the  value  in  MANTISSA-LENGTH.
;;Examples:
;;
;;  (set! mantissa-dot-index 1)
;;  (set! mantissa-length 6)
;;  (set! mantissa-buffer "123000")
;;  (mantissa-strip-tail-zeros)
;;  mantissa-length => 4
;;
;;  (set! mantissa-dot-index 4)
;;  (set! mantissa-length 6)
;;  (set! mantissa-buffer "123000")
;;  (mantissa-strip-tail-zeros)
;;  mantissa-length => 5
;;
(define (mantissa-strip-tail-zeros)
  (string-set! mantissa-buffer mantissa-length #\0)
  (do ((i mantissa-length (- i 1)))
      ((or (not (char=? #\0 (string-ref mantissa-buffer i)))
	   (<= i mantissa-dot-index))
       (set! mantissa-length (+ i 1)))))

;;Count  leading zeros  in  the  mantissa buffer.  Examples:
;;
;;  (set! mantissa-buffer "000123")
;;  (mantissa-count-leading-zeros) => 3
;;
;;  (set! mantissa-buffer "0")
;;  (mantissa-count-leading-zeros) => 0
;;
;;Return zero if the mantissa is actually zero, that is "0".
(define (mantissa-count-leading-zeros)
  (do ((i 0 (+ i 1)))
      ((or (= i mantissa-length)
	   (not (char=? #\0 (string-ref mantissa-buffer i))))
       (if (= i mantissa-length)
	   0
	 i))))

;;When  a minimum number  of decimals  after the  dot is  requested: add
;;zeros if missing, or round and truncate decimals if too many.
(define (mantissa-adjust-decimals-as-requested requested-decimals)
  (let ((number-of-decimals (- mantissa-length mantissa-dot-index)))
    (if (<= number-of-decimals requested-decimals)
	(mantissa-append-zeros (- requested-decimals number-of-decimals))
      (mantissa-round-digits-after-dot requested-decimals))))



;;;; helpers, rounding floating point numbers

(define (mantissa-round-digits-after-dot number-of-digits)

  ;;Think of the mantissa buffer like this:
  ;;
  ;; I = integer digits		F = fractional digits
  ;; X = rounded digit		T = truncated digits
  ;;
  ;;     IIIIIIIIIIIIIIFFFFFFFFFFFXTTTTTTTTTTTTTTTTTTT
  ;;     ^             ^          ^^
  ;;     |             |          ||
  ;; index zero    index of dot   | --- index of first
  ;;                              |     truncated digit
  ;;                              |
  ;;                          index of
  ;;                          rounded digit

  (define (compute-rounded-digit-with-carry digit first-truncated-digit-idx)
    (let ((rounded (if (= first-truncated-digit-idx mantissa-length)
		       digit
		     (let ((d (mantissa-ref first-truncated-digit-idx)))
		       (cond ((char>? #\5 d)	digit)
			     ((char<? #\5 d)	(+ 1 digit))
			     (else
			      ;;Here D  is #\5, so  we scan the  rest of
			      ;;the  mantissa  buffer:   if  we  find  a
			      ;;non-zero char, we  round up; if we reach
			      ;;the end of the buffer we round to even.
			      (let loop ((i (+ 1 first-truncated-digit-idx)))
				(cond
				 ((= i mantissa-length)
				  (if (even? digit)
				      digit
				    (+ 1 digit)))
				 ((char=? #\0 (mantissa-ref i))
				  (loop (+ 1 i)))
				 (else
				  (+ 1 digit))))))))))
      (if (> 10 rounded)
	  (values rounded #f)
	(values 0 #t))))

  (define (propagate-carry idx)
    (let ((carry #t))
      (do ((i idx (- i 1)))
	  ((or (not carry) (< i 0))
	   (when carry
	     ;;This  body prepends  a  "1" to  the  mantissa buffer  and
	     ;;increments the  dot position.   This way it  performs the
	     ;;carry normalisation for the roundings like:
	     ;;
	     ;;	"9.9" -> "10.0"
	     ;;
	     (mantissa-prepend-zeros 1)
	     (mantissa-set! 0 #\1)
	     (increment! mantissa-dot-index)))
	(let ((digit (+ 1 (mantissa-digit-ref i))))
	  (set! carry (>= digit 10))
	  (mantissa-digit-set! i (if carry (- digit 10) digit))))))

  (when (and (= 0 mantissa-dot-index)
	     (= 0 number-of-digits))
    (mantissa-prepend-zeros 1)
    (increment! mantissa-dot-index))
  (let* ((i (+ mantissa-dot-index number-of-digits -1))
	 (j (+ 1 i)))
    (unless (= i mantissa-length)
      (receive (rounded-digit carry)
	  (compute-rounded-digit-with-carry (mantissa-digit-ref i) j)
	(mantissa-digit-set! i rounded-digit) ;;store the rounded digit
	(set! mantissa-length j)	      ;;truncate the tail digits
	(when carry (propagate-carry (- i 1)))))))



;;;; helpers, parsing flonums

(define (format:parse-flonum number-string normalisation-format scale)
  ;;Parse  the  flonum  representation  in  NUMBER-STRING,  filling  the
  ;;MANTISSA-* and  EXPONENT-* variables with the  result.  The argument
  ;;NORMALISATION-FORMAT  selects  how  the  mantissa and  exponent  are
  ;;normalised:
  ;;
  ;;* fixed-point
  ;;
  ;;* exponential
  ;;
  ;;The string rep in NUM-STR is expected to be one of the following:
  ;;
  ;;  "12"		"+12"		"-12"
  ;;  "12.345"		"+12.345"	"-12.345"
  ;;  "12.345e67"	"+12.345e67"	"-12.345e67"
  ;;  "12.345E67"	"+12.345E67"	"-12.345E67"
  ;;  "12.345e-67"	"+12.345e-67"	"-12.345e-67"
  ;;  "12.345E-67"	"+12.345E-67"	"-12.345E-67"
  ;;
  ;;everything  before the  'e' or  'E' char  is called  "mantissa", and
  ;;everything  after   is  called  "exponent".   We   accept  a  string
  ;;representation  that  starts with  "#d"  (which  is  the prefix  for
  ;;decimal representations).
  ;;
  ;;Notice that the integer part of the mantissa may be missing, that is
  ;;".123" is a valid string rep for "0.123".
  ;;
  ;;Notice that the fractional part of the mantissa may be missing, that
  ;;is "12." is a valid string rep for "12.0".
  ;;

  (initialise-flonum-variables)

  (when (string-prefix? "#d" number-string)
    (set! number-string (substring number-string
				   2 (string-length number-string))))

  (let ( ;This is #t while parsing  the mantissa, and becomes #f if/when
	;;the exponential is found.
	(mantissa?		#t)

	;;Once  the first  char of  the  mantissa or  exponent has  been
	;;parsed, some  characters are  no more allowed.   The following
	;;variables detect this.
	(mantissa-started?	#f)
	(exponent-started?	#f)

	;;Set to  #t if  all the  digits in the  mantissa are  zeros, #f
	;;otherwise.  It is used to detect a true zero like "0.0000".
	(all-zeros?		#t)

	;;The number of  zeros at the beginning of  the mantissa buffer.
	;;For this value it does not matter where the dot index is.
	(left-zeros		0)

	(number-len		(string-length number-string))

	(error-message		"invalid character in number string representation"))

    ;;This cycle parses the NUMBER-STRING.
    (do ((i 0 (+ i 1)))
	((= i number-len))
      (let ((ch (string-ref number-string i)))
	(cond

	 ((char-numeric? ch)
	  ;;Store   the   numeric  char   in   MANTISSA-BUFFER,  or   in
	  ;;EXPONENT-BUFFER.  Update  MANTISSA-LENGTH or EXPONENT-LENGTH
	  ;;accordingly.
	  (if mantissa?
	      (begin
		(set! mantissa-started? #t)
		(if (char=? ch #\0)
		    (when all-zeros?
		      (increment! left-zeros 1))
		  (set! all-zeros? #f))
		(string-set! mantissa-buffer mantissa-length ch)
		(increment! mantissa-length 1))
	    (begin
	      (set! exponent-started? #t)
	      (string-set! exponent-buffer exponent-length ch)
	      (increment! exponent-length 1))))

	 ((or (char=? ch #\-) (char=? ch #\+))
	  ;;Record the sign of the mantissa or exponent.  Raise an error
	  ;;if  the  sign  comes  inside  the  mantissa  or  inside  the
	  ;;exponent.
	  (let ((positive (char=? ch #\+)))
	    (if mantissa?
		(if mantissa-started?
		    (error 'format:parse-flonum error-message number-string)
		  (begin
		    (set! mantissa-is-positive positive)
		    (set! mantissa-started? #t)))
	      (if exponent-started?
		  (error 'format:parse-flonum error-message number-string)
		(begin
		  (set! exponent-is-positive positive)
		  (set! exponent-started? #t))))))

	 ((char=? ch #\.)
	  ;;Record the  index of  the first digit  after the dot  in the
	  ;;mantissa buffer.  Raise  an error if the dot  is found twice
	  ;;or if we are not parsing the mantissa.
	  (when (or mantissa-dot-index (not mantissa?))
	    (error 'format:parse-flonum error-message number-string))
	  (set! mantissa-dot-index mantissa-length))

	 ((or (char=? ch #\e) (char=? ch #\E))
	  ;;Record the end of mantissa  and start of exponent.  Raise an
	  ;;error if we are already parsing the exponent.
	  (unless mantissa?
	    (error 'format:parse-flonum error-message number-string))
	  (set! mantissa? #f))

	 (else
	  (error 'format:parse-flonum error-message ch)))))

    ;;Normalisation: if no dot in the input string, we put the dot index
    ;;at the end of the buffer.
    (when (not mantissa-dot-index)
      (set! mantissa-dot-index mantissa-length))

    ;;Normalisation: this  is when  all the digits  in the  mantissa are
    ;;zero,  we normalise  the values  so that  the mantissa  is  just a
    ;;single zero.
    (when all-zeros?
      (set! left-zeros		0)
      (set! mantissa-dot-index	0)
      (set! mantissa-length	1))

    ;;Parsing of NUMBER-STRING is finished.

    ;;Now we normalise the buffers according to the requested format.
    (case normalisation-format

      ((fixed-point)

       ;;Remove the leading zeros in the mantissa.  Examples:
       (when (and (> left-zeros 0)
		  (> mantissa-dot-index 0))
	 (cond ((> mantissa-dot-index left-zeros)
		;;Normalise buffers like:
		;;
		;;  "0000123.45" -> "123.45"
		;;
		(mantissa-shift-left left-zeros)
		(increment! mantissa-dot-index (- left-zeros))
		(set! left-zeros 0))
	       (else
		;;Normalise buffers like:
		;;
		;;  "000.000123" -> ".000123"
		;;
		(mantissa-shift-left mantissa-dot-index)
		(increment! left-zeros (- mantissa-dot-index))
		(set! mantissa-dot-index 0))))

       ;;Normalise buffers to have zero exponent.
       (unless (and (= 0 scale) (= 0 exponent-length) (not all-zeros?))
	 ;;SHIFT is  the number  of positions we  have to shift  the dot
	 ;;index to have zero exponent.  It may happen that shifting the
	 ;;dot index moves it outside the mantissa buffer, in which case
	 ;;we have to append or prepend zeros.
	 (let* ((shift			(+ scale (exponent-buffer->integer)))
		(shifted-dot-index	(+ mantissa-dot-index shift)))
	   (cond
	    ;;This is for cases like:
	    ;;
	    ;;  shift           = 5
	    ;;  mantissa-buffer = "123456"
	    ;;                        ^
	    ;;                  dot index = 3
	    ;;
	    ;;which must be normalised to:
	    ;;
	    ;;  mantissa-buffer = "12345600"
	    ;;                             ^
	    ;;                       dot index = 8
	    ;;
	    ((< mantissa-length shifted-dot-index)
	     (mantissa-append-zeros (- shift (- mantissa-length mantissa-dot-index)))
	     (set! mantissa-dot-index mantissa-length))

	    ;;This is for cases like:
	    ;;
	    ;;  shift           = -5
	    ;;  mantissa-buffer = "123456"
	    ;;                        ^
	    ;;                  dot index = 3
	    ;;
	    ;;which must be normalised to:
	    ;;
	    ;;  mantissa-buffer = "00123456"
	    ;;                     ^
	    ;;               dot index = 0
	    ;;
	    ((< shifted-dot-index 0)
	     (mantissa-prepend-zeros (- (- shift) mantissa-dot-index))
	     (set! mantissa-dot-index 0))

	    ;;The following are cases in which shifting does not require
	    ;;appending or prepending zeros,  but only to adjust the dot
	    ;;index.
	    ;;
	    ;;Remember that we have removed the leading zeros before the
	    ;;dot index, so there are only 2 cases: there are no leading
	    ;;zeros; there are leading zeros and the dot index is zero.

	    ;;This is for cases like:
	    ;;
	    ;;  shift           = 2
	    ;;  mantissa-buffer = "123456"
	    ;;                        ^
	    ;;                    dot index
	    ;;
	    ;;which must be normalised to:
	    ;;
	    ;;  mantissa-buffer = "123456"
	    ;;                          ^
	    ;;                      dot index
	    ;;
	    ((= 0 left-zeros)
	     (increment! mantissa-dot-index shift))

	    ;;This is for cases like:
	    ;;
	    ;;  shift           = 2
	    ;;  mantissa-buffer = "0000123456"
	    ;;                     ^
	    ;;                 dot index
	    ;;
	    ;;which must be normalised to:
	    ;;
	    ;;  mantissa-buffer = "00123456"
	    ;;                     ^
	    ;;                 dot index
	    ;;
	    ((<= shift left-zeros)
	     (mantissa-shift-left shift))

	    ;;This is for cases like:
	    ;;
	    ;;  shift           = 4
	    ;;  mantissa-buffer = "00123456789"
	    ;;                     ^
	    ;;                 dot index
	    ;;
	    ;;which must be normalised to:
	    ;;
	    ;;  mantissa-buffer = "123456789"
	    ;;                       ^
	    ;;                   dot index
	    ;;
	    (else
	     (mantissa-shift-left left-zeros)
	     (set! mantissa-dot-index (- shift left-zeros)))))))

      ((exponential)
       (let ((negexp (if (> left-zeros 0)
			 (- left-zeros mantissa-dot-index -1)
		       (if (= mantissa-dot-index 0) 1 0))))
	 (if (> left-zeros 0)
	     (begin ; normalize 0{0}.nnn to n.nn
	       (mantissa-shift-left left-zeros)
	       (set! mantissa-dot-index 1))
	   (when (= mantissa-dot-index 0)
	     (set! mantissa-dot-index 1)))
	 (integer->exponent-buffer (- (+ (- mantissa-dot-index scale)
					 (exponent-buffer->integer))
				      negexp))
	 (cond
	  (all-zeros?
	   (integer->exponent-buffer 0)
	   (set! mantissa-dot-index 1))
	  ((< scale 0) ; leading zero
	   (mantissa-prepend-zeros (- scale))
	   (set! mantissa-dot-index 0))
	  ((> scale mantissa-dot-index)
	   (mantissa-append-zeros (- scale mantissa-dot-index))
	   (set! mantissa-dot-index scale))
	  (else
	   (set! mantissa-dot-index scale)))))

      (else
       (error 'format:parse-flonum
	 "internal error, unknown flonum normalisation format"
	 normalisation-format)))))



;;;; helpers, flonums: fixed-point format

;;Print the  fixed point  string representation of  a number; it  is the
;;implementation of the "~f" escape sequence.
;;
;;This function  parses the NUMBER  into the MANTISSA-*  variables, then
;;formats a fixed point number.
(define (format:print-flonum-fixed-point modifier number parameters)
  (validate-flonum-argument number 'format:print-flonum-fixed-point)
  (let ((l (length parameters)))
    (let ((width	(format:par parameters l 0 #f "width"))
	  (decimals	(format:par parameters l 1 #f "decimals"))
	  (scale	(format:par parameters l 2 0  #f))
	  (overch	(format:par parameters l 3 #f #f))
	  (padch	(format:par parameters l 4 space-char-integer #f)))

      (let ((number-string (if (string? number)
			       number
			     (number->string (inexact number)))))

	(cond
	 ((member number-string '("+inf.0" "-inf.0" "+nan.0" "-nan.0"))
	  (format:print-inf-nan number-string width decimals #f overch padch))

	 (decimals
	  ;;This fills MANTISSA-* variables.
	  (format:parse-flonum number-string 'fixed-point scale)

	  ;;A number of decimals after the dot is requested: add them if
	  ;;missing or round and truncate decimals if too many.
	  (mantissa-adjust-decimals-as-requested decimals)

	  (if (not width)
	      (mantissa-print modifier #t)
	    ;;An output  width is requested.   We compute the  number of
	    ;;characters required to  output the mantissa, starting with
	    ;;digits in the buffer plus the dot char.
	    (let  ((output-len		(+ mantissa-length 1))
		   (prepend-zero	(> width (+ decimals 1))))
	      ;;Plus or minus sign.
	      (when (or (not mantissa-is-positive) (eq? modifier 'at))
		(increment! output-len))
	      ;;If mantissa's integer part is zero and it does not cause
	      ;;a  width overflow:  prepend  a "0."   to the  fractional
	      ;;part, else prepend only the dot.
	      (when (and (= mantissa-dot-index 0) prepend-zero)
		(increment! output-len))
	      ;;Output pad characters before the number.
	      (when (< output-len width)
		(format:print-fill-chars (- width output-len) (integer->char padch)))
	      ;;Output the number or the overflow chars.
	      (if (and overch (> output-len width))
		  (format:print-fill-chars width (integer->char overch))
		(mantissa-print modifier prepend-zero)))))

	 (else
	  ;;This fills MANTISSA-* variables.
	  (format:parse-flonum number-string 'fixed-point scale)
	  (mantissa-strip-tail-zeros)
	  (if (not width)
	      (mantissa-print modifier #t)
	    ;;An output  width is requested.   We compute the  number of
	    ;;characters required to  output the mantissa, starting with
	    ;;digits in the buffer plus the dot char.
	    (let ((output-len (+ mantissa-length 1)))
	      ;;Plus or minus sign.
	      (when (or (not mantissa-is-positive) (eq? modifier 'at))
		(increment! output-len))
	      ;;If mantissa's  integer part is  zero prepend a  "0."  to
	      ;;the fractional part.
	      (when (= mantissa-dot-index 0)
		(increment! output-len))
	      ;;Output pad characters before the number.
	      (when (< output-len width)
		(format:print-fill-chars (- width output-len) (integer->char padch)))
	      ;;Adjust precision if possible.   Beware that we can still
	      ;;be forced to output the overflow characters.
	      (if (<= output-len width)
		  (mantissa-print modifier #t)
		(let ((dot-index (- output-len
				    (- mantissa-length mantissa-dot-index))))
		  (if (> dot-index width)
		      (if overch
			  ;;too big for required width
			  (format:print-fill-chars width (integer->char overch))
			(mantissa-print modifier #t))
		    (begin
		      (mantissa-round-digits-after-dot (- width dot-index))
		      (mantissa-print modifier #t)))))))))))))


;;;; helpers, flonums: exponential format

;;Print the  exponential string representation  of a number.  It  is the
;;implementation of the "~e" escape sequence.
;;
;;This  function parses the  NUMBER into  the MANTISSA-*  and EXPONENT-*
;;variables, then formats an exponential number.
;;
(define (format:print-flonum-exponential modifier number parameters)
  (validate-flonum-argument number 'format:print-flonum-exponential)
  (let ((l (length parameters)))
    (let ((width	(format:par parameters l 0 #f "width"))
	  (decimals	(format:par parameters l 1 #f "decimals"))
	  (expdigits	(format:par parameters l 2 #f "expdigits"))
	  (intdigits	(format:par parameters l 3 1  #f))
	  (overflowchar	(format:par parameters l 4 #f #f))
	  (padchar	(format:par parameters l 5 space-char-integer #f))
	  (expchar	(format:par parameters l 6 #f #f)))

      (let ((number-string (if (string? number)
			       number
			     (number->string (inexact number)))))

	(define (compute-exponent-digits)
	  (if (and expdigits (> expdigits exponent-length))
	      expdigits
	    exponent-length))

	(define (print-padding-chars number-of-chars)
	  (format:print-fill-chars number-of-chars
				   (integer->char padchar)))

	(define (print-padding-chars-if-needed output-len)
	  (when (< output-len width)
	    (print-padding-chars (- width output-len))))

	(define (print-overflow-chars number-of-chars)
	  (format:print-fill-chars number-of-chars
				   (integer->char overflowchar)))

	(define print-number
	  (case-lambda
	   ((add-leading-zero?)
	    (mantissa-print modifier add-leading-zero?)
	    (exponent-print expdigits expchar))
	   (()
	    (print-number #t))))

	(cond
	 ((member number-string '("+inf.0" "-inf.0" "+nan.0" "-nan.0"))
	  (format:print-inf-nan number-string width expdigits #f overflowchar padchar))

	 (decimals ;;Requested decimals.

	  ;;We hand  INTDIGITS as SCALE  argument to FORMAT:PARSE-FLONUM.
	  ;;This can lead to the  following results for the mantissa and
	  ;;exponent:
	  ;;
	  ;;  INTDIGITS = 2   "1.2345" ->    "123.45e-2"
	  ;;  INTDIGITS = 4   "1.2345" ->  "12345.0e-4"
	  ;;  INTDIGITS = 5   "1.2345" -> "123450.0e-5"
	  ;;
	  ;;that   is:   decimals   may   disappear  from   the   number
	  ;;representation in the mantissa+exponent buffers.
	  ;;
	  ;;We  do not  care  about  this: if  the  user requested  both
	  ;;integer  and decimals  digits,  we print  them  even if  the
	  ;;decimals are all zeros.
	  ;;

;;;*** TO BE REMOVED ***
;;;
;;;This is a piece of code from the pre-MarcoMaggi swirling.  It detects
;;;the case  of positive INTDIGITS  and DECIMALS and does  some decimals
;;;normalisation that (in the opinion of MM) makes not sense at all.
;;;
;;; 	  (when (< 0 intdigits)
;;; 	    (set! decimals (if (< intdigits (+ decimals 2))
;;; 			       (+ (- decimals intdigits) 1)
;;; 			     0)))
;;;
;;;*** END TO BE REMOVED ***

	  ;;This fills MANTISSA-* and EXPONENT-* variables.
	  (format:parse-flonum number-string 'exponential intdigits)

	  ;;A  number of  decimals after  the dot  is requested:  if not
	  ;;enough are in the mantissa buffer, append zeros; if too many
	  ;;are in the mantissa buffer, round and truncate them.
	  (mantissa-adjust-decimals-as-requested decimals)

	  (cond
	   ;;If more exponent digits that requested are present: print
	   ;;the overflow chars.
	   ((and width expdigits overflowchar (> exponent-length expdigits))
	    (print-overflow-chars width))

	   (width
	    ;;Compute  the output  length starting  with  the mantissa
	    ;;plus the string ".E+" or ".E-".
	    (let ((output-len (+ mantissa-length 3)))
	      ;;Sign before the mantissa.
	      (when (or (not mantissa-is-positive) (eq? modifier 'at))
		(increment! output-len))

	      ;;If there  is room  and the integer  part is  zero: the
	      ;;mantissa will start with "0.", else it will start with
	      ;;"."; for example "0.123E+0" rather than ".123E+0".
	      (when (and (= mantissa-dot-index 0) (> width (+ decimals 1)))
		(increment! output-len))

	      ;;If more exponent digits  than present are required: we
	      ;;will   add  them   (with  the   appropriate   call  to
	      ;;EXPONENT-PRINT).
	      (increment! output-len (compute-exponent-digits))

	      ;;Print the padding chars before the number.
	      (print-padding-chars-if-needed output-len)

	      ;;Print the overflow chars or the number itself.
	      (if (and overflowchar (> output-len width))
		  (print-overflow-chars width)
		(print-number (> width (- output-len 1))))))

	   (else
	    ;;No width requested, so just print the number.
	    (print-number))))

	 (else ;;No decimals requested.
	  ;;This fills MANTISSA-* and EXPONENT-* variables.
	  (format:parse-flonum number-string 'exponential intdigits)
	  (mantissa-strip-tail-zeros)

	  (cond
	   ;;If more  exponent digits that requested  are present: print
	   ;;the overflow chars.
	   ((and width expdigits overflowchar (> exponent-length expdigits))
	    (print-overflow-chars width))

	   (width
	    ;;Compute the output length  starting with the mantissa plus
	    ;;the string ".E+" or ".E-".
	    (let ((output-len (+ mantissa-length 3)))
	      ;;Sign before the mantissa.
	      (when (or (not mantissa-is-positive) (eq? modifier 'at))
		(increment! output-len 1))

	      ;;If  the integer part  is zero:  the mantissa  will start
	      ;;with "0."  not only  "."; for example  "0.123E+0" rather
	      ;;than ".123E+0".
	      (when (= mantissa-dot-index 0)
		(increment! output-len 1))

	      ;;If more  exponent digits  than present are  required: we
	      ;;will   add   them   (with   the  appropriate   call   to
	      ;;EXPONENT-PRINT).
	      (increment! output-len (compute-exponent-digits))

	      ;;Print the padding chars before the number.
	      (print-padding-chars-if-needed output-len)

	      (if (<= output-len width)
		  (print-number)
		;;If rounding decimals is  enough to make the output fit
		;;the requested  width: do  it; else print  the overflow
		;;char, if given; else just print the number.
		(let* ((fractional-len	(- mantissa-length mantissa-dot-index))
		       (integer-len	(- output-len fractional-len))
		       (rounding-fixes	(<= integer-len width)))
		  (cond
		   (rounding-fixes
		    (mantissa-round-digits-after-dot (- width integer-len))
		    (print-number))
		   (overflowchar
		    (print-overflow-chars width))
		   (else
		    (print-number)))))))

	   (else
	    ;;No width requested, so just print the number.
	    (print-number)))))))))



;;;; helpers, flonums: dollar format

;;Print  the  dollar string  representation  of  a  number.  It  is  the
;;implementation of the "~$" escape sequence.
(define (format:print-flonum-dollar modifier number parameters)
  (validate-flonum-argument number 'format:print-flonum-dollar)
  (let ((l (length parameters)))
    (let ((decimals	(format:par parameters l 0 2 "decimals"))
	  (mindig	(format:par parameters l 1 1 "mindig"))
	  (width	(format:par parameters l 2 0 "width"))
	  (padch	(format:par parameters l 3 space-char-integer #f)))

      (let ((number-string (if (string? number)
			       number
			     (number->string (inexact number)))))

	(cond
	 ((member number-string '("+inf.0" "-inf.0" "+nan.0" "-nan.0"))
	  (format:print-inf-nan number-string width decimals #f #f padch))

	 (else
	  ;;This fills the internal state MANTISSA-* variables.
	  (format:parse-flonum number-string 'fixed-point 0)

	  ;;A number of  decimals after the dot is  requested: add them if
	  ;;missing or round and truncate decimals if too many.
	  (mantissa-adjust-decimals-as-requested decimals)

	  (let ((numlen (+ mantissa-length 1)))
	    (when (or (not mantissa-is-positive) (memq modifier '(at colon-at)))
	      (increment! numlen 1))
	    (when (and mindig (> mindig mantissa-dot-index))
	      (increment! numlen (- mindig mantissa-dot-index)))
	    (when (and (= mantissa-dot-index 0) (not mindig))
	      (increment! numlen 1))
	    (if (< numlen width)
		(case modifier
		  ((colon)
		   (if (not mantissa-is-positive)
		       (format:print-char #\-))
		   (format:print-fill-chars (- width numlen) (integer->char padch)))
		  ((at)
		   (format:print-fill-chars (- width numlen) (integer->char padch))
		   (format:print-char (if mantissa-is-positive #\+ #\-)))
		  ((colon-at)
		   (format:print-char (if mantissa-is-positive #\+ #\-))
		   (format:print-fill-chars (- width numlen) (integer->char padch)))
		  (else
		   (format:print-fill-chars (- width numlen) (integer->char padch))
		   (if (not mantissa-is-positive)
		       (format:print-char #\-))))
	      (if mantissa-is-positive
		  (if (memq modifier '(at colon-at)) (format:print-char #\+))
		(format:print-char #\-))))
	  (when (and mindig (> mindig mantissa-dot-index))
	    (format:print-fill-chars (- mindig mantissa-dot-index) #\0))
	  (when (and (= mantissa-dot-index 0) (not mindig))
	    (format:print-char #\0))
	  (format:print-substring mantissa-buffer 0 mantissa-dot-index)
	  (format:print-char #\.)
	  (format:print-substring mantissa-buffer mantissa-dot-index mantissa-length)))))))



;;;; helpers, tabulation

(define (format:tabulate modifier parameters)
  (let ((l (length parameters)))
    (let ((colnum	(format:par parameters l 0 1 "colnum"))
	  (padinc	(format:par parameters l 1 1 "padinc"))
	  (padch	(integer->char
			 (format:par parameters l 2 space-char-integer #f))))
      (case modifier
	((colon colon-at)
	 (error 'format:tabulate
	   "unsupported modifier for escape sequence ~t"
	   modifier))
	((at)	; relative tabulation
	 (format:print-fill-chars
	  (if (= padinc 0)
	      colnum ; colnum = colrel
	    (do ((c 0 (+ c padinc))
		 (col (+ format:output-col colnum)))
		((>= c col)
		 (- c format:output-col))))
	  padch))
	(else	; absolute tabulation
	 (format:print-fill-chars
	  (cond
	   ((< format:output-col colnum)
	    (- colnum format:output-col))
	   ((= padinc 0)
	    0)
	   (else
	    (do ((c colnum (+ c padinc)))
		((>= c format:output-col)
		 (- c format:output-col)))))
	  padch))))))


;;;; actual formatting

(define (format:format format-string arglist)
  (letrec
      ((format-string-len (string-length format-string))
       (arg-pos 0)		  ;argument position in arglist
       (arg-len (length arglist)) ;number of arguments
       (modifier #f)		  ;'colon | 'at | 'colon-at | #f
       (params '())		  ;directive parameter list
       (param-value-found #f)	  ;a directive parameter value found
       (conditional-nest 0)	  ;conditional nesting level
       (clause-pos 0)		  ;last cond. clause beginning char pos
       (clause-default #f)	  ;conditional default clause string
       (clauses '())		  ;conditional clause string list
       (conditional-type #f)	  ;reflects the contional modifiers
       (conditional-arg #f)	  ;argument to apply the conditional
       (iteration-nest 0)	  ;iteration nesting level
       (iteration-pos 0)	  ;iteration string beginning char pos
       (iteration-type #f)	  ;reflects the iteration modifiers
       (max-iterations #f)	  ;maximum number of iterations
       (recursive-pos-save format:pos))

    ;;Gets the next char from FORMAT-STRING.
    (define (next-char)
      (let ((ch (peek-next-char)))
	(set! format:pos (+ 1 format:pos))
	ch))

    (define (peek-next-char)
      (if (>= format:pos format-string-len)
	  (error 'format:format
	    "illegal format string")
	(string-ref format-string format:pos)))

    (define (one-positive-integer? params)
      (cond
       ((null? params)
	#f)
       ((and (integer? (car params))
	     (>= (car params) 0)
	     (= (length params) 1))
	#t)
       (else
	(error 'format:format
	  "one positive integer parameter expected"))))

    (define (next-arg)
      (when (>= arg-pos arg-len)
	(set! format:arg-pos (+ arg-len 1))
	(error 'format:format
	  "missing argument(s)"))
      (add-arg-pos 1)
      (list-ref arglist (- arg-pos 1)))

    (define (prev-arg)
      (add-arg-pos -1)
      (when (negative? arg-pos)
	(error 'format:format
	  "missing backward argument(s)"))
      (list-ref arglist arg-pos))

    (define (rest-args)
      (let loop ((l arglist) (k arg-pos)) ; list-tail definition
	(if (= k 0)
	    l
	  (loop (cdr l) (- k 1)))))

    (define (add-arg-pos n)
      (set! arg-pos (+ n arg-pos))
      (set! format:arg-pos arg-pos))

    ;;Dispatches the format-string.
    (define (anychar-dispatch)
      (if (>= format:pos format-string-len)
	  arg-pos ; used for ~? continuance
	(let ((char (next-char)))
	  (cond
	   ((char=? char #\~)
	    (set! modifier #f)
	    (set! params '())
	    (set! param-value-found #f)
	    (tilde-dispatch))
	   (else
	    (if (and (zero? conditional-nest)
		     (zero? iteration-nest))
		(format:print-char char))
	    (anychar-dispatch))))))

    (define (tilde-dispatch)
      (cond
       ((>= format:pos format-string-len)
	(format:print-string "~") ; tilde at end of
		; string is just
		; output
	arg-pos) ; used for ~?
		; continuance
       ((and (or (zero? conditional-nest)
		 (memv (peek-next-char) ; find conditional
		; directives
		       (append '(#\[ #\] #\; #\: #\@ #\^)
			       parameter-characters)))
	     (or (zero? iteration-nest)
		 (memv (peek-next-char) ; find iteration
		; directives
		       (append '(#\{ #\} #\: #\@ #\^)
			       parameter-characters))))
	(case (char-upcase (next-char))
	  ;; format directives
	  ((#\A) ; Any -- for humans
	   (set! format:read-proof
		 (memq modifier '(colon colon-at)))
	   (format:out-obj-padded (memq modifier '(at colon-at))
				  (next-arg) #f params)
	   (anychar-dispatch))
	  ((#\S) ; Slashified -- for parsers
	   (set! format:read-proof
		 (memq modifier '(colon colon-at)))
	   (format:out-obj-padded (memq modifier '(at colon-at))
				  (next-arg) #t params)
	   (anychar-dispatch))
	  ((#\D) ; Decimal
	   (format:out-num-padded modifier (next-arg) params 10)
	   (anychar-dispatch))
	  ((#\X) ; Hexadecimal
	   (format:out-num-padded modifier (next-arg) params 16)
	   (anychar-dispatch))
	  ((#\O) ; Octal
	   (format:out-num-padded modifier (next-arg) params 8)
	   (anychar-dispatch))
	  ((#\B) ; Binary
	   (format:out-num-padded modifier (next-arg) params 2)
	   (anychar-dispatch))
	  ((#\R)
	   (if (null? params)
	       (format:out-obj-padded ; Roman, cardinal, ordinal numerals
		#f
		((case modifier
		   ((at) format:num->roman)
		   ((colon-at) format:num->old-roman)
		   ((colon) format:num->ordinal)
		   (else format:num->cardinal))
		 (next-arg))
		#f params)
	     (format:out-num-padded ; any Radix
	      modifier (next-arg) (cdr params) (car params)))
	   (anychar-dispatch))
	  ((#\F) ; Fixed-format floating-point
	   (format:print-flonum-fixed-point modifier (next-arg) params)
	   (anychar-dispatch))
	  ((#\E) ; Exponential floating-point
	   (format:print-flonum-exponential modifier (next-arg) params)
	   (anychar-dispatch))
	  ((#\$) ; Dollars floating-point
	   (format:print-flonum-dollar modifier (next-arg) params)
	   (anychar-dispatch))
	  ((#\I) ; Complex numbers
	   (let ((z (next-arg)))
	     (when (not (complex? z))
	       (error 'format:format
		 "argument not a complex number"))
	     (format:print-flonum-fixed-point modifier (real-part z) params)
	     (format:print-flonum-fixed-point 'at      (imag-part z) params)
	     (format:print-char #\i))
	   (anychar-dispatch))
	  ((#\C) ; Character
	   (let ((ch (if (one-positive-integer? params)
			 (integer->char (car params))
		       (next-arg))))
	     (when (not (char? ch))
	       (error 'format:format
		 "escape sequence ~c expects a character"))
	     (case modifier
	       ((at)
		(format:print-string (format:char->str ch)))
	       ((colon)
		(let ((c (char->integer ch)))
		  (if (< c 0)
		      (set! c (+ c 256))) ; compensate
		; complement
		; impl.
		  (cond
		   ((< c #x20) ; assumes that control
		; chars are < #x20
		    (format:print-char #\^)
		    (format:print-char
		     (integer->char (+ c #x40))))
		   ((>= c #x7f)
		    (format:print-string "#\\")
		    (format:print-string (number->string c 8)))
		   (else
		    (format:print-char ch)))))
	       (else (format:print-char ch))))
	   (anychar-dispatch))
	  ((#\P) ; Plural
	   (if (memq modifier '(colon colon-at))
	       (prev-arg))
	   (let ((arg (next-arg)))
	     (when (not (number? arg))
	       (error 'format:format
		 "escape sequence ~p expects a number argument"))
	     (if (= arg 1)
		 (when (memq modifier '(at colon-at))
		   (format:print-char #\y))
	       (if (memq modifier '(at colon-at))
		   (format:print-string "ies")
		 (format:print-char #\s))))
	   (anychar-dispatch))
	  ((#\~) ; Tilde
	   (if (one-positive-integer? params)
	       (format:print-fill-chars (car params) #\~)
	     (format:print-char #\~))
	   (anychar-dispatch))
	  ((#\%) ; Newline
	   (if (one-positive-integer? params)
	       (format:print-fill-chars (car params) #\newline)
	     (format:print-char #\newline))
	   (set! format:output-col 0)
	   (anychar-dispatch))
	  ((#\&) ; Fresh line
	   (if (one-positive-integer? params)
	       (begin
		 (if (> (car params) 0)
		     (format:print-fill-chars (- (car params)
					 (if (>
					      format:output-col
					      0) 0 1))
				      #\newline))
		 (set! format:output-col 0))
	     (if (> format:output-col 0)
		 (format:print-char #\newline)))
	   (anychar-dispatch))
	  ((#\_) ; Space character
	   (if (one-positive-integer? params)
	       (format:print-fill-chars (car params) #\space)
	     (format:print-char #\space))
	   (anychar-dispatch))
	  ((#\/) ; Tabulator character
	   (if (one-positive-integer? params)
	       (format:print-fill-chars (car params) #\tab)
	     (format:print-char #\tab))
	   (anychar-dispatch))
	  ((#\|) ; Page seperator
	   (if (one-positive-integer? params)
	       (format:print-fill-chars (car params) #\page)
	     (format:print-char #\page))
	   (set! format:output-col 0)
	   (anychar-dispatch))
	  ((#\T) ; Tabulate
	   (format:tabulate modifier params)
	   (anychar-dispatch))
	  ((#\Y) ; Pretty-print
	   (pretty-print (next-arg) destination-port)
	   (set! format:output-col 0)
	   (anychar-dispatch))
	  ((#\? #\K) ; Indirection (is "~K" in T-Scheme)
	   (cond
	    ((memq modifier '(colon colon-at))
	     (error 'format:format
	       "illegal modifier in escape sequence ~?"))
	    ((eq? modifier 'at)
	     (let* ((frmt (next-arg))
		    (args (rest-args)))
	       (add-arg-pos (format:format frmt args))))
	    (else
	     (let* ((frmt (next-arg))
		    (args (next-arg)))
	       (format:format frmt args))))
	   (anychar-dispatch))
	  ((#\!) ; Flush output
	   (set! format:flush-output #t)
	   (anychar-dispatch))
	  ((#\newline) ; Continuation lines
	   (if (eq? modifier 'at)
	       (format:print-char #\newline))
	   (if (< format:pos format-string-len)
	       (do ((ch (peek-next-char) (peek-next-char)))
		   ((or (not (char-whitespace? ch))
			(= format:pos (- format-string-len 1))))
		 (if (eq? modifier 'colon)
		     (format:print-char (next-char))
		   (next-char))))
	   (anychar-dispatch))
	  ((#\*) ; Argument jumping
	   (case modifier
	     ((colon) ; jump backwards
	      (if (one-positive-integer? params)
		  (do ((i 0 (+ i 1)))
		      ((= i (car params)))
		    (prev-arg))
		(prev-arg)))
	     ((at) ; jump absolute
	      (set! arg-pos (if (one-positive-integer? params)
				(car params) 0)))
	     ((colon-at)
	      (error 'format:format
		"illegal modifier `:@' in escape sequence ~*"))
	     (else ; jump forward
	      (if (one-positive-integer? params)
		  (do ((i 0 (+ i 1)))
		      ((= i (car params)))
		    (next-arg))
		(next-arg))))
	   (anychar-dispatch))
	  ((#\() ; Case conversion begin
	   (set! format:case-conversion
		 (case modifier
		   ((at)	string-titlecase/first)
		   ((colon)	string-titlecase)
		   ((colon-at)	string-upcase)
		   (else	string-downcase)))
	   (anychar-dispatch))
	  ((#\)) ; Case conversion end
	   (when (not format:case-conversion)
	     (error 'format:format
	       "missing escape sequence ~("))
	   (set! format:case-conversion #f)
	   (anychar-dispatch))
	  ((#\[) ; Conditional begin
	   (set! conditional-nest (+ conditional-nest 1))
	   (cond
	    ((= conditional-nest 1)
	     (set! clause-pos format:pos)
	     (set! clause-default #f)
	     (set! clauses '())
	     (set! conditional-type
		   (case modifier
		     ((at) 'if-then)
		     ((colon) 'if-else-then)
		     ((colon-at)
		      (error 'format:format
			"illegal modifier in escape sequence ~["))
		     (else 'num-case)))
	     (set! conditional-arg
		   (if (one-positive-integer? params)
		       (car params)
		     (next-arg)))))
	   (anychar-dispatch))
	  ((#\;) ; Conditional separator
	   (when (zero? conditional-nest)
	     (error 'format:format
	       "escape sequence ~; not in ~[~] conditional"))
	   (when (not (null? params))
	     (error 'format:format
	       "no parameter allowed in ~~;"))
	   (when (= conditional-nest 1)
	     (let ((clause-str
		    (cond
		     ((eq? modifier 'colon)
		      (set! clause-default #t)
		      (substring format-string clause-pos
				 (- format:pos 3)))
		     ((memq modifier '(at colon-at))
		      (error 'format:format
			"illegal modifier in escape sequence ~;"))
		     (else
		      (substring format-string clause-pos
				 (- format:pos 2))))))
	       (set! clauses (append clauses (list clause-str)))
	       (set! clause-pos format:pos)))
	   (anychar-dispatch))
	  ((#\]) ; Conditional end
	   (when (zero? conditional-nest)
	     (error 'format:format
	       "missing escape sequence ~["))
	   (set! conditional-nest (- conditional-nest 1))
	   (when modifier
	     (error 'format:format
	       "no modifier allowed in escape sequence ~]"))
	   (when (not (null? params))
	     (error 'format:format
	       "no parameter allowed in escape sequence ~]"))
	   (cond
	    ((zero? conditional-nest)
	     (let ((clause-str (substring format-string clause-pos
					  (- format:pos 2))))
	       (if clause-default
		   (set! clause-default clause-str)
		 (set! clauses (append clauses (list clause-str)))))
	     (case conditional-type
	       ((if-then)
		(if conditional-arg
		    (format:format (car clauses)
					(list conditional-arg))))
	       ((if-else-then)
		(add-arg-pos
		 (format:format (if conditional-arg
					 (cadr clauses)
				       (car clauses))
				     (rest-args))))
	       ((num-case)
		(when (or (not (integer? conditional-arg))
			  (< conditional-arg 0))
		  (error 'format:format
		    "argument not a positive integer"))
		(when (not (and (>= conditional-arg (length clauses))
				(not clause-default)))
		  (add-arg-pos
		   (format:format
		    (if (>= conditional-arg (length clauses))
			clause-default
		      (list-ref clauses conditional-arg))
		    (rest-args))))))))
	   (anychar-dispatch))
	  ((#\{) ; Iteration begin
	   (set! iteration-nest (+ iteration-nest 1))
	   (cond
	    ((= iteration-nest 1)
	     (set! iteration-pos format:pos)
	     (set! iteration-type
		   (case modifier
		     ((at) 'rest-args)
		     ((colon) 'sublists)
		     ((colon-at) 'rest-sublists)
		     (else 'list)))
	     (set! max-iterations (if (one-positive-integer? params)
				      (car params) #f))))
	   (anychar-dispatch))
	  ((#\}) ; Iteration end
	   (when (zero? iteration-nest)
	     (error 'format:format
	       "missing in escape sequence ~{"))
	   (set! iteration-nest (- iteration-nest 1))
	   (case modifier
	     ((colon)
	      (when (not max-iterations)
		(set! max-iterations 1)))
	     ((colon-at at)
	      (error 'format:format
		"illegal modifier")))
	   (when (not (null? params))
	     (error 'format:format
	       "no parameters allowed in escape sequence ~}"))
	   (if (zero? iteration-nest)
	       (let ((iteration-str
		      (substring format-string iteration-pos
				 (- format:pos (if modifier 3 2)))))
		 (if (string=? iteration-str "")
		     (set! iteration-str (next-arg)))
		 (case iteration-type
		   ((list)
		    (let ((args (next-arg))
			  (args-len 0))
		      (when (not (list? args))
			(error 'format:format
			  "expected a list argument"))
		      (set! args-len (length args))
		      (do ((arg-pos 0 (+ arg-pos
					 (format:format
					  iteration-str
					  (list-tail args arg-pos))))
			   (i 0 (+ i 1)))
			  ((or (>= arg-pos args-len)
			       (and max-iterations
				    (>= i max-iterations)))))))
		   ((sublists)
		    (let ((args (next-arg))
			  (args-len 0))
		      (when (not (list? args))
			(error 'format:format
			  "expected a list argument"))
		      (set! args-len (length args))
		      (do ((arg-pos 0 (+ arg-pos 1)))
			  ((or (>= arg-pos args-len)
			       (and max-iterations
				    (>= arg-pos max-iterations))))
			(let ((sublist (list-ref args arg-pos)))
			  (when (not (list? sublist))
			    (error 'format:format
			      "expected a list of lists argument"))
			  (format:format iteration-str sublist)))))
		   ((rest-args)
		    (let* ((args (rest-args))
			   (args-len (length args))
			   (usedup-args
			    (do ((arg-pos 0 (+ arg-pos
					       (format:format
						iteration-str
						(list-tail
						 args arg-pos))))
				 (i 0 (+ i 1)))
				((or (>= arg-pos args-len)
				     (and max-iterations
					  (>= i max-iterations)))
				 arg-pos))))
		      (add-arg-pos usedup-args)))
		   ((rest-sublists)
		    (let* ((args (rest-args))
			   (args-len (length args))
			   (usedup-args
			    (do ((arg-pos 0 (+ arg-pos 1)))
				((or (>= arg-pos args-len)
				     (and max-iterations
					  (>= arg-pos max-iterations)))
				 arg-pos)
			      (let ((sublist (list-ref args arg-pos)))
				(when (not (list? sublist))
				  (error 'format:format
				    "expected list arguments"))
				(format:format iteration-str sublist)))))
		      (add-arg-pos usedup-args)))
		   (else
		    (error 'format:format
		      "internal error in escape sequence ~}")))))
	   (anychar-dispatch))
	  ((#\^) ; Up and out
	   (let* ((continue
		   (cond
		    ((not (null? params))
		     (not
		      (case (length params)
			((1) (zero? (car params)))
			((2) (= (list-ref params 0) (list-ref params 1)))
			((3) (<= (list-ref params 0)
				 (list-ref params 1)
				 (list-ref params 2)))
			(else
			 (error 'format:format
			   "too much parameters")))))
		    (format:case-conversion ; if conversion stop conversion
		     (set! format:case-conversion string-copy) #t)
		    ((= iteration-nest 1) #t)
		    ((= conditional-nest 1) #t)
		    ((>= arg-pos arg-len)
		     (set! format:pos format-string-len) #f)
		    (else #t))))
	     (if continue
		 (anychar-dispatch))))

	  ;; format directive modifiers and parameters

	  ((#\@) ; `@' modifier
	   (when (memq modifier '(at colon-at))
	     (error 'format:format
	       "double `@' modifier"))
	   (set! modifier (if (eq? modifier 'colon) 'colon-at 'at))
	   (tilde-dispatch))
	  ((#\:) ; `:' modifier
	   (when (memq modifier '(colon colon-at))
	     (error 'format:format
	       "double escape sequence `:' modifier"))
	   (set! modifier (if (eq? modifier 'at) 'colon-at 'colon))
	   (tilde-dispatch))
	  ((#\') ; Character parameter
	   (when modifier
	     (error 'format:format
	       "misplaced escape sequence modifier"))
	   (set! params (append params (list (char->integer (next-char)))))
	   (set! param-value-found #t)
	   (tilde-dispatch))
	  ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9 #\- #\+) ; num. paramtr
	   (when modifier
	     (error 'format:format
	       "misplaced escape sequence modifier"))
	   (let ((num-str-beg (- format:pos 1))
		 (num-str-end format:pos))
	     (do ((ch (peek-next-char) (peek-next-char)))
		 ((not (char-numeric? ch)))
	       (next-char)
	       (set! num-str-end (+ 1 num-str-end)))
	     (set! params
		   (append params
			   (list (string->number
				  (substring format-string
					     num-str-beg
					     num-str-end))))))
	   (set! param-value-found #t)
	   (tilde-dispatch))
	  ((#\V) ; Variable parameter from next argum.
	   (when modifier
	     (error 'format:format
	       "misplaced escape sequence modifier"))
	   (set! params (append params (list (next-arg))))
	   (set! param-value-found #t)
	   (tilde-dispatch))
	  ((#\#) ; Parameter is number of remaining args
	   (when param-value-found
	     (error 'format:format
	       "misplaced '#'"))
	   (when modifier
	     (error 'format:format
	       "misplaced escape sequence modifier"))
	   (set! params (append params (list (length (rest-args)))))
	   (set! param-value-found #t)
	   (tilde-dispatch))
	  ((#\,) ; Parameter separators
	   (when modifier
	     (error 'format:format
	       "misplaced escape sequence modifier"))
	   (if (not param-value-found)
	       (set! params (append params '(#f)))) ; append empty paramtr
	   (set! param-value-found #f)
	   (tilde-dispatch))
	  (else ; Unknown tilde directive
	   (error 'format:format
	     "unknown control character"
	     (string-ref format-string (- format:pos 1))))))
       (else
	(anychar-dispatch)))) ; in case of conditional

    (set! format:pos 0)
    (set! format:arg-pos 0)
    (anychar-dispatch) ; start the formatting
    (set! format:pos recursive-pos-save)

    ;;Return the position in the arguments list.
    arg-pos))


;;;; body of FORMAT

(format:dispatch-arguments arg0 args)))


;;; end of file
