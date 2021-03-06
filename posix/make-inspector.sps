;;;!mosh
;;; -*- coding: utf-8-unix -*-
;;;
;;;Part of: Nausicaa/POSIX
;;;Contents: foreign library inspection generator
;;;Date: Sun Dec  6, 2009
;;;
;;;Abstract
;;;
;;;
;;;
;;;Copyright (c) 2009-2011 Marco Maggi <marco.maggi-ipsu@poste.it>
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
  (inspector-maker))

(class-uid-prefix "nausicaa:posix")

(sizeof-lib-imports/quote
 (prefix (nausicaa posix clang stub-functions) stub.)
 (prefix (nausicaa ffi cstrings) ffi.))


;;;; primitive accessors and mutators

(sizeof-lib/quote

 (define (embedded.bytevector->memory! bv pointer number-of-bytes)
   ;;Copy the selected  number of bytes from a  bytevector into a memory
   ;;block into.
   ;;
   (do ((i 0 (+ 1 i)))
       ((= i number-of-bytes))
     (ffi.pointer-c-set! uint8_t pointer i (bytevector-u8-ref bv i))))

 (define (embedded.memory->bytevector! pointer bv number-of-bytes)
   ;;Copy  the selected  number  of bytes  from  a memory  block into  a
   ;;bytevector.
   ;;
   (do ((i 0 (+ 1 i)))
       ((= i number-of-bytes))
     (bytevector-u8-set! bv i (ffi.pointer-c-ref uint8_t pointer i))))

;;; --------------------------------------------------------------------

 (define (embedded.generic-struct-pointer-bytevector struct-pointer field-offset number-of-bytes)
   ;;Generic  embedded   memory  block  accessor.   Store   into  a  new
   ;;bytevector  the selected number  of bytes  embedded into  a struct;
   ;;return the bytevector.
   ;;
   (let ((bv (make-bytevector number-of-bytes)))
     (embedded.memory->bytevector! (ffi.pointer-add struct-pointer field-offset) bv number-of-bytes)
     bv))

 (define (embedded.generic-struct-pointer-bytevector-set! struct-pointer field-offset number-of-bytes bv)
   ;;Generic embedded  memory block mutator.  Store the  given number of
   ;;bytes from bytevector into a memory block embedded into a struct.
   ;;
   (embedded.bytevector->memory! bv (ffi.pointer-add struct-pointer field-offset) number-of-bytes))

;;; --------------------------------------------------------------------

 (define-inline (embedded.generic-struct-pointer-cstring struct-pointer field-offset)
   ;;Generic embedded C string accessor.  Convert a C string embedded in
   ;;a struct into a Scheme string; return the Scheme string.
   ;;
   (ffi.cstring->string (ffi.pointer-add struct-pointer field-offset)))

 (define (embedded.generic-struct-pointer-cstring-set! struct-pointer field-offset str)
   ;;Generic embedded C string mutator.  Convert the given Scheme string
   ;;into  a UTF8  bytevector  and  store the  bytes  into the  embedded
   ;;string.
   ;;
   ;;Beware using this function!!!
   ;;
   (let (((bv <bytevector>) (string->utf8 str))
	 (fp* (ffi.pointer-add struct-pointer field-offset)))
     (embedded.bytevector->memory! bv fp* bv.length)
     ;;terminate with a zero byte
     (pointer-c-set! uint8_t (ffi.pointer-add fp* bv.length) 0 0)))

;;; --------------------------------------------------------------------

 (define (embedded.generic-struct-pointer-timeval struct-pointer field-offset)
   ;;Generic embedded "struct timeval"  accessor.  Extract the fields of
   ;;the embedded structure and return an instance of <timeval>.
   ;;
   (make <timeval>
     (pointer: (ffi.pointer-add struct-pointer field-offset))))

 (define (embedded.generic-struct-pointer-timeval-set! struct-pointer field-offset (tv <timeval>))
   ;;Generic embedded "struct timeval" mutator.  Extract the fields of a
   ;;<timeval> instance  and store the values into  the embedded "struct
   ;;timeval".
   ;;
   (let (((tv* <pointer-to-timeval>) (ffi.pointer-add struct-pointer field-offset)))
     (set! tv*.tv_sec  tv.tv_sec)
     (set! tv*.tv_usec tv.tv_usec)))

 )


;;;; accessor and mutator definition utilities

(sizeof-lib/quote

 (define-syntax embedded.define-cstring-accessor
   (identifier-syntax embedded.generic-struct-pointer-cstring))

;;; --------------------------------------------------------------------

 (define-syntax embedded.define-timeval-accessor
   (identifier-syntax embedded.generic-struct-pointer-timeval))

 (define-syntax embedded.define-timeval-mutator
   (identifier-syntax embedded.generic-struct-pointer-timeval-set!))

 (define-syntax embedded.define-timeval-accessor-and-mutator
   (syntax-rules ()
     ((_ ?accesor ?mutator)
      (begin
	(embedded.define-timeval-accessor ?accessor)
	(embedded.define-timeval-mutator  ?mutator)))))

;;; --------------------------------------------------------------------

 (define-syntax embedded.define-bytevector-accessor
   (syntax-rules ()
     ((_ ?accessor ?number-of-bytes)
      (define-inline (?accessor struct-pointer field-offset)
	(embedded.generic-struct-pointer-bytevector struct-pointer field-offset ?number-of-bytes)))))

 (define-syntax embedded.define-bytevector-mutator
   (syntax-rules ()
     ((_ ?mutator ?number-of-bytes)
      (define-inline (?mutator struct-pointer field-offset bv)
	(embedded.generic-struct-pointer-bytevector-set! struct-pointer field-offset
							 ?number-of-bytes bv)))))

 (define-syntax embedded.define-bytevector-accessor-and-mutator
   (syntax-rules ()
     ((_ ?accessor ?mutator ?number-of-bytes)
      (begin
	(embedded.define-bytevector-accessor ?accessor ?number-of-bytes)
	(embedded.define-bytevector-mutator  ?mutator  ?number-of-bytes)))))

;;; --------------------------------------------------------------------

 (define-syntax embedded.define-error-accessor
   ;;Define an accessor which raises an error when invoked.  This is for
   ;;fields  embedded  in  C  structs  which cannot  be  modified,  like
   ;;"sa_data" in "struct sockaddr".
   ;;
   (lambda (stx)
     (syntax-case stx ()
       ((_ ?name ?struct-name ?field-name)
	(with-syntax
	    ((MESSAGE (string-append "embedded field \"" (syntax->datum #'?field-name)
				     "\" of C struct \"" (syntax->datum #'?struct-name)
				     "\" cannot be accessed")))
	  #'(define (?name struct-pointer field-offset value)
	      (error '?name MESSAGE)))))))

 (define-syntax embedded.define-error-mutator
   ;;Define a mutator  which raises an error when  invoked.  This is for
   ;;fields  embedded  in  C  structs  which cannot  be  modified,  like
   ;;"d_name" in "struct dirent".
   ;;
   (lambda (stx)
     (syntax-case stx ()
       ((_ ?name ?struct-name ?field-name)
	(with-syntax
	    ((MESSAGE (string-append "embedded field \"" (syntax->datum #'?field-name)
				     "\" of C struct \"" (syntax->datum #'?struct-name)
				     "\" cannot be modified")))
	  #'(define (?name struct-pointer field-offset)
	      (error '?name MESSAGE)))))))

 (define-syntax embedded.define-error-accessor-and-mutator
   (syntax-rules ()
     ((_ ?accesor ?mutator ?number-of-bytes)
      (begin
	(embedded.define-error-accessor ?accessor)
	(embedded.define-error-mutator  ?mutator)))))

 )


;;;; inspection: typedefs

(define-c-type blkcnt_t		unsigned-int)
(define-c-type clock_t		signed-int)
(define-c-type dev_t		signed-int)
(define-c-type gid_t		signed-int)
(define-c-type ino_t		unsigned-int)
(define-c-type mode_t		unsigned-int)
(define-c-type nlink_t		unsigned-int)
(define-c-type off_t		unsigned-int)
(define-c-type pid_t		signed-int)
(define-c-type time_t		signed-int)
(define-c-type uid_t		signed-int)
(define-c-type wchar_t		signed-int)
(define-c-type socklen_t	signed-int)

(define-c-type-alias socklen_t*	pointer)


;;;; inspection: struct types

(define-c-struct flock
  "struct flock"
  (signed-int		l_type)
  (signed-int		l_whence)
  (signed-int		l_start)
  (signed-int		l_len)
  (signed-int		l_pid))

(define-c-struct timeval
  "struct timeval"
  (signed-int		tv_sec)
  (signed-int		tv_usec))

(define-c-struct timespec
  "struct timespec"
  (signed-int		tv_sec)
  (signed-int		tv_nsec))

(define-c-struct tms
  "struct tms"
  (options no-fields-inspection)
  (dummy tms_utime
	 (struct-accessor: stub.<pointer-to-tms>-tms_utime)
	 (struct-mutator:  stub.<pointer-to-tms>-tms_utime-set!))
  (dummy tms_stime
	 (struct-accessor: stub.<pointer-to-tms>-tms_stime)
	 (struct-mutator:  stub.<pointer-to-tms>-tms_stime-set!))
  (dummy tms_cutime
	 (struct-accessor: stub.<pointer-to-tms>-tms_cutime)
	 (struct-mutator:  stub.<pointer-to-tms>-tms_cutime-set!))
  (dummy tms_cstime
	 (struct-accessor: stub.<pointer-to-tms>-tms_cstime)
	 (struct-mutator:  stub.<pointer-to-tms>-tms_cstime-set!)))

(define-c-struct dirent
  "struct dirent"
  (signed-int		d_ino)
  (signed-int		d_off)
  (unsigned-int		d_reclen)
  (unsigned-int		d_type)
  (embedded		d_name
			(struct-accessor: embedded.generic-struct-pointer-cstring)
			(struct-mutator:  embedded.pointer-to-dirent-d_name-set!)))

(sizeof-lib/quote
 (embedded.define-error-mutator embedded.pointer-to-dirent-d_name-set! "dirent" "d_name"))

;;The stat structure  is "special", so the following  tests do not work.
;;We relay  on the stub library  to access it.  Note  that the following
;;fields are not present on all the platforms:
;;
;;     time_usec st_dev st_mtime_usec st_atime_usec st_ctime_usec
;;
;;

;;; NAU_POSIX_INSPECT_STRUCT_TYPE([STRUCT_STAT],[struct stat])

;;; AC_DEFUN([NAU_POSIX_STRUCT_STAT_FIELD],
;;;   [NAU_POSIX_INSPECT_FIELD_TYPE([STRUCT_STAT_$1],[struct stat],[$2],[$3])])

;;; NAU_POSIX_STRUCT_STAT_FIELD([ST_MODE],[st_mode],[unsigned-int])
;;; NAU_POSIX_STRUCT_STAT_FIELD([ST_INO],[st_ino],[unsigned-int])
;;; NAU_POSIX_STRUCT_STAT_FIELD([ST_DEV],[st_dev],[unsigned-int])
;;; NAU_POSIX_STRUCT_STAT_FIELD([ST_NLINK],[st_nlink],[unsigned-int])
;;; NAU_POSIX_STRUCT_STAT_FIELD([ST_UID],[st_uid],[signed-int])
;;; NAU_POSIX_STRUCT_STAT_FIELD([ST_GID],[st_gid],[signed-int])
;;; NAU_POSIX_STRUCT_STAT_FIELD([ST_SIZE],[st_size],[unsigned-int])
;;; NAU_POSIX_STRUCT_STAT_FIELD([ST_ATIME],[st_atime],[signed-int])
;;; NAU_POSIX_STRUCT_STAT_FIELD([ST_ATIME_USEC],[st_atime_usec],[unsigned-int])
;;; NAU_POSIX_STRUCT_STAT_FIELD([ST_MTIME],[st_mtime],[signed-int])
;;; NAU_POSIX_STRUCT_STAT_FIELD([ST_MTIME_USEC],[st_mtime_usec],[unsigned-int])
;;; NAU_POSIX_STRUCT_STAT_FIELD([ST_CTIME],[st_ctime],[signed-int])
;;; NAU_POSIX_STRUCT_STAT_FIELD([ST_CTIME_USEC],[st_ctime_usec],[unsigned-int])
;;; NAU_POSIX_STRUCT_STAT_FIELD([ST_BLOCKS],[st_blocks],[unsigned-int])
;;; NAU_POSIX_STRUCT_STAT_FIELD([ST_BLKSIZE],[st_blksize],[unsigned-int])

;;We can still check for the existence of some fields.
(autoconf-lib "
AC_CHECK_MEMBERS([struct stat.st_atime_usec])
AC_CHECK_MEMBERS([struct stat.st_mtime_usec])
AC_CHECK_MEMBERS([struct stat.st_ctime_usec])
")

(define-c-struct utimbuf
  "struct utimbuf"
  (signed-int		actime)
  (signed-int		modtime))

(define-c-struct timezone
  "struct timezone"
  (signed-int		tz_minuteswest)
  (signed-int		tz_dsttime))

(define-c-struct tm
  "struct tm"
  (signed-int		tm_sec)
  (signed-int		tm_min)
  (signed-int		tm_hour)
  (signed-int		tm_mday)
  (signed-int		tm_mon)
  (signed-int		tm_year)
  (signed-int		tm_wday)
  (signed-int		tm_yday)
  (signed-int		tm_isdst)
  (signed-int		tm_gmtoff)
  (pointer		tm_zone))

(define-c-struct ntptimeval
  "struct ntptimeval"
  (embedded		time
			(struct-accessor: embedded.generic-struct-pointer-timeval)
			(struct-mutator:  embedded.generic-struct-pointer-timeval-set!)
			(field-tags: <timeval>))
  (signed-int		maxerror)
  (signed-int		esterror))

(define-c-struct timex
  "struct timex"
  (unsigned-int		modes)
  (signed-int		offset)
  (signed-int		freq)
  (signed-int		maxerror)
  (signed-int		esterror)
  (signed-int		status)
  (signed-int		constant)
  (signed-int		precision)
  (signed-int		tolerance)
  (embedded		time
			(struct-accessor: embedded.generic-struct-pointer-timeval)
			(struct-mutator:  embedded.generic-struct-pointer-timeval-set!))
  (signed-int		tick)
  (signed-int		ppsfreq)
  (signed-int		jitter)
  (signed-int		shift)
  (signed-int		stabil)
  (signed-int		jitcnt)
  (signed-int		calcnt)
  (signed-int		errcnt)
  (signed-int		stbcnt))

(define-c-struct itimerval
  "struct itimerval"
  (embedded	it_interval
		(struct-accessor: embedded.generic-struct-pointer-timeval)
		(struct-mutator:  embedded.generic-struct-pointer-timeval-set!))
  (embedded	it_value
		(struct-accessor: embedded.generic-struct-pointer-timeval)
		(struct-mutator:  embedded.generic-struct-pointer-timeval-set!)))

(define-c-struct FTW
  "struct FTW"
  (signed-int		base)
  (signed-int		level))

(define-c-struct iovec
  "struct iovec"
  (pointer		iov_base)
  (unsigned-int		iov_len))

(define-c-struct fdset
  "fd_set")

(define-c-struct passwd
  "struct passwd"
  (pointer		pw_name)
  (pointer		pw_passwd)
  (signed-int		pw_uid)
  (signed-int		pw_gid)
  (pointer		pw_gecos)
  (pointer		pw_dir)
  (pointer		pw_shell))

(define-c-struct group
  "struct group"
  (pointer		gr_name)
  (signed-int		gr_gid)
  (pointer		gr_mem))

(define-c-struct utsname
  "struct utsname"
  (embedded		sysname
			(struct-accessor: embedded.generic-struct-pointer-cstring)
			(struct-mutator:  embedded.pointer-to-utsname-sysname-set!))
  (embedded		release
			(struct-accessor: embedded.generic-struct-pointer-cstring)
			(struct-mutator:  embedded.pointer-to-utsname-release-set!))
  (embedded		version
			(struct-accessor: embedded.generic-struct-pointer-cstring)
			(struct-mutator:  embedded.pointer-to-utsname-version-set!))
  (embedded		machine
			(struct-accessor: embedded.generic-struct-pointer-cstring)
			(struct-mutator:  embedded.pointer-to-utsname-machine-set!))
  (embedded		nodename
			(struct-accessor: embedded.generic-struct-pointer-cstring)
			(struct-mutator:  embedded.pointer-to-utsname-nodename-set!))
  (embedded		domainname
			(struct-accessor: embedded.generic-struct-pointer-cstring)
			(struct-mutator:  embedded.pointer-to-utsname-domainname-set!)))

(sizeof-lib/quote
 (embedded.define-error-mutator embedded.pointer-to-utsname-sysname-set! "utsname" "sysname")
 (embedded.define-error-mutator embedded.pointer-to-utsname-release-set! "utsname" "release")
 (embedded.define-error-mutator embedded.pointer-to-utsname-version-set! "utsname" "version")
 (embedded.define-error-mutator embedded.pointer-to-utsname-machine-set! "utsname" "machine")
 (embedded.define-error-mutator embedded.pointer-to-utsname-nodename-set! "utsname" "nodename")
 (embedded.define-error-mutator embedded.pointer-to-utsname-domainname-set! "utsname" "domainname"))

(define-c-struct fstab
  "struct fstab"
  (pointer		fs_spec)
  (pointer		fs_file)
  (pointer		fs_vfstype)
  (pointer		fs_mntops)
  (pointer		fs_type)
  (signed-int		fs_freq)
  (signed-int		fs_passno))

(define-c-struct mntent
  "struct mntent"
  (pointer		mnt_fsname)
  (pointer		mnt_dir)
  (pointer		mnt_type)
  (pointer		mnt_opts)
  (signed-int		mnt_freq)
  (signed-int		mnt_passno))

(define-c-struct sockaddr
  "struct sockaddr"
  (signed-int		sa_family)
;;;The dimension of this field is format-dependent, so we leave it out.
;;;  (embedded		sa_data)
  )

(define-c-struct sockaddr_in
  "struct sockaddr_in"
  (signed-int		sin_family)
  (embedded		sin_addr
			(struct-accessor: embedded.pointer-to-sockaddr_in-sin_addr)
			(struct-mutator:  embedded.pointer-to-sockaddr_in-sin_addr-set!))
  (unsigned-int		sin_port))

(sizeof-lib/quote
 ;; (embedded.define-bytevector-accessor embedded.pointer-to-sockaddr_in-sin_addr
 ;; 				      (c-sizeof struct-in_addr))
 ;; (embedded.define-bytevector-mutator  embedded.pointer-to-sockaddr_in-sin_addr-set!
 ;; 				      (c-sizeof struct-in_addr))
 (embedded.define-bytevector-accessor-and-mutator embedded.pointer-to-sockaddr_in-sin_addr
						  embedded.pointer-to-sockaddr_in-sin_addr-set!
						  (c-sizeof struct-in_addr)))

(define-c-struct sockaddr_in6
  "struct sockaddr_in6"
  (signed-int		sin6_family)
  (embedded		sin6_addr
			(struct-accessor: embedded.pointer-to-sockaddr_in6-sin6_addr)
			(struct-mutator:  embedded.pointer-to-sockaddr_in6-sin6_addr-set!))
;;;This field is documented as unimplemented in Glibc.
;;;
;;;  (unsigned-int		sin6_flowinfo)
  (unsigned-int		sin6_port))

(sizeof-lib/quote
 (embedded.define-bytevector-accessor embedded.pointer-to-sockaddr_in6-sin6_addr
				      (c-sizeof struct-in6_addr))
 (embedded.define-bytevector-mutator  embedded.pointer-to-sockaddr_in6-sin6_addr-set!
				      (c-sizeof struct-in6_addr))
 #;(embedded.define-bytevector-accessor-and-mutator embedded.pointer-to-sockaddr_in6-sin6_addr
						  embedded.pointer-to-sockaddr_in6-sin6_addr-set!
						  (c-sizeof struct-in6_addr)))

(define-c-struct sockaddr_un
  "struct sockaddr_un"
  (signed-int		sun_family)
  (embedded		sun_path
			(struct-accessor: embedded.generic-struct-pointer-cstring)
			(struct-mutator:  embedded.generic-struct-pointer-cstring-set!)))

(define-c-struct in_addr
  "struct in_addr"
  (unsigned-int		s_addr))

(define-c-struct in6_addr
  "struct in6_addr"
  (options no-label no-wrapper no-mirror))

(define-c-struct if_nameindex
  "struct if_nameindex"
  (unsigned-int		if_index)
  (pointer		if_name))

(define-c-struct netent
  "struct netent"
  (pointer		n_name)
  (pointer		n_aliases)
  (signed-int		n_addrtype)
  (unsigned-int		n_net))

(define-c-struct linger
  "struct linger"
  (signed-int		l_onoff)
  (signed-int		l_linger))

(define-c-struct hostent
  "struct hostent"
  (pointer		h_name)
  (pointer		h_aliases)
  (signed-int		h_addrtype)
  (signed-int		h_length)
  (pointer		h_addr_list)
  (pointer		h_addr))

(define-c-struct protoent
  "struct protoent"
  (pointer		p_name)
  (pointer		p_aliases)
  (signed-int		p_proto))

(define-c-struct servent
  "struct servent"
  (pointer		s_name)
  (pointer		s_aliases)
  (signed-int		s_port)
  (pointer		s_proto))

(autoconf-lib "AC_CACHE_SAVE")


;;;; inspection: constants

(define-c-defines/public "seek whence arguments"
  SEEK_SET
  SEEK_CUR
  SEEK_END)

(define-c-defines/public "file descriptor related flags"
  O_ACCMODE
  O_APPEND
  O_ASYNC
  O_CREAT
  O_EXCL
  O_EXEC
  O_EXLOCK
  O_FSYNC
  O_IGNORE_CTTY
  O_NDELAY
  O_NOCTTY
  O_NOLINK
  O_NONBLOCK
  O_NOTRANS
  O_RDONLY
  O_RDWR
  O_READ
  O_SHLOCK
  O_SYNC
  O_TRUNC
  O_WRITE
  O_WRONLY

;;; This is GNU specific.
  O_NOATIME

;;; These are Linux specific.
  O_CLOEXEC
  O_DIRECT
  O_DIRECTORY
  O_LARGEFILE
  O_NOFOLLOW

  FD_CLOEXEC)

(autoconf-lib "AC_CACHE_SAVE")

(define-c-defines/public "ioctl action selection"
  F_DUPFD
  F_GETFD
  F_GETFL
  F_GETLK
  F_GETOWN
  F_SETFD
  F_SETFL
  F_SETLKW
  F_SETLK
  F_SETOWN

  F_RDLCK
  F_UNLCK
  F_WRLCK)

(define-c-defines/public "miscellaneous file-related constants"
  WNOHANG
  WUNTRACED
  WCONTINUED

  R_OK
  W_OK
  X_OK
  F_OK)

(define-c-defines/public "miscellaneous constants"
  L_ctermid
  L_tmpnam

  CLOCKS_PER_SEC)

(define-c-defines/public "mode bits"
  S_IRUSR
  S_IWUSR
  S_IXUSR

  S_IRGRP
  S_IWGRP
  S_IXGRP

  S_IROTH
  S_IWOTH
  S_IXOTH

  S_IRWXU
  S_IRWXG
  S_IRWXO

  S_ISUID
  S_ISGID
  S_ISVTX)

;;; "struct dirent" related stuff

(autoconf-lib "
AC_CHECK_DECL([_DIRENT_HAVE_D_NAMELEN],
  [NAU_DIRENT_HAVE_D_NAMELEN=\"#t\"],
  [NAU_DIRENT_HAVE_D_NAMELEN=\"#f\"],
  [NAU_POSIX_INCLUDES])
AC_CHECK_DECL([_DIRENT_HAVE_D_RECLEN],
  [NAU_DIRENT_HAVE_D_RECLEN=\"#t\"],
  [NAU_DIRENT_HAVE_D_RECLEN=\"#f\"],
  [NAU_POSIX_INCLUDES])
AC_CHECK_DECL([_DIRENT_HAVE_D_OFF],
  [NAU_DIRENT_HAVE_D_OFF=\"#t\"],
  [NAU_DIRENT_HAVE_D_OFF=\"#f\"],
  [NAU_POSIX_INCLUDES])
AC_CHECK_DECL([_DIRENT_HAVE_D_TYPE],
  [NAU_DIRENT_HAVE_D_TYPE=\"#t\"],
  [NAU_DIRENT_HAVE_D_TYPE=\"#f\"],
  [NAU_POSIX_INCLUDES])
AC_SUBST([NAU_DIRENT_HAVE_D_NAMELEN])
AC_SUBST([NAU_DIRENT_HAVE_D_RECLEN])
AC_SUBST([NAU_DIRENT_HAVE_D_OFF])
AC_SUBST([NAU_DIRENT_HAVE_D_TYPE])
")

(sizeof-lib/quote
 (define DIRENT_HAVE_D_NAMELEN	^NAU_DIRENT_HAVE_D_NAMELEN^)
 (define DIRENT_HAVE_D_RECLEN	^NAU_DIRENT_HAVE_D_RECLEN^)
 (define DIRENT_HAVE_D_OFF	^NAU_DIRENT_HAVE_D_OFF^)
 (define DIRENT_HAVE_D_TYPE	^NAU_DIRENT_HAVE_D_TYPE^))

(define-c-defines/public "dirent stuff"
  DT_BLK
  DT_CHR
  DT_DIR
  DT_FIFO
  DT_LNK
  DT_REG
  DT_SOCK
  DT_UNKNOWN)

(define-c-defines/public "constants related to ftw() and nftw()"
  FTW_F
  FTW_D
  FTW_NS
  FTW_DNR
  FTW_SL
  FTW_DP
  FTW_SLN
  FTW_PHYS
  FTW_MOUNT
  FTW_CHDIR
  FTW_DEPTH
  FTW_ACTIONRETVAL
  FTW_CONTINUE
  FTW_STOP
  FTW_SKIP_SUBTREE
  FTW_SKIP_SIBLINGS)

(define-c-defines/public "setitimer() stuff"
  ITIMER_REAL
  ITIMER_VIRTUAL
  ITIMER_PROF)

(define-c-defines/public "miscellaneous"
  EOF
  MAXSYMLINKS
  MAXPATHLEN)

(define-c-defines/public "mmap constants"
  MAP_PRIVATE		MAP_SHARED
  MAP_FIXED
  MAP_ANON		MAP_ANONYMOUS
  MAP_32BITS		MAP_DENYWRITE
  MAP_EXECUTABLE	MAP_FILE
  MAP_GROWSDOWN		MAP_LOCKED
  MAP_NONBLOCK		MAP_NORESERVE
  MAP_POPULATE		MAP_STACK
  MAP_AUTOGROW		MAP_AUTORESRV
  MAP_COPY

  PROT_READ	PROT_WRITE
  PROT_EXEC	PROT_NONE

  MS_SYNC	MS_ASYNC

  MREMAP_MAYMOVE)

(define-c-defines/public "select related symbols"
  FD_SETSIZE)

(define-c-defines/public "max size of string for cuserid()"
  L_cuserid)

(define-c-defines/public "system capacity limitations"
  ARG_MAX	_POSIX_ARG_MAX
  CHILD_MAX	_POSIX_CHILD_MAX
  OPEN_MAX	_POSIX_OPEN_MAX
  STREAM_MAX	_POSIX_STREAM_MAX
  TZNAME_MAX	_POSIX_TZNAME_MAX
  NGROUPS_MAX
  SSIZE_MAX
  RE_DUP_MAX)

(define-c-defines/public "overall system options"
  _POSIX_JOB_CONTROL
  _POSIX_SAVED_IDS
  _POSIX2_C_DEV
  _POSIX2_FORT_DEV
  _POSIX2_FORT_RUN
  _POSIX2_LOCALEDEF
  _POSIX2_SW_DEV)

(define-c-defines/public "supported POSIX version"
  _POSIX_VERSION
  _POSIX2_C_VERSION)

(define-c-defines/public "sysconf constants"
  _SC_ARG_MAX
  _SC_CHILD_MAX
  _SC_CLK_TCK
  _SC_NGROUPS_MAX
  _SC_OPEN_MAX
  _SC_STREAM_MAX
  _SC_TZNAME_MAX
  _SC_JOB_CONTROL
  _SC_SAVED_IDS
  _SC_REALTIME_SIGNALS
  _SC_PRIORITY_SCHEDULING
  _SC_TIMERS
  _SC_ASYNCHRONOUS_IO
  _SC_PRIORITIZED_IO
  _SC_SYNCHRONIZED_IO
  _SC_FSYNC
  _SC_MAPPED_FILES
  _SC_MEMLOCK
  _SC_MEMLOCK_RANGE
  _SC_MEMORY_PROTECTION
  _SC_MESSAGE_PASSING
  _SC_SEMAPHORES
  _SC_SHARED_MEMORY_OBJECTS
  _SC_AIO_LISTIO_MAX
  _SC_AIO_MAX
  _SC_AIO_PRIO_DELTA_MAX
  _SC_DELAYTIMER_MAX
  _SC_MQ_OPEN_MAX
  _SC_MQ_PRIO_MAX
  _SC_VERSION
  _SC_PAGESIZE
  _SC_PAGE_SIZE
  _SC_RTSIG_MAX
  _SC_SEM_NSEMS_MAX
  _SC_SEM_VALUE_MAX
  _SC_SIGQUEUE_MAX
  _SC_TIMER_MAX
  _SC_BC_BASE_MAX
  _SC_BC_DIM_MAX
  _SC_BC_SCALE_MAX
  _SC_BC_STRING_MAX
  _SC_COLL_WEIGHTS_MAX
  _SC_EQUIV_CLASS_MAX
  _SC_EXPR_NEST_MAX
  _SC_LINE_MAX
  _SC_RE_DUP_MAX
  _SC_CHARCLASS_NAME_MAX
  _SC_2_VERSION
  _SC_2_C_BIND
  _SC_2_C_DEV
  _SC_2_FORT_DEV
  _SC_2_FORT_RUN
  _SC_2_SW_DEV
  _SC_2_LOCALEDEF
  _SC_PII
  _SC_PII_XTI
  _SC_PII_SOCKET
  _SC_PII_INTERNET
  _SC_PII_OSI
  _SC_POLL
  _SC_SELECT
  _SC_UIO_MAXIOV
  _SC_IOV_MAX
  _SC_PII_INTERNET_STREAM
  _SC_PII_INTERNET_DGRAM
  _SC_PII_OSI_COTS
  _SC_PII_OSI_CLTS
  _SC_PII_OSI_M
  _SC_T_IOV_MAX
  _SC_THREADS
  _SC_THREAD_SAFE_FUNCTIONS
  _SC_GETGR_R_SIZE_MAX
  _SC_GETPW_R_SIZE_MAX
  _SC_LOGIN_NAME_MAX
  _SC_TTY_NAME_MAX
  _SC_THREAD_DESTRUCTOR_ITERATIONS
  _SC_THREAD_KEYS_MAX
  _SC_THREAD_STACK_MIN
  _SC_THREAD_THREADS_MAX
  _SC_THREAD_ATTR_STACKADDR
  _SC_THREAD_ATTR_STACKSIZE
  _SC_THREAD_PRIORITY_SCHEDULING
  _SC_THREAD_PRIO_INHERIT
  _SC_THREAD_PRIO_PROTECT
  _SC_THREAD_PROCESS_SHARED
  _SC_NPROCESSORS_CONF
  _SC_NPROCESSORS_ONLN
  _SC_PHYS_PAGES
  _SC_AVPHYS_PAGES
  _SC_ATEXIT_MAX
  _SC_PASS_MAX
  _SC_XOPEN_VERSION
  _SC_XOPEN_XCU_VERSION
  _SC_XOPEN_UNIX
  _SC_XOPEN_CRYPT
  _SC_XOPEN_ENH_I18N
  _SC_XOPEN_SHM
  _SC_2_CHAR_TERM
  _SC_2_C_VERSION
  _SC_2_UPE
  _SC_XOPEN_XPG2
  _SC_XOPEN_XPG3
  _SC_XOPEN_XPG4
  _SC_CHAR_BIT
  _SC_CHAR_MAX
  _SC_CHAR_MIN
  _SC_INT_MAX
  _SC_INT_MIN
  _SC_LONG_BIT
  _SC_WORD_BIT
  _SC_MB_LEN_MAX
  _SC_NZERO
  _SC_SSIZE_MAX
  _SC_SCHAR_MAX
  _SC_SCHAR_MIN
  _SC_SHRT_MAX
  _SC_SHRT_MIN
  _SC_UCHAR_MAX
  _SC_UINT_MAX
  _SC_ULONG_MAX
  _SC_USHRT_MAX
  _SC_NL_ARGMAX
  _SC_NL_LANGMAX
  _SC_NL_MSGMAX
  _SC_NL_NMAX
  _SC_NL_SETMAX
  _SC_NL_TEXTMAX
  _SC_XBS5_ILP32_OFF32
  _SC_XBS5_ILP32_OFFBIG
  _SC_XBS5_LP64_OFF64
  _SC_XBS5_LPBIG_OFFBIG
  _SC_XOPEN_LEGACY
  _SC_XOPEN_REALTIME
  _SC_XOPEN_REALTIME_THREADS
  _SC_ADVISORY_INFO
  _SC_BARRIERS
  _SC_BASE
  _SC_C_LANG_SUPPORT
  _SC_C_LANG_SUPPORT_R
  _SC_CLOCK_SELECTION
  _SC_CPUTIME
  _SC_THREAD_CPUTIME
  _SC_DEVICE_IO
  _SC_DEVICE_SPECIFIC
  _SC_DEVICE_SPECIFIC_R
  _SC_FD_MGMT
  _SC_FIFO
  _SC_PIPE
  _SC_FILE_ATTRIBUTES
  _SC_FILE_LOCKING
  _SC_FILE_SYSTEM
  _SC_MONOTONIC_CLOCK
  _SC_MULTI_PROCESS
  _SC_SINGLE_PROCESS
  _SC_NETWORKING
  _SC_READER_WRITER_LOCKS
  _SC_SPIN_LOCKS
  _SC_REGEXP
  _SC_REGEX_VERSION
  _SC_SHELL
  _SC_SIGNALS
  _SC_SPAWN
  _SC_SPORADIC_SERVER
  _SC_THREAD_SPORADIC_SERVER
  _SC_SYSTEM_DATABASE
  _SC_SYSTEM_DATABASE_R
  _SC_TIMEOUTS
  _SC_TYPED_MEMORY_OBJECTS
  _SC_USER_GROUPS
  _SC_USER_GROUPS_R
  _SC_2_PBS
  _SC_2_PBS_ACCOUNTING
  _SC_2_PBS_LOCATE
  _SC_2_PBS_MESSAGE
  _SC_2_PBS_TRACK
  _SC_SYMLOOP_MAX
  _SC_STREAMS
  _SC_2_PBS_CHECKPOINT
  _SC_V6_ILP32_OFF32
  _SC_V6_ILP32_OFFBIG
  _SC_V6_LP64_OFF64
  _SC_V6_LPBIG_OFFBIG
  _SC_HOST_NAME_MAX
  _SC_TRACE
  _SC_TRACE_EVENT_FILTER
  _SC_TRACE_INHERIT
  _SC_TRACE_LOG
  _SC_LEVEL1_ICACHE_SIZE
  _SC_LEVEL1_ICACHE_ASSOC
  _SC_LEVEL1_ICACHE_LINESIZE
  _SC_LEVEL1_DCACHE_SIZE
  _SC_LEVEL1_DCACHE_ASSOC
  _SC_LEVEL1_DCACHE_LINESIZE
  _SC_LEVEL2_CACHE_SIZE
  _SC_LEVEL2_CACHE_ASSOC
  _SC_LEVEL2_CACHE_LINESIZE
  _SC_LEVEL3_CACHE_SIZE
  _SC_LEVEL3_CACHE_ASSOC
  _SC_LEVEL3_CACHE_LINESIZE
  _SC_LEVEL4_CACHE_SIZE
  _SC_LEVEL4_CACHE_ASSOC
  _SC_LEVEL4_CACHE_LINESIZE
  _SC_IPV6
  _SC_RAW_SOCKETS)

(define-c-defines/public "limits on file system capacity"
  LINK_MAX
  MAX_CANON
  MAX_INPUT
  NAME_MAX
  PATH_MAX
  PIPE_BUF
  MAXNAMLEN
  FILENAME_MAX)

(define-c-defines/public "optional features in file support"
  _POSIX_CHOWN_RESTRICTED
  _POSIX_NO_TRUNC
  _POSIX_VDISABLE)

(define-c-defines/public "minimum values for file system limits"
  _POSIX_LINK_MAX
  _POSIX_MAX_CANON
  _POSIX_MAX_INPUT
  _POSIX_NAME_MAX
  _POSIX_PATH_MAX
  _POSIX_PIPE_BUF
  SYMLINK_MAX
  POSIX_REC_INCR_XFER_SIZE
  POSIX_REC_MAX_XFER_SIZE
  POSIX_REC_MIN_XFER_SIZE
  POSIX_REC_XFER_ALIGN)

(define-c-defines/public "constants for pathconf and fpathconf"
  _PC_LINK_MAX
  _PC_MAX_CANON
  _PC_MAX_INPUT
  _PC_NAME_MAX
  _PC_PATH_MAX
  _PC_PIPE_BUF
  _PC_CHOWN_RESTRICTED
  _PC_NO_TRUNC
  _PC_VDISABLE
  _PC_SYNC_IO
  _PC_ASYNC_IO
  _PC_PRIO_IO
  _PC_FILESIZEBITS
  _PC_REC_INCR_XFER_SIZE
  _PC_REC_MAX_XFER_SIZE
  _PC_REC_MIN_XFER_SIZE
  _PC_REC_XFER_ALIGN)

(define-c-defines/public "glibc system inspection constants"
  BC_BASE_MAX		_POSIX_BC_BASE_MAX
  BC_DIM_MAX		_POSIX_BC_DIM_MAX
  BC_SCALE_MAX		_POSIX_BC_SCALE_MAX
  BC_STRING_MAX		_POSIX_BC_STRING_MAX
  COLL_WEIGHTS_MAX	_POSIX_COLL_WEIGHTS_MAX
  EXPR_NEXT_MAX		_POSIX_EXPR_NEXT_MAX
  LINE_MAX		_POSIX_LINE_MAX
  EQUIV_CLASS_MAX	_POSIX_EQUIV_CLASS_MAX)

(define-c-defines/public "string-valued system configuration parameters"
  _CS_PATH
  _CS_LFS_CFLAGS
  _CS_LFS_LDFLAGS
  _CS_LFS_LIBS
  _CS_LFS_LINTFLAGS
  _CS_LFS64_CFLAGS
  _CS_LFS64_LDFLAGS
  _CS_LFS64_LIBS
  _CS_LFS64_LINTFLAGS)

(define-c-string-defines "file system files pathnames"
  _PATH_MNTTAB
  _PATH_FSTAB
  _PATH_MOUNTED)

(define-c-string-defines "mount options"
  FSTAB_RW
  FSTAB_RQ
  FSTAB_RO
  FSTAB_SW
  FSTAB_XX)

(define-c-string-defines "values for the mnt_type field of struct mtab"
  MNTTYPE_IGNORE
  MNTTYPE_NFS
  MNTTYPE_SWAP)

(define-c-string-defines "values for the mnt_opts field of struct mtab"
  MNTOPT_DEFAULTS
  MNTOPT_RO
  MNTOPT_RW
  MNTOPT_SUID
  MNTOPT_NOSUID
  MNTOPT_NOAUTO)

(define-c-defines/public "options for mount"
  MS_MGC_MASK
  MS_REMOUNT
  MS_RDONLY
  S_IMMUTABLE
  S_APPEND
  MS_NOSUID
  MS_NOEXEC
  MS_NODEV
  MS_SYNCHRONOUS
  MS_MANDLOCK
  MS_NOATIME
  MS_NODIRATIME)

(define-c-defines/public "flags for umount2"
  MNT_FORCE)

(define-c-defines/public "interprocess signal constants"
  NSIG

  ;; program error
  SIGFPE	SIGILL
  SIGSEGV	SIGBUS
  SIGABRT	SIGIOT
  SIGTRAP	SIGEMT
  SIGSYS

  ;; termination
  SIGTERM	SIGINT
  SIGQUIT	SIGKILL
  SIGHUP

  ;; alarm
  SIGALRM	SIGVRALRM
  SIGPROF

  ;; asynchronous I/O
  SIGIO		SIGURG
  SIGPOLL

  ;; job control
  SIGCHLD	SIGCLD
  SIGCONT	SIGSTOP
  SIGTSTP	SIGTTIN
  SIGTTOU

  ;; operation error
  SIGPIPE	SIGLOST
  SIGXCPU	SIGXSFZ

  ;; misc
  SIGUSR1	SIGUSR2
  SIGWINCH	SIGINFO)

(define-c-defines/public "sockets constants"
  SOCK_STREAM	SOCK_DGRAM
  SOCK_RAW	SOCK_RDM
  SOCK_SEQPACKET

  AF_LOCAL	PF_LOCAL
  AF_UNIX	PF_UNIX
  AF_FILE	PF_FILE
  AF_INET	PF_INET
  AF_INET6	PF_INET6
  AF_UNSPEC	PF_UNSPEC

  SHUT_RD	SHUT_WR
  SHUT_RDWR

  IPPORT_RESERVED
  IPPORT_USERRESERVED

  IFNAMSIZ

  MSG_OOB
  MSG_PEEK
  MSG_DONTROUTE

  SOL_SOCKET
  SO_DEBUG	SO_REUSEADDR
  SO_KEEPALIVE	SO_DONTROUTE
  SO_LINGER	SO_BROADCAST
  SO_OOBINLINE	SO_SNDBUF
  SO_RCVBUF
  SO_TYPE	SO_STYLE
  SO_ERROR

  INADDR_LOOPBACK
  INADDR_ANY
  INADDR_BROADCAST
  INADDR_NONE

  INET_ADDRSTRLEN
  INET6_ADDRSTRLEN

  HOST_NOT_FOUND
  TRY_AGAIN
  NO_RECOVERY
  NO_ADDRESS
  )

(autoconf-lib "AC_CACHE_SAVE")


;;;; done

(define posix-library-spec
  '(nausicaa posix sizeof))

(define posix-structs-library-spec
  '(nausicaa posix structs))

(define posix-clang-types-library-spec
  '(nausicaa posix clang type-translation))

(autoconf-lib-write "configuration/posix-inspector.m4"
		    posix-library-spec
		    "NAUSICAA_POSIX")

(sizeof-lib-write   "src/libraries/nausicaa/posix/sizeof.sls.in"
		    posix-library-spec
		    posix-clang-types-library-spec)

(clang-type-translation-lib-write
 "src/libraries/nausicaa/posix/clang/type-translation.sls.in"
 posix-clang-types-library-spec)


;;; end of file
