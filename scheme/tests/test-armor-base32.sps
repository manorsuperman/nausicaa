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
  (nausicaa armor base32)
  (nausicaa armor conditions)
  (nausicaa checks))

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


;;;; base32/hex test vectors

(define test-vectors-/hex
  ;; binary			encoded padded		encoded non-padded
  '((""				""			"")
    ("f"			"CO======"		"CO")
    ("fo"			"CPNG===="		"CPNG")
    ("foo"			"CPNMU==="		"CPNMU")
    ("foob"			"CPNMUOG="		"CPNMUOG")
    ("fooba"			"CPNMUOJ1"		"CPNMUOJ1")
    ("foobar"			"CPNMUOJ1E8======"	"CPNMUOJ1E8")
    (" "			"40======"		"40")
    ("  "			"40G0===="		"40G0")
    ("   "			"40G20==="		"40G20")
    ("    "			"40G2080="		"40G2080")
    ("     "			"40G20810"		"40G20810")
    ("      "			"40G2081040======"	"40G2081040")
    (#vu8(#o000)		"00======"		"00")
    (#vu8(#o010)		"10======"		"10")
    (#vu8(#o020)		"20======"		"20")
    (#vu8(#o030)		"30======"		"30")
    (#vu8(#o001)		"04======"		"04")
    (#vu8(#o011)		"14======"		"14")
    (#vu8(#o021)		"24======"		"24")
    (#vu8(#o031)		"34======"		"34")
    (#vu8(#o002)		"08======"		"08")
    (#vu8(#o012)		"18======"		"18")
    (#vu8(#o022)		"28======"		"28")
    (#vu8(#o032)		"38======"		"38")
    (#vu8(#o003)		"0C======"		"0C")
    (#vu8(#o013)		"1C======"		"1C")
    (#vu8(#o023)		"2C======"		"2C")
    (#vu8(#o033)		"3C======"		"3C")
    (#vu8(#o004)		"0G======"		"0G")
    (#vu8(#o014)		"1G======"		"1G")
    (#vu8(#o024)		"2G======"		"2G")
    (#vu8(#o034)		"3G======"		"3G")
    (#vu8(#o005)		"0K======"		"0K")
    (#vu8(#o015)		"1K======"		"1K")
    (#vu8(#o025)		"2K======"		"2K")
    (#vu8(#o035)		"3K======"		"3K")
    (#vu8(#o006)		"0O======"		"0O")
    (#vu8(#o016)		"1O======"		"1O")
    (#vu8(#o026)		"2O======"		"2O")
    (#vu8(#o036)		"3O======"		"3O")
    (#vu8(#o007)		"0S======"		"0S")
    (#vu8(#o017)		"1S======"		"1S")
    (#vu8(#o027)		"2S======"		"2S")
    (#vu8(#o037)		"3S======"		"3S")
    (#vu8(#o040)		"40======"		"40")
    (#vu8(#o050)		"50======"		"50")
    (#vu8(#o060)		"60======"		"60")
    (#vu8(#o070)		"70======"		"70")
    (#vu8(#o041)		"44======"		"44")
    (#vu8(#o051)		"54======"		"54")
    (#vu8(#o061)		"64======"		"64")
    (#vu8(#o071)		"74======"		"74")
    (#vu8(#o042)		"48======"		"48")
    (#vu8(#o052)		"58======"		"58")
    (#vu8(#o062)		"68======"		"68")
    (#vu8(#o072)		"78======"		"78")
    (#vu8(#o043)		"4C======"		"4C")
    (#vu8(#o053)		"5C======"		"5C")
    (#vu8(#o063)		"6C======"		"6C")
    (#vu8(#o073)		"7C======"		"7C")
    (#vu8(#o044)		"4G======"		"4G")
    (#vu8(#o054)		"5G======"		"5G")
    (#vu8(#o064)		"6G======"		"6G")
    (#vu8(#o074)		"7G======"		"7G")
    (#vu8(#o045)		"4K======"		"4K")
    (#vu8(#o055)		"5K======"		"5K")
    (#vu8(#o065)		"6K======"		"6K")
    (#vu8(#o075)		"7K======"		"7K")
    (#vu8(#o046)		"4O======"		"4O")
    (#vu8(#o056)		"5O======"		"5O")
    (#vu8(#o066)		"6O======"		"6O")
    (#vu8(#o076)		"7O======"		"7O")
    (#vu8(#o047)		"4S======"		"4S")
    (#vu8(#o057)		"5S======"		"5S")
    (#vu8(#o067)		"6S======"		"6S")
    (#vu8(#o077)		"7S======"		"7S")
    (#vu8(#o100)		"80======"		"80")
    (#vu8(#o110)		"90======"		"90")
    (#vu8(#o120)		"A0======"		"A0")
    (#vu8(#o130)		"B0======"		"B0")
    (#vu8(#o101)		"84======"		"84")
    (#vu8(#o111)		"94======"		"94")
    (#vu8(#o121)		"A4======"		"A4")
    (#vu8(#o131)		"B4======"		"B4")
    (#vu8(#o102)		"88======"		"88")
    (#vu8(#o112)		"98======"		"98")
    (#vu8(#o122)		"A8======"		"A8")
    (#vu8(#o132)		"B8======"		"B8")
    (#vu8(#o103)		"8C======"		"8C")
    (#vu8(#o113)		"9C======"		"9C")
    (#vu8(#o123)		"AC======"		"AC")
    (#vu8(#o133)		"BC======"		"BC")
    (#vu8(#o104)		"8G======"		"8G")
    (#vu8(#o114)		"9G======"		"9G")
    (#vu8(#o124)		"AG======"		"AG")
    (#vu8(#o134)		"BG======"		"BG")
    (#vu8(#o105)		"8K======"		"8K")
    (#vu8(#o115)		"9K======"		"9K")
    (#vu8(#o125)		"AK======"		"AK")
    (#vu8(#o135)		"BK======"		"BK")
    (#vu8(#o106)		"8O======"		"8O")
    (#vu8(#o116)		"9O======"		"9O")
    (#vu8(#o126)		"AO======"		"AO")
    (#vu8(#o136)		"BO======"		"BO")
    (#vu8(#o107)		"8S======"		"8S")
    (#vu8(#o117)		"9S======"		"9S")
    (#vu8(#o127)		"AS======"		"AS")
    (#vu8(#o137)		"BS======"		"BS")
    (#vu8(#o140)		"C0======"		"C0")
    (#vu8(#o150)		"D0======"		"D0")
    (#vu8(#o160)		"E0======"		"E0")
    (#vu8(#o170)		"F0======"		"F0")
    (#vu8(#o141)		"C4======"		"C4")
    (#vu8(#o151)		"D4======"		"D4")
    (#vu8(#o161)		"E4======"		"E4")
    (#vu8(#o171)		"F4======"		"F4")
    (#vu8(#o142)		"C8======"		"C8")
    (#vu8(#o152)		"D8======"		"D8")
    (#vu8(#o162)		"E8======"		"E8")
    (#vu8(#o172)		"F8======"		"F8")
    (#vu8(#o143)		"CC======"		"CC")
    (#vu8(#o153)		"DC======"		"DC")
    (#vu8(#o163)		"EC======"		"EC")
    (#vu8(#o173)		"FC======"		"FC")
    (#vu8(#o144)		"CG======"		"CG")
    (#vu8(#o154)		"DG======"		"DG")
    (#vu8(#o164)		"EG======"		"EG")
    (#vu8(#o174)		"FG======"		"FG")
    (#vu8(#o145)		"CK======"		"CK")
    (#vu8(#o155)		"DK======"		"DK")
    (#vu8(#o165)		"EK======"		"EK")
    (#vu8(#o175)		"FK======"		"FK")
    (#vu8(#o146)		"CO======"		"CO")
    (#vu8(#o156)		"DO======"		"DO")
    (#vu8(#o166)		"EO======"		"EO")
    (#vu8(#o176)		"FO======"		"FO")
    (#vu8(#o147)		"CS======"		"CS")
    (#vu8(#o157)		"DS======"		"DS")
    (#vu8(#o167)		"ES======"		"ES")
    (#vu8(#o177)		"FS======"		"FS")
    (#vu8(#o200)		"G0======"		"G0")
    (#vu8(#o210)		"H0======"		"H0")
    (#vu8(#o220)		"I0======"		"I0")
    (#vu8(#o230)		"J0======"		"J0")
    (#vu8(#o201)		"G4======"		"G4")
    (#vu8(#o211)		"H4======"		"H4")
    (#vu8(#o221)		"I4======"		"I4")
    (#vu8(#o231)		"J4======"		"J4")
    (#vu8(#o202)		"G8======"		"G8")
    (#vu8(#o212)		"H8======"		"H8")
    (#vu8(#o222)		"I8======"		"I8")
    (#vu8(#o232)		"J8======"		"J8")
    (#vu8(#o203)		"GC======"		"GC")
    (#vu8(#o213)		"HC======"		"HC")
    (#vu8(#o223)		"IC======"		"IC")
    (#vu8(#o233)		"JC======"		"JC")
    (#vu8(#o204)		"GG======"		"GG")
    (#vu8(#o214)		"HG======"		"HG")
    (#vu8(#o224)		"IG======"		"IG")
    (#vu8(#o234)		"JG======"		"JG")
    (#vu8(#o205)		"GK======"		"GK")
    (#vu8(#o215)		"HK======"		"HK")
    (#vu8(#o225)		"IK======"		"IK")
    (#vu8(#o235)		"JK======"		"JK")
    (#vu8(#o206)		"GO======"		"GO")
    (#vu8(#o216)		"HO======"		"HO")
    (#vu8(#o226)		"IO======"		"IO")
    (#vu8(#o236)		"JO======"		"JO")
    (#vu8(#o207)		"GS======"		"GS")
    (#vu8(#o217)		"HS======"		"HS")
    (#vu8(#o227)		"IS======"		"IS")
    (#vu8(#o237)		"JS======"		"JS")
    (#vu8(#o240)		"K0======"		"K0")
    (#vu8(#o250)		"L0======"		"L0")
    (#vu8(#o260)		"M0======"		"M0")
    (#vu8(#o270)		"N0======"		"N0")
    (#vu8(#o241)		"K4======"		"K4")
    (#vu8(#o251)		"L4======"		"L4")
    (#vu8(#o261)		"M4======"		"M4")
    (#vu8(#o271)		"N4======"		"N4")
    (#vu8(#o242)		"K8======"		"K8")
    (#vu8(#o252)		"L8======"		"L8")
    (#vu8(#o262)		"M8======"		"M8")
    (#vu8(#o272)		"N8======"		"N8")
    (#vu8(#o243)		"KC======"		"KC")
    (#vu8(#o253)		"LC======"		"LC")
    (#vu8(#o263)		"MC======"		"MC")
    (#vu8(#o273)		"NC======"		"NC")
    (#vu8(#o244)		"KG======"		"KG")
    (#vu8(#o254)		"LG======"		"LG")
    (#vu8(#o264)		"MG======"		"MG")
    (#vu8(#o274)		"NG======"		"NG")
    (#vu8(#o245)		"KK======"		"KK")
    (#vu8(#o255)		"LK======"		"LK")
    (#vu8(#o265)		"MK======"		"MK")
    (#vu8(#o275)		"NK======"		"NK")
    (#vu8(#o246)		"KO======"		"KO")
    (#vu8(#o256)		"LO======"		"LO")
    (#vu8(#o266)		"MO======"		"MO")
    (#vu8(#o276)		"NO======"		"NO")
    (#vu8(#o247)		"KS======"		"KS")
    (#vu8(#o257)		"LS======"		"LS")
    (#vu8(#o267)		"MS======"		"MS")
    (#vu8(#o277)		"NS======"		"NS")
    (#vu8(#o300)		"O0======"		"O0")
    (#vu8(#o310)		"P0======"		"P0")
    (#vu8(#o320)		"Q0======"		"Q0")
    (#vu8(#o330)		"R0======"		"R0")
    (#vu8(#o301)		"O4======"		"O4")
    (#vu8(#o311)		"P4======"		"P4")
    (#vu8(#o321)		"Q4======"		"Q4")
    (#vu8(#o331)		"R4======"		"R4")
    (#vu8(#o302)		"O8======"		"O8")
    (#vu8(#o312)		"P8======"		"P8")
    (#vu8(#o322)		"Q8======"		"Q8")
    (#vu8(#o332)		"R8======"		"R8")
    (#vu8(#o303)		"OC======"		"OC")
    (#vu8(#o313)		"PC======"		"PC")
    (#vu8(#o323)		"QC======"		"QC")
    (#vu8(#o333)		"RC======"		"RC")
    (#vu8(#o304)		"OG======"		"OG")
    (#vu8(#o314)		"PG======"		"PG")
    (#vu8(#o324)		"QG======"		"QG")
    (#vu8(#o334)		"RG======"		"RG")
    (#vu8(#o305)		"OK======"		"OK")
    (#vu8(#o315)		"PK======"		"PK")
    (#vu8(#o325)		"QK======"		"QK")
    (#vu8(#o335)		"RK======"		"RK")
    (#vu8(#o306)		"OO======"		"OO")
    (#vu8(#o316)		"PO======"		"PO")
    (#vu8(#o326)		"QO======"		"QO")
    (#vu8(#o336)		"RO======"		"RO")
    (#vu8(#o307)		"OS======"		"OS")
    (#vu8(#o317)		"PS======"		"PS")
    (#vu8(#o327)		"QS======"		"QS")
    (#vu8(#o337)		"RS======"		"RS")
    (#vu8(#o340)		"S0======"		"S0")
    (#vu8(#o350)		"T0======"		"T0")
    (#vu8(#o360)		"U0======"		"U0")
    (#vu8(#o370)		"V0======"		"V0")
    (#vu8(#o341)		"S4======"		"S4")
    (#vu8(#o351)		"T4======"		"T4")
    (#vu8(#o361)		"U4======"		"U4")
    (#vu8(#o371)		"V4======"		"V4")
    (#vu8(#o342)		"S8======"		"S8")
    (#vu8(#o352)		"T8======"		"T8")
    (#vu8(#o362)		"U8======"		"U8")
    (#vu8(#o372)		"V8======"		"V8")
    (#vu8(#o343)		"SC======"		"SC")
    (#vu8(#o353)		"TC======"		"TC")
    (#vu8(#o363)		"UC======"		"UC")
    (#vu8(#o373)		"VC======"		"VC")
    (#vu8(#o344)		"SG======"		"SG")
    (#vu8(#o354)		"TG======"		"TG")
    (#vu8(#o364)		"UG======"		"UG")
    (#vu8(#o374)		"VG======"		"VG")
    (#vu8(#o345)		"SK======"		"SK")
    (#vu8(#o355)		"TK======"		"TK")
    (#vu8(#o365)		"UK======"		"UK")
    (#vu8(#o375)		"VK======"		"VK")
    (#vu8(#o346)		"SO======"		"SO")
    (#vu8(#o356)		"TO======"		"TO")
    (#vu8(#o366)		"UO======"		"UO")
    (#vu8(#o376)		"VO======"		"VO")
    (#vu8(#o347)		"SS======"		"SS")
    (#vu8(#o357)		"TS======"		"TS")
    (#vu8(#o367)		"US======"		"US")
    (#vu8(#o377)		"VS======"		"VS")))


;;;; base32 encoding and decoding routines

(define (encode binary)
  ;;Encode BINARY which  must be a Scheme string  or bytevector.  Return
  ;;two values:  (1) the resulting boolean from  the encoding functions,
  ;;(2) a string representing the encoded data.
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
  (define (%output dst dst-past)
    (let ((bv (subbytevector dst 0 dst-past)))
      (if string-result?
	  (utf8->string bv)
	bv)))
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
	  (list result (%output dst dst-next))
	(receive (result dst-next src-next)
	    (base32-decode-final! ctx dst dst-next src src-next src-len)
	  (list result (%output dst dst-next)))))))


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

  (check	;invalid input length
      (let ((ctx (make-<base32-decode-ctx> 'base32 #t 'upper)))
	(guard (E ((armor-invalid-input-length-condition? E)
;;;		   (display (condition-irritants E))(newline)
		   #t)
		  (else
		   (debug-print-condition "invalid input length" E)
		   #f))
	  (receive (a b c)
	      (base32-decode-final! ctx
				    (make-bytevector 256) 0
				    '#vu8(70 71 72 73 74 75 76) 0 7)
	    (list a b c))))
    => #t)

;;; --------------------------------------------------------------------
;;; encoding show off for the documentation

  (let ()

    (define ctx
      (make-<base32-encode-ctx> 'base32 #t 'upper))

    (define bin-1.bv
      '#vu8(0 1 2 3 4))
    (define bin-1.len
      (bytevector-length bin-1.bv))

    (define asc-1.len
      (base32-encode-update-length bin-1.len))
    (define asc-1.bv
      (make-bytevector asc-1.len))

    (define-values (dst-next-1 src-next-1)
      (base32-encode-update! ctx
			     asc-1.bv 0
			     bin-1.bv 0 bin-1.len))

    ;; (display (list (utf8->string asc-1.bv)
    ;; 		   asc-1.len
    ;; 		   dst-next-1
    ;; 		   src-next-1))
    ;; (newline)

    (define bin-2.bv
      '#vu8(0 1 2 3 4 5 6))
    (define bin-2.len
      (bytevector-length bin-2.bv))

    (define asc-2.len
      (base32-encode-update-length bin-2.len))
    (define asc-2.bv
      (make-bytevector asc-2.len))

    (define-values (dst-next-2 src-next-2)
      (base32-encode-update! ctx
    			     asc-2.bv 0
    			     bin-2.bv 0 bin-2.len))

    ;; (display (list (utf8->string (subbytevector asc-2.bv 0 dst-next-2))
    ;; 		   asc-2.len
    ;; 		   dst-next-2
    ;; 		   src-next-2))
    ;; (newline)

    (define bin-3.bv
      '#vu8(0 1 2 3 4 5 6))
    (define bin-3.len
      (bytevector-length bin-3.bv))

    (define delta
      (- bin-2.len src-next-2))

    (define bin-23.len
      (+ bin-3.len delta))

    (define bin-23.bv
      (let ((bv (make-bytevector bin-23.len)))
	(do ((i 0          (+ 1 i))
	     (j src-next-2 (+ 1 j)))
	    ((= i delta))
	  (bytevector-u8-set! bv i (bytevector-u8-ref bin-2.bv j)))
	(do ((i delta (+ 1 i))
	     (j 0     (+ 1 j)))
	    ((= j bin-3.len)
	     bv)
	  (bytevector-u8-set! bv i (bytevector-u8-ref bin-3.bv j)))))

    (define asc-3.len
      (base32-encode-length bin-23.len #t))

    (define asc-3.bv
      (make-bytevector asc-3.len))

    (define-values (result dst-next-3 src-next-3)
      (base32-encode-final! ctx
			    asc-3.bv 0
			    bin-23.bv 0 bin-23.len))

    ;; (display (list (utf8->string asc-3.bv)
    ;;		   result
    ;; 		   dst-next-3
    ;; 		   src-next-3))
    ;; (newline)

    (check
	(parametrise ((encoding		'base32)
		      (padding?		#t)
		      (encoding-case	'upper))
	  (encode '#vu8(0 1 2 3 4 0 1 2 3 4 5 6 0 1 2 3 4 5 6)))
      => '(#t "AAAQEAYEAAAQEAYEAUDAAAICAMCAKBQ="))

    #f)

;;; --------------------------------------------------------------------
;;; decoding show off for the documentation

  (let ()

    (define ctx
      (make-<base32-decode-ctx> 'base32 #t 'upper))

    (define asc-1.bv
      (string->utf8 "AAAQEAYE"))
    (define asc-1.len
      (bytevector-length asc-1.bv))

    (define bin-1.len
      (base32-decode-update-length asc-1.len))
    (define bin-1.bv
      (make-bytevector bin-1.len))

    (define-values (finished-1? dst-next-1 src-next-1)
      (base32-decode-update! ctx
			     bin-1.bv 0
			     asc-1.bv 0 asc-1.len))

    ;; (display (list bin-1.bv
    ;; 		   finished-1?
    ;; 		   asc-1.len
    ;; 		   dst-next-1
    ;; 		   src-next-1))
    ;; (newline)

    (define asc-2.bv
      (string->utf8 "AAAQEAYEAU"))
    (define asc-2.len
      (bytevector-length asc-2.bv))

    (define bin-2.len
      (base32-decode-update-length asc-2.len))
    (define bin-2.bv
      (make-bytevector bin-2.len))

    (define-values (finished-2? dst-next-2 src-next-2)
      (base32-decode-update! ctx
    			     bin-2.bv 0
    			     asc-2.bv 0 asc-2.len))

    ;; (display (list bin-2.bv
    ;; 		   bin-2.len
    ;; 		   finished-2?
    ;; 		   dst-next-2
    ;; 		   src-next-2))
    ;; (newline)

    (define asc-3.bv
      (string->utf8 "DAAAICAMCAKBQ="))
    (define asc-3.len
      (bytevector-length asc-3.bv))

    (define delta
      (- asc-2.len src-next-2))

    (define asc-23.len
      (+ asc-3.len delta))

    (define asc-23.bv
      (let ((bv (make-bytevector asc-23.len)))
    	(do ((i 0          (+ 1 i))
    	     (j src-next-2 (+ 1 j)))
    	    ((= i delta))
    	  (bytevector-u8-set! bv i (bytevector-u8-ref asc-2.bv j)))
    	(do ((i delta (+ 1 i))
    	     (j 0     (+ 1 j)))
    	    ((= j asc-3.len)
    	     bv)
    	  (bytevector-u8-set! bv i (bytevector-u8-ref asc-3.bv j)))))

    (define bin-3.len
      (base32-decode-length asc-23.len #t))

    (define bin-3.bv
      (make-bytevector bin-3.len))

    (define-values (result dst-next-3 src-next-3)
      (base32-decode-final! ctx
    			    bin-3.bv 0
    			    asc-23.bv 0 asc-23.len))

    ;; (display (list (subbytevector bin-3.bv 0 dst-next-3)
    ;; 		   result
    ;; 		   'bin-3.len bin-3.len
    ;; 		   'dst-next-3 dst-next-3
    ;; 		   'src-next-3 src-next-3))
    ;; (newline)

    (check
    	(parametrise ((encoding		'base32)
    		      (padding?		#t)
    		      (encoding-case	'upper))
    	  (decode "AAAQEAYEAAAQEAYEAUDAAAICAMCAKBQ=" #f))
      => '(#t #vu8(0 1 2 3 4 0 1 2 3 4 5 6 0 1 2 3 4 5 6)))

    #f)

  #t)


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
		    (unpadded	(caddr triplet)))
		(check
		    `(,binary -> ,(encode binary))
		  => `(,binary -> (#t ,unpadded)))
		(check
		    `(,unpadded -> ,(decode unpadded (string? binary)))
		  => `(,unpadded -> (#t ,binary)))
		))
    test-vectors)

  (check	;invalid input length
      (let ((ctx (make-<base32-decode-ctx> 'base32 #f 'upper)))
	(guard (E ((armor-invalid-input-length-condition? E)
;;;		   (display (condition-irritants E))(newline)
		   #t)
		  (else
		   (debug-print-condition "invalid input length" E)
		   #f))
	  (receive (a b c)
	      (base32-decode-final! ctx
				    (make-bytevector 256) 0
				    '#vu8(70) 0 1)
	    (list a b c))))
    => #t)

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
		    (unpadded	(caddr triplet)))
		(check
		    `(,binary -> ,(encode binary))
		  => `(,binary -> (#t ,(string-downcase unpadded))))
		(check
		    `(,unpadded -> ,(decode unpadded (string? binary)))
		  => `(,unpadded -> (#t ,binary)))
		))
    test-vectors)

  #t)


(parametrise ((check-test-name	'four)
	      (encoding		'base32/hex)
	      (padding?		#t)
	      (encoding-case	'upper)
	      (debugging	#t))

  (for-each (lambda (triplet)
	      (let ((binary	(car  triplet))
		    (padded	(cadr triplet)))
		(check
		    `(,binary -> ,(encode binary))
		  => `(,binary -> (#t ,padded)))
		(check
		    `(,padded -> ,(decode padded (string? binary)))
		  => `(,padded -> (#t ,binary)))
		))
    test-vectors-/hex)

  #t)


(parametrise ((check-test-name	'five)
	      (encoding		'base32/hex)
	      (padding?		#f)
	      (encoding-case	'upper)
	      (debugging	#t))

  (for-each (lambda (triplet)
	      (let ((binary	(car   triplet))
		    (unpadded	(caddr triplet)))
		(check
		    `(,binary -> ,(encode binary))
		  => `(,binary -> (#t ,unpadded)))
		(check
		    `(,unpadded -> ,(decode unpadded (string? binary)))
		  => `(,unpadded -> (#t ,binary)))
		))
    test-vectors-/hex)

  #t)


(parametrise ((check-test-name	'six)
	      (encoding		'base32/hex)
	      (padding?		#f)
	      (encoding-case	'lower)
	      (debugging	#t))

  (for-each (lambda (triplet)
	      (let ((binary	(car   triplet))
		    (unpadded	(caddr triplet)))
		(check
		    `(,binary -> ,(encode binary))
		  => `(,binary -> (#t ,(string-downcase unpadded))))
		(check
		    `(,unpadded -> ,(decode unpadded (string? binary)))
		  => `(,unpadded -> (#t ,binary)))
		))
    test-vectors-/hex)

  #t)


;;;; done

(check-report)

;;; end of file
