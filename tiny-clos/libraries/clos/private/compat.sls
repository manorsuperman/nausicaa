
(library (clos private compat)

  (export every
          every-2
          append-map
          last
          get-arg
          position
          make-parameter
          pointer-value)

  (import (rnrs)
          (only (srfi lists)
                every
                append-map
                last)
          (only (srfi parameters)
                make-parameter))

  (define (pointer-value value)
    (string-hash
     (call-with-string-output-port (lambda () (display value)))))

  (define (position obj lst)
    (let loop ((lst lst) (idx 0) (obj obj))
      (cond
        ((null? lst)
         #f)
        ((eq? (car lst) obj)
         idx)
        (else
         (loop (cdr lst) (+ idx 1) obj)))))

  (define (every-2 pred lst1 lst2)
    (let loop ((pred pred) (lst1 lst1) (lst2 lst2))
      (or (null? lst1)
          (null? lst2)
          (and (pred (car lst1) (car lst2))
               (loop pred (cdr lst1) (cdr lst2))))))

  (define (get-arg key lst . def)
    (let ((probe (member key lst)))
      (if (or (not probe)
              (not (pair? (cdr probe))))
          (if (pair? def)
              (car def)
              (error 'get-arg
                     "mandatory keyword argument ~a missing in ~a" key lst))
          (cadr probe))))

  ) ;; library (clos private compat)
