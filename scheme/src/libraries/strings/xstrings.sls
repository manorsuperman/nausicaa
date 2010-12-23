;;; -*- coding: utf-8 -*-
;;;
;;;Part of: Nausicaa/Scheme
;;;Contents: label interface to the strings library
;;;Date: Thu Dec 23, 2010
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


#!r6rs
(library (strings xstrings)
  (export <xstring> view start past)
  (import (nausicaa)
    (strings))


(define-label <xstring>
  (inherit <string>)
  (custom-maker string)
  (predicate string?)

  ;; constructors
  (method-syntax concatenate
    (syntax-rules ()
      ((_ o ?list-of-strings)
       (string-concatenate (cons o ?list-of-strings)))))

  (method-syntax concatenate-reverse
    (syntax-rules ()
      ((_ o . ?args)
       (string-concatenate-reverse o . ?args))))

  (method-syntax tabulate
    (syntax-rules ()
      ((_ o . ?args)
       (string-tabulate o . ?args))))

  ;; predicates
  (method-syntax string-null?
    (syntax-rules ()
      ((_ o . ?args)
       (string-null? o . ?args))))

  (method-syntax string-every
    (syntax-rules ()
      ((_ o . ?args)
       (string-every o . ?args))))

  (method-syntax string-any
    (syntax-rules ()
      ((_ o . ?args)
       (string-any o . ?args))))

  ;; comparison
  (method-syntax compare
    (syntax-rules ()
      ((_ o . ?args)
       (string-compare o . ?args))))

  (method-syntax compare-ci
    (syntax-rules ()
      ((_ o . ?args)
       (string-compare-ci o . ?args))))

  (method-syntax =
    (syntax-rules ()
      ((_ o . ?args)
       (string= o . ?args))))

  (method-syntax <>
    (syntax-rules ()
      ((_ o . ?args)
       (string<> o . ?args))))

  (method-syntax ci=
    (syntax-rules ()
      ((_ o . ?args)
       (string-ci= o . ?args))))

  (method-syntax ci<>
    (syntax-rules ()
      ((_ o . ?args)
       (string-ci<> o . ?args))))

  (method-syntax <
    (syntax-rules ()
      ((_ o . ?args)
       (string< o . ?args))))

  (method-syntax <=
    (syntax-rules ()
      ((_ o . ?args)
       (string<= o . ?args))))

  (method-syntax ci<
    (syntax-rules ()
      ((_ o . ?args)
       (string-ci< o . ?args))))

  (method-syntax ci<=
    (syntax-rules ()
      ((_ o . ?args)
       (string-ci<= o . ?args))))

  (method-syntax >
    (syntax-rules ()
      ((_ o . ?args)
       (string> o . ?args))))

  (method-syntax >=
    (syntax-rules ()
      ((_ o . ?args)
       (string>= o . ?args))))

  (method-syntax ci>
    (syntax-rules ()
      ((_ o . ?args)
       (string-ci> o . ?args))))

  (method-syntax ci>=
    (syntax-rules ()
      ((_ o . ?args)
       (string-ci>= o . ?args))))

  ;; dictionary comparison
  (method-syntax dictionary-compare
    (syntax-rules ()
      ((_ o . ?args)
       (string-dictionary-compare o . ?args))))

  (method-syntax dictionary=?
    (syntax-rules ()
      ((_ o . ?args)
       (string-dictionary=? o . ?args))))

  (method-syntax dictionary<>?
    (syntax-rules ()
      ((_ o . ?args)
       (string-dictionary<>? o . ?args))))

  (method-syntax dictionary<?
    (syntax-rules ()
      ((_ o . ?args)
       (string-dictionary<? o . ?args))))

  (method-syntax dictionary<=?
    (syntax-rules ()
      ((_ o . ?args)
       (string-dictionary<=? o . ?args))))

  (method-syntax dictionary>?
    (syntax-rules ()
      ((_ o . ?args)
       (string-dictionary>? o . ?args))))

  (method-syntax dictionary>=?
    (syntax-rules ()
      ((_ o . ?args)
       (string-dictionary>=? o . ?args))))


  (method-syntax dictionary-compare-ci
    (syntax-rules ()
      ((_ o . ?args)
       (string-dictionary-compare-ci o . ?args))))

  (method-syntax dictionary-ci=?
    (syntax-rules ()
      ((_ o . ?args)
       (string-dictionary-ci=? o . ?args))))

  (method-syntax dictionary-ci<>?
    (syntax-rules ()
      ((_ o . ?args)
       (string-dictionary-ci<>? o . ?args))))

  (method-syntax dictionary-ci<?
    (syntax-rules ()
      ((_ o . ?args)
       (string-dictionary-ci<? o . ?args))))

  (method-syntax dictionary-ci<=?
    (syntax-rules ()
      ((_ o . ?args)
       (string-dictionary-ci<=? o . ?args))))

  (method-syntax dictionary-ci>?
    (syntax-rules ()
      ((_ o . ?args)
       (string-dictionary-ci>? o . ?args))))

  (method-syntax dictionary-ci>=?
    (syntax-rules ()
      ((_ o . ?args)
       (string-dictionary-ci>=? o . ?args))))

  ;; string/numbers lexicographic comparison
  (method-syntax string/numbers-compare
    (syntax-rules ()
      ((_ o . ?args)
       (string/numbers-compare o . ?args))))

  (method-syntax string/numbers=?
    (syntax-rules ()
      ((_ o . ?args)
       (string/numbers=? o . ?args))))

  (method-syntax string/numbers<>?
    (syntax-rules ()
      ((_ o . ?args)
       (string/numbers<>? o . ?args))))

  (method-syntax string/numbers<?
    (syntax-rules ()
      ((_ o . ?args)
       (string/numbers<? o . ?args))))

  (method-syntax string/numbers<=?
    (syntax-rules ()
      ((_ o . ?args)
       (string/numbers<=? o . ?args))))

  (method-syntax string/numbers>?
    (syntax-rules ()
      ((_ o . ?args)
       (string/numbers>? o . ?args))))

  (method-syntax string/numbers>=?
    (syntax-rules ()
      ((_ o . ?args)
       (string/numbers>=? o . ?args))))

  (method-syntax string/numbers-compare-ci
    (syntax-rules ()
      ((_ o . ?args)
       (string/numbers-compare-ci o . ?args))))

  (method-syntax string/numbers-ci=?
    (syntax-rules ()
      ((_ o . ?args)
       (string/numbers-ci=? o . ?args))))

  (method-syntax string/numbers-ci<>?
    (syntax-rules ()
      ((_ o . ?args)
       (string/numbers-ci<>? o . ?args))))

  (method-syntax string/numbers-ci<?
    (syntax-rules ()
      ((_ o . ?args)
       (string/numbers-ci<? o . ?args))))

  (method-syntax string/numbers-ci>?
    (syntax-rules ()
      ((_ o . ?args)
       (string/numbers-ci>? o . ?args))))

  (method-syntax string/numbers-ci<=?
    (syntax-rules ()
      ((_ o . ?args)
       (string/numbers-ci<=? o . ?args))))

  (method-syntax string/numbers-ci>=?
    (syntax-rules ()
      ((_ o . ?args)
       (string/numbers-ci>=? o . ?args))))

  ;; string/numbers dictionary comparison
  (method-syntax string/numbers-dictionary-compare
    (syntax-rules ()
      ((_ o . ?args)
       (string/numbers-dictionary-compare o . ?args))))

  (method-syntax string/numbers-dictionary=?
    (syntax-rules ()
      ((_ o . ?args)
       (string/numbers-dictionary=? o . ?args))))

  (method-syntax string/numbers-dictionary<>?
    (syntax-rules ()
      ((_ o . ?args)
       (string/numbers-dictionary<>? o . ?args))))

  (method-syntax string/numbers-dictionary<?
    (syntax-rules ()
      ((_ o . ?args)
       (string/numbers-dictionary<? o . ?args))))

  (method-syntax string/numbers-dictionary<=?
    (syntax-rules ()
      ((_ o . ?args)
       (string/numbers-dictionary<=? o . ?args))))

  (method-syntax string/numbers-dictionary>?
    (syntax-rules ()
      ((_ o . ?args)
       (string/numbers-dictionary>? o . ?args))))

  (method-syntax string/numbers-dictionary>=?
    (syntax-rules ()
      ((_ o . ?args)
       (string/numbers-dictionary>=? o . ?args))))

  (method-syntax string/numbers-dictionary-compare-ci
    (syntax-rules ()
      ((_ o . ?args)
       (string/numbers-dictionary-compare-ci o . ?args))))

  (method-syntax string/numbers-dictionary-ci=?
    (syntax-rules ()
      ((_ o . ?args)
       (string/numbers-dictionary-ci=? o . ?args))))

  (method-syntax string/numbers-dictionary-ci<>?
    (syntax-rules ()
      ((_ o . ?args)
       (string/numbers-dictionary-ci<>? o . ?args))))

  (method-syntax string/numbers-dictionary-ci<?
    (syntax-rules ()
      ((_ o . ?args)
       (string/numbers-dictionary-ci<? o . ?args))))

  (method-syntax string/numbers-dictionary-ci>?
    (syntax-rules ()
      ((_ o . ?args)
       (string/numbers-dictionary-ci>? o . ?args))))

  (method-syntax string/numbers-dictionary-ci<=?
    (syntax-rules ()
      ((_ o . ?args)
       (string/numbers-dictionary-ci<=? o . ?args))))

  (method-syntax string/numbers-dictionary-ci>=?
    (syntax-rules ()
      ((_ o . ?args)
       (string/numbers-dictionary-ci>=? o . ?args))))

  ;; mapping
  (method-syntax map
    (syntax-rules ()
      ((_ o . ?args)
       (string-map o . ?args))))

  (method-syntax map!
    (syntax-rules ()
      ((_ o . ?args)
       (string-map! o . ?args))))

  (method-syntax map*
    (syntax-rules ()
      ((_ o . ?args)
       (string-map* o . ?args))))

  (method-syntax map*!
    (syntax-rules ()
      ((_ o . ?args)
       (string-map*! o . ?args))))

  (method-syntax for-each*
    (syntax-rules ()
      ((_ o . ?args)
       (string-for-each* o . ?args))))

  (method-syntax substring-map
    (syntax-rules ()
      ((_ o . ?args)
       (substring-map o . ?args))))

  (method-syntax substring-map!
    (syntax-rules ()
      ((_ o . ?args)
       (substring-map! o . ?args))))

  (method-syntax substring-for-each
    (syntax-rules ()
      ((_ o . ?args)
       (substring-for-each o . ?args))))

  (method-syntax substring-for-each-index
    (syntax-rules ()
      ((_ o . ?args)
       (substring-for-each-index o . ?args))))

  ;; case
  (method-syntax downcase*
    (syntax-rules ()
      ((_ o . ?args)
       (string-downcase* o . ?args))))

  (method-syntax upcase*
    (syntax-rules ()
      ((_ o . ?args)
       (string-upcase* o . ?args))))

  (method-syntax titlecase*
    (syntax-rules ()
      ((_ o . ?args)
       (string-titlecase* o . ?args))))

  (method-syntax downcase*!
    (syntax-rules ()
      ((_ o . ?args)
       (string-downcase*! o . ?args))))

  (method-syntax upcase*!
    (syntax-rules ()
      ((_ o . ?args)
       (string-upcase*! o . ?args))))

  (method-syntax titlecase*!
    (syntax-rules ()
      ((_ o . ?args)
       (string-titlecase*! o . ?args))))

  ;; folding
  (method-syntax fold-left
    (syntax-rules ()
      ((_ o . ?args)
       (string-fold-left o . ?args))))

  (method-syntax fold-right
    (syntax-rules ()
      ((_ o . ?args)
       (string-fold-right o . ?args))))

  (method-syntax fold-left*
    (syntax-rules ()
      ((_ o . ?args)
       (string-fold-left* o . ?args))))

  (method-syntax fold-right*
    (syntax-rules ()
      ((_ o . ?args)
       (string-fold-right* o . ?args))))

  (method-syntax substring-fold-left
    (syntax-rules ()
      ((_ o . ?args)
       (substring-fold-left o . ?args))))

  (method-syntax substring-fold-right
    (syntax-rules ()
      ((_ o . ?args)
       (substring-fold-right o . ?args))))

  (method-syntax unfold
    (syntax-rules ()
      ((_ o . ?args)
       (string-unfold o . ?args))))

  (method-syntax unfold-right
    (syntax-rules ()
      ((_ o . ?args)
       (string-unfold-right o . ?args))))

  ;; selecting
  (method-syntax substring*
    (syntax-rules ()
      ((_ o . ?args)
       (substring* o . ?args))))

  (method-syntax reverse-copy*
    (syntax-rules ()
      ((_ o . ?args)
       (string-reverse-copy* o . ?args))))

  (method-syntax copy*!
    (syntax-rules ()
      ((_ o . ?args)
       (string-copy*! o . ?args))))

  (method-syntax reverse-copy*!
    (syntax-rules ()
      ((_ o . ?args)
       (string-reverse-copy*! o . ?args))))

  (method-syntax take
    (syntax-rules ()
      ((_ o . ?args)
       (string-take o . ?args))))

  (method-syntax take-right
    (syntax-rules ()
      ((_ o . ?args)
       (string-take-right o . ?args))))

  (method-syntax drop
    (syntax-rules ()
      ((_ o . ?args)
       (string-drop o . ?args))))

  (method-syntax drop-right
    (syntax-rules ()
      ((_ o . ?args)
       (string-drop-right o . ?args))))

  ;; padding and trimming
  (method-syntax trim
    (syntax-rules ()
      ((_ o . ?args)
       (string-trim o . ?args))))

  (method-syntax trim-right
    (syntax-rules ()
      ((_ o . ?args)
       (string-trim-right o . ?args))))

  (method-syntax trim-both
    (syntax-rules ()
      ((_ o . ?args)
       (string-trim-both o . ?args))))

  (method-syntax pad
    (syntax-rules ()
      ((_ o . ?args)
       (string-pad o . ?args))))

  (method-syntax pad-right
    (syntax-rules ()
      ((_ o . ?args)
       (string-pad-right o . ?args))))

  ;; prefix and suffix
  (method-syntax prefix-length
    (syntax-rules ()
      ((_ o . ?args)
       (string-prefix-length o . ?args))))

  (method-syntax prefix-length-ci
    (syntax-rules ()
      ((_ o . ?args)
       (string-prefix-length-ci o . ?args))))

  (method-syntax suffix-length
    (syntax-rules ()
      ((_ o . ?args)
       (string-suffix-length o . ?args))))

  (method-syntax suffix-length-ci
    (syntax-rules ()
      ((_ o . ?args)
       (string-suffix-length-ci o . ?args))))

  (method-syntax prefix?
    (syntax-rules ()
      ((_ o . ?args)
       (string-prefix? o . ?args))))

  (method-syntax prefix-ci?
    (syntax-rules ()
      ((_ o . ?args)
       (string-prefix-ci? o . ?args))))

  (method-syntax suffix?
    (syntax-rules ()
      ((_ o . ?args)
       (string-suffix? o . ?args))))

  (method-syntax suffix-ci?
    (syntax-rules ()
      ((_ o . ?args)
       (string-suffix-ci? o . ?args))))

  ;; searching
  (method-syntax index
    (syntax-rules ()
      ((_ o . ?args)
       (string-index o . ?args))))

  (method-syntax index-right
    (syntax-rules ()
      ((_ o . ?args)
       (string-index-right o . ?args))))

  (method-syntax skip
    (syntax-rules ()
      ((_ o . ?args)
       (string-skip o . ?args))))

  (method-syntax skip-right
    (syntax-rules ()
      ((_ o . ?args)
       (string-skip-right o . ?args))))

  (method-syntax contains
    (syntax-rules ()
      ((_ o . ?args)
       (string-contains o . ?args))))

  (method-syntax contains-ci
    (syntax-rules ()
      ((_ o . ?args)
       (string-contains-ci o . ?args))))

  (method-syntax count
    (syntax-rules ()
      ((_ o . ?args)
       (string-count o . ?args))))

  ;; filtering
  (method-syntax filter
    (syntax-rules ()
      ((_ o . ?args)
       (string-filter o . ?args))))

  (method-syntax delete
    (syntax-rules ()
      ((_ o . ?args)
       (string-delete o . ?args))))

  ;; lists
  (method-syntax >list*
    (syntax-rules ()
      ((_ o . ?args)
       (string->list* o . ?args))))

  (method-syntax reverse-list->string
    (syntax-rules ()
      ((_ o . ?args)
       (reverse-list->string o . ?args))))

  (method-syntax join
    (syntax-rules ()
      ((_ o . ?args)
       (string-join o . ?args))))

  (method-syntax tokenize
    (syntax-rules ()
      ((_ o . ?args)
       (string-tokenize o . ?args))))

  (method-syntax tokenise
    (syntax-rules ()
      ((_ o . ?args)
       (string-tokenise o . ?args))))

  ;; replicating
  (method-syntax xsubstring
    (syntax-rules ()
      ((_ o . ?args)
       (xsubstring o . ?args))))

  (method-syntax xcopy!
    (syntax-rules ()
      ((_ o . ?args)
       (string-xcopy! o . ?args))))

  ;; mutating
  (method-syntax fill*!
    (syntax-rules ()
      ((_ o . ?args)
       (string-fill*! o . ?args))))

  (method-syntax swap!
    (syntax-rules ()
      ((_ o . ?args)
       (string-swap! o . ?args))))

  ;; reverse and replace
  (method-syntax reverse
    (syntax-rules ()
      ((_ o . ?args)
       (string-reverse o . ?args))))

  (method-syntax reverse!
    (syntax-rules ()
      ((_ o . ?args)
       (string-reverse! o . ?args))))

  (method-syntax replace
    (syntax-rules ()
      ((_ o . ?args)
       (string-replace o . ?args))))

  )


;;;; done

)

;;; end of file
