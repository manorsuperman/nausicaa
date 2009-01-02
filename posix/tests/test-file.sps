;;;
;;;Part of: Nausicaa/POSIX
;;;Contents: tests for the file system functions
;;;Date: Fri Jan  2, 2009
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



;;;; setup

(import (except (r6rs) read write)
  (uriel lang)
  (uriel foreign)
  (only (string-lib) string-join)
  (uriel test)
  (posix process)
  (posix fd)
  (posix file)
  (posix sizeof)
  (env-lib))

(check-set-mode! 'report-failed)

(define debugging #t)
(define (debug . args)
  (when debugging
    (apply format (current-error-port) args)
    (newline (current-error-port))))


;;;; test hierarchy

(define TMPDIR
  (or (get-environment-variable "TMPDIR")
      "/tmp"))

(define the-root	(string-join (list TMPDIR "root-dir") "/"))
(define the-file	(string-join (list the-root "name.ext") "/"))
(define the-subdir-1	(string-join (list the-root "dir-1") "/"))
(define the-file-10	(string-join (list the-subdir-1 "name-10.ext") "/"))
(define the-file-11	(string-join (list the-subdir-1 "name-11.ext") "/"))
(define the-subdir-2	(string-join (list the-root "dir-2") "/"))
(define the-file-2	(string-join (list the-subdir-2 "name-2.ext") "/"))
(define the-subdir-3	(string-join (list the-root "dir-3") "/"))

(define the-string "Le Poete est semblable au prince des nuees
Qui hante la tempete e se rit de l'archer;
Exile sul le sol au milieu des huees,
Ses ailes de geant l'empechent de marcher.")

;;The hierarchy looks like this:
;;
;; $TMPDIR/root-dir/
;; $TMPDIR/root-dir/dir-1/
;; $TMPDIR/root-dir/dir-1/name-10.ext
;; $TMPDIR/root-dir/dir-1/name-11.ext
;; $TMPDIR/root-dir/dir-2/
;; $TMPDIR/root-dir/dir-2/name-2.ext
;; $TMPDIR/root-dir/dir-3/
;; $TMPDIR/root-dir/name.ext
;;
(define the-layout
  (list the-root
	the-subdir-1 the-file-10 the-file-11
	the-subdir-2 the-file-2
	the-subdir-3
	the-file))

(define (make-test-hierarchy)
  (system (string-append "mkdir --mode=0700 " the-root))
  (system (string-append "mkdir --mode=0700 " the-subdir-1))
  (system (string-append "mkdir --mode=0700 " the-subdir-2))
  (system (string-append "mkdir --mode=0700 " the-subdir-3))
  (system (string-append "umask 0077; echo \"" the-string "\" >" the-file))
  (system (string-append "umask 0077; echo \"" the-string "\" >" the-file-10))
  (system (string-append "umask 0077; echo \"" the-string "\" >" the-file-11))
  (system (string-append "umask 0077; echo \"" the-string "\" >" the-file-2)))

(define (clean-test-hierarchy)
  (system (string-append "rm -fr " the-root)))



(parameterize ((testname 'working-directory))

  (check
      (let ((dirname '/))
	(chdir dirname))
    => 0)

  (check
      (let ((dirname '/usr/local/bin))
	(chdir dirname))
    => 0)

  (check
      (let ((dirname '/scrappy/dappy/doo))
	(guard (exc (else
		     (list (errno-condition? exc)
			   (condition-who exc)
			   (errno-symbolic-value exc))))
	  (chdir dirname)))
    => '(#t primitive-chdir ENOENT))

  (check
      (let ((dirname '/usr/local/bin))
	(chdir dirname)
	(getcwd))
    => "/usr/local/bin")

  (check
      (let ((dirname '/bin))
	(chdir dirname)
	(pwd))
    => "/bin")

  )



(clean-test-hierarchy)

(parameterize ((testname 'directory-access))

  (with-compensations
      (compensate
	  (make-test-hierarchy)
	(with
	 (clean-test-hierarchy)))

    (check
	(with-compensations
	  (let ((dir	(opendir/c the-root))
		(layout	'()))
	    (do ((entry (readdir dir) (readdir dir)))
		((pointer-null? entry))
	      (set! layout
		    (cons (cstring->string (struct-dirent-d_name-ref entry))
			  layout)))
	    (list-sort string<? layout)))
      => '("." ".." "dir-1" "dir-2" "dir-3" "name.ext"))

    (check
	(with-compensations
	  (let ((dir	(opendir/c the-subdir-1))
		(layout	'()))
	    (do ((entry (readdir dir) (readdir dir)))
		((pointer-null? entry))
	      (set! layout
		    (cons (cstring->string (struct-dirent-d_name-ref entry))
			  layout)))
	    (list-sort string<? layout)))
      => '("." ".." "name-10.ext" "name-11.ext"))

    (check
	(with-compensations
	  (let ((dir	(opendir/c the-subdir-3))
		(layout	'()))
	    (do ((entry (readdir dir) (readdir dir)))
		((pointer-null? entry))
	      (set! layout
		    (cons (cstring->string (struct-dirent-d_name-ref entry))
			  layout)))
	    (list-sort string<? layout)))
      => '("." ".."))

    (check
	(list-sort string<? (directory-list the-root))
      => '("." ".." "dir-1" "dir-2" "dir-3" "name.ext"))

    (check
	(list-sort string<? (directory-list the-subdir-1))
      => '("." ".." "name-10.ext" "name-11.ext"))

    (check
	(list-sort string<? (directory-list the-subdir-3))
      => '("." ".."))

    (check
	(letrec ((fd	(compensate
			    (open the-root O_RDONLY 0)
			  (with
			   (close fd)))))
	  (list-sort string<? (directory-list/fd fd)))
      => '("." ".." "dir-1" "dir-2" "dir-3" "name.ext"))

    (when (number? O_NOATIME)
      (check
	  (letrec ((fd	(compensate
			    (open the-root O_RDONLY 0)
			  (with
			   (close fd)))))
	    (list-sort string<? (directory-list/fd fd)))
	=> '("." ".." "dir-1" "dir-2" "dir-3" "name.ext")))

    (check
	(with-compensations
	  (let ((dir		(opendir/c the-root))
		(layout2	'())
		(layout1	'()))
	    (do ((entry (readdir dir) (readdir dir)))
		((pointer-null? entry))
	      (set! layout1
		    (cons (cstring->string (struct-dirent-d_name-ref entry))
			  layout1)))
	    (rewinddir dir)
	    (do ((entry (readdir dir) (readdir dir)))
		((pointer-null? entry))
	      (set! layout2
		    (cons (cstring->string (struct-dirent-d_name-ref entry))
			  layout2)))
	    (append (list-sort string<? layout1)
		    (list-sort string<? layout2))))
      => '("." ".." "dir-1" "dir-2" "dir-3" "name.ext"
	   "." ".." "dir-1" "dir-2" "dir-3" "name.ext"))

    (check
	(with-compensations
	  (let ((dir	(opendir/c the-root))
		(layout	'()))
	    (do ((entry (readdir dir) (readdir dir)))
		((pointer-null? entry))
	      (set! layout
		    (cons (cons (cstring->string (struct-dirent-d_name-ref entry))
				(telldir entry))
			  layout)))
	    (map car (list-sort (lambda (a b)
				  (string<? (car a) (car b)))
				layout))))
      => '("." ".." "dir-1" "dir-2" "dir-3" "name.ext"))

    ))

(clean-test-hierarchy)


;;;; done

(check-report)

;;; end of file