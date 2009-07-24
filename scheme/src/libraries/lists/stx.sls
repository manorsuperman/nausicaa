;;;Derived from SRFI-1 list-processing library, reference implementation
;;;
;;;Copyright (c) 2008, 2009 Marco Maggi <marcomaggi@gna.org>
;;;Copyright (c) 1998, 1999 by Olin Shivers <shivers@ai.mit.edu>.
;;;Modified by Abdulaziz Ghuloum to port to Ikarus.
;;;Modified by Derick Eddington to port to R6RS.
;;;Modified by Marco Maggi for inclusion in Nausicaa.
;;;
;;;You may do as you please with  this code as long as you do not remove
;;;this copyright notice or hold me liable for its use.  Please send bug
;;;reports to <shivers@ai.mit.edu>.
;;;
;;;This is  a library of list-processing  and pair-processing functions.
;;;I wrote it after carefully  considering the functions provided by the
;;;libraries  found in  R4RS/R5RS Scheme,  MIT Scheme,  Gambit, RScheme,
;;;MzScheme,  slib, Common  Lisp,  Bigloo,  guile, T,  APL  and the  SML
;;;standard basis.  It is a pretty rich toolkit, providing a superset of
;;;the functionality found in any of the various Schemes I considered.
;;;
;;;This   implementation   is   intended   as   a   portable   reference
;;;implementation  for SRFI-1.   See the  porting notes  below  for more
;;;information.
;;;


#!r6rs
(library (lists stx)
  (export

    ;; constructors
    make-list/stx
    list-copy/stx		tree-copy/stx
    list-tabulate/stx		iota/stx

    ;; predicates
    and-null?/stx		or-null?/stx
    and/or-null?/stx

    ;; selectors
    fifth/stx			sixth/stx
    seventh/stx			eighth/stx
    ninth/stx			tenth/stx
    take/stx			drop/stx
    take-right/stx		drop-right/stx
    take!/stx
    drop-right!/stx
    split-at/stx		split-at!/stx
    last/stx			last-pair/stx

    ;; miscellaneous
    concatenate/stx		concatenate!/stx
    append-reverse/stx		append-reverse!/stx
    zip/stx			unzip1/stx
    unzip2/stx			unzip3/stx
    unzip4/stx			unzip5/stx
    count/stx
    reverse!/stx

    ;; folding
    fold-left/stx		fold-right/stx
    fold-left*/stx		fold-right*/stx
    fold/stx			fold*/stx
    and-fold-left*/stx		and-fold-right*/stx

    reduce/stx			reduce*/stx
    unfold-right/stx		unfold/stx

    ;; mappers
    (rename (map-in-order*/stx map*/stx))
    map-in-order/stx		map-in-order*/stx
    map!/stx			map*!/stx
    for-each*/stx		pair-for-each*/stx
    filter-map/stx

    )
  (import (nausicaa)
    (rnrs mutable-pairs))


;;;; helpers

(define (append! . lists)
  ;; First, scan through lists looking for a non-empty one.
  (let lp ((lists lists)
	   (prev '()))
    (if (not (pair? lists))
	prev
      (let ((first (car lists))
	    (rest (cdr lists)))
	(if (not (pair? first))
	    (lp rest first)
	  ;; Now, do the splicing.
	  (let lp2 ((tail-cons (last-pair/stx first))
		    (rest rest))
	    (if (pair? rest)
		(let ((next (car rest))
		      (rest (cdr rest)))
		  (set-cdr! tail-cons next)
		  (lp2 (if (pair? next) (last-pair/stx next) tail-cons)
		       rest))
	      first)))))))


;;;; constructors

(define-syntax make-list/stx
  (syntax-rules ()
    ((_ ?len)
     (make-list/stx ?len #f))
    ((_ ?len ?fill)
     (let ((fill ?fill)
	   (len  ?len))
       (do ((i 0 (+ 1 i))
	    (l '() (cons fill l)))
	   ((= i len)
	    l))))))

(define-syntax list-copy/stx
  (syntax-rules ()
    ((_ ?ell)
     (let loop ((ell ?ell))
       (if (pair? ell)
	   (cons (car ell) (loop (cdr ell)))
	 ell)))))

(define-syntax tree-copy/stx
  (syntax-rules ()
    ((_ ?x)
     (let loop ((x ?x))
       (if (pair? x)
	   (cons (loop (car x))
		 (loop (cdr x)))
	 x)))))

(define-syntax list-tabulate/stx
  (syntax-rules ()
    ((_ ?len ?proc)
     (let ((len  ?len)
	   (proc ?proc))
       (do ((i (- len 1) (- i 1))
	    (ans '() (cons (?proc i) ans)))
	   ((< i 0)
	    ans))))))

(define-syntax iota/stx
  (syntax-rules ()
    ((_ ?count)
     (iota/stx ?count 0 1))
    ((_ ?count ?start)
     (iota/stx ?count ?start 1))
    ((_ ?count ?start ?step)
     (let ((counter ?count)
	   (step    ?step))
       (do ((count counter (- count 1))
	    (val (+ ?start (* (- counter 1) step)) (- val step))
	    (ans '() (cons val ans)))
	   ((<= count 0)
	    ans))))))


;;;; predicates

(define-syntax and-null?/stx
  (lambda (stx)
    (syntax-case stx ()
      ((_ ?ell ...)
       (with-syntax (((ell ...) (generate-temporaries (syntax (?ell ...)))))
	 (syntax (let ((ell  ?ell)
		       ...)
		   (and (null? ell) ...))))))))

(define-syntax or-null?/stx
  (lambda (stx)
    (syntax-case stx ()
      ((_ ?ell ...)
       (with-syntax (((ell ...) (generate-temporaries (syntax (?ell ...)))))
	 (syntax (let ((ell  ?ell)
		       ...)
		   (or (null? ell) ...))))))))

(define-syntax and/or-null?/stx
  (lambda (stx)
    (syntax-case stx ()
      ((_ ?ell ...)
       (with-syntax (((ell ...) (generate-temporaries (syntax (?ell ...))))
		     ((nil ...) (generate-temporaries (syntax (?ell ...)))))
	 (syntax (let* ((ell  ?ell)
			...
			(nil  (null? ell))
			...)
		   (values (and nil ...)
			   (or  nil ...)))))))))


;;;; selectors

(define-syntax fifth/stx	(syntax-rules () ((_ ?x) (car (cddddr ?x)))))
(define-syntax sixth/stx	(syntax-rules () ((_ ?x) (cadr (cddddr ?x)))))
(define-syntax seventh/stx	(syntax-rules () ((_ ?x) (caddr (cddddr ?x)))))
(define-syntax eighth/stx	(syntax-rules () ((_ ?x) (cadddr (cddddr ?x)))))
(define-syntax ninth/stx	(syntax-rules () ((_ ?x) (car (cddddr (cddddr ?x))))))
(define-syntax tenth/stx	(syntax-rules () ((_ ?x) (cadr (cddddr (cddddr ?x))))))

(define-syntax take/stx
  (syntax-rules ()
    ((_ ?ell ?k)
     (let loop ((ell ?ell)
		(k   ?k))
       (if (zero? k)
	   '()
	 (cons (car ell)
	       (loop (cdr ell) (- k 1))))))))

(define-syntax drop/stx
  (syntax-rules ()
    ((_ ?ell ?k)
     (let loop ((ell ?ell)
		(k   ?k))
       (if (zero? k)
	   ell
	 (loop (cdr ell) (- k 1)))))))

(define-syntax take-right/stx
  (syntax-rules ()
    ((_ ?ell ?k)
     (let ((ell ?ell))
       (let loop ((lag	ell)
		  (lead	(drop/stx ell ?k)))
	 (if (pair? lead)
	     (loop (cdr lag) (cdr lead))
	   lag))))))

(define-syntax drop-right/stx
  (syntax-rules ()
    ((_ ?ell ?k)
     (let ((ell ?ell))
       (let loop ((lag	ell)
		  (lead	(drop/stx ell ?k)))
	 (if (pair? lead)
	     (cons (car lag)
		   (loop (cdr lag) (cdr lead)))
	   '()))))))

(define-syntax take!/stx
  (syntax-rules ()
    ((_ ?ell ?k)
     (let ((ell ?ell)
	   (k   ?k))
       (if (zero? k)
	   '()
	 (begin
	   (set-cdr! (drop/stx ell (- k 1)) '())
	   ell))))))

(define-syntax drop-right!/stx
  (syntax-rules ()
    ((_ ?ell ?k)
     (let ((ell ?ell))
       (let ((lead (drop/stx ell ?k)))
	 (if (pair? lead)
	     (let loop ((lag  ell)
			(lead (cdr lead)))
	       (if (pair? lead)
		   (loop (cdr lag) (cdr lead))
		 (begin (set-cdr! lag '())
			ell)))
	   '()))))))

(define-syntax split-at/stx
  (syntax-rules ()
    ((_ ?ell ?k)
     (let loop ((ell ?ell)
		(k   ?k))
       (if (zero? k) (values '() ell)
	 (receive (prefix suffix)
	     (loop (cdr ell) (- k 1))
	   (values (cons (car ell) prefix) suffix)))))))

(define-syntax split-at!/stx
  (syntax-rules ()
    ((_ ?x ?k)
     (let ((x ?x)
	   (k ?k))
       (if (zero? k)
	   (values '() x)
	 (let* ((prev   (drop/stx x (- k 1)))
		(suffix (cdr prev)))
	   (set-cdr! prev '())
	   (values x suffix)))))))

(define-syntax last/stx
  (syntax-rules ()
    ((_ ?ell)
     (car (last-pair/stx ?ell)))))

(define-syntax last-pair/stx
  (syntax-rules ()
    ((_ ?x)
     (let loop ((x ?x))
       (if (pair? (cdr x))
	   (loop (cdr x))
	 x)))))


;;;; miscellaneous

(define-syntax concatenate/stx
  (syntax-rules ()
    ((_ ?lists)
     (reduce*/stx append  '() ?lists))))

(define-syntax concatenate!/stx
  (syntax-rules ()
    ((_ ?lists)
     (reduce*/stx append! '() ?lists))))

(define-syntax append-reverse/stx
  (syntax-rules ()
    ((_ ?rev-head ?tail)
     (let lp ((rev-head ?rev-head)
	      (tail     ?tail))
       (if (null? rev-head)
	   tail
	 (lp (cdr rev-head) (cons (car rev-head) tail)))))))

(define-syntax append-reverse!/stx
  (syntax-rules ()
    ((_ ?rev-head ?tail)
     (let lp ((rev-head ?rev-head)
	      (tail     ?tail))
       (if (null? rev-head)
	   tail
	 (let ((next-rev (cdr rev-head)))
	   (set-cdr! rev-head tail)
	   (lp next-rev rev-head)))))))

(define-syntax zip/stx
  (syntax-rules ()
    ((_ ?list0 ?list ...)
     (map-in-order*/stx list ?list0 ?list ...))))

(define-syntax unzip1/stx
  (syntax-rules ()
    ((_ ?ell)
     (map car ?ell))))

(define-syntax unzip2/stx
  (syntax-rules ()
    ((_ ?lis)
     (let recur ((lis ?lis))
       (if (null? lis)
	   (values lis lis) ; Use NOT-PAIR? to handle
	 (let ((elt (car lis)))		     ; dotted lists.
	   (receive (a b) (recur (cdr lis))
	     (values (cons (car  elt) a)
		     (cons (cadr elt) b)))))))))

(define-syntax unzip3/stx
  (syntax-rules ()
    ((_ ?lis)
     (let recur ((lis ?lis))
       (if (null? lis)
	   (values lis lis lis)
	 (let ((elt (car lis)))
	   (receive (a b c) (recur (cdr lis))
	     (values (cons (car   elt) a)
		     (cons (cadr  elt) b)
		     (cons (caddr elt) c)))))))))

(define-syntax unzip4/stx
  (syntax-rules ()
    ((_ ?lis)
     (let recur ((lis ?lis))
       (if (null? lis)
	   (values lis lis lis lis)
	 (let ((elt (car lis)))
	   (receive (a b c d) (recur (cdr lis))
	     (values (cons (car    elt) a)
		     (cons (cadr   elt) b)
		     (cons (caddr  elt) c)
		     (cons (cadddr elt) d)))))))))

(define-syntax unzip5/stx
  (syntax-rules ()
    ((_ ?lis)
     (let recur ((lis ?lis))
       (if (null? lis)
	   (values lis lis lis lis lis)
	 (let ((elt (car lis)))
	   (receive (a b c d e) (recur (cdr lis))
	     (values (cons (car     elt) a)
		     (cons (cadr    elt) b)
		     (cons (caddr   elt) c)
		     (cons (cadddr  elt) d)
		     (cons (car (cddddr  elt)) e)))))))))

(define-syntax count/stx
  (lambda (stx)
    (syntax-case stx ()
      ((_ ?pred ?ell0 ?ell ...)
       (with-syntax (((ell ...) (generate-temporaries (syntax (?ell ...)))))
	 (syntax
	  (let ((pred ?pred))
	    (let loop ((counter	0)
		       (ell0	?ell0)
		       (ell	?ell)
		       ...)
	      (cond ((or (null? ell0)
			 (null? ell)
			 ...)
		     counter)
		    ((pred (car ell0) (car ell) ...)
		     (loop (+ 1 counter) (cdr ell0) (cdr ell) ...))
		    (else
		     (loop counter (cdr ell0) (cdr ell) ...)))))))))))

(define-syntax reverse!/stx
  (syntax-rules ()
    ((_ ?lis)
     (let lp ((lis ?lis)
	      (ans '()))
       (if (null? lis)
	   ans
	 (let ((tail (cdr lis)))
	   (set-cdr! lis ans)
	   (lp tail lis)))))))


;;;; fold syntaxes

(define-syntax fold-left/stx
  (lambda (stx)
    (syntax-case stx ()
      ((_ ?combine ?knil ?ell0 ?ell ...)
       (with-syntax (((L ...) (generate-temporaries (syntax (?ell ...)))))
	 (syntax (let ((combine ?combine))
		   (let loop ((knil ?knil)
			      (ell0 ?ell0)
			      (L    ?ell)
			      ...)
		     (if (or (null? ell0) (null? L) ...)
			 (begin
			   (unless (and (null? ell0) (null? L) ...)
			     (assertion-violation 'fold-left/stx
			       "expected lists of equal length"))
			   knil)
		       (loop (combine knil (car ell0) (car L) ...)
			     (cdr ell0)
			     (cdr L)
			     ...))))))))))

(define-syntax fold-right/stx
  (lambda (stx)
    (syntax-case stx ()
      ((_ ?combine ?knil ?ell0 ?ell ...)
       (with-syntax (((ell ...) (generate-temporaries (syntax (?ell ...)))))
	 (syntax (let ((combine ?combine)
		       (knil ?knil))
		   (let loop ((ell0 ?ell0)
			      (ell    ?ell)
			      ...)
		     (if (or (null? ell0) (null? ell) ...)
			 (begin
			   (unless (and (null? ell0) (null? ell) ...)
			     (assertion-violation 'fold-right/stx
			       "expected lists of equal length"))
			   knil)
		       (combine (car ell0) (car ell) ...
				(loop (cdr ell0) (cdr ell) ...)))))))))))

;;; --------------------------------------------------------------------

(define-syntax fold-left*/stx
  (lambda (stx)
    (syntax-case stx ()
      ((_ ?combine ?knil ?ell0 ?ell ...)
       (with-syntax (((L ...) (generate-temporaries (syntax (?ell ...)))))
	 (syntax (let ((combine ?combine))
		   (let loop ((knil ?knil)
			      (ell0 ?ell0)
			      (L  ?ell)
			      ...)
		     (if (or (null? ell0) (null? L) ...)
			 knil
		       (loop (combine knil (car ell0) (car L) ...)
			     (cdr ell0)
			     (cdr L)
			     ...))))))))))

(define-syntax fold-right*/stx
  (lambda (stx)
    (syntax-case stx ()
      ((_ ?combine ?knil ?ell0 ?ell ...)
       (with-syntax (((L ...) (generate-temporaries (syntax (?ell ...)))))
	 (syntax (let ((combine ?combine)
		       (knil ?knil))
		   (let loop ((ell0 ?ell0)
			      (L    ?ell)
			      ...)
		     (if (or (null? ell0) (null? L) ...)
			 knil
		       (combine (car ell0) (car L) ...
				(loop (cdr ell0) (cdr L) ...)))))))))))

;;; --------------------------------------------------------------------

(define-syntax fold/stx
  (lambda (stx)
    (syntax-case stx ()
      ((_ ?kons ?knil ?ell0 ?ell ...)
       (with-syntax (((ell ...) (generate-temporaries (syntax (?ell ...)))))
	 (syntax (let ((kons ?kons))
		   (let loop ((knil ?knil)
			      (ell0 ?ell0)
			      (ell    ?ell)
			      ...)
		     (if (or (null? ell0) (null? ell) ...)
			 knil
		       (loop (kons (car ell0) (car ell) ... knil)
			     (cdr ell0) (cdr ell) ...))))))))))

(define-syntax fold*/stx
  (lambda (stx)
    (syntax-case stx ()
      ((_ ?kons ?knil ?ell0 ?ell ...)
       (with-syntax (((ell ...) (generate-temporaries (syntax (?ell ...)))))
	 (syntax (let ((kons ?kons)
		       (knil ?knil))
		   (let loop ((ell0 ?ell0)
			      (ell    ?ell)
			      ...)
		     (if (or (null? ell0) (null? ell) ...)
			 knil
		       (kons (car ell0) (car ell) ...
			     (loop (cdr ell0) (cdr ell) ...)))))))))))


;;;; derived fold syntaxes

(define-syntax and-fold-left*/stx
  (lambda (stx)
    (syntax-case stx ()
      ((_ ?combine ?knil ?ell0 ?ell ...)
       (with-syntax (((ell ...) (generate-temporaries (syntax (?ell ...)))))
	 (syntax (let ((combine ?combine))
		   (let loop ((knil ?knil)
			      (ell0 ?ell0)
			      (ell    ?ell)
			      ...)
		     (if (or (null? ell0) (null? ell) ...)
			 knil
		       (let ((knil (combine knil (car ell0) (car ell) ...)))
			 (and knil
			      (loop knil (cdr ell0) (cdr ell) ...))))))))))))

(define-syntax and-fold-right*/stx
  (lambda (stx)
    (syntax-case stx ()
      ((_ ?combine ?knil ?ell0 ?ell ...)
       (with-syntax (((ell ...) (generate-temporaries (syntax (?ell ...)))))
	 (syntax (let ((combine ?combine))
		   (let loop ((knil ?knil)
			      (ell0 ?ell0)
			      (ell    ?ell)
			      ...)
		     (if (or (null? ell0) (null? ell) ...)
			 knil
		       (let ((knil (loop (cdr ell0) (cdr ell) ...)))
			 (and knil
			      (combine (car ell0) (cdr ell) ... knil))))))))))))


;;;; reduce and unfold

(define-syntax reduce/stx
  (syntax-rules ()
    ((_ ?f ?ridentity ?ell)
     (let ((ell ?ell))
       (if (null? ell)
	   ?ridentity
	 (fold/stx ?f (car ell) (cdr ell)))))))

(define-syntax reduce*/stx
  (syntax-rules ()
    ((_ ?f ?ridentity ?ell)
     (let ((ell ?ell)
	   (f   ?f))
       (if (null? ell)
	   ?ridentity
	 (let loop ((head	(car ell))
		    (ell	(cdr ell)))
	   (if (pair? ell)
	       (f head (loop (car ell) (cdr ell)))
	     head)))))))

(define-syntax unfold-right/stx
  (syntax-rules ()
    ((_ stop? map-to-knil seed-step seed)
     (unfold-right/stx stop? map-to-knil seed-step seed '()))
    ((_ ?stop? ?map-to-knil ?seed-step ?seed ?tail)
     (let ((stop?       ?stop?)
	   (map-to-knil ?map-to-knil)
	   (seed-step	?seed-step))
       (let loop ((seed ?seed)
		  (knil ?tail))
	 (if (stop? seed)
	     knil
	   (loop (seed-step seed)
		 (cons (map-to-knil seed) knil))))))))

(define-syntax unfold/stx
  (syntax-rules ()
    ((_ ?stop? ?map-to-knil ?seed-step ?seed)
     (let ((stop?	?stop?)
	   (map-to-knil ?map-to-knil)
	   (seed-step	?seed-step))
       (let loop ((seed ?seed))
	 (if (stop? seed)
	     '()
	   (cons (map-to-knil seed)
		 (loop (seed-step seed)))))))

    ((_ ?stop? ?map-to-knil ?seed-step ?seed ?tail-gen)
     (let ((stop?	?stop?)
	   (map-to-knil ?map-to-knil)
	   (seed-step	?seed-step)
	   (tail-gen	?tail-gen))
       (let loop ((seed ?seed))
	 (if (stop? seed)
	     (tail-gen seed)
	   (cons (map-to-knil seed)
		 (loop (seed-step seed)))))))))


;;;; mappers

(define-syntax map-in-order/stx
  (lambda (stx)
    (syntax-case stx ()
      ;;We split the single list case from the other to have more speed.
      ;;The rule for  multiple lists has been tested  in the single list
      ;;case, too, and it worked.
      ;;
      ((_ ?f ?ell)
       (syntax
	(let ((f ?f))
	  (let loop ((result '())
		     (ell    ?ell))
	    (if (null? ell)
		(reverse result)
	      (loop (cons (f (car ell)) result) (cdr ell)))))))

      ((_ ?f ?ell0 ?ell ...)
       (with-syntax (((ell ...) (generate-temporaries (syntax (?ell ...))))
		     ((nil ...) (generate-temporaries (syntax (?ell ...)))))
	 (syntax (let ((f ?f))
		   (let loop ((result '())
			      (ell0   ?ell0)
			      (ell    ?ell)
			      ...)
		     (let ((nil (null? ell))
			   ...)
		       (if (null? ell0)
			   (if (and nil ...)
			       (reverse result)
			     (assertion-violation 'map-in-order/stx
			       "expected lists of equal length"))
			 (if (or nil ...)
			     (assertion-violation 'map-in-order/stx
			       "expected lists of equal length")
			   (loop (cons (f (car ell0) (car ell) ...) result)
				 (cdr ell0) (cdr ell) ...))))))))))))

(define-syntax map-in-order*/stx
  (lambda (stx)
    (syntax-case stx ()
      ((_ ?f ?ell0 ?ell ...)
       (with-syntax (((ell ...) (generate-temporaries (syntax (?ell ...)))))
	 (syntax (let ((f ?f))
		   (let loop ((result '())
			      (ell0   ?ell0)
			      (ell    ?ell)
			      ...)
		     (if (or (null? ell0)
			     (null? ell)
			     ...)
			 (reverse result)
		       (loop (cons (f (car ell0) (car ell) ...) result)
			     (cdr ell0) (cdr ell) ...))
		     ))))))))

;;; --------------------------------------------------------------------

(define-syntax map!/stx
  ;;We stop when ELL runs out, not when any list runs out.
  ;;
  (lambda (stx)
    (syntax-case stx ()
      ((_ ?f ?ell0 ?ell ...)
       (with-syntax (((ell  ...) (generate-temporaries (syntax (?ell ...))))
		     ((pair ...) (generate-temporaries (syntax (?ell ...)))))
	 (syntax (let ((f ?f))
		   (let loop ((result '())
			      (ell0   ?ell0)
			      (ell    ?ell)
			      ...)
		     (pair-for-each*/stx (lambda (pair0 pair ...)
					   (set-car! pair0 (f (car pair0)
							      (car pair)
							      ...)))
					 ell0 ell ...)
		     ell0))))))))


(define-syntax map*!/stx
  (lambda (stx)
    (syntax-case stx ()
      ((_ ?f ?ell0 ?ell ...)
       (with-syntax (((ell ...) (generate-temporaries (syntax (?ell ...))))
		     ((p   ...) (generate-temporaries (syntax (?ell ...)))))
	 (syntax
	  (let ((f	?f)
		(ell0	?ell0))
	    (pair-for-each*/stx (lambda (pair p ...)
				  (set-car! pair (f (car pair) (car p) ...)))
				ell0 ?ell ...)
	    ell0)))))))

;;; --------------------------------------------------------------------

(define-syntax for-each*/stx
  (lambda (stx)
    (syntax-case stx ()
      ((_ ?f ?ell0 ?ell ...)
       (with-syntax (((ell ...) (generate-temporaries (syntax (?ell ...)))))
	 (syntax (let ((f ?f))
		   (let loop ((ell0 ?ell0)
			      (ell  ?ell)
			      ...)
		     (unless (or (null? ell0)
				 (null? ell)
				 ...)
		       (f (car ell0) (car ell) ...)
		       (loop (cdr ell0) (cdr ell) ...))))))))))

(define-syntax pair-for-each*/stx
  (lambda (stx)
    (syntax-case stx ()
      ((_ ?f ?ell0 ?ell ...)
       (with-syntax (((ell ...) (generate-temporaries (syntax (?ell ...)))))
	 (syntax (let ((f ?f))
		   (let loop ((ell0   ?ell0)
			      (ell    ?ell)
			      ...)
		     (unless (or (null? ell0)
				 (null? ell)
				 ...)
		       ;; Grab the cdr now, in case PROC SET-CDR!s ELL.
		       (let ((tail (list (cdr ell0) (cdr ell) ...)))
			 (f ell0 ell ...)
			 (apply loop tail)))))))))))

(define-syntax filter-map/stx
  ;;Map F across L, and save up all the non-false results.
  ;;
  (lambda (stx)
    (syntax-case stx ()
      ((_ ?f ?ell0 ?ell ...)
       (with-syntax (((ell  ...) (generate-temporaries (syntax (?ell ...)))))
	 (syntax (let ((f ?f))
		   (let loop ((result	'())
			      (ell0	?ell0)
			      (ell	?ell)
			      ...)
		     (if (or (null? ell0)
			     (null? ell)
			     ...)
			 (reverse result)
		       (let* ((v	(f (car ell0) (car ell) ...))
			      (result	(if v
					    (cons v result)
					  result)))
			 (loop result (cdr ell0) (cdr ell) ...)))))))))))

;; (define-syntax filter-map*/stx
;;   )



;;;; done

)

;;; end of file
