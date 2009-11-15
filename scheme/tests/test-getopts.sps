;;; -*- coding: utf-8-unix -*-
;;;
;;;Part of: Nausicaa/Scheme
;;;Contents: tests for the (getopts) library
;;;Date: Wed Nov 11, 2009
;;;
;;;Abstract
;;;
;;;
;;;
;;;Copyright (c) 2009 Marco Maggi <marcomaggi@gna.org>
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
  (strings)
  (vectors)
  (checks)
  (getopts))

(check-set-mode! 'report-failed)
(display "*** testing getopts\n")


(parametrise ((check-test-name	'non-options))

  (check
      (let ((args '()))
	(list (getopts '()
		       '()
		       (lambda (non-option)
			 (set-cons! args non-option)))
	      args))
    => '(#t ()))

  (check
      (let ((args '()))
	(list (getopts '("alpha" "beta")
		       '()
		       (lambda (non-option)
			 (set-cons! args non-option)))
	      args))
    => '(#t ("beta" "alpha")))

  (check
      (let ((args '()))
	(list (getopts '("alpha" "beta" "-")
		       '()
		       (lambda (non-option)
			 (set-cons! args non-option)))
	      args))
    => '(#t ("-" "beta" "alpha")))

;;; --------------------------------------------------------------------
;;; Double-dash and multiple double-dash handling.

  (check
      (let ((args '()))
	(list (getopts '("--")
		       '()
		       (lambda (non-option)
			 (set-cons! args non-option)))
	      args))
    => '(#t ()))

  (check
      (let ((args '()))
	(list (getopts '("alpha" "beta" "--" "delta")
		       '()
		       (lambda (non-option)
			 (set-cons! args non-option)))
	      args))
    => '(#t ("delta" "beta" "alpha")))

  (check
      (let ((args '()))
	(list (getopts '("alpha" "beta" "--" "--")
		       '()
		       (lambda (non-option)
			 (set-cons! args non-option)))
	      args))
    => '(#t ("--" "beta" "alpha")))

  (check
      (let ((args '()))
	(list (getopts '("alpha" "beta" "--" "--")
		       '()
		       (lambda (non-option)
			 (set-cons! args non-option))
		       (getopts-options ignore-multiple-double-dashes))
	      args))
    => '(#t ("beta" "alpha")))

;;; --------------------------------------------------------------------
;;; Returning after unknown option.

  (check		;returning after long
      (with-exception-handler
	  (lambda (e) #t)
	(lambda ()
	  (let ((args '()))
	    (list (getopts '("alpha" "beta" "--wow" "delta")
			   '()
			   (lambda (non-option)
			     (set-cons! args non-option)))
		  args))))
    => '(#t ("delta" "beta" "alpha")))

  (check		;returning after brief
      (with-exception-handler
	  (lambda (e) #t)
	(lambda ()
	  (let ((args '()))
	    (list (getopts '("alpha" "beta" "-I" "delta")
			   '()
			   (lambda (non-option)
			     (set-cons! args non-option)))
		  args))))
    => '(#t ("delta" "beta" "alpha")))

  (check		;multiple returning
      (with-exception-handler
	  (lambda (e) #t)
	(lambda ()
	  (let ((args '()))
	    (list (getopts '("alpha" "beta" "--wow" "delta" "-I" "gamma")
			   '()
			   (lambda (non-option)
			     (set-cons! args non-option)))
		  args))))
    => '(#t ("gamma" "delta" "beta" "alpha")))

  #t)


(parametrise ((check-test-name	'long-options))

  (define (noop . args)
    #f)

;;; --------------------------------------------------------------------
;;; without values

  (check
      (let* ((result		'())
	     (register-without	(lambda (opt)
				  (set-cons! result (<option>-long opt))))
	     (alpha		(make-<option> #\a "alpha" #f "the option alpha" register-without)))
	(list (getopts '("--alpha") (list alpha) noop)
	      result))
    => '(#t ("alpha")))

  (check
      (let* ((result		'())
	     (register-without	(lambda (opt)
				  (set-cons! result (<option>-long opt))))
	     (alpha		(make-<option> #\a "alpha" #f "the option alpha" register-without))
	     (beta		(make-<option> #\b "beta" #f "the option alpha"  register-without)))
	(list (getopts '("--alpha" "--beta") (list alpha beta) noop)
	      result))
    => '(#t ("beta" "alpha")))

;;; --------------------------------------------------------------------
;;; with values

  (check
      (let* ((result		'())
	     (register-with	(lambda (opt val)
				  (set-cons! result (list (<option>-long opt) val))))
	     (alpha		(make-<option> #\a "alpha" #t "the option alpha" register-with)))
	(list (getopts '("--alpha=123") (list alpha) noop)
	      result))
    => '(#t (("alpha" "123"))))

  (check		;empty value
      (let* ((result		'())
	     (register-with	(lambda (opt val)
				  (set-cons! result (list (<option>-long opt) val))))
	     (alpha		(make-<option> #\a "alpha" #t "the option alpha" register-with)))
	(list (getopts '("--alpha=") (list alpha) noop)
	      result))
    => '(#t (("alpha" ""))))

  (check
      (let* ((result		'())
	     (register-with	(lambda (opt val)
				  (set-cons! result (list (<option>-long opt) val))))
	     (alpha		(make-<option> #\a "alpha" #t "the option alpha" register-with))
	     (beta		(make-<option> #\b "beta"  #t "the option beta"  register-with)))
	(list (getopts '("--alpha=123" "--beta=456") (list alpha beta) noop)
	      result))
    => '(#t (("beta" "456")
	     ("alpha" "123"))))

  (check
      (let* ((result		'())
	     (register-with	(lambda (opt val)
				  (set-cons! result (list (<option>-long opt) val))))
	     (alpha		(make-<option> #\a "alpha" #t "the option alpha" register-with))
	     (beta		(make-<option> #\b "beta"  #t "the option beta"  register-with)))
	(list (getopts '("--alpha" "123" "--beta" "456") (list alpha beta) noop)
	      result))
    => '(#t (("beta" "456")
	     ("alpha" "123"))))

;;; --------------------------------------------------------------------
;;; unknown option error

  (check		;without value
      (let* ((result '())
	     (register-with	(lambda (opt val)
				  (set-cons! result (list (<option>-long opt) val))))
	     (alpha		(make-<option> #\a "alpha" #t "the option alpha" register-with))
	     (beta		(make-<option> #\b "beta"  #t "the option beta"  register-with)))
	(guard (E ((unknown-option-condition? E)
		   (list (condition-brief/long E)
			 (condition-argument E)))
		  (else
		   #f))
	  (getopts '("--delta") (list alpha beta) noop)))
    => '("delta" "--delta"))

  (check		;with value
      (let* ((result '())
	     (register-with	(lambda (opt val)
				  (set-cons! result (list (<option>-long opt) val))))
	     (alpha		(make-<option> #\a "alpha" #t "the option alpha" register-with))
	     (beta		(make-<option> #\b "beta"  #t "the option beta"  register-with)))
	(guard (E ((unknown-option-condition? E)
		   (list (condition-brief/long E)
			 (condition-argument E)))
		  (else
		   #f))
	  (getopts '("--delta=123") (list alpha beta) noop)))
    => '("delta" "--delta=123"))

;;; --------------------------------------------------------------------
;;; option requires value error

  (check
      (let* ((result '())
	     (register-with	(lambda (opt val)
				  (set-cons! result (list (<option>-long opt) val))))
	     (alpha		(make-<option> #\a "alpha" #t "the option alpha" register-with)))
	(guard (E ((option-requires-value-condition? E)
		   (list (<option>-long (condition-option E))
			 (condition-argument E)))
		  (else
		   #f))
	  (getopts '("--alpha") (list alpha) noop)))
    => '("alpha" "--alpha"))

;;; --------------------------------------------------------------------
;;; option requires no value error

  (check
      (let* ((result '())
	     (register-with	(lambda (opt val)
				  (set-cons! result (list (<option>-long opt) val))))
	     (alpha		(make-<option> #\a "alpha" #f "the option alpha" register-with)))
	(guard (E ((option-requires-no-value-condition? E)
		   (list (<option>-long (condition-option E))
			 (condition-argument E)))
		  (else
		   #f))
	  (getopts '("--alpha=123") (list alpha) noop)))
    => '("alpha" "--alpha=123"))

  (check
      (let* ((result '())
	     (register-with	(lambda (opt val)
				  (set-cons! result (list (<option>-long opt) val))))
	     (alpha		(make-<option> #\a "alpha" #f "the option alpha" register-with)))
	(guard (E ((option-requires-no-value-condition? E)
		   (list (<option>-long (condition-option E))
			 (condition-argument E)))
		  (else
		   #f))
	  (getopts '("--alpha=") (list alpha) noop)))
    => '("alpha" "--alpha="))


  #t)


(parametrise ((check-test-name	'brief-options))

  (define (noop . args)
    #f)

;;; --------------------------------------------------------------------
;;; without values

  (check
      (let* ((result		'())
	     (register-without	(lambda (opt)
				  (set-cons! result (<option>-long opt))))
	     (alpha		(make-<option> #\a "alpha" #f "the option alpha" register-without)))
	(list (getopts '("-a") (list alpha) noop)
	      result))
    => '(#t ("alpha")))

  (check
      (let* ((result		'())
	     (register-without	(lambda (opt)
				  (set-cons! result (<option>-long opt))))
	     (alpha		(make-<option> #\a "alpha" #f "the option alpha" register-without))
	     (beta		(make-<option> #\b "beta" #f "the option beta"  register-without)))
	(list (getopts '("-a" "-b") (list alpha beta) noop)
	      result))
    => '(#t ("beta" "alpha")))

  (check	;train
      (let* ((result		'())
	     (register-without	(lambda (opt)
				  (set-cons! result (<option>-long opt))))
	     (alpha		(make-<option> #\a "alpha" #f "the option alpha" register-without))
	     (beta		(make-<option> #\b "beta" #f "the option beta"  register-without))
	     (delta		(make-<option> #\d "delta" #f "the option delta" register-without)))
	(list (getopts '("-abd") (list alpha beta delta) noop)
	      result))
    => '(#t ("delta" "beta" "alpha")))

;;; --------------------------------------------------------------------
;;; with values

  (check
      (let* ((result		'())
	     (register-with	(lambda (opt val)
				  (set-cons! result (list (<option>-long opt) val))))
	     (alpha		(make-<option> #\a "alpha" #t "the option alpha" register-with)))
	(list (getopts '("-a123") (list alpha) noop)
	      result))
    => '(#t (("alpha" "123"))))

  (check
      (let* ((result		'())
	     (register-with	(lambda (opt val)
				  (set-cons! result (list (<option>-long opt) val))))
	     (alpha		(make-<option> #\a "alpha" #t "the option alpha" register-with))
	     (beta		(make-<option> #\b "beta"  #t "the option beta"  register-with)))
	(list (getopts '("-a" "123" "-b" "456") (list alpha beta) noop)
	      result))
    => '(#t (("beta" "456")
	     ("alpha" "123"))))

  (check		;train
      (let* ((result		'())
	     (register-with	(lambda (opt val)
				  (set-cons! result (list (<option>-long opt) val))))
	     (register-without	(lambda (opt)
				  (set-cons! result (<option>-long opt))))
	     (alpha		(make-<option> #\a "alpha" #f "the option alpha" register-without))
	     (beta		(make-<option> #\b "beta"  #f "the option beta"  register-without))
	     (delta		(make-<option> #\d "delta" #t "the option delta" register-with)))
	(list (getopts '("-abd" "123") (list alpha beta delta) noop)
	      result))
    => '(#t (("delta" "123") "beta" "alpha")))

;;; --------------------------------------------------------------------
;;; unknown option error

  (check	;without value
      (let* ((result '())
	     (register-with	(lambda (opt val)
				  (set-cons! result (list (<option>-long opt) val))))
	     (alpha		(make-<option> #\a "alpha" #t "the option alpha" register-with))
	     (beta		(make-<option> #\b "beta"  #t "the option beta"  register-with)))
	(guard (E ((unknown-option-condition? E)
		   (list (condition-brief/long E)
			 (condition-argument E)))
		  (else
		   #f))
	  (getopts '("-d") (list alpha beta) noop)))
    => '(#\d "-d"))

  (check	;without value, in train
      (let* ((result '())
	     (register-with	(lambda (opt val)
				  (set-cons! result (list (<option>-long opt) val))))
	     (register-without	(lambda (opt)
				  (set-cons! result (<option>-long opt))))
	     (alpha		(make-<option> #\a "alpha" #f "the option alpha" register-without))
	     (beta		(make-<option> #\b "beta"  #f "the option beta"  register-without)))
	(guard (E ((unknown-option-condition? E)
		   (list (condition-brief/long E)
			 (condition-argument E)))
		  (else
		   #f))
	  (getopts '("-abd") (list alpha beta) noop)))
    => '(#\d "-abd"))

  (check	;without value, in train
      (let* ((result '())
	     (register-with	(lambda (opt val)
				  (set-cons! result (list (<option>-long opt) val))))
	     (register-without	(lambda (opt)
				  (set-cons! result (<option>-long opt))))
	     (alpha		(make-<option> #\a "alpha" #f "the option alpha" register-without))
	     (beta		(make-<option> #\b "beta"  #f "the option beta"  register-without)))
	(guard (E ((unknown-option-condition? E)
		   (list (condition-brief/long E)
			 (condition-argument E)))
		  (else
		   #f))
	  (getopts '("-adb") (list alpha beta) noop)))
    => '(#\d "-adb"))

  (check	;with value
      (let* ((result '())
	     (register-with	(lambda (opt val)
				  (set-cons! result (list (<option>-long opt) val))))
	     (alpha		(make-<option> #\a "alpha" #t "the option alpha" register-with))
	     (beta		(make-<option> #\b "beta"  #t "the option beta"  register-with)))
	(guard (E ((unknown-option-condition? E)
		   (list (condition-brief/long E)
			 (condition-argument E)))
		  (else
		   #f))
	  (getopts '("-d123") (list alpha beta) noop)))
    => '(#\d "-d123"))

;;; --------------------------------------------------------------------
;;; option requires value error

  (check
      (let* ((result '())
	     (register-with	(lambda (opt val)
				  (set-cons! result (list (<option>-long opt) val))))
	     (alpha		(make-<option> #\a "alpha" #t "the option alpha" register-with)))
	(guard (E ((option-requires-value-condition? E)
		   (list (<option>-long (condition-option E))
			 (condition-argument E)))
		  (else
		   #f))
	  (getopts '("-a") (list alpha) noop)))
    => '("alpha" "-a"))

;;; --------------------------------------------------------------------
;;; option requires no value error

  (check
      (let* ((result '())
	     (register-without	(lambda (opt)
				  (set-cons! result (<option>-long opt))))
	     (alpha		(make-<option> #\a "alpha" #f "the option alpha" register-without)))
	(guard (E ((unknown-option-condition? E)
		   (list (condition-brief/long E)
			 (condition-argument E)))
		  (else
		   #f))
	  (getopts '("-a123") (list alpha) noop)))
    => '(#\1 "-a123"))

;;; --------------------------------------------------------------------
;;; invalid option, train of brief with value attached

  (check		;train
      (let* ((result		'())
	     (register-with	(lambda (opt val)
				  (set-cons! result (list (<option>-long opt) val))))
	     (register-without	(lambda (opt)
				  (set-cons! result (<option>-long opt))))
	     (alpha		(make-<option> #\a "alpha" #f "the option alpha" register-without))
	     (beta		(make-<option> #\b "beta"  #f "the option beta"  register-without))
	     (delta		(make-<option> #\d "delta" #t "the option delta" register-with)))
	(guard (E ((invalid-option-condition? E)
		   (list (<option>-brief (condition-option E))
			 (condition-argument E)))
		  (else
		   #f))
	  (getopts '("-abd123") (list alpha beta delta) noop)))
    => '(#\d "-abd123"))

  #t)


(parametrise ((check-test-name	'arguments))

  (define result #f)

  (define-syntax %getopts
    (syntax-rules ()
      ((_ ?arg ...)
       (begin
	 (set! result '())
	 (getopts ?arg ...)
	 (reverse result)))))

  (define (register-with opt val)
    (set-cons! result (list (<option>-long opt) val)))

  (define (register-without opt)
    (set-cons! result (list (<option>-long opt))))

  (define (register-non-option arg)
    (set-cons! result arg))

  (define-option interactive
    (brief #\i)
    (long "interactive")
    (with-arg? #f)
    (description "ask the user first")
    (action register-without))

  (define-option force
    (brief #\f)
    (long "force")
    (with-arg? #f)
    (description "hurt me plenty")
    (action register-without))

  (define-option help
    (brief #\h)
    (long "help")
    (with-arg? #f)
    (description "print help screen")
    (action register-without))

  (define-option file
    (brief #\F)
    (long "file")
    (with-arg? #t)
    (description "input file")
    (action register-with))

  (define-option archive
    (brief #\A)
    (long "archive")
    (with-arg? #t)
    (description "output archive")
    (action register-with))

  (define options
    (list interactive force help file archive))

;;; --------------------------------------------------------------------

  (check
      (%getopts '("--file" "ciao") options register-non-option)
    => '(("file" "ciao")))

  #t)


;;;; done

(check-report)

;;; end of file
