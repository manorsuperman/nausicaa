;;; -*- coding: utf-8-unix -*-
;;;
;;;Part of: Nausicaa/POSIX
;;;Contents: posix interface to file functions
;;;Date: Wed Nov  4, 2009
;;;
;;;Abstract
;;;
;;;
;;;
;;;Copyright (c) 2009 Marco Maggi <marco.maggi-ipsu@poste.it>
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


(library (posix file primitives)
  (export

    ;; working directory
    getcwd		chdir		fchdir

    ;; directory access
    opendir		fdopendir	dirfd
    closedir		readdir		readdir_r
    rewinddir		telldir		seekdir
    dirent-name->string
    ftw			nftw
    make-ftw-callback	make-nftw-callback

    ;; links
    link		symlink		readlink
    realpath

    ;; removing
    unlink		rmdir		remove

    ;; renaming
    rename

    ;; mkdir
    mkdir

    ;; changing owner
    chown		fchown

    ;; changing permissions
    chmod		fchmod
    getumask		(rename (platform:umask	umask))

    ;; access test
    access

    ;; file times, note that LUTIMES and FUTIMES are glibc stuff
    utime		utimes

    ;; file size
    file-size		ftruncate	truncate

    ;; temporary files
    mkstemp		mkdtemp

    ;; stat
    stat lstat fstat
    (rename (platform:S_ISDIR		S_ISDIR)
	    (platform:S_ISCHR		S_ISCHR)
	    (platform:S_ISBLK		S_ISBLK)
	    (platform:S_ISREG		S_ISREG)
	    (platform:S_ISFIFO		S_ISFIFO)
	    (platform:S_ISLNK		S_ISLNK)
	    (platform:S_ISSOCK		S_ISSOCK)
	    (platform:S_TYPEISMQ	S_TYPEISMQ)
	    (platform:S_TYPEISSEM	S_TYPEISSEM)
	    (platform:S_TYPEISSHM	S_TYPEISSHM))

    pointer-><struct-stat>

    )
  (import (except (rnrs) remove truncate)
    (receive)
    (begin0)
    (compensations)
    (foreign ffi)
    (foreign ffi sizeof)
    (foreign memory)
    (only (foreign cstrings) cstring->string string->cstring/c)
    (foreign errno)
    (posix sizeof)
    (posix typedefs)
    (prefix (posix fd) posix:)
    (prefix (posix file platform) platform:))


;;;; working directory

(define (getcwd)
  (let loop ((buflen 1024))
    (with-compensations
      (let ((buffer (malloc-block/c buflen)))
	(receive (cstr errno)
	    (platform:getcwd buffer buflen)
	  (if (and (= 0 (pointer->integer cstr))
		   (or (= EINVAL errno)
		       (= ERANGE errno)))
	      (loop (* 2 buflen))
	    (begin
	      (when (pointer-null? cstr)
		(raise-errno-error 'getcwd errno))
	      (cstring->string buffer))))))))

(define (chdir directory-pathname)
  (with-compensations
    (receive (result errno)
	(platform:chdir (string->cstring/c directory-pathname))
      (unless (= 0 result)
	(raise-errno-error 'chdir errno
			   directory-pathname))
      result)))

(define (fchdir fd)
  (receive (result errno)
      (platform:fchdir (file-descriptor->integer fd))
    (unless (= 0 result)
      (raise-errno-error 'fchdir errno fd))
    result))


;;;; directory access

(define (opendir pathname)
  (with-compensations
    (receive (result errno)
	(platform:opendir (string->cstring/c pathname))
      (when (pointer-null? result)
	(raise-errno-error 'opendir errno pathname))
      result)))

(define (fdopendir fd)
  (receive (result errno)
      (platform:fdopendir (file-descriptor->integer fd))
    (when (pointer-null? result)
      (raise-errno-error 'fdopendir errno fd))
    result))

(define (dirfd stream)
  (receive (result errno)
      (platform:dirfd stream)
    (when (= -1 result)
      (raise-errno-error 'dirfd errno stream))
    result))

(define (closedir stream)
  (receive (result errno)
      (platform:closedir stream)
    (when (= -1 result)
      (raise-errno-error 'closedir errno stream))
    result))

(define (readdir stream)
  (receive (result errno)
      (platform:readdir stream)
    (if (and (pointer-null? result)
	     (not (= 0 errno)))
	(raise-errno-error 'readdir errno stream)
      result)))

(define (readdir_r stream)
  (let ((result (malloc-block/c sizeof-dirent)))
    (with-compensations
      ;;*FIXME*  It looks  like the  size  of the  "struct dirent"  type
      ;;cannot  be  safely  determined  with  the  "sizeof"  C  language
      ;;operator.   So the  allocation form  below  may turn  out to  be
      ;;wrong.   See the  manual page  of "readdir_r()"  on  a GNU+Linux
      ;;system for details on the correct way to determine the size.
      ;;
      ;;It  is not  implemented  here  because it  needs  to change  the
      ;;interface adding the pathname  of the directory to be inspected;
      ;;this is not desirable now, we will see in the future.
      ;;
      ;;For the time being, it  seems that on GNU+Linux systems for i686
      ;;architectures   the   size  is   correct.    Also  notice   that
      ;;MALLOC-BLOCK/C will  probably allocate a page  (4096 bytes) from
      ;;its own cache; see the documentation of Nausicaa/Scheme.
      ;;
      (let ((entry	(malloc-block/c sizeof-dirent))
	    (*result	(malloc-block/c sizeof-pointer)))
	(receive (retval errno)
	    (platform:readdir_r stream entry *result)
	  (cond ((not (= 0 retval))
		 (raise-errno-error 'readdir errno stream))
		((pointer-null? (pointer-ref-c-pointer *result 0))
		 pointer-null)
		(else
		 (memcpy result entry sizeof-dirent)
		 result)))))))

(define (rewinddir stream)
  (platform:rewinddir stream))

(define (telldir stream)
  (platform:telldir stream))

(define (seekdir stream position)
  (platform:seekdir stream position))

(define (dirent-name->string struct-dirent-pointer)
  (cstring->string (struct-dirent-d_name-ref struct-dirent-pointer)))


;;;; tree walk functions

(define (ftw pathname inspector-callback descriptors)
  (with-compensations
    (receive (result errno)
	(platform:ftw (string->cstring/c pathname) inspector-callback descriptors)
      (if (= -1 result)
	  (raise-errno-error 'ftw errno (list pathname inspector-callback descriptors))
	result))))

(define (nftw pathname inspector-callback descriptors flags)
  (with-compensations
    (receive (result errno)
	(platform:nftw (string->cstring/c pathname) inspector-callback descriptors flags)
      (if (= -1 result)
	  (raise-errno-error 'ftw errno (list pathname inspector-callback descriptors flags))
	result))))

(define (make-ftw-callback scheme-function)
  (make-c-callback* int
		    (lambda (pathname-cstr struct-stat flag)
		      (guard (E (else -1))
			(scheme-function (cstring->string pathname-cstr)
					 (if (= 0 (bitwise-and flag FTW_NS))
					     #f
					   (pointer-><struct-stat> struct-stat))
					 flag)))
		    (char* void* int)))

(define (make-nftw-callback scheme-function)
  (make-c-callback* int
		    (lambda (pathname-cstr struct-stat flag struct-ftw)
		      (guard (E (else -1))
			(scheme-function (cstring->string pathname-cstr)
					 (if (= 0 (bitwise-and flag FTW_NS))
					     #f
					   (pointer-><struct-stat> struct-stat))
					 flag
					 (struct-FTW-base-ref  struct-ftw)
					 (struct-FTW-level-ref struct-ftw))))
		    (char* void* int void*)))


;;;; links

(define (%real-link func funcname oldname newname)
  (with-compensations
    (receive (result errno)
	(func (string->cstring/c oldname)
	      (string->cstring/c newname))
      (when (= -1 result)
	(raise-errno-error funcname errno
			   (list oldname newname)))
      result)))

(define (link oldname newname)
  (%real-link platform:link 'link oldname newname))

(define (symlink oldname newname)
  (%real-link platform:symlink 'symlink oldname newname))

(define (readlink pathname)
  (with-compensations

    (define (%readlink c-pathname buffer provided-size)
      (receive (required-size errno)
	  (platform:readlink c-pathname buffer provided-size)
	(cond ((= -1 required-size)
	       (raise-errno-error 'readlink errno pathname))
	      ((<= provided-size required-size)
		;READLINK  returns  the  number  of  bytes  copied  into
		;BUFFER, read carefully the documentation!!!
	       (let ((provided-size (* 2 required-size)))
		 (%readlink c-pathname (malloc-block/c provided-size) provided-size)))
	      (else
	       (cstring->string buffer required-size)))))

    (let ((provided-size 4))
      (%readlink (string->cstring/c pathname) (malloc-block/c provided-size) provided-size))))

(define (realpath pathname)
  (with-compensations
    (receive (buffer errno)
	(platform:realpath (string->cstring/c pathname) pointer-null)
      (if (pointer-null? buffer)
	  (raise-errno-error 'realpath errno pathname)
	(begin0
	    (cstring->string buffer)
	  (primitive-free buffer))))))


;;;; changing owner

(define (chown pathname owner-id group-id)
  (with-compensations
    (receive (result errno)
	(platform:chown (string->cstring/c pathname)
			owner-id group-id)
      (when (= -1 result)
	(raise-errno-error 'chown errno (list pathname owner-id group-id)))
      result)))

(define (fchown fd owner-id group-id)
  (with-compensations
    (receive (result errno)
	(platform:fchown (file-descriptor->integer fd) owner-id group-id)
      (when (= -1 result)
	(raise-errno-error 'fchown errno (list fd owner-id group-id)))
      result)))


;;;; changing permissions

(define (umask mask)
  (with-compensations
    (receive (result errno)
	(platform:umask mask)
      (when (= -1 result)
	(raise-errno-error 'umask errno mask))
      result)))

(define (getumask)
  (let ((m (umask 0)))
    (umask m)
    m))

(define (chmod pathname mode)
  (with-compensations
    (receive (result errno)
	(platform:chmod (string->cstring/c pathname) mode)
      (when (= -1 result)
	(raise-errno-error 'chmod errno (list pathname mode)))
      result)))

(define (fchmod fd mode)
  (with-compensations
    (receive (result errno)
	(platform:fchmod (file-descriptor->integer fd) mode)
      (when (= -1 result)
	(raise-errno-error 'fchmod errno (list fd mode)))
      result)))


;;;; testing access

(define (access pathname mask)
  (with-compensations
    (receive (result errno)
	(platform:access (string->cstring/c pathname) mask)
      (when (and (= -1 result)
		 (not (= 0 errno))
		 (not (= EACCES errno))
		 (not (= ENOENT errno)))
	(raise-errno-error 'access errno (list pathname mask)))
      (= 0 result))))


;;;; file times

(define utime
  (case-lambda

   ((pathname access-time modification-time)
    (with-compensations
      (let ((struct-utimbuf* (malloc-block/c sizeof-utimbuf)))
	(struct-utimbuf-actime-set!  struct-utimbuf* access-time)
	(struct-utimbuf-modtime-set! struct-utimbuf* modification-time)
	(receive (result errno)
	    (platform:utime (string->cstring/c pathname) struct-utimbuf*)
	  (if (= -1 result)
	      (raise-errno-error 'utime errno (list pathname access-time modification-time))
	    result)))))

   ((pathname)	;set the times to the current time
    (receive (result errno)
	(platform:utime (string->cstring/c pathname) pointer-null)
      (if (= -1 result)
	  (raise-errno-error 'utime errno pathname)
	result)))))

(define utimes
  (case-lambda
   ((pathname access-time-sec access-time-usec modification-time-sec modification-time-usec)
    (%real-utimes (lambda (*arry)
		    (platform:utimes (string->cstring/c pathname) *arry))
		  'utimes pathname
		  access-time-sec access-time-usec
		  modification-time-sec modification-time-usec))
   ((pathname)
    (%real-utimes (lambda (*arry)
		    (platform:utimes (string->cstring/c pathname) *arry))
		  'utimes pathname))))

(define %real-utimes
  (case-lambda
   ((func funcname obj
	  access-time-sec	    access-time-usec
	  modification-time-sec modification-time-usec)
    (with-compensations
      (let* ((*arry	(malloc-block/c (* 2 strideof-timeval)))
	     (*atime	*arry)
	     (*mtime	(pointer-add *arry strideof-timeval)))
	(struct-timeval-tv_sec-set!  *atime access-time-sec)
	(struct-timeval-tv_usec-set! *atime access-time-usec)
	(struct-timeval-tv_sec-set!  *mtime modification-time-sec)
	(struct-timeval-tv_usec-set! *mtime modification-time-usec)
	(receive (result errno)
	    (func *arry)
	  (when (= -1 result)
	    (raise-errno-error funcname errno
			       (list obj
				     access-time-sec access-time-usec
				     modification-time-sec modification-time-usec)))
	  result))))
   ((func funcname obj)
    (receive (result errno)
	(func pointer-null)
      (if (= -1 result)
	  (raise-errno-error funcname errno obj)
	result)))))


;;;; file size

(define (file-size obj)
  (cond ((or (string? obj) (symbol? obj))
	 (with-compensations
	   (letrec ((fd (compensate
			    (posix:open obj O_RDONLY 0)
			  (with
			   (posix:close fd)))))
	     (file-size fd))))
	((file-descriptor? obj)
	 (with-compensations
	   (letrec ((pos (compensate
			     (posix:lseek obj 0 SEEK_CUR)
			   (with
			    (posix:lseek obj pos SEEK_SET)))))
	     (posix:lseek obj 0 SEEK_END))))
	(else
	 (error 'file-size
	   "expected file descriptor or file pathname" obj))))

(define (ftruncate obj length)
  (cond ((or (string? obj) (symbol? obj))
	 (with-compensations
	   (letrec ((fd (compensate
			    (posix:open obj O_WRONLY 0)
			  (with
			   (posix:close fd)))))
	     (platform:ftruncate (file-descriptor->integer fd) length))))
	((file-descriptor? obj)
	 (receive (result errno)
	     (platform:ftruncate (file-descriptor->integer obj) length)
	   (when (= -1 result)
	     (raise-errno-error 'ftruncate errno (list obj length)))
	   result))
	(else
	 (error 'ftruncate
	   "expected file descriptor or file pathname" obj))))

(define (truncate pathname length)
  (with-compensations
    (receive (result errno)
	(platform:truncate (string->cstring/c pathname) length)
      (if (= -1 result)
	  (raise-errno-error 'truncate errno (list pathname length))
	result))))


;;;; removing

(define (unlink pathname)
  (with-compensations
    (receive (result errno)
	(platform:unlink (string->cstring/c pathname))
      (when (= -1 result)
	(raise-errno-error 'unlink errno pathname))
      result)))

(define (remove pathname)
  (with-compensations
    (receive (result errno)
	(platform:remove (string->cstring/c pathname))
      (when (= -1 result)
	(raise-errno-error 'remove errno pathname))
      result)))

(define (rmdir pathname)
  (with-compensations
    (receive (result errno)
	(platform:rmdir (string->cstring/c pathname))
      (when (= -1 result)
	(raise-errno-error 'rmdir errno pathname))
      result)))


;;;; renaming

(define (rename oldname newname)
  (with-compensations
    (receive (result errno)
	(platform:rename (string->cstring/c oldname)
			 (string->cstring/c newname))
      (when (= -1 result)
	(raise-errno-error 'rename errno (list oldname newname)))
      result)))


;;;; making directories

(define (mkdir pathname mode)
  (with-compensations
    (receive (result errno)
	(platform:mkdir (string->cstring/c pathname) mode)
      (when (= -1 result)
	(raise-errno-error 'primitive-mkdir errno (list pathname mode)))
      result)))


;;;; temporary files

(define (mkstemp template)
  (with-compensations
    (let ((p	(string->cstring/c template)))
      (receive (result errno)
	  (platform:mkstemp p)
	(if (= -1 result)
	    (raise-errno-error 'mktemp errno template)
	  (values (integer->file-descriptor result) (cstring->string p)))))))

(define (mkdtemp template)
  (with-compensations
    (let ((p	(string->cstring/c template)))
      (receive (result errno)
	  (platform:mkdtemp p)
	(if (pointer-null? result)
	    (raise-errno-error 'mkdtemp errno template)
	  (cstring->string p))))))


;;; stat interface

(define (pointer-><struct-stat> struct-stat*)
  ;;Some "struct  stat" field  may be unimplemented,  so we  default its
  ;;value to #f.
  (let-syntax ((get	(syntax-rules ()
			  ((_ ?getter)
			   (guard (exc (else #f))
			     (?getter struct-stat*))))))
    (make-<struct-stat>
     (get platform:struct-stat-st_mode-ref)
     (get platform:struct-stat-st_ino-ref)
     (get platform:struct-stat-st_dev-ref)
     (get platform:struct-stat-st_nlink-ref)
     (get platform:struct-stat-st_uid-ref)
     (get platform:struct-stat-st_gid-ref)
     (get platform:struct-stat-st_size-ref)
     (get platform:struct-stat-st_atime-ref)
     (get platform:struct-stat-st_atime_usec-ref)
     (get platform:struct-stat-st_mtime-ref)
     (get platform:struct-stat-st_mtime_usec-ref)
     (get platform:struct-stat-st_ctime-ref)
     (get platform:struct-stat-st_ctime_usec-ref)
     (get platform:struct-stat-st_blocks-ref)
     (get platform:struct-stat-st_blksize-ref))))

(define (%real-stat func funcname pathname)
  (with-compensations
    (let ((struct-stat*	(malloc-block/c platform:sizeof-stat)))
      (receive (result errno)
	  (func (string->cstring/c pathname) struct-stat*)
	(when (= -1 result)
	  (raise-errno-error funcname errno pathname))
	(pointer-><struct-stat> struct-stat*)))))

(define (stat pathname)
  (%real-stat platform:stat 'stat pathname))

(define (lstat pathname)
  (%real-stat platform:lstat 'lstat pathname))

(define (fstat fd)
  (with-compensations
    (let ((struct-stat* (malloc-block/c platform:sizeof-stat)))
      (receive (result errno)
	  (platform:fstat (file-descriptor->integer fd) struct-stat*)
	(when (= -1 result)
	  (raise-errno-error 'fstat errno fd))
	(pointer-><struct-stat> struct-stat*)))))


;;;; done

)

;;; end of file