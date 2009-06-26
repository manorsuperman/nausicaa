;;;
;;;Copyright (c) 2008, 2009 Marco Maggi <marcomaggi@gna.org>
;;;Copyright (c) 2008 Derick Eddington
;;;
;;;Taylor Campbell wrote this code; he places it in the public domain.
;;;Modified by Derick Eddington to be included into an R6RS library.
;;;Modified by Marco Maggi to be included in Nausicaa.
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

;;;Many  functions  are  derived  from  the SRFI  13  (strings  library)
;;;reference implementation.  Its copyright notices are below.
;;;
;;;Olin Shivers 7/2000
;;;
;;;Copyright (c) 1988-1994 Massachusetts Institute of Technology.
;;;Copyright (c) 1998, 1999, 2000 Olin Shivers.  All rights reserved.
;;;
;;;MIT Scheme copyright terms
;;;==========================
;;;
;;;This   material  was  developed   by  the   Scheme  project   at  the
;;;Massachusetts  Institute  of  Technology,  Department  of  Electrical
;;;Engineering and Computer Science.  Permission to copy and modify this
;;;software, to redistribute either  the original software or a modified
;;;version, and to use this software for any purpose is granted, subject
;;;to the following restrictions and understandings.
;;;
;;;1. Any copy made of  this software must include this copyright notice
;;;   in full.
;;;
;;;2. Users  of this software  agree to make  their best efforts  (a) to
;;;   return to  the MIT Scheme  project any improvements  or extensions
;;;   that they make, so that  these may be included in future releases;
;;;   and (b) to inform MIT of noteworthy uses of this software.
;;;
;;;3.  All materials  developed  as a  consequence  of the  use of  this
;;;   software shall  duly acknowledge such use, in  accordance with the
;;;   usual standards of acknowledging credit in academic research.
;;;
;;;4. MIT has made no  warrantee or representation that the operation of
;;;   this software will  be error-free, and MIT is  under no obligation
;;;   to  provide  any  services,  by  way of  maintenance,  update,  or
;;;   otherwise.
;;;
;;;5. In  conjunction  with  products  arising  from  the  use  of  this
;;;   material, there shall  be no use of the  name of the Massachusetts
;;;   Institute  of Technology  nor  of any  adaptation  thereof in  any
;;;   advertising,  promotional,  or   sales  literature  without  prior
;;;   written consent from MIT in each case.
;;;
;;;Scsh copyright terms
;;;====================
;;;
;;;All rights reserved.
;;;
;;;Redistribution and  use in source  and binary forms, with  or without
;;;modification,  are permitted provided  that the  following conditions
;;;are met:
;;;
;;;1.  Redistributions of source  code must  retain the  above copyright
;;;   notice, this list of conditions and the following disclaimer.
;;;
;;;2. Redistributions in binary  form must reproduce the above copyright
;;;   notice, this  list of conditions  and the following  disclaimer in
;;;   the  documentation  and/or   other  materials  provided  with  the
;;;   distribution.
;;;
;;;3. The  name of  the authors may  not be  used to endorse  or promote
;;;   products derived from this software without specific prior written
;;;   permission.
;;;
;;;THIS SOFTWARE IS PROVIDED BY THE AUTHORS ``AS IS'' AND ANY EXPRESS OR
;;;IMPLIED  WARRANTIES,  INCLUDING,  BUT  NOT LIMITED  TO,  THE  IMPLIED
;;;WARRANTIES OF  MERCHANTABILITY AND  FITNESS FOR A  PARTICULAR PURPOSE
;;;ARE  DISCLAIMED.  IN NO  EVENT SHALL  THE AUTHORS  BE LIABLE  FOR ANY
;;;DIRECT,  INDIRECT, INCIDENTAL,  SPECIAL, EXEMPLARY,  OR CONSEQUENTIAL
;;;DAMAGES  (INCLUDING, BUT  NOT LIMITED  TO, PROCUREMENT  OF SUBSTITUTE
;;;GOODS  OR  SERVICES; LOSS  OF  USE,  DATA,  OR PROFITS;  OR  BUSINESS
;;;INTERRUPTION) HOWEVER CAUSED AND  ON ANY THEORY OF LIABILITY, WHETHER
;;;IN  CONTRACT,  STRICT LIABILITY,  OR  TORT  (INCLUDING NEGLIGENCE  OR
;;;OTHERWISE) ARISING IN  ANY WAY OUT OF THE USE  OF THIS SOFTWARE, EVEN
;;;IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.



#!r6rs
(library (vectors vectors-low)
  (export

    ;; constructors
    vector-concatenate  %vector-concatenate-reverse
    vector-tabulate  vector-append

    ;; predicates
    %vector-null?  %vector-any  %vector-every

    ;; comparison
    %vector-compare
    %vector=  %vector<>
    %vector<  %vector<=
    %vector>  %vector>=

    ;; mapping
    vector-map!
    vector-map*     vector-map*!     vector-for-each*
    %subvector-map  %subvector-map!  %subvector-for-each  %subvector-for-each-index

    ;; folding
    vector-fold       vector-fold-right
    vector-fold*      vector-fold-right*
    %subvector-fold  %subvector-fold-right
    vector-unfold     vector-unfold-right

    ;; selecting
    %vector-copy   %vector-reverse-copy
    %vector-copy!  %vector-reverse-copy!
    %vector-take   %vector-take-right
    %vector-drop   %vector-drop-right

    ;; padding and trimming
    %vector-trim  %vector-trim-right  %vector-trim-both
    %vector-pad   %vector-pad-right

    ;; prefix and suffix
    %vector-prefix-length  %vector-suffix-length
    %vector-prefix?        %vector-suffix?

    ;; searching
    %vector-index  %vector-index-right
    %vector-skip   %vector-skip-right
    %vector-count  %vector-contains
    %vector-binary-search

    ;; filtering
    %vector-delete  %vector-filter

    ;; lists
    %vector->list*  %reverse-vector->list
    reverse-list->vector

    ;; replicating
    %xsubvector  %vector-xcopy!

    ;; mutating
    vector-swap!  %vector-fill*!

    ;; reverse and replace
    %vector-reverse  %vector-reverse!
    %vector-replace)
  (import (rnrs)
    (only (rnrs r5rs) modulo quotient)
    (knuth-morris-pratt))


;;;; helpers

(define (vectors-list-min-length vectors)
  (apply min (map vector-length vectors)))


;;;; constructors

(define (vector-concatenate vectors)
  (let* ((total (do ((vectors vectors (cdr vectors))
		     (i 0 (+ i (vector-length (car vectors)))))
		    ((not (pair? vectors))
		     i)))
	 (result (make-vector total)))
    (let lp ((i 0) (vectors vectors))
      (if (pair? vectors)
	  (let* ((s (car vectors))
		 (slen (vector-length s)))
	    (%vector-copy! result i s 0 slen)
	    (lp (+ i slen) (cdr vectors)))))
    result))

(define (%vector-concatenate-reverse vector-list final past)
  (let* ((len (let loop ((sum 0) (lis vector-list))
		(if (pair? lis)
		    (loop (+ sum (vector-length (car lis))) (cdr lis))
		  sum)))
	 (result (make-vector (+ past len))))
    (%vector-copy! result len final 0 past)
    (let loop ((i len) (lis vector-list))
      (if (pair? lis)
	  (let* ((s   (car lis))
		 (lis (cdr lis))
		 (slen (vector-length s))
		 (i (- i slen)))
	    (%vector-copy! result i s 0 slen)
	    (loop i lis))))
    result))

(define (vector-append . vectors-list)
  (vector-concatenate vectors-list))

(define (vector-tabulate index->item len)
  (let ((vec (make-vector len)))
    (do ((i 0 (+ 1 i)))
	((= len i)
	 vec)
      (vector-set! vec i (index->item i)))))


;;;; predicates

(define (%vector-null? vec start past)
  (or (= 0 past)
      (= start past)))

(define (%vector-every pred vec start past)
  (and (< start past)
       (let loop ((i start))
	 (let ((c (vector-ref vec i))
	       (i1 (+ i 1)))
	   (if (= i1 past)
	       (pred c)
	     (and (pred c) (loop i1)))))))

(define (%vector-any pred vec start past)
  (and (< start past)
       (let loop ((i start))
	 (let ((c (vector-ref vec i))
	       (i1 (+ i 1)))
	   (if (= i1 past)
	       (pred c)
	     (or (pred c) (loop i1)))))))


;;;; comparison

(define (%vector-compare item= item<
			 str1 start1 past1 str2 start2 past2
			 proc< proc= proc>)
  (let ((size1 (- past1 start1))
	(size2 (- past2 start2)))
    (let ((match (%vector-prefix-length item= str1 start1 past1 str2 start2 past2)))
      (if (= match size1)
	  ((if (= match size2) proc= proc<) past1)
	((if (= match size2)
	     proc>
	   (if (item< (vector-ref str1 (+ start1 match))
		      (vector-ref str2 (+ start2 match)))
	       proc< proc>))
	 (+ match start1))))))

;;; --------------------------------------------------------------------

(define (%vector= item= vec1 start1 past1 vec2 start2 past2)
  (and (= (- past1 start1) (- past2 start2))
       (or (and (eq? vec1 vec2)
		(= start1 start2))
	   (let loop ((i start1) (j start2))
	     (or (= past1 i)
		 (and (item= (vector-ref vec1 i) (vector-ref vec2 j))
		      (loop (+ 1 i) (+ 1 j))))))))

(define (%vector<> item= vec1 start1 past1 vec2 start2 past2)
  (not (%vector= item= vec1 start1 past1 vec2 start2 past2)))

;;; --------------------------------------------------------------------

(define (%vector< item= item< str1 start1 past1 str2 start2 past2)
  (if (and (eq? str1 str2) (= start1 start2))
      (< past1 past2)
    (%vector-compare item= item<
		     str1 start1 past1 str2 start2 past2
		     values (lambda (i) #f) (lambda (i) #f))))

(define (%vector<= item= item< str1 start1 past1 str2 start2 past2)
  (if (and (eq? str1 str2) (= start1 start2))
      (<= past1 past2)
    (%vector-compare item= item<
		     str1 start1 past1 str2 start2 past2
		     values values (lambda (i) #f))))

(define (%vector> item= item< str1 start1 past1 str2 start2 past2)
  (if (and (eq? str1 str2) (= start1 start2))
      (> past1 past2)
    (%vector-compare item= item<
		     str1 start1 past1 str2 start2 past2
		     (lambda (i) #f) (lambda (i) #f) values)))

(define (%vector>= item= item< str1 start1 past1 str2 start2 past2)
  (if (and (eq? str1 str2) (= start1 start2))
      (>= past1 past2)
    (%vector-compare item= item<
		     str1 start1 past1 str2 start2 past2
		     (lambda (i) #f) values values)))


;;;; mapping

(define (=* . args)
  ;;This exists because some implementations (Mosh) do not allow = to be
  ;;called with less than 2 arguments.
  (if (null? args)
      #t
    (let loop ((val  (car args))
	       (args (cdr args)))
      (or (null? args)
	  (let ((new-val (car args)))
	    (and (= val new-val)
		 (loop new-val (cdr args))))))))

(define (vector-map! proc vec0 . vectors)
  (let ((vectors (cons vec0 vectors)))
    (if (apply =* (map vector-length vectors))
	(let ((len (vector-length vec0)))
	  (do ((i 0 (+ 1 i)))
	      ((= len i))
	    (vector-set! vec0 i
			 (apply proc i (map (lambda (vec) (vector-ref vec i))
					 vectors)))))
      (assertion-violation 'vector-map!
	"expected vectors of the same length"))))

(define (vector-map* proc vec0 . vectors)
  (let* ((vectors  (cons vec0 vectors))
	 (len      (vectors-list-min-length vectors)))
    (do ((i 0 (+ 1 i))
	 (result (make-vector len)))
	((= len i)
	 result)
      (vector-set! result i
		   (apply proc i (map (lambda (vec) (vector-ref vec i))
				   vectors))))))

(define (vector-map*! proc vec0 . vectors)
  (let* ((vectors  (cons vec0 vectors))
	 (len      (vectors-list-min-length vectors)))
    (do ((i 0 (+ 1 i)))
	((= len i))
      (vector-set! vec0 i
		   (apply proc i (map (lambda (vec) (vector-ref vec i))
				   vectors))))))

(define (vector-for-each* proc vec0 . vectors)
  (let* ((vectors  (cons vec0 vectors))
	 (len      (vectors-list-min-length vectors)))
    (do ((i 0 (+ 1 i)))
	((= len i))
      (apply proc i (map (lambda (vec) (vector-ref vec i))
		      vectors)))))

;;; --------------------------------------------------------------------

(define (%subvector-map proc vec start past)
  (do ((i start (+ 1 i))
       (j 0 (+ 1 j))
       (result (make-vector (- past start))))
      ((= i past)
       result)
    (vector-set! result j (proc (vector-ref vec i)))))

(define (%subvector-map! proc vec start past)
  (do ((i start (+ 1 i)))
      ((= i past)
       vec)
    (vector-set! vec i (proc (vector-ref vec i)))))

(define (%subvector-for-each proc vec start past)
  (let loop ((i start))
    (when (< i past)
      (proc (vector-ref vec i))
      (loop (+ i 1)))))

(define (%subvector-for-each-index proc vec start past)
  (let loop ((i start))
    (when (< i past)
      (proc i)
      (loop (+ i 1)))))


;;;; folding

(define (vector-fold kons knil vec0 . vectors)
  (let ((vectors (cons vec0 vectors)))
    (if (apply =* (map vector-length vectors))
	(let ((len (vector-length vec0)))
	  (let loop ((i     0)
		     (knil  knil))
	    (if (= len i)
		knil
	      (loop (+ 1 i) (apply kons i knil
				   (map (lambda (vec)
					  (vector-ref vec i))
				     vectors))))))
      (assertion-violation 'vector-fold
	"expected vectors of the same length"))))

(define (vector-fold-right kons knil vec0 . vectors)
  (let* ((vectors  (cons vec0 vectors)))
    (if (apply =* (map vector-length vectors))
	(let ((len (vectors-list-min-length vectors)))
	  (let loop ((i     (- len 1))
		     (knil  knil))
	    (if (< i 0)
		knil
	      (loop (- i 1) (apply kons i knil
				   (map (lambda (vec)
					  (vector-ref vec i))
				     vectors))))))
      (assertion-violation 'vector-fold-right
	"expected vectors of the same length"))))

(define (vector-fold* kons knil vec0 . vectors)
  (let* ((vectors  (cons vec0 vectors))
	 (len      (vectors-list-min-length vectors)))
    (let loop ((i     0)
	       (knil  knil))
      (if (= len i)
	  knil
	(loop (+ 1 i) (apply kons i knil
			     (map (lambda (vec)
				    (vector-ref vec i))
			       vectors)))))))

(define (vector-fold-right* kons knil vec0 . vectors)
  (let* ((vectors  (cons vec0 vectors))
	 (len      (vectors-list-min-length vectors)))
    (let loop ((i     (- len 1))
	       (knil  knil))
      (if (< i 0)
	  knil
	(loop (- i 1) (apply kons i knil
			     (map (lambda (vec)
				    (vector-ref vec i))
			       vectors)))))))

(define (%subvector-fold kons knil vec start past)
  (let loop ((v knil)
	     (i start))
    (if (< i past)
	(loop (kons (vector-ref vec i) v) (+ i 1))
      v)))

(define (%subvector-fold-right kons knil vec start past)
  (let loop ((v knil)
	     (i (- past 1)))
    (if (>= i start)
	(loop (kons (vector-ref vec i) v) (- i 1))
      v)))


;;The following unfold functions are  from the SRFI 13 (strings library)
;;reference  implementation.  For  some documentation  on them,  see the
;;(strings) library source code.

(define vector-unfold
  (case-lambda
   ((stop? seed->value make-seed seed)
    (vector-unfold stop? seed->value make-seed seed '#() (lambda (x) '#())))
   ((stop? seed->value make-seed seed base)
    (vector-unfold stop? seed->value make-seed seed base (lambda (x) '#())))
   ((stop? seed->value make-seed seed base make-final)
    (let loop ((chunks     '())
	       (nvalues     0)
	       (chunk      (make-vector 40))
	       (chunk-len  40)
	       (i          0)
	       (seed       seed))
      (let loop2 ((i i) (seed seed))
	(if (not (stop? seed))
	    (let ((c    (seed->value seed))
		  (seed (make-seed seed)))
	      (if (< i chunk-len)
		  (begin
		    (vector-set! chunk i c)
		    (loop2 (+ i 1) seed))

		(let* ((nvalues2    (+ chunk-len nvalues))
		       (chunk-len2  (min 4096 nvalues2))
		       (new-chunk   (make-vector chunk-len2)))
		  (vector-set! new-chunk 0 c)
		  (loop (cons chunk chunks) (+ nvalues chunk-len)
			new-chunk chunk-len2 1 seed))))

	  (let* ((final     (make-final seed))
		 (flen      (vector-length final))
		 (base-len  (vector-length base))
		 (j         (+ base-len nvalues i))
		 (ans       (make-vector (+ j flen))))
	    (%vector-copy! ans j final 0 flen)
	    (let ((j (- j i)))
	      (%vector-copy! ans j chunk 0 i)
	      (let loop ((j j) (chunks chunks))
		(if (pair? chunks)
		    (let* ((chunk      (car chunks))
			   (chunks     (cdr chunks))
			   (chunk-len  (vector-length chunk))
			   (j          (- j chunk-len)))
		      (%vector-copy! ans j chunk 0 chunk-len)
		      (loop j chunks)))))
	    (%vector-copy! ans 0 base 0 base-len) ; Install BASE.
	    ans)))))))

(define vector-unfold-right
  (case-lambda
   ((stop? seed->value make-seed seed)
    (vector-unfold-right stop? seed->value make-seed seed '#() (lambda (x) '#())))
   ((stop? seed->value make-seed seed base)
    (vector-unfold-right stop? seed->value make-seed seed base (lambda (x) '#())))
   ((stop? seed->value make-seed seed base make-final)
    (let loop ((chunks     '())
	       (nvalues    0)
	       (chunk      (make-vector 40))
	       (chunk-len  40)
	       (i          40)
	       (seed       seed))
      (let loop2 ((i i) (seed seed))
	(if (not (stop? seed))
	    (let ((c     (seed->value seed))
		  (seed  (make-seed seed)))
	      (if (> i 0)
		  (let ((i (- i 1)))
		    (vector-set! chunk i c)
		    (loop2 i seed))

		(let* ((nvalues2    (+ chunk-len nvalues))
		       (chunk-len2  (min 4096 nvalues2))
		       (new-chunk   (make-vector chunk-len2))
		       (i           (- chunk-len2 1)))
		  (vector-set! new-chunk i c)
		  (loop (cons chunk chunks) (+ nvalues chunk-len)
			new-chunk chunk-len2 i seed))))
	  (let* ((final       (make-final seed))
		 (flen        (vector-length final))
		 (base-len    (vector-length base))
		 (chunk-used  (- chunk-len i))
		 (j           (+ base-len nvalues chunk-used))
		 (ans         (make-vector (+ j flen))))
	    (%vector-copy! ans 0 final 0 flen)
	    (%vector-copy! ans flen chunk i chunk-len)
	    (let loop ((j (+ flen chunk-used))
		       (chunks chunks))
	      (if (pair? chunks)
		  (let* ((chunk      (car chunks))
			 (chunks     (cdr chunks))
			 (chunk-len  (vector-length chunk)))
		    (%vector-copy! ans j chunk 0 chunk-len)
		    (loop (+ j chunk-len) chunks))
		(%vector-copy! ans j base 0 base-len)))
	    ans)))))))


;;;; selecting

(define (%vector-copy vec start past)
  (let* ((len     (- past start))
	 (result  (make-vector len)))
    (do ((i start (+ 1 i))
	 (j 0 (+ 1 j)))
	((= past i)
	 result)
      (vector-set! result j (vector-ref vec i)))))

(define (%vector-reverse-copy vec start past)
  (let ((result (make-vector (- past start))))
    (do ((i (- past 1) (- i 1))
	 (j 0 (+ j 1)))
	((< i start)
	 result)
      (vector-set! result j (vector-ref vec i)))))

(define (%vector-take nvalues vec start past)
  (if (<= nvalues (- past start))
      (%vector-copy vec start (+ start nvalues))
    (assertion-violation '%vector-take
      "requested number of values greater than length of subvector" nvalues)))

(define (%vector-take-right nvalues vec start past)
  (if (<= nvalues (- past start))
      (%vector-copy vec (- past nvalues) past)
    (assertion-violation '%vector-take-right
      "requested number of values greater than length of subvector" nvalues)))

(define (%vector-drop nvalues vec start past)
  (if (<= nvalues (- past start))
      (%vector-copy vec nvalues past)
    (assertion-violation '%vector-take
      "requested number of values greater than length of subvector" nvalues)))

(define (%vector-drop-right nvalues vec start past)
  (if (<= nvalues (- past start))
      (%vector-copy vec start (+ start nvalues))
    (assertion-violation '%vector-take
      "requested number of values greater than length of subvector" nvalues)))

(define (%vector-trim criterion vec start past)
  (cond ((%vector-skip criterion vec start past)
	 => (lambda (i) (%vector-copy vec i past)))
	(else '#())))

(define (%vector-trim-right criterion vec start past)
  (cond ((%vector-skip-right criterion vec start past)
	 => (lambda (i) (%vector-copy vec start (+ 1 i))))
	(else '#())))

(define (%vector-trim-both criterion vec start past)
  (let ((vec (%vector-trim-right criterion vec start past)))
    (%vector-trim criterion vec start (vector-length vec))))

(define (%vector-pad requested-len fill-value vec start past)
  (let ((len (- past start)))
    (if (<= requested-len len)
	(%vector-copy vec (- past requested-len) past)
      (let ((result (make-vector requested-len fill-value)))
	(%vector-copy! result (- requested-len len) vec start past)
	result))))

(define (%vector-pad-right requested-len fill-value vec start past)
  (let ((len (- past start)))
    (if (<= requested-len len)
	(%vector-copy vec start (+ start requested-len))
      (let ((result (make-vector requested-len fill-value)))
	(%vector-copy! result 0 vec start past)
	result))))


;;;; prefix and suffix

(define (%vector-prefix-length item= vec1 start1 past1 vec2 start2 past2)
  ;;Find the length  of the common prefix.  It is  not required that the
  ;;two subvectors passed be of equal length.
  (let* ((delta (min (- past1 start1) (- past2 start2)))
	 (past1 (+ start1 delta)))
    (if (and (eq? vec1 vec2) (= start1 start2)) ; EQ fast path
	delta
      (let lp ((i start1) (j start2)) ; Regular path
	(if (or (>= i past1)
		(not (item= (vector-ref vec1 i)
				(vector-ref vec2 j))))
	    (- i start1)
	  (lp (+ i 1) (+ j 1)))))))

(define (%vector-suffix-length item= vec1 start1 past1 vec2 start2 past2)
  ;;Find the length  of the common suffix.  It is  not required that the
  ;;two subvectors passed be of equal length.
  (let* ((delta (min (- past1 start1) (- past2 start2)))
	 (start1 (- past1 delta)))
    (if (and (eq? vec1 vec2) (= past1 past2)) ; EQ fast path
	delta
      (let lp ((i (- past1 1)) (j (- past2 1))) ; Regular path
	(if (or (< i start1)
		(not (item= (vector-ref vec1 i)
				(vector-ref vec2 j))))
	    (- (- past1 i) 1)
	  (lp (- i 1) (- j 1)))))))

(define (%vector-prefix? item= vec1 start1 past1 vec2 start2 past2)
  (let ((len1 (- past1 start1)))
    (and (<= len1 (- past2 start2)) ; Quick check
	 (= len1 (%vector-prefix-length item=
					vec1 start1 past1
					vec2 start2 past2)))))

(define (%vector-suffix? item= vec1 start1 past1 vec2 start2 past2)
  (let ((len1 (- past1 start1)))
    (and (<= len1 (- past2 start2)) ; Quick check
	 (= len1 (%vector-suffix-length item=
					vec1 start1 past1
					vec2 start2 past2)))))


;;;; searching

(define (%vector-index pred? vec start past)
  (let loop ((i start))
    (and (< i past)
	 (if (pred? (vector-ref vec i)) i
	   (loop (+ i 1))))))

(define (%vector-index-right pred? vec start past)
  (let loop ((i (- past 1)))
    (and (>= i start)
	 (if (pred? (vector-ref vec i)) i
	   (loop (- i 1))))))

(define (%vector-skip pred? vec start past)
  (let loop ((i start))
    (and (< i past)
	 (if (pred? (vector-ref vec i)) (loop (+ i 1))
	   i))))

(define (%vector-skip-right pred? vec start past)
  (let loop ((i (- past 1)))
    (and (>= i start)
	 (if (pred? (vector-ref vec i)) (loop (- i 1))
	   i))))

(define (%vector-count pred? vec start past)
  (do ((i start (+ i 1))
       (count 0 (if (pred? (vector-ref vec i)) (+ count 1) count)))
      ((>= i past) count)))

(define (%vector-contains item= vec vec-start vec-past pattern pattern-start pattern-past)
  (%kmp-search item= vector-ref vec vec-start vec-past pattern pattern-start pattern-past))

(define (%vector-binary-search value cmp vec start past)
  (let loop ((start start) (past past) (j #f))
    (let ((i (quotient (+ start past) 2)))
      (if (or (= start past) (and j (= i j)))
	  #f
	(let ((comparison (cmp (vector-ref vec i) value)))
	  (cond ((zero?     comparison) i)
		((positive? comparison) (loop start i i))
		(else                   (loop i past i))))))))


;;;; filtering

(define (%vector-delete pred? vec start past)
  (let* ((slen (- past start))
	 (temp (make-vector slen))
	 (ans-len (%subvector-fold (lambda (c i)
				     (if (pred? c) i
				       (begin (vector-set! temp i c)
					      (+ i 1))))
				   0 vec start past)))
    (if (= ans-len slen) temp (%vector-copy temp 0 ans-len))))

(define (%vector-filter pred? vec start past)
  (let* ((slen (- past start))
	 (temp (make-vector slen))
	 (ans-len (%subvector-fold (lambda (c i)
				     (if (pred? c)
					 (begin (vector-set! temp i c)
						(+ i 1))
				       i))
				   0 vec start past)))
    (if (= ans-len slen) temp (%vector-copy temp 0 ans-len))))


;;;; extended subvector

(define (%xsubvector from to vec start past)
  (let ((vec-len     (- past start))
	(result-len  (- to from)))
    (cond ((zero? result-len) '#())
	  ((zero? vec-len)
	   (assertion-violation '%xsubvector "cannot replicate empty (sub)vector"))
	  ((= 1 vec-len)
	   (make-vector result-len (vector-ref vec start)))
	  ((= (floor (/ from vec-len)) (floor (/ to vec-len)))
	   (%vector-copy vec
			 (+ start (modulo from vec-len))
			 (+ start (modulo to   vec-len))))
	  (else
	   (let ((result (make-vector result-len)))
	     (%multispan-repcopy! from to result 0 vec start past)
	     result)))))

(define (%vector-xcopy! from to
			dst-vec dst-start dst-past
			src-vec src-start src-past)
  (let* ((tocopy	(- to from))
	 (tend		(+ dst-start tocopy))
	 (vec-len	(- src-past src-start)))
    (cond ((zero? tocopy))
	  ((zero? vec-len)
	   (assertion-violation '%vector-xcopy! "cannot replicate empty (sub)vector"))
	  ((= 1 vec-len)
	   (%vector-fill*! dst-vec (vector-ref src-vec src-start) dst-start dst-past))
	  ((= (floor (/ from vec-len)) (floor (/ to vec-len)))
	   (%vector-copy! dst-vec dst-start src-vec
			  (+ src-start (modulo from vec-len))
			  (+ src-start (modulo to   vec-len))))
	  (else
	   (%multispan-repcopy! from to dst-vec dst-start src-vec src-start src-past)))))

(define (%multispan-repcopy! from to dst-vec dst-start src-vec src-start src-past)
  (let* ((vec-len	(- src-past src-start))
	 (i0		(+ src-start (modulo from vec-len)))
	 (total-values	(- to from)))
    (%vector-copy! dst-vec dst-start src-vec i0 src-past)
    (let* ((ncopied (- src-past i0))
	   (nleft (- total-values ncopied))
	   (nspans (quotient nleft vec-len)))
      (do ((i (+ dst-start ncopied) (+ i vec-len))
	   (nspans nspans (- nspans 1)))
	  ((zero? nspans)
	   (%vector-copy! dst-vec i src-vec src-start (+ src-start (- total-values (- i dst-start)))))
	(%vector-copy! dst-vec i src-vec src-start src-past)))))


;;;; reverse and replace

(define (%vector-reverse str start past)
  (let* ((len (- past start))
	 (result (make-vector len)))
    (do ((i start (+ i 1))
	 (j (- len 1) (- j 1)))
	((< j 0))
      (vector-set! result j (vector-ref str i)))
    result))

(define (%vector-replace str1 start1 past1 str2 start2 past2)
  (let* ((len1		(vector-length str1))
	 (len2		(- past2 start2))
	 (result	(make-vector (+ len2 (- len1 (- past1 start1))))))
    (%vector-copy! result 0 str1 0 start1)
    (%vector-copy! result start1 str2 start2 past2)
    (%vector-copy! result (+ start1 len2) str1 past1 len1)
    result))

(define (%vector-reverse! str start past)
  (do ((i (- past 1) (- i 1))
       (j start (+ j 1)))
      ((<= i j))
    (let ((ci (vector-ref str i)))
      (vector-set! str i (vector-ref str j))
      (vector-set! str j ci))))


;;;; mutating

(define (%vector-fill*! fill-value str start past)
  (do ((i (- past 1) (- i 1)))
      ((< i start))
    (vector-set! str i fill-value)))

(define (vector-swap! vec i j)
  (when (= 0 (vector-length vec))
    (assertion-violation 'vector-swap!
      "attempt to swap elements in an empty vector"))
  (when (not (= i j))
    (let ((x (vector-ref vec i)))
      (vector-set! vec i (vector-ref vec j))
      (vector-set! vec j x))))


;;;; mutators

(define (%vector-copy! dst-vec dst-start src-vec src-start src-past)
  (when (< (- (vector-length dst-vec) dst-start)
	   (- src-past src-start))
    (assertion-violation '%vector-copy!
      "not enough room in destination vector"))
  ;;We must handle correctly copying over the same vector.
  (if (> src-start dst-start)
      (do ((i src-start (+ i 1))
	   (j dst-start (+ j 1)))
	  ((>= i src-past))
	(vector-set! dst-vec j (vector-ref src-vec i)))
    (do ((i (- src-past 1) (- i 1))
	 (j (+ -1 dst-start (- src-past src-start)) (- j 1)))
	((< i src-start))
      (vector-set! dst-vec j (vector-ref src-vec i)))))

(define (%vector-reverse-copy! dst-vec dst-start src-vec src-start src-past)
  (when (< (- (vector-length dst-vec) dst-start)
	   (- src-past src-start))
    (assertion-violation '%vector-reverse-copy!
      "not enough room in destination vector"))
  ;;We  must handle  correctly copying  over  the same  vector.  If  the
  ;;source  and  destination vectors  are  the  same,  we copy  all  the
  ;;elements  in a  temporary  buffer first;  this  should be  optimised
  ;;someway to reduce to the minimum the size of the buffer.
  (if (eq? src-vec dst-vec)
      (when (< src-start src-past)
	(let* ((buffer (%vector-reverse-copy src-vec src-start src-past)))
	  (%vector-copy! dst-vec dst-start buffer 0 (vector-length buffer))))
    (do ((i (- src-past 1) (- i 1))
	 (j dst-start (+ j 1)))
	((< i src-start))
      (vector-set! dst-vec j (vector-ref src-vec i)))))


;;;; lists

(define (reverse-list->vector vlist)
  (let* ((len (length vlist))
	 (s (make-vector len)))
    (do ((i (- len 1) (- i 1))
	 (vlist vlist (cdr vlist)))
	((not (pair? vlist)))
      (vector-set! s i (car vlist)))
    s))

(define (%reverse-vector->list vec start past)
  (let loop ((i       start)
	     (result  '()))
    (if (= i past)
	result
      (loop (+ 1 i) (cons (vector-ref vec i) result)))))

(define (%vector->list* str start past)
  (do ((i (- past 1) (- i 1))
       (result '() (cons (vector-ref str i) result)))
      ((< i start) result)))


;;;; done

)

;;; end of file