;;; (nausicaa posix clang-data-types) --
;;;
;;;Part of: Nausicaa
;;;Contents: foreign library C language type mapping
;;;Date: 
;;;
;;;Abstract
;;;
;;;
;;;
;;;Copyright (c)  Marco Maggi <marco.maggi-ipsu@poste.it>
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


(library (nausicaa posix clang-data-types)
  (export clang-foreign-type->clang-external-type
    clang-maybe-foreign-type->clang-external-type
    enum-clang-foreign-types clang-foreign-types)
  (import (rnrs))
  (define-enumeration enum-clang-foreign-types
    (blkcnt_t clock_t dev_t gid_t ino_t mode_t nlink_t off_t
      pid_t time_t uid_t wchar_t socklen_t socklen_t* flock
      timeval timespec tms dirent utimbuf timezone tm
      ntptimeval timex itimerval FTW iovec fdset passwd
      group utsname fstab mntent sockaddr* sockaddr
      sockaddr_in* sockaddr_in sockaddr_in6* sockaddr_in6
      sockaddr_un* sockaddr_un in_addr* in_addr in6_addr*
      in6_addr if_nameindex* if_nameindex netent* netent
      linger hostent protoent servent)
    clang-foreign-types)
  (define (clang-foreign-type->clang-external-type type)
    (case type
      ((blkcnt_t) 'unsigned-long-long)
      ((clock_t) 'signed-int)
      ((dev_t) 'signed-long-long)
      ((gid_t) 'signed-int)
      ((ino_t) 'unsigned-long-long)
      ((mode_t) 'unsigned-int)
      ((nlink_t) 'unsigned-int)
      ((off_t) 'unsigned-long-long)
      ((pid_t) 'signed-int)
      ((time_t) 'signed-int)
      ((uid_t) 'signed-int)
      ((wchar_t) 'signed-int)
      ((socklen_t) 'signed-int)
      ((socklen_t*) 'pointer)
      ((flock) 'flock)
      ((timeval) 'timeval)
      ((timespec) 'timespec)
      ((tms) 'tms)
      ((dirent) 'dirent)
      ((utimbuf) 'utimbuf)
      ((timezone) 'timezone)
      ((tm) 'tm)
      ((ntptimeval) 'ntptimeval)
      ((timex) 'timex)
      ((itimerval) 'itimerval)
      ((FTW) 'FTW)
      ((iovec) 'iovec)
      ((fdset) 'fdset)
      ((passwd) 'passwd)
      ((group) 'group)
      ((utsname) 'utsname)
      ((fstab) 'fstab)
      ((mntent) 'mntent)
      ((sockaddr*) 'pointer)
      ((sockaddr) 'sockaddr)
      ((sockaddr_in*) 'pointer)
      ((sockaddr_in) 'sockaddr_in)
      ((sockaddr_in6*) 'pointer)
      ((sockaddr_in6) 'sockaddr_in6)
      ((sockaddr_un*) 'pointer)
      ((sockaddr_un) 'sockaddr_un)
      ((in_addr*) 'pointer)
      ((in_addr) 'in_addr)
      ((in6_addr*) 'pointer)
      ((in6_addr) 'in6_addr)
      ((if_nameindex*) 'pointer)
      ((if_nameindex) 'if_nameindex)
      ((netent*) 'pointer)
      ((netent) 'netent)
      ((linger) 'linger)
      ((hostent) 'hostent)
      ((protoent) 'protoent)
      ((servent) 'servent)
      (else #f)))
  (define (clang-maybe-foreign-type->clang-external-type
            type)
    (or (clang-foreign-type->clang-external-type type) type)))


;;; end of file
