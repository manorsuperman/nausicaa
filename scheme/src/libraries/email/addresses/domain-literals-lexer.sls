(library (email addresses domain-literals-lexer)
  (export
    domain-literals-table)
  (import (rnrs) (silex lexer)(lalr lr-driver)(email addresses common))

;
; Table generated from the file domain-literals.l by SILex 1.0
;

(define domain-literals-table
  (vector
   'all
   (lambda (yycontinue yygetc yyungetc)
     (lambda (yytext yyline yycolumn yyoffset)
       			(make-lexical-token
			 '*eoi*
			 (make-source-location #f yyline yycolumn yyoffset 0)
			 (eof-object))
       ))
   (lambda (yycontinue yygetc yyungetc)
     (lambda (yytext yyline yycolumn yyoffset)
         		(make-lexical-token
			 '*lexer-error*
			 (make-source-location #f yyline yycolumn yyoffset
					       (string-length yytext))
			 yytext)

;;; end of file
       ))
   (vector
    #t
    (lambda (yycontinue yygetc yyungetc)
      (lambda (yytext yyline yycolumn yyoffset)
              		(let ((yytext1 (unquote-string yytext)))
			  (make-lexical-token
			   'DOMAIN-LITERAL-CLOSE
			   (make-source-location #f yyline yycolumn yyoffset
						 (string-length yytext))
			   yytext1))
        ))
    #t
    (lambda (yycontinue yygetc yyungetc)
      (lambda (yytext yyline yycolumn yyoffset)
         		(let* ((yytext1 (unquote-string yytext))
			       (num     (string->number yytext1)))
			  (make-lexical-token
			   (if (< num 256) 'DOMAIN-LITERAL-INTEGER '*lexer-error*)
			   (make-source-location #f yyline yycolumn yyoffset
						 (string-length yytext))
			   yytext1))
        ))
    #t
    (lambda (yycontinue yygetc yyungetc)
      (lambda (yytext yyline yycolumn yyoffset)
     			(make-lexical-token
			 'DOT
			 (make-source-location #f yyline yycolumn yyoffset 1)
			 yytext)
        )))
   'decision-trees
   0
   0
   '#((58 (47 (46 err 1) (48 err 2)) (93 (92 err 3) (94 4 err))) err (58
    (48 err 2) (= 92 3 err)) (58 (48 err 2) (= 92 3 err)) err)
   '#((#f . #f) (2 . 2) (1 . 1) (#f . #f) (0 . 0))))

) ; end of library
