;;; -*- coding: utf-8-unix -*-
;;;
;;;Part of: Nausicaa/Scheme
;;;Contents: tests for base32 ASCII armor of bytevectors
;;;Date: Sat Jan 30, 2010
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
  (armor base32)
  (armor conditions)
  (checks)
  (parameters))

(check-set-mode! 'report-failed)
(display "*** testing ASCII armor base32\n")


;;;; helpers

(define (subbytevector src start past)
  (let ((dst (make-bytevector (- past start))))
    (do ((i 0 (+ 1 i))
	 (j start (+ 1 j)))
	((= j past)
	 dst)
      (bytevector-u8-set! dst i (bytevector-u8-ref src j)))))


;;;; parameters

(define encoding
  (make-parameter #t))

(define padding?
  (make-parameter #t))

(define encoding-case
  (make-parameter #t))


;;;; base32 test vectors

(define test-vectors
  ;; binary			encoded padded		encoded non-padded
  '((""				""			"")
    ("f"			"MY======"		"MY")
    ("fo"			"MZXQ===="		"MZXQ")
    ("foo"			"MZXW6==="		"MZXW6")
    ("foob"			"MZXW6YQ="		"MZXW6YQ")
    ("fooba"			"MZXW6YTB"		"MZXW6YTB")
    ("foobar"			"MZXW6YTBOI======"	"MZXW6YTBOI")
    (" "			"EA======"		"EA")
    ("  "			"EAQA===="		"EAQA")
    ("   "			"EAQCA==="		"EAQCA")
    ("    "			"EAQCAIA="		"EAQCAIA")
    ("     "			"EAQCAIBA"		"EAQCAIBA")
    ("      "			"EAQCAIBAEA======"	"EAQCAIBAEA")
    (#vu8(#o000)		"AA======"		"AA")
    (#vu8(#o010)		"BA======"		"BA")
    (#vu8(#o020)		"CA======"		"CA")
    (#vu8(#o030)		"DA======"		"DA")
    (#vu8(#o001)		"AE======"		"AE")
    (#vu8(#o011)		"BE======"		"BE")
    (#vu8(#o021)		"CE======"		"CE")
    (#vu8(#o031)		"DE======"		"DE")
    (#vu8(#o002)		"AI======"		"AI")
    (#vu8(#o012)		"BI======"		"BI")
    (#vu8(#o022)		"CI======"		"CI")
    (#vu8(#o032)		"DI======"		"DI")
    (#vu8(#o003)		"AM======"		"AM")
    (#vu8(#o013)		"BM======"		"BM")
    (#vu8(#o023)		"CM======"		"CM")
    (#vu8(#o033)		"DM======"		"DM")
    (#vu8(#o004)		"AQ======"		"AQ")
    (#vu8(#o014)		"BQ======"		"BQ")
    (#vu8(#o024)		"CQ======"		"CQ")
    (#vu8(#o034)		"DQ======"		"DQ")
    (#vu8(#o005)		"AU======"		"AU")
    (#vu8(#o015)		"BU======"		"BU")
    (#vu8(#o025)		"CU======"		"CU")
    (#vu8(#o035)		"DU======"		"DU")
    (#vu8(#o006)		"AY======"		"AY")
    (#vu8(#o016)		"BY======"		"BY")
    (#vu8(#o026)		"CY======"		"CY")
    (#vu8(#o036)		"DY======"		"DY")
    (#vu8(#o007)		"A4======"		"A4")
    (#vu8(#o017)		"B4======"		"B4")
    (#vu8(#o027)		"C4======"		"C4")
    (#vu8(#o037)		"D4======"		"D4")
    (#vu8(#o040)		"EA======"		"EA")
    (#vu8(#o050)		"FA======"		"FA")
    (#vu8(#o060)		"GA======"		"GA")
    (#vu8(#o070)		"HA======"		"HA")
    (#vu8(#o041)		"EE======"		"EE")
    (#vu8(#o051)		"FE======"		"FE")
    (#vu8(#o061)		"GE======"		"GE")
    (#vu8(#o071)		"HE======"		"HE")
    (#vu8(#o042)		"EI======"		"EI")
    (#vu8(#o052)		"FI======"		"FI")
    (#vu8(#o062)		"GI======"		"GI")
    (#vu8(#o072)		"HI======"		"HI")
    (#vu8(#o043)		"EM======"		"EM")
    (#vu8(#o053)		"FM======"		"FM")
    (#vu8(#o063)		"GM======"		"GM")
    (#vu8(#o073)		"HM======"		"HM")
    (#vu8(#o044)		"EQ======"		"EQ")
    (#vu8(#o054)		"FQ======"		"FQ")
    (#vu8(#o064)		"GQ======"		"GQ")
    (#vu8(#o074)		"HQ======"		"HQ")
    (#vu8(#o045)		"EU======"		"EU")
    (#vu8(#o055)		"FU======"		"FU")
    (#vu8(#o065)		"GU======"		"GU")
    (#vu8(#o075)		"HU======"		"HU")
    (#vu8(#o046)		"EY======"		"EY")
    (#vu8(#o056)		"FY======"		"FY")
    (#vu8(#o066)		"GY======"		"GY")
    (#vu8(#o076)		"HY======"		"HY")
    (#vu8(#o047)		"E4======"		"E4")
    (#vu8(#o057)		"F4======"		"F4")
    (#vu8(#o067)		"G4======"		"G4")
    (#vu8(#o077)		"H4======"		"H4")
    (#vu8(#o100)		"IA======"		"IA")
    (#vu8(#o110)		"JA======"		"JA")
    (#vu8(#o120)		"KA======"		"KA")
    (#vu8(#o130)		"LA======"		"LA")
    (#vu8(#o101)		"IE======"		"IE")
    (#vu8(#o111)		"JE======"		"JE")
    (#vu8(#o121)		"KE======"		"KE")
    (#vu8(#o131)		"LE======"		"LE")
    (#vu8(#o102)		"II======"		"II")
    (#vu8(#o112)		"JI======"		"JI")
    (#vu8(#o122)		"KI======"		"KI")
    (#vu8(#o132)		"LI======"		"LI")
    (#vu8(#o103)		"IM======"		"IM")
    (#vu8(#o113)		"JM======"		"JM")
    (#vu8(#o123)		"KM======"		"KM")
    (#vu8(#o133)		"LM======"		"LM")
    (#vu8(#o104)		"IQ======"		"IQ")
    (#vu8(#o114)		"JQ======"		"JQ")
    (#vu8(#o124)		"KQ======"		"KQ")
    (#vu8(#o134)		"LQ======"		"LQ")
    (#vu8(#o105)		"IU======"		"IU")
    (#vu8(#o115)		"JU======"		"JU")
    (#vu8(#o125)		"KU======"		"KU")
    (#vu8(#o135)		"LU======"		"LU")
    (#vu8(#o106)		"IY======"		"IY")
    (#vu8(#o116)		"JY======"		"JY")
    (#vu8(#o126)		"KY======"		"KY")
    (#vu8(#o136)		"LY======"		"LY")
    (#vu8(#o107)		"I4======"		"I4")
    (#vu8(#o117)		"J4======"		"J4")
    (#vu8(#o127)		"K4======"		"K4")
    (#vu8(#o137)		"L4======"		"L4")
    (#vu8(#o140)		"MA======"		"MA")
    (#vu8(#o150)		"NA======"		"NA")
    (#vu8(#o160)		"OA======"		"OA")
    (#vu8(#o170)		"PA======"		"PA")
    (#vu8(#o141)		"ME======"		"ME")
    (#vu8(#o151)		"NE======"		"NE")
    (#vu8(#o161)		"OE======"		"OE")
    (#vu8(#o171)		"PE======"		"PE")
    (#vu8(#o142)		"MI======"		"MI")
    (#vu8(#o152)		"NI======"		"NI")
    (#vu8(#o162)		"OI======"		"OI")
    (#vu8(#o172)		"PI======"		"PI")
    (#vu8(#o143)		"MM======"		"MM")
    (#vu8(#o153)		"NM======"		"NM")
    (#vu8(#o163)		"OM======"		"OM")
    (#vu8(#o173)		"PM======"		"PM")
    (#vu8(#o144)		"MQ======"		"MQ")
    (#vu8(#o154)		"NQ======"		"NQ")
    (#vu8(#o164)		"OQ======"		"OQ")
    (#vu8(#o174)		"PQ======"		"PQ")
    (#vu8(#o145)		"MU======"		"MU")
    (#vu8(#o155)		"NU======"		"NU")
    (#vu8(#o165)		"OU======"		"OU")
    (#vu8(#o175)		"PU======"		"PU")
    (#vu8(#o146)		"MY======"		"MY")
    (#vu8(#o156)		"NY======"		"NY")
    (#vu8(#o166)		"OY======"		"OY")
    (#vu8(#o176)		"PY======"		"PY")
    (#vu8(#o147)		"M4======"		"M4")
    (#vu8(#o157)		"N4======"		"N4")
    (#vu8(#o167)		"O4======"		"O4")
    (#vu8(#o177)		"P4======"		"P4")
    (#vu8(#o200)		"QA======"		"QA")
    (#vu8(#o210)		"RA======"		"RA")
    (#vu8(#o220)		"SA======"		"SA")
    (#vu8(#o230)		"TA======"		"TA")
    (#vu8(#o201)		"QE======"		"QE")
    (#vu8(#o211)		"RE======"		"RE")
    (#vu8(#o221)		"SE======"		"SE")
    (#vu8(#o231)		"TE======"		"TE")
    (#vu8(#o202)		"QI======"		"QI")
    (#vu8(#o212)		"RI======"		"RI")
    (#vu8(#o222)		"SI======"		"SI")
    (#vu8(#o232)		"TI======"		"TI")
    (#vu8(#o203)		"QM======"		"QM")
    (#vu8(#o213)		"RM======"		"RM")
    (#vu8(#o223)		"SM======"		"SM")
    (#vu8(#o233)		"TM======"		"TM")
    (#vu8(#o204)		"QQ======"		"QQ")
    (#vu8(#o214)		"RQ======"		"RQ")
    (#vu8(#o224)		"SQ======"		"SQ")
    (#vu8(#o234)		"TQ======"		"TQ")
    (#vu8(#o205)		"QU======"		"QU")
    (#vu8(#o215)		"RU======"		"RU")
    (#vu8(#o225)		"SU======"		"SU")
    (#vu8(#o235)		"TU======"		"TU")
    (#vu8(#o206)		"QY======"		"QY")
    (#vu8(#o216)		"RY======"		"RY")
    (#vu8(#o226)		"SY======"		"SY")
    (#vu8(#o236)		"TY======"		"TY")
    (#vu8(#o207)		"Q4======"		"Q4")
    (#vu8(#o217)		"R4======"		"R4")
    (#vu8(#o227)		"S4======"		"S4")
    (#vu8(#o237)		"T4======"		"T4")
    (#vu8(#o240)		"UA======"		"UA")
    (#vu8(#o250)		"VA======"		"VA")
    (#vu8(#o260)		"WA======"		"WA")
    (#vu8(#o270)		"XA======"		"XA")
    (#vu8(#o241)		"UE======"		"UE")
    (#vu8(#o251)		"VE======"		"VE")
    (#vu8(#o261)		"WE======"		"WE")
    (#vu8(#o271)		"XE======"		"XE")
    (#vu8(#o242)		"UI======"		"UI")
    (#vu8(#o252)		"VI======"		"VI")
    (#vu8(#o262)		"WI======"		"WI")
    (#vu8(#o272)		"XI======"		"XI")
    (#vu8(#o243)		"UM======"		"UM")
    (#vu8(#o253)		"VM======"		"VM")
    (#vu8(#o263)		"WM======"		"WM")
    (#vu8(#o273)		"XM======"		"XM")
    (#vu8(#o244)		"UQ======"		"UQ")
    (#vu8(#o254)		"VQ======"		"VQ")
    (#vu8(#o264)		"WQ======"		"WQ")
    (#vu8(#o274)		"XQ======"		"XQ")
    (#vu8(#o245)		"UU======"		"UU")
    (#vu8(#o255)		"VU======"		"VU")
    (#vu8(#o265)		"WU======"		"WU")
    (#vu8(#o275)		"XU======"		"XU")
    (#vu8(#o246)		"UY======"		"UY")
    (#vu8(#o256)		"VY======"		"VY")
    (#vu8(#o266)		"WY======"		"WY")
    (#vu8(#o276)		"XY======"		"XY")
    (#vu8(#o247)		"U4======"		"U4")
    (#vu8(#o257)		"V4======"		"V4")
    (#vu8(#o267)		"W4======"		"W4")
    (#vu8(#o277)		"X4======"		"X4")
    (#vu8(#o300)		"YA======"		"YA")
    (#vu8(#o310)		"ZA======"		"ZA")
    (#vu8(#o320)		"2A======"		"2A")
    (#vu8(#o330)		"3A======"		"3A")
    (#vu8(#o301)		"YE======"		"YE")
    (#vu8(#o311)		"ZE======"		"ZE")
    (#vu8(#o321)		"2E======"		"2E")
    (#vu8(#o331)		"3E======"		"3E")
    (#vu8(#o302)		"YI======"		"YI")
    (#vu8(#o312)		"ZI======"		"ZI")
    (#vu8(#o322)		"2I======"		"2I")
    (#vu8(#o332)		"3I======"		"3I")
    (#vu8(#o303)		"YM======"		"YM")
    (#vu8(#o313)		"ZM======"		"ZM")
    (#vu8(#o323)		"2M======"		"2M")
    (#vu8(#o333)		"3M======"		"3M")
    (#vu8(#o304)		"YQ======"		"YQ")
    (#vu8(#o314)		"ZQ======"		"ZQ")
    (#vu8(#o324)		"2Q======"		"2Q")
    (#vu8(#o334)		"3Q======"		"3Q")
    (#vu8(#o305)		"YU======"		"YU")
    (#vu8(#o315)		"ZU======"		"ZU")
    (#vu8(#o325)		"2U======"		"2U")
    (#vu8(#o335)		"3U======"		"3U")
    (#vu8(#o306)		"YY======"		"YY")
    (#vu8(#o316)		"ZY======"		"ZY")
    (#vu8(#o326)		"2Y======"		"2Y")
    (#vu8(#o336)		"3Y======"		"3Y")
    (#vu8(#o307)		"Y4======"		"Y4")
    (#vu8(#o317)		"Z4======"		"Z4")
    (#vu8(#o327)		"24======"		"24")
    (#vu8(#o337)		"34======"		"34")
    (#vu8(#o340)		"4A======"		"4A")
    (#vu8(#o350)		"5A======"		"5A")
    (#vu8(#o360)		"6A======"		"6A")
    (#vu8(#o370)		"7A======"		"7A")
    (#vu8(#o341)		"4E======"		"4E")
    (#vu8(#o351)		"5E======"		"5E")
    (#vu8(#o361)		"6E======"		"6E")
    (#vu8(#o371)		"7E======"		"7E")
    (#vu8(#o342)		"4I======"		"4I")
    (#vu8(#o352)		"5I======"		"5I")
    (#vu8(#o362)		"6I======"		"6I")
    (#vu8(#o372)		"7I======"		"7I")
    (#vu8(#o343)		"4M======"		"4M")
    (#vu8(#o353)		"5M======"		"5M")
    (#vu8(#o363)		"6M======"		"6M")
    (#vu8(#o373)		"7M======"		"7M")
    (#vu8(#o344)		"4Q======"		"4Q")
    (#vu8(#o354)		"5Q======"		"5Q")
    (#vu8(#o364)		"6Q======"		"6Q")
    (#vu8(#o374)		"7Q======"		"7Q")
    (#vu8(#o345)		"4U======"		"4U")
    (#vu8(#o355)		"5U======"		"5U")
    (#vu8(#o365)		"6U======"		"6U")
    (#vu8(#o375)		"7U======"		"7U")
    (#vu8(#o346)		"4Y======"		"4Y")
    (#vu8(#o356)		"5Y======"		"5Y")
    (#vu8(#o366)		"6Y======"		"6Y")
    (#vu8(#o376)		"7Y======"		"7Y")
    (#vu8(#o347)		"44======"		"44")
    (#vu8(#o357)		"54======"		"54")
    (#vu8(#o367)		"64======"		"64")
    (#vu8(#o377)		"74======"		"74")

    ("Le Poete est semblable au prince des nuees Qui hante la tempete e se rit de l'archer; Exile sul le sol au milieu des huees, Ses ailes de geant l'empechent de marcher."
     "JRSSAUDPMV2GKIDFON2CA43FNVRGYYLCNRSSAYLVEBYHE2LOMNSSAZDFOMQG45LFMVZSAULVNEQGQYLOORSSA3DBEB2GK3LQMV2GKIDFEBZWKIDSNF2CAZDFEBWCOYLSMNUGK4R3EBCXQ2LMMUQHG5LMEBWGKIDTN5WCAYLVEBWWS3DJMV2SAZDFOMQGQ5LFMVZSYICTMVZSAYLJNRSXGIDEMUQGOZLBNZ2CA3BHMVWXAZLDNBSW45BAMRSSA3LBOJRWQZLSFY======"
     "JRSSAUDPMV2GKIDFON2CA43FNVRGYYLCNRSSAYLVEBYHE2LOMNSSAZDFOMQG45LFMVZSAULVNEQGQYLOORSSA3DBEB2GK3LQMV2GKIDFEBZWKIDSNF2CAZDFEBWCOYLSMNUGK4R3EBCXQ2LMMUQHG5LMEBWGKIDTN5WCAYLVEBWWS3DJMV2SAZDFOMQGQ5LFMVZSYICTMVZSAYLJNRSXGIDEMUQGOZLBNZ2CA3BHMVWXAZLDNBSW45BAMRSSA3LBOJRWQZLSFY")))


;;;; base32 encoding and decoding routines

(define (encode binary)
  ;;Encode BINARY which  must be a Scheme string  or bytevector.  Return
  ;;tow values: the result boolean from the encoding functions, a string
  ;;representing the encoded data.
  ;;
  ;;Make use of the ENCODING, PADDING? and ENCODING-CASE parameters.
  ;;
  (let* ((ctx		(make-<base32-encode-ctx> (encoding) (padding?) (encoding-case)))
	 (src		(if (string? binary) (string->utf8 binary) binary))
	 (src-len	(bytevector-length src))
	 (dst		(make-bytevector (base32-encode-length src-len (padding?)))))
    (receive (dst-next src-next)
	(base32-encode-update! ctx dst 0 src 0 src-len)
      (receive (result dst-next src-next)
	  (base32-encode-final! ctx dst dst-next src src-next src-len)
	(list result (utf8->string (subbytevector dst 0 dst-next)))))))

(define (decode binary string-result?)
  ;;Decode BINARY which  must be a Scheme string  or bytevector.  Return
  ;;two  values: the  boolean result  from the  decoding  functions, the
  ;;decoded data.
  ;;
  ;;If STRING-RESULT?  is  true, the decoded data is  returned as Scheme
  ;;string; else it is returned as Scheme bytevector.
  ;;
  ;;Make use of the ENCODING, PADDING? and ENCODING-CASE parameters.
  ;;
  (define (output dst dst-past)
    (let ((by (subbytevector dst 0 dst-past)))
      (if string-result?
	  (utf8->string by)
	by)))
  (let* ((ctx		(make-<base32-decode-ctx> (encoding) (padding?) (encoding-case)))
	 (src		(if (string? binary)
			    (string->utf8 (case (encoding-case)
					    ((upper)	(string-upcase binary))
					    ((lower)	(string-downcase binary))
					    (else	binary)))
			  binary))
	 (src-len	(bytevector-length src))
	 (dst		(make-bytevector (base32-decode-length src-len (padding?)))))
    (receive (result dst-next src-next)
	(base32-decode-update! ctx dst 0 src 0 src-len)
      (if result
	  (list result (output dst dst-next))
	(receive (result dst-next src-next)
	    (base32-decode-final! ctx dst dst-next src src-next src-len)
	  (list result (output dst dst-next)))))))


(parametrise ((check-test-name	'one)
	      (encoding		'base32)
	      (padding?		#t)
	      (encoding-case	'upper)
	      (debugging	#t))


  (check
      (encode "foobar")
    => '(#t "MZXW6YTBOI======"))

  (check
      (decode "MZXW6YTBOI======" #t)
    => '(#t "foobar"))

  (check
      (decode "AA======" #f)
    => '(#t #vu8(#o000)))

  (for-each (lambda (triplet)
	      (let ((binary	(car   triplet))
		    (padded	(cadr  triplet)))
		(check
		    `(,binary -> ,(encode binary))
		  => `(,binary -> (#t ,padded)))
		(check
		    `(,padded -> ,(decode padded (string? binary)))
		  => `(,padded -> (#t ,binary)))
		))
    test-vectors)

;;; --------------------------------------------------------------------

  (check
      (guard (E ((armor-invalid-input-byte-condition? E)
;;;		   (display (condition-irritants E))(newline)
		 #t)
		(else
		 #f))
	(decode "ABCDE0AA" #f))
    => #t)

  (check
      (guard (E ((armor-invalid-padding-condition? E)
;;;		   (display (condition-irritants E))(newline)
		 #t)
		(else
		 (debug-print-condition "invalid padding" E)
		 #f))
	(decode "A=======" #f))
    => #t)

  (check
      (guard (E ((armor-invalid-padding-condition? E)
;;;		   (display (condition-irritants E))(newline)
		 #t)
		(else
		 (debug-print-condition "invalid padding" E)
		 #f))
	(decode "ACA=====" #f))
    => #t)

  (check
      (guard (E ((armor-invalid-padding-condition? E)
;;;		   (display (condition-irritants E))(newline)
		 #t)
		(else
		 (debug-print-condition "invalid padding" E)
		 #f))
	(decode "A=CA====" #f))
    => #t)

  #f)


(parametrise ((check-test-name	'two)
	      (encoding		'base32)
	      (padding?		#f)
	      (encoding-case	'upper)
	      (debugging	#t))

  (check
      (encode "foobar")
    => '(#t "MZXW6YTBOI"))

  (for-each (lambda (triplet)
	      (let ((binary	(car   triplet))
		    (unpadded (caddr triplet)))
		(check
		    `(,binary -> ,(encode binary))
		  => `(,binary -> (#t ,unpadded)))
		(check
		    `(,unpadded -> ,(decode unpadded (string? binary)))
		  => `(,unpadded -> (#t ,binary)))
		))
    test-vectors)

  #t)


(parametrise ((check-test-name	'three)
	      (encoding		'base32)
	      (padding?		#f)
	      (encoding-case	'lower)
	      (debugging	#t))

    (check
	(encode "foobar")
      => '(#t "mzxw6ytboi"))

    (for-each (lambda (triplet)
		(let ((binary	(car   triplet))
		      (unpadded (caddr triplet)))
		  (check
		      `(,binary -> ,(encode binary))
		    => `(,binary -> (#t ,(string-downcase unpadded))))
		  (check
		      `(,unpadded -> ,(decode unpadded (string? binary)))
		    => `(,unpadded -> (#t ,binary)))
		  ))
      test-vectors)

  #t)


;;;; done

(check-report)

;;; end of file