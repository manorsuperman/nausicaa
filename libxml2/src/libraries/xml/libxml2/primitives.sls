;;; -*- coding: utf-8-unix -*-
;;;
;;;Part of: Nausicaa/Libxml2
;;;Contents: primitive functions
;;;Date: Thu Dec 10, 2009
;;;
;;;Abstract
;;;
;;;
;;;
;;;Copyright (c) 2009, 2010 Marco Maggi <marco.maggi-ipsu@poste.it>
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


(library (xml libxml2 primitives)
  (export

    ;; callback makers
    make-xml-c14n-is-visible-callback
    make-xml-shell-readline-func
    make-xml-shell-cmd
    make-xml-char-encoding-input-func
    make-xml-char-encoding-output-func
    make-xml-parser-input-buffer-create-filename-func
    make-xml-output-buffer-create-filename-func
    make-xml-register-node-func
    make-xml-deregister-node-func
    make-xml-hash-deallocator
    make-xml-hash-copier
    make-xml-hash-scanner
    make-xml-hash-scanner-full
    make-xml-list-deallocator
    make-xml-list-data-compare
    make-xml-list-walker
    make-ftp-list-callback
    make-ftp-data-callback
    make-xml-parser-input-deallocate
    make-resolve-entity-sax-func
    make-internal-subset-sax-func
    make-external-subset-sax-func
    make-get-entity-sax-func
    make-get-parameter-entity-sax-func
    make-entity-decl-sax-func
    make-notation-decl-sax-func
    make-attribute-decl-sax-func
    make-element-decl-sax-func
    make-unparsed-entity-decl-sax-func
    make-set-document-locator-sax-func
    make-start-document-sax-func
    make-end-document-sax-func
    make-start-element-sax-func
    make-end-element-sax-func
    make-attribute-sax-func
    make-reference-sax-func
    make-characters-sax-func
    make-ignorable-whitespace-sax-func
    make-comment-sax-func
    make-cdata-block-sax-func
;;;make-warning-sax-func		;;Variadic!!!
;;;make-error-sax-func			;;Variadic!!!
;;;make-fatal-error-sax-func		;;Variadic!!!
    make-is-standalone-sax-func
    make-has-internal-subset-sax-func
    make-has-external-subset-sax-func
    make-start-element-ns-sax2-func
    make-end-element-ns-sax2-func
    make-xml-external-entity-loader
;;;make-xml-relax-ng-validity-error-func	;;Variadic!!!
;;;make-xml-relax-ng-validity-warning-func	;;Variadic!!!
;;;make-xml-schematron-validity-error-func	;;Variadic!!!
;;;make-xml-schematron-validity-warning-func 	;;Variadic!!!
    make-xml-dom-wrap-acquire-ns-function
;;;make-xml-validity-error-func			;;Variadic!!!
;;;make-xml-validity-warning-func		;;Variadic!!!
;;;make-xml-generic-error-func			;;Variadic!!!
    make-xml-structured-error-func
    make-xml-input-match-callback
    make-xml-input-open-callback
    make-xml-input-read-callback
    make-xml-input-close-callback
    make-xml-output-match-callback
    make-xml-output-open-callback
    make-xml-output-write-callback
    make-xml-output-close-callback
    make-xml-free-func
    make-xml-malloc-func
    make-xml-realloc-func
    make-xml-strdup-func
    make-xml-text-reader-error-func
    make-xml-reg-exec-callbacks
;;;make-xml-schema-validity-error-func 		;;Variadic!!!
;;;make-xml-schema-validity-warning-func 	;;Variadic!!!
    make-xml-xpath-convert-func
    make-xml-xpath-eval-func
    make-xml-xpath-axis-func
    make-xml-xpath-function
    make-xml-xpath-variable-lookup-func
    make-xml-xpath-func-lookup-func

    ;; Canonical XML and Exclusive XML Canonicalization
    (rename
     (xmlC14NDocSaveTo				xml-c14n-doc-save-to)
     (xmlC14NDocDumpMemory			xml-c14n-doc-dump-memory)
     (xmlC14NDocSave				xml-c14n-doc-save)
     (xmlC14NExecute				xml-c14n-execute))

    ;; Unicode character range checking
    (rename
     (xmlCharInRange				xml-char-in-range)
     (xmlIsBaseChar				xml-is-base-char)
     (xmlIsBlank				xml-is-blank)
     (xmlIsChar					xml-is-char)
     (xmlIsCombining				xml-is-combining)
     (xmlIsDigit				xml-is-digit)
     (xmlIsExtender				xml-is-extender)
     (xmlIsIdeographic				xml-is-ideographic)
     (xmlIsPubidChar				xml-is-pubid-char)

     (xmlIsBaseChar_ch				xml-is-base-char-ch)
     (xmlIsBaseCharQ				xml-is-base-char-q)
     (xmlIsBaseCharGroup			xml-is-base-char-group)
     (xmlIsBlank_ch				xml-is-blank-ch)
     (xmlIsBlankQ				xml-is-blank-q)
     (xmlIsChar_ch				xml-is-char-ch)
     (xmlIsCharQ				xml-is-char-q)
     (xmlIsCharGroup				xml-is-char-group)
     (xmlIsCombiningQ				xml-is-combining-q)
     (xmlIsCombiningGroup			xml-is-combining-group)
     (xmlIsDigit_ch				xml-is-digit-ch)
     (xmlIsDigitQ				xml-is-digit-q)
     (xmlIsDigitGroup				xml-is-digit-group)
     (xmlIsExtender_ch				xml-is-extender-ch)
     (xmlIsExtenderQ				xml-is-extender-q)
     (xmlIsExtenderGroup			xml-is-extender-group)
     (xmlIsIdeographicQ				xml-is-ideographic-q)
     (xmlIsIdeographicGroup			xml-is-ideographic-group)
     (xmlIsPubidChar_tab			xml-is-pubid-char-tab)
     (xmlIsPubidChar_ch				xml-is-pubid-char-ch)
     (xmlIsPubidCharQ				xml-is-pubid-char-q))

    ;; Interfaces to the Catalog handling system
    (rename
     (xmlNewCatalog				xml-new-catalog)
     (xmlLoadACatalog				xml-load-a-catalog)
     (xmlLoadSGMLSuperCatalog			xml-load-sgml-super-catalog)
     (xmlConvertSGMLCatalog			xml-convert-sgml-catalog)
     (xmlACatalogAdd				xml-a-catalog-add)
     (xmlACatalogRemove				xml-a-catalog-remove)
     (xmlACatalogResolve			xml-a-catalog-resolve)
     (xmlACatalogResolveSystem			xml-a-catalog-resolve-system)
     (xmlACatalogResolvePublic			xml-a-catalog-resolve-public)
     (xmlACatalogResolveURI			xml-a-catalog-resolve-uri)
     (xmlACatalogDump				xml-a-catalog-dump)
     (xmlFreeCatalog				xml-free-catalog)
     (xmlCatalogIsEmpty				xml-catalog-is-empty)
     (xmlInitializeCatalog			xml-initialize-catalog)
     (xmlLoadCatalog				xml-load-catalog)
     (xmlLoadCatalogs				xml-load-catalogs)
     (xmlCatalogCleanup				xml-catalog-cleanup)
     (xmlCatalogDump				xml-catalog-dump)
     (xmlCatalogResolve				xml-catalog-resolve)
     (xmlCatalogResolveSystem			xml-catalog-resolve-system)
     (xmlCatalogResolvePublic			xml-catalog-resolve-public)
     (xmlCatalogResolveURI			xml-catalog-resolve-uri)
     (xmlCatalogAdd				xml-catalog-add)
     (xmlCatalogRemove				xml-catalog-remove)
     (xmlParseCatalogFile			xml-parse-catalog-file)
     (xmlCatalogConvert				xml-catalog-convert)
     (xmlCatalogFreeLocal			xml-catalog-free-local)
     (xmlCatalogAddLocal			xml-catalog-add-local)
     (xmlCatalogLocalResolve			xml-catalog-local-resolve)
     (xmlCatalogLocalResolveURI			xml-catalog-local-resolve-uri)
     (xmlCatalogSetDebug			xml-catalog-set-debug)
     (xmlCatalogSetDefaultPrefer		xml-catalog-set-default-prefer)
     (xmlCatalogSetDefaults			xml-catalog-set-defaults)
     (xmlCatalogGetDefaults			xml-catalog-get-defaults)
     (xmlCatalogGetSystem			xml-catalog-get-system)
     (xmlCatalogGetPublic			xml-catalog-get-public))

    ;; Tree debugging APIs
    (rename
     (xmlDebugDumpString			xml-debug-dump-string)
     (xmlDebugDumpAttr				xml-debug-dump-attr)
     (xmlDebugDumpAttrList			xml-debug-dump-attr-list)
     (xmlDebugDumpOneNode			xml-debug-dump-one-node)
     (xmlDebugDumpNode				xml-debug-dump-node)
     (xmlDebugDumpNodeList			xml-debug-dump-node-list)
     (xmlDebugDumpDocumentHead			xml-debug-dump-document-head)
     (xmlDebugDumpDocument			xml-debug-dump-document)
     (xmlDebugDumpDTD				xml-debug-dump-dtd)
     (xmlDebugDumpEntities			xml-debug-dump-entities)
     (xmlDebugCheckDocument			xml-debug-check-document)
     (xmlLsOneNode				xml-ls-one-node)
     (xmlLsCountNode				xml-ls-count-node)
     (xmlBoolToText				xml-bool-to-text)
     (xmlShellPrintXPathError			xml-shell-print-xpath-error)
     (xmlShellPrintXPathResult			xml-shell-print-xpath-result)
     (xmlShellList				xml-shell-list)
     (xmlShellBase				xml-shell-base)
     (xmlShellDir				xml-shell-dir)
     (xmlShellLoad				xml-shell-load)
     (xmlShellPrintNode				xml-shell-print-node)
     (xmlShellCat				xml-shell-cat)
     (xmlShellWrite				xml-shell-write)
     (xmlShellSave				xml-shell-save)
     (xmlShellValidate				xml-shell-validate)
     (xmlShellDu				xml-shell-du)
     (xmlShellPwd				xml-shell-pwd)
     (xmlShell					xml-shell))

    ;; string dictionary
    (rename
     (xmlDictCreate				xml-dict-create)
     (xmlDictCreateSub				xml-dict-create-sub)
     (xmlDictReference				xml-dict-reference)
     (xmlDictFree				xml-dict-free)
     (xmlDictLookup				xml-dict-lookup)
     (xmlDictExists				xml-dict-exists)
     (xmlDictQLookup				xml-dict-qlookup)
     (xmlDictOwns				xml-dict-owns)
     (xmlDictSize				xml-dict-size)
     (xmlDictCleanup				xml-dict-cleanup))

    ;; interface for the encoding conversion functions
    (rename
     (xmlInitCharEncodingHandlers		xml-init-char-encoding-handlers)
     (xmlCleanupCharEncodingHandlers		xml-cleanup-char-encoding-handlers)
     (xmlRegisterCharEncodingHandler		xml-register-char-encoding-handler)
     (xmlGetCharEncodingHandler			xml-get-char-encoding-handler)
     (xmlFindCharEncodingHandler		xml-find-char-encoding-handler)
     (xmlNewCharEncodingHandler			xml-new-char-encoding-handler)
     (xmlAddEncodingAlias			xml-add-encoding-alias)
     (xmlDelEncodingAlias			xml-del-encoding-alias)
     (xmlGetEncodingAlias			xml-get-encoding-alias)
     (xmlCleanupEncodingAliases			xml-cleanup-encoding-aliases)
     (xmlParseCharEncoding			xml-parse-char-encoding)
     (xmlGetCharEncodingName			xml-get-char-encoding-name)
     (xmlDetectCharEncoding			xml-detect-char-encoding)
     (xmlCharEncOutFunc				xml-char-enc-out-func)
     (xmlCharEncInFunc				xml-char-enc-in-func)
     (xmlCharEncFirstLine			xml-char-enc-first-line)
     (xmlCharEncCloseFunc			xml-char-enc-close-func)
     (UTF8Toisolat1				utf8-to-isolat1)
     (isolat1ToUTF8				isolat1-to-utf8))

    ;; interface for the XML entities handling
    (rename
     (xmlInitializePredefinedEntities		xml-initialize-predefined-entities)
     (xmlNewEntity				xml-new-entity)
     (xmlAddDocEntity				xml-add-doc-entity)
     (xmlAddDtdEntity				xml-add-dtd-entity)
     (xmlGetPredefinedEntity			xml-get-predefined-entity)
     (xmlGetDocEntity				xml-get-doc-entity)
     (xmlGetDtdEntity				xml-get-dtd-entity)
     (xmlGetParameterEntity			xml-get-parameter-entity)
     (xmlEncodeEntities				xml-encode-entities)
     (xmlEncodeEntitiesReentrant		xml-encode-entities-reentrant)
     (xmlEncodeSpecialChars			xml-encode-special-chars)
     (xmlCreateEntitiesTable			xml-create-entities-table)
     (xmlCopyEntitiesTable			xml-copy-entities-table)
     (xmlFreeEntitiesTable			xml-free-entities-table)
     (xmlDumpEntitiesTable			xml-dump-entities-table)
     (xmlDumpEntityDecl				xml-dump-entity-decl)
     (xmlCleanupPredefinedEntities		xml-cleanup-predefined-entities))

    ;; interface for all global variables of the library
    (rename
     (xmlInitGlobals					xml-init-globals)
     (xmlCleanupGlobals					xml-cleanup-globals)
     (xmlParserInputBufferCreateFilenameDefault		xml-parser-input-buffer-create-filename-default)
     (xmlOutputBufferCreateFilenameDefault		xml-output-buffer-create-filename-default)
     (xmlInitializeGlobalState				xml-initialize-global-state)
     (xmlThrDefSetGenericErrorFunc			xml-thr-def-set-generic-error-func)
     (xmlThrDefSetStructuredErrorFunc			xml-thr-def-set-structured-error-func)
     (xmlRegisterNodeDefault				xml-register-node-default)
     (xmlThrDefRegisterNodeDefault			xml-thr-def-register-node-default)
     (xmlDeregisterNodeDefault				xml-deregister-node-default)
     (xmlThrDefDeregisterNodeDefault			xml-thr-def-deregister-node-default)
     (xmlThrDefOutputBufferCreateFilenameDefault	xml-thr-def-output-buffer-create-filename-default)
     (xmlThrDefParserInputBufferCreateFilenameDefault
      xml-thr-def-parser-input-buffer-create-filename-default)
     (xmlMalloc						xml-malloc)
     (xmlMallocAtomic					xml-malloc-atomic)
     (xmlRealloc					xml-realloc)
     (xmlFree						xml-free)
     (xmlMemStrdup					xml-mem-strdup))

    ;; chained hash tables
    (rename
     (xmlHashCreate				xml-hash-create)
     (xmlHashCreateDict				xml-hash-create-dict)
     (xmlHashFree				xml-hash-free)
     (xmlHashAddEntry				xml-hash-add-entry)
     (xmlHashUpdateEntry			xml-hash-update-entry)
     (xmlHashAddEntry2				xml-hash-add-entry2)
     (xmlHashUpdateEntry2			xml-hash-update-entry2)
     (xmlHashAddEntry3				xml-hash-add-entry3)
     (xmlHashUpdateEntry3			xml-hash-update-entry3)
     (xmlHashRemoveEntry			xml-hash-remove-entry)
     (xmlHashRemoveEntry2			xml-hash-remove-entry2)
     (xmlHashRemoveEntry3			xml-hash-remove-entry3)
     (xmlHashLookup				xml-hash-lookup)
     (xmlHashLookup2				xml-hash-lookup2)
     (xmlHashLookup3				xml-hash-lookup3)
     (xmlHashQLookup				xml-hash-qlookup)
     (xmlHashQLookup2				xml-hash-qlookup2)
     (xmlHashQLookup3				xml-hash-qlookup3)
     (xmlHashCopy				xml-hash-copy)
     (xmlHashSize				xml-hash-size)
     (xmlHashScan				xml-hash-scan)
     (xmlHashScan3				xml-hash-scan3)
     (xmlHashScanFull				xml-hash-scan-full)
     (xmlHashScanFull3				xml-hash-scan-full3))

    ;; HTML parser
    (rename
     (htmlTagLookup				html-tag-lookup)
     (htmlEntityLookup				html-entity-lookup)
     (htmlEntityValueLookup			html-entity-value-lookup)
     (htmlIsAutoClosed				html-is-auto-closed)
     (htmlAutoCloseTag				html-auto-close-tag)
     (htmlParseEntityRef			html-parse-entity-ref)
     (htmlParseCharRef				html-parse-char-ref)
     (htmlParseElement				html-parse-element)
     (htmlNewParserCtxt				html-new-parser-ctxt)
     (htmlCreateMemoryParserCtxt		html-create-memory-parser-ctxt)
     (htmlParseDocument				html-parse-document)
     (htmlSAXParseDoc				html-sax-parse-doc)
     (htmlParseDoc				html-parse-doc)
     (htmlSAXParseFile				html-sax-parse-file)
     (htmlParseFile				html-parse-file)
     (UTF8ToHtml				utf8-to-html)
     (htmlEncodeEntities			html-encode-entities)
     (htmlIsScriptAttribute			html-is-script-attribute)
     (htmlHandleOmittedElem			html-handle-omitted-elem)
     (htmlCreatePushParserCtxt			html-create-push-parser-ctxt)
     (htmlParseChunk				html-parse-chunk)
     (htmlFreeParserCtxt			html-free-parser-ctxt)
     (htmlCtxtReset				html-ctxt-reset)
     (htmlCtxtUseOptions			html-ctxt-use-options)
     (htmlReadDoc				html-read-doc)
     (htmlReadFile				html-read-file)
     (htmlReadMemory				html-read-memory)
     (htmlReadFd				html-read-fd)
     (htmlReadIO				html-read-io)
     (htmlCtxtReadDoc				html-ctxt-read-doc)
     (htmlCtxtReadFile				html-ctxt-read-file)
     (htmlCtxtReadMemory			html-ctxt-read-memory)
     (htmlCtxtReadFd				html-ctxt-read-fd)
     (htmlCtxtReadIO				html-ctxt-read-io)
     (htmlAttrAllowed				html-attr-allowed)
     (htmlElementAllowedHere			html-element-allowed-here)
     (htmlElementStatusHere			html-element-status-here)
     (htmlNodeStatus				html-node-status))

    ;; specific APIs to process HTML tree, especially serialization
    (rename
     (htmlNewDoc				html-new-doc)
     (htmlNewDocNoDtD				html-new-doc-no-dtd)
     (htmlGetMetaEncoding			html-get-meta-encoding)
     (htmlSetMetaEncoding			html-set-meta-encoding)
     (htmlDocDumpMemory				html-doc-dump-memory)
     (htmlDocDumpMemoryFormat			html-doc-dump-memory-format)
     (htmlDocDump				html-doc-dump)
     (htmlSaveFile				html-save-file)
     (htmlNodeDump				html-node-dump)
     (htmlNodeDumpFile				html-node-dump-file)
     (htmlNodeDumpFileFormat			html-node-dump-file-format)
     (htmlSaveFileEnc				html-save-file-enc)
     (htmlSaveFileFormat			html-save-file-format)
     (htmlNodeDumpFormatOutput			html-node-dump-format-output)
     (htmlDocContentDumpOutput			html-doc-content-dump-output)
     (htmlDocContentDumpFormatOutput		html-doc-content-dump-format-output)
     (htmlNodeDumpOutput			html-node-dump-output)
     (htmlIsBooleanAttr				html-is-boolean-attr))

    ;; lists interfaces
    (rename
     (xmlListCreate				xml-list-create)
     (xmlListDelete				xml-list-delete)
     (xmlListSearch				xml-list-search)
     (xmlListReverseSearch			xml-list-reverse-search)
     (xmlListInsert				xml-list-insert)
     (xmlListAppend				xml-list-append)
     (xmlListRemoveFirst			xml-list-remove-first)
     (xmlListRemoveLast				xml-list-remove-last)
     (xmlListRemoveAll				xml-list-remove-all)
     (xmlListClear				xml-list-clear)
     (xmlListEmpty				xml-list-empty)
     (xmlListFront				xml-list-front)
     (xmlListEnd				xml-list-end)
     (xmlListSize				xml-list-size)
     (xmlListPopFront				xml-list-pop-front)
     (xmlListPopBack				xml-list-pop-back)
     (xmlListPushFront				xml-list-push-front)
     (xmlListPushBack				xml-list-push-back)
     (xmlListReverse				xml-list-reverse)
     (xmlListSort				xml-list-sort)
     (xmlListWalk				xml-list-walk)
     (xmlListReverseWalk			xml-list-reverse-walk)
     (xmlListMerge				xml-list-merge)
     (xmlListDup				xml-list-dup)
     (xmlListCopy				xml-list-copy)
     (xmlLinkGetData				xml-link-get-data))

    ;; minimal FTP implementation
    (rename
     (xmlNanoFTPInit				xml-nano-ftp-init)
     (xmlNanoFTPCleanup				xml-nano-ftp-cleanup)
     (xmlNanoFTPNewCtxt				xml-nano-ftp-new-ctxt)
     (xmlNanoFTPFreeCtxt			xml-nano-ftp-free-ctxt)
     (xmlNanoFTPConnectTo			xml-nano-ftp-connect-to)
     (xmlNanoFTPOpen				xml-nano-ftp-open)
     (xmlNanoFTPConnect				xml-nano-ftp-connect)
     (xmlNanoFTPClose				xml-nano-ftp-close)
     (xmlNanoFTPQuit				xml-nano-ftp-quit)
     (xmlNanoFTPScanProxy			xml-nano-ftp-scan-proxy)
     (xmlNanoFTPProxy				xml-nano-ftp-proxy)
     (xmlNanoFTPUpdateURL			xml-nano-ftp-update-url)
     (xmlNanoFTPGetResponse			xml-nano-ftp-get-response)
     (xmlNanoFTPCheckResponse			xml-nano-ftp-check-response)
     (xmlNanoFTPCwd				xml-nano-ftp-cwd)
     (xmlNanoFTPDele				xml-nano-ftp-dele)
     (xmlNanoFTPGetConnection			xml-nano-ftp-get-connection)
     (xmlNanoFTPCloseConnection			xml-nano-ftp-close-connection)
     (xmlNanoFTPList				xml-nano-ftp-list)
     (xmlNanoFTPGetSocket			xml-nano-ftp-get-socket)
     (xmlNanoFTPGet				xml-nano-ftp-get)
     (xmlNanoFTPRead				xml-nano-ftp-read))

    ;; minimal HTTP implementation
    (rename
     (xmlNanoHTTPInit				xml-nano-http-init)
     (xmlNanoHTTPCleanup			xml-nano-http-cleanup)
     (xmlNanoHTTPScanProxy			xml-nano-http-scan-proxy)
     (xmlNanoHTTPFetch				xml-nano-http-fetch)
     (xmlNanoHTTPMethod				xml-nano-http-method)
     (xmlNanoHTTPMethodRedir			xml-nano-http-method-redir)
     (xmlNanoHTTPOpen				xml-nano-http-open)
     (xmlNanoHTTPOpenRedir			xml-nano-http-open-redir)
     (xmlNanoHTTPReturnCode			xml-nano-http-return-code)
     (xmlNanoHTTPAuthHeader			xml-nano-http-auth-header)
     (xmlNanoHTTPRedir				xml-nano-http-redir)
     (xmlNanoHTTPContentLength			xml-nano-http-content-length)
     (xmlNanoHTTPEncoding			xml-nano-http-encoding)
     (xmlNanoHTTPMimeType			xml-nano-http-mime-type)
     (xmlNanoHTTPRead				xml-nano-http-read)
     (xmlNanoHTTPSave				xml-nano-http-save)
     (xmlNanoHTTPClose				xml-nano-http-close))

    ;; the core parser module
    (rename
     (xmlInitParser				xml-init-parser)
     (xmlCleanupParser				xml-cleanup-parser)
     (xmlParserInputRead			xml-parser-input-read)
     (xmlParserInputGrow			xml-parser-input-grow)
     (xmlParseDoc				xml-parse-doc)
     (xmlParseFile				xml-parse-file)
     (xmlParseMemory				xml-parse-memory)
     (xmlSubstituteEntitiesDefault		xml-substitute-entities-default)
     (xmlKeepBlanksDefault			xml-keep-blanks-default)
     (xmlStopParser				xml-stop-parser)
     (xmlPedanticParserDefault			xml-pedantic-parser-default)
     (xmlLineNumbersDefault			xml-line-numbers-default)
     (xmlRecoverDoc				xml-recover-doc)
     (xmlRecoverMemory				xml-recover-memory)
     (xmlRecoverFile				xml-recover-file)
     (xmlParseDocument				xml-parse-document)
     (xmlParseExtParsedEnt			xml-parse-ext-parsed-ent)
     (xmlSAXUserParseFile			xml-sax-user-parse-file)
     (xmlSAXUserParseMemory			xml-sax-user-parse-memory)
     (xmlSAXParseDoc				xml-sax-parse-doc)
     (xmlSAXParseMemory				xml-sax-parse-memory)
     (xmlSAXParseMemoryWithData			xml-sax-parse-memory-with-data)
     (xmlSAXParseFile				xml-sax-parse-file)
     (xmlSAXParseFileWithData			xml-sax-parse-file-with-data)
     (xmlSAXParseEntity				xml-sax-parse-entity)
     (xmlParseEntity				xml-parse-entity)
     (xmlSAXParseDTD				xml-sax-parse-dtd)
     (xmlParseDTD				xml-parse-dtd)
     (xmlIOParseDTD				xml-io-parse-dtd)
     (xmlParseBalancedChunkMemory		xml-parse-balanced-chunk-memory)
     (xmlParseInNodeContext			xml-parse-in-node-context)
     (xmlParseBalancedChunkMemoryRecover	xml-parse-balanced-chunk-memory-recover)
     (xmlParseExternalEntity			xml-parse-external-entity)
     (xmlParseCtxtExternalEntity		xml-parse-ctxt-external-entity)
     (xmlNewParserCtxt				xml-new-parser-ctxt)
     (xmlInitParserCtxt				xml-init-parser-ctxt)
     (xmlClearParserCtxt			xml-clear-parser-ctxt)
     (xmlFreeParserCtxt				xml-free-parser-ctxt)
     (xmlSetupParserForBuffer			xml-setup-parser-for-buffer)
     (xmlCreateDocParserCtxt			xml-create-doc-parser-ctxt)
     (xmlGetFeaturesList			xml-get-features-list)
     (xmlGetFeature				xml-get-feature)
     (xmlSetFeature				xml-set-feature)
     (xmlCreatePushParserCtxt			xml-create-push-parser-ctxt)
     (xmlParseChunk				xml-parse-chunk)
     (xmlCreateIOParserCtxt			xml-create-io-parser-ctxt)
     (xmlNewIOInputStream			xml-new-io-input-stream)
     (xmlParserFindNodeInfo			xml-parser-find-node-info)
     (xmlInitNodeInfoSeq			xml-init-node-info-seq)
     (xmlClearNodeInfoSeq			xml-clear-node-info-seq)
     (xmlParserFindNodeInfoIndex		xml-parser-find-node-info-index)
     (xmlParserAddNodeInfo			xml-parser-add-node-info)
     (xmlSetExternalEntityLoader		xml-set-external-entity-loader)
     (xmlGetExternalEntityLoader		xml-get-external-entity-loader)
     (xmlLoadExternalEntity			xml-load-external-entity)
     (xmlByteConsumed				xml-byte-consumed)
     (xmlCtxtReset				xml-ctxt-reset)
     (xmlCtxtResetPush				xml-ctxt-reset-push)
     (xmlCtxtUseOptions				xml-ctxt-use-options)
     (xmlReadDoc				xml-read-doc)
     (xmlReadFile				xml-read-file)
     (xmlReadMemory				xml-read-memory)
     (xmlReadFd					xml-read-fd)
     (xmlReadIO					xml-read-io)
     (xmlCtxtReadDoc				xml-ctxt-read-doc)
     (xmlCtxtReadFile				xml-ctxt-read-file)
     (xmlCtxtReadMemory				xml-ctxt-read-memory)
     (xmlCtxtReadFd				xml-ctxt-read-fd)
     (xmlCtxtReadIO				xml-ctxt-read-io)
     (xmlHasFeature				xml-has-feature))

    ;; pattern expression handling
    (rename
     (xmlFreePattern				xml-free-pattern)
     (xmlFreePatternList			xml-free-pattern-list)
     (xmlPatterncompile				xml-patterncompile)
     (xmlPatternMatch				xml-pattern-match)
     (xmlPatternStreamable			xml-pattern-streamable)
     (xmlPatternMaxDepth			xml-pattern-max-depth)
     (xmlPatternMinDepth			xml-pattern-min-depth)
     (xmlPatternFromRoot			xml-pattern-from-root)
     (xmlPatternGetStreamCtxt			xml-pattern-get-stream-ctxt)
     (xmlFreeStreamCtxt				xml-free-stream-ctxt)
     (xmlStreamPushNode				xml-stream-push-node)
     (xmlStreamPush				xml-stream-push)
     (xmlStreamPushAttr				xml-stream-push-attr)
     (xmlStreamPop				xml-stream-pop)
     (xmlStreamWantsAnyNode			xml-stream-wants-any-node))

    ;; implementation of the Relax-NG validation
    (rename
     (xmlRelaxNGInitTypes			xml-relax-ng-init-types)
     (xmlRelaxNGCleanupTypes			xml-relax-ng-cleanup-types)
     (xmlRelaxNGNewParserCtxt			xml-relax-ng-new-parser-ctxt)
     (xmlRelaxNGNewMemParserCtxt		xml-relax-ng-new-mem-parser-ctxt)
     (xmlRelaxNGNewDocParserCtxt		xml-relax-ng-new-doc-parser-ctxt)
     (xmlRelaxParserSetFlag			xml-relax-parser-set-flag)
     (xmlRelaxNGFreeParserCtxt			xml-relax-ng-free-parser-ctxt)
     (xmlRelaxNGSetParserErrors			xml-relax-ng-set-parser-errors)
     (xmlRelaxNGGetParserErrors			xml-relax-ng-get-parser-errors)
     (xmlRelaxNGSetParserStructuredErrors	xml-relax-ng-set-parser-structured-errors)
     (xmlRelaxNGParse				xml-relax-ng-parse)
     (xmlRelaxNGFree				xml-relax-ng-free)
     (xmlRelaxNGDump				xml-relax-ng-dump)
     (xmlRelaxNGDumpTree			xml-relax-ng-dump-tree)
     (xmlRelaxNGSetValidErrors			xml-relax-ng-set-valid-errors)
     (xmlRelaxNGGetValidErrors			xml-relax-ng-get-valid-errors)
     (xmlRelaxNGSetValidStructuredErrors	xml-relax-ng-set-valid-structured-errors)
     (xmlRelaxNGNewValidCtxt			xml-relax-ng-new-valid-ctxt)
     (xmlRelaxNGFreeValidCtxt			xml-relax-ng-free-valid-ctxt)
     (xmlRelaxNGValidateDoc			xml-relax-ng-validate-doc)
     (xmlRelaxNGValidatePushElement		xml-relax-ng-validate-push-element)
     (xmlRelaxNGValidatePushCData		xml-relax-ng-validate-push-cdata)
     (xmlRelaxNGValidatePopElement		xml-relax-ng-validate-pop-element)
     (xmlRelaxNGValidateFullElement		xml-relax-ng-validate-full-element))

    ;; SAX2 parser interface used to build the DOM tree
    (rename
     (xmlSAX2GetPublicId			xml-sax2-get-public-id)
     (xmlSAX2GetSystemId			xml-sax2-get-system-id)
     (xmlSAX2SetDocumentLocator			xml-sax2-set-document-locator)
     (xmlSAX2GetLineNumber			xml-sax2-get-line-number)
     (xmlSAX2GetColumnNumber			xml-sax2-get-column-number)
     (xmlSAX2IsStandalone			xml-sax2-is-standalone)
     (xmlSAX2HasInternalSubset			xml-sax2-has-internal-subset)
     (xmlSAX2HasExternalSubset			xml-sax2-has-external-subset)
     (xmlSAX2InternalSubset			xml-sax2-internal-subset)
     (xmlSAX2ExternalSubset			xml-sax2-external-subset)
     (xmlSAX2GetEntity				xml-sax2-get-entity)
     (xmlSAX2GetParameterEntity			xml-sax2-get-parameter-entity)
     (xmlSAX2ResolveEntity			xml-sax2-resolve-entity)
     (xmlSAX2EntityDecl				xml-sax2-entity-decl)
     (xmlSAX2AttributeDecl			xml-sax2-attribute-decl)
     (xmlSAX2ElementDecl			xml-sax2-element-decl)
     (xmlSAX2NotationDecl			xml-sax2-notation-decl)
     (xmlSAX2UnparsedEntityDecl			xml-sax2-unparsed-entity-decl)
     (xmlSAX2StartDocument			xml-sax2-start-document)
     (xmlSAX2EndDocument			xml-sax2-end-document)
     (xmlSAX2StartElement			xml-sax2-start-element)
     (xmlSAX2EndElement				xml-sax2-end-element)
     (xmlSAX2StartElementNs			xml-sax2-start-element-ns)
     (xmlSAX2EndElementNs			xml-sax2-end-element-ns)
     (xmlSAX2Reference				xml-sax2-reference)
     (xmlSAX2Characters				xml-sax2-characters)
     (xmlSAX2IgnorableWhitespace		xml-sax2-ignorable-whitespace)
     (xmlSAX2ProcessingInstruction		xml-sax2-processing-instruction)
     (xmlSAX2Comment				xml-sax2-comment)
     (xmlSAX2CDataBlock				xml-sax2-cdata-block)
     (xmlSAXDefaultVersion			xml-sax-default-version)
     (xmlSAXVersion				xml-sax-version)
     (xmlSAX2InitDefaultSAXHandler		xml-sax2-init-default-sax-handler)
     (xmlSAX2InitHtmlDefaultSAXHandler		xml-sax2-init-html-default-sax-handler)
     (htmlDefaultSAXHandlerInit			html-default-sax-handler-init)
     (xmlSAX2InitDocbDefaultSAXHandler		xml-sax2-init-docb-default-sax-handler)
     (docbDefaultSAXHandlerInit			docb-default-sax-handler-init)
     (xmlDefaultSAXHandlerInit			xml-default-sax-handler-init))

    ;; XML Schematron implementation
    (rename
     (xmlSchematronNewParserCtxt		xml-schematron-new-parser-ctxt)
     (xmlSchematronNewMemParserCtxt		xml-schematron-new-mem-parser-ctxt)
     (xmlSchematronNewDocParserCtxt		xml-schematron-new-doc-parser-ctxt)
     (xmlSchematronFreeParserCtxt		xml-schematron-free-parser-ctxt)
;;; xmlSchematronSetParserErrors
;;; xmlSchematronGetParserErrors
;;; xmlSchematronIsValid
     (xmlSchematronParse			xml-schematron-parse)
     (xmlSchematronFree				xml-schematron-free)
     (xmlSchematronSetValidStructuredErrors	xml-schematron-set-valid-structured-errors)
;;;    xmlSchematronSetValidErrors
;;;    xmlSchematronGetValidErrors
;;;    xmlSchematronSetValidOptions
;;;    xmlSchematronValidCtxtGetOptions
;;;    xmlSchematronValidateOneElement
     (xmlSchematronNewValidCtxt			xml-schematron-new-valid-ctxt)
     (xmlSchematronFreeValidCtxt		xml-schematron-free-valid-ctxt)
     (xmlSchematronValidateDoc			xml-schematron-validate-doc))

    ;; interfaces for thread handling
    (rename
     (xmlNewMutex				xml-new-mutex)
     (xmlMutexLock				xml-mutex-lock)
     (xmlMutexUnlock				xml-mutex-unlock)
     (xmlFreeMutex				xml-free-mutex)
     (xmlNewRMutex				xml-new-rmutex)
     (xmlRMutexLock				xml-rmutex-lock)
     (xmlRMutexUnlock				xml-rmutex-unlock)
     (xmlFreeRMutex				xml-free-rmutex)
     (xmlInitThreads				xml-init-threads)
     (xmlLockLibrary				xml-lock-library)
     (xmlUnlockLibrary				xml-unlock-library)
     (xmlGetThreadId				xml-get-thread-id)
     (xmlIsMainThread				xml-is-main-thread)
     (xmlCleanupThreads				xml-cleanup-threads)
     (xmlGetGlobalState				xml-get-global-state))
;;;    xmlDllMain

    ;; interfaces for tree manipulation
    (rename
     (xmlValidateNCName				xml-validate-ncname)
     (xmlValidateQName				xml-validate-qname)
     (xmlValidateName				xml-validate-name)
     (xmlValidateNMToken			xml-validate-nmtoken)
     (xmlBuildQName				xml-build-qname)
     (xmlSplitQName2				xml-split-qname2)
     (xmlSplitQName3				xml-split-qname3)
     (xmlSetBufferAllocationScheme		xml-set-buffer-allocation-scheme)
     (xmlGetBufferAllocationScheme		xml-get-buffer-allocation-scheme)
     (xmlBufferCreate				xml-buffer-create)
     (xmlBufferCreateSize			xml-buffer-create-size)
     (xmlBufferCreateStatic			xml-buffer-create-static)
     (xmlBufferResize				xml-buffer-resize)
     (xmlBufferFree				xml-buffer-free)
     (xmlBufferDump				xml-buffer-dump)
     (xmlBufferAdd				xml-buffer-add)
     (xmlBufferAddHead				xml-buffer-add-head)
     (xmlBufferCat				xml-buffer-cat)
     (xmlBufferCCat				xml-buffer-ccat)
     (xmlBufferShrink				xml-buffer-shrink)
     (xmlBufferGrow				xml-buffer-grow)
     (xmlBufferEmpty				xml-buffer-empty)
     (xmlBufferContent				xml-buffer-content)
     (xmlBufferSetAllocationScheme		xml-buffer-set-allocation-scheme)
     (xmlBufferLength				xml-buffer-length)
     (xmlCreateIntSubset			xml-create-int-subset)
     (xmlNewDtd					xml-new-dtd)
     (xmlGetIntSubset				xml-get-int-subset)
     (xmlFreeDtd				xml-free-dtd)
     (xmlNewGlobalNs				xml-new-global-ns)
     (xmlNewNs					xml-new-ns)
     (xmlFreeNs					xml-free-ns)
     (xmlFreeNsList				xml-free-ns-list)
     (xmlNewDoc					xml-new-doc)
     (xmlFreeDoc				xml-free-doc)
     (xmlNewDocProp				xml-new-doc-prop)
     (xmlNewProp				xml-new-prop)
     (xmlNewNsProp				xml-new-ns-prop)
     (xmlNewNsPropEatName			xml-new-ns-prop-eat-name)
     (xmlFreePropList				xml-free-prop-list)
     (xmlFreeProp				xml-free-prop)
     (xmlCopyProp				xml-copy-prop)
     (xmlCopyPropList				xml-copy-prop-list)
     (xmlCopyDtd				xml-copy-dtd)
     (xmlCopyDoc				xml-copy-doc)
     (xmlNewDocNode				xml-new-doc-node)
     (xmlNewDocNodeEatName			xml-new-doc-node-eat-name)
     (xmlNewNode				xml-new-node)
     (xmlNewNodeEatName				xml-new-node-eat-name)
     (xmlNewChild				xml-new-child)
     (xmlNewDocText				xml-new-doc-text)
     (xmlNewText				xml-new-text)
     (xmlNewDocPI				xml-new-doc-pi)
     (xmlNewPI					xml-new-pi)
     (xmlNewDocTextLen				xml-new-doc-text-len)
     (xmlNewTextLen				xml-new-text-len)
     (xmlNewDocComment				xml-new-doc-comment)
     (xmlNewComment				xml-new-comment)
     (xmlNewCDataBlock				xml-new-cdata-block)
     (xmlNewCharRef				xml-new-char-ref)
     (xmlNewReference				xml-new-reference)
     (xmlCopyNode				xml-copy-node)
     (xmlDocCopyNode				xml-doc-copy-node)
     (xmlDocCopyNodeList			xml-doc-copy-node-list)
     (xmlCopyNodeList				xml-copy-node-list)
     (xmlNewTextChild				xml-new-text-child)
     (xmlNewDocRawNode				xml-new-doc-raw-node)
     (xmlNewDocFragment				xml-new-doc-fragment)
     (xmlGetLineNo				xml-get-line-no)
     (xmlGetNodePath				xml-get-node-path)
     (xmlDocGetRootElement			xml-doc-get-root-element)
     (xmlGetLastChild				xml-get-last-child)
     (xmlNodeIsText				xml-node-is-text)
     (xmlIsBlankNode				xml-is-blank-node)
     (xmlDocSetRootElement			xml-doc-set-root-element)
     (xmlNodeSetName				xml-node-set-name)
     (xmlAddChild				xml-add-child)
     (xmlAddChildList				xml-add-child-list)
     (xmlReplaceNode				xml-replace-node)
     (xmlAddPrevSibling				xml-add-prev-sibling)
     (xmlAddSibling				xml-add-sibling)
     (xmlAddNextSibling				xml-add-next-sibling)
     (xmlUnlinkNode				xml-unlink-node)
     (xmlTextMerge				xml-text-merge)
     (xmlTextConcat				xml-text-concat)
     (xmlFreeNodeList				xml-free-node-list)
     (xmlFreeNode				xml-free-node)
     (xmlSetTreeDoc				xml-set-tree-doc)
     (xmlSetListDoc				xml-set-list-doc)
     (xmlSearchNs				xml-search-ns)
     (xmlSearchNsByHref				xml-search-ns-by-href)
     (xmlGetNsList				xml-get-ns-list)
     (xmlSetNs					xml-set-ns)
     (xmlCopyNamespace				xml-copy-namespace)
     (xmlCopyNamespaceList			xml-copy-namespace-list)
     (xmlSetProp				xml-set-prop)
     (xmlSetNsProp				xml-set-ns-prop)
     (xmlGetNoNsProp				xml-get-no-ns-prop)
     (xmlGetProp				xml-get-prop)
     (xmlHasProp				xml-has-prop)
     (xmlHasNsProp				xml-has-ns-prop)
     (xmlGetNsProp				xml-get-ns-prop)
     (xmlStringGetNodeList			xml-string-get-node-list)
     (xmlStringLenGetNodeList			xml-string-len-get-node-list)
     (xmlNodeListGetString			xml-node-list-get-string)
     (xmlNodeListGetRawString			xml-node-list-get-raw-string)
     (xmlNodeSetContent				xml-node-set-content)
     (xmlNodeSetContentLen			xml-node-set-content-len)
     (xmlNodeAddContent				xml-node-add-content)
     (xmlNodeAddContentLen			xml-node-add-content-len)
     (xmlNodeGetContent				xml-node-get-content)
     (xmlNodeBufGetContent			xml-node-buf-get-content)
     (xmlNodeGetLang				xml-node-get-lang)
     (xmlNodeGetSpacePreserve			xml-node-get-space-preserve)
     (xmlNodeSetLang				xml-node-set-lang)
     (xmlNodeSetSpacePreserve			xml-node-set-space-preserve)
     (xmlNodeGetBase				xml-node-get-base)
     (xmlNodeSetBase				xml-node-set-base)
     (xmlRemoveProp				xml-remove-prop)
     (xmlUnsetNsProp				xml-unset-ns-prop)
     (xmlUnsetProp				xml-unset-prop)
     (xmlBufferWriteCHAR			xml-buffer-write-CHAR)
     (xmlBufferWriteChar			xml-buffer-write-char)
     (xmlBufferWriteQuotedString		xml-buffer-write-quoted-string)
     (xmlDocPtr					xml-doc-ptr)
     (xmlReconciliateNs				xml-reconciliate-ns)
     (xmlDocDumpFormatMemory			xml-doc-dump-format-memory)
     (xmlDocDumpMemory				xml-doc-dump-memory)
     (xmlDocDumpMemoryEnc			xml-doc-dump-memory-enc)
     (xmlDocDumpFormatMemoryEnc			xml-doc-dump-format-memory-enc)
     (xmlDocFormatDump				xml-doc-format-dump)
     (xmlDocDump				xml-doc-dump)
     (xmlElemDump				xml-elem-dump)
     (xmlSaveFile				xml-save-file)
     (xmlSaveFormatFile				xml-save-format-file)
     (xmlNodeDump				xml-node-dump)
     (xmlSaveFileTo				xml-save-file-to)
     (xmlSaveFormatFileTo			xml-save-format-file-to)
     (xmlNodeDumpOutput				xml-node-dump-output)
     (xmlSaveFormatFileEnc			xml-save-format-file-enc)
     (xmlSaveFileEnc				xml-save-file-enc)
     (xmlIsXHTML				xml-is-xhtml)
     (xmlGetDocCompressMode			xml-get-doc-compress-mode)
     (xmlSetDocCompressMode			xml-set-doc-compress-mode)
     (xmlGetCompressMode			xml-get-compress-mode)
     (xmlSetCompressMode			xml-set-compress-mode)
     (xmlDOMWrapNewCtxt				xml-dom-wrap-new-ctxt)
     (xmlDOMWrapFreeCtxt			xml-dom-wrap-free-ctxt)
     (xmlDOMWrapReconcileNamespaces		xml-dom-wrap-reconcile-namespaces)
     (xmlDOMWrapAdoptNode			xml-dom-wrap-adopt-node)
     (xmlDOMWrapRemoveNode			xml-dom-wrap-remove-node)
     (xmlDOMWrapCloneNode			xml-dom-wrap-clone-node)
     (xmlChildElementCount			xml-child-element-count)
     (xmlNextElementSibling			xml-next-element-sibling)
     (xmlFirstElementChild			xml-first-element-child)
     (xmlLastElementChild			xml-last-element-child)
     (xmlPreviousElementSibling			xml-previous-element-sibling))

    ;; library of generic URI related routines
    (rename
     (xmlCreateURI				xml-create-uri)
     (xmlBuildURI				xml-build-uri)
     (xmlBuildRelativeURI			xml-build-relative-uri)
     (xmlParseURI				xml-parse-uri)
     (xmlParseURIRaw				xml-parse-uri-raw)
     (xmlParseURIReference			xml-parse-uri-reference)
     (xmlSaveUri				xml-save-uri)
     (xmlPrintURI				xml-print-uri)
     (xmlURIEscapeStr				xml-uri-escape-str)
     (xmlURIUnescapeString			xml-uri-unescape-string)
     (xmlNormalizeURIPath			xml-normalize-uri-path)
     (xmlURIEscape				xml-uri-escape)
     (xmlFreeURI				xml-free-uri)
     (xmlCanonicPath				xml-canonic-path)
     (xmlPathToURI				xml-path-to-uri))

    ;; The DTD validation
    (rename
     (xmlAddNotationDecl			xml-add-notation-decl)
     (xmlCopyNotationTable			xml-copy-notation-table)
     (xmlFreeNotationTable			xml-free-notation-table)
     (xmlDumpNotationDecl			xml-dump-notation-decl)
     (xmlDumpNotationTable			xml-dump-notation-table)
     (xmlNewElementContent			xml-new-element-content)
     (xmlCopyElementContent			xml-copy-element-content)
     (xmlFreeElementContent			xml-free-element-content)
     (xmlNewDocElementContent			xml-new-doc-element-content)
     (xmlCopyDocElementContent			xml-copy-doc-element-content)
     (xmlFreeDocElementContent			xml-free-doc-element-content)
     (xmlSnprintfElementContent			xml-snprintf-element-content)
     (xmlSprintfElementContent			xml-sprintf-element-content)
     (xmlAddElementDecl				xml-add-element-decl)
     (xmlCopyElementTable			xml-copy-element-table)
     (xmlFreeElementTable			xml-free-element-table)
     (xmlDumpElementTable			xml-dump-element-table)
     (xmlDumpElementDecl			xml-dump-element-decl)
     (xmlCreateEnumeration			xml-create-enumeration)
     (xmlFreeEnumeration			xml-free-enumeration)
     (xmlCopyEnumeration			xml-copy-enumeration)
     (xmlAddAttributeDecl			xml-add-attribute-decl)
     (xmlCopyAttributeTable			xml-copy-attribute-table)
     (xmlFreeAttributeTable			xml-free-attribute-table)
     (xmlDumpAttributeTable			xml-dump-attribute-table)
     (xmlDumpAttributeDecl			xml-dump-attribute-decl)
     (xmlAddID					xml-add-id)
     (xmlFreeIDTable				xml-free-id-table)
     (xmlGetID					xml-get-id)
     (xmlIsID					xml-is-id)
     (xmlRemoveID				xml-remove-id)
     (xmlAddRef					xml-add-ref)
     (xmlFreeRefTable				xml-free-ref-table)
     (xmlIsRef					xml-is-ref)
     (xmlRemoveRef				xml-remove-ref)
     (xmlGetRefs				xml-get-refs)
     (xmlNewValidCtxt				xml-new-valid-ctxt)
     (xmlFreeValidCtxt				xml-free-valid-ctxt)
     (xmlValidateRoot				xml-validate-root)
     (xmlValidateElementDecl			xml-validate-element-decl)
     (xmlValidNormalizeAttributeValue		xml-valid-normalize-attribute-value)
     (xmlValidCtxtNormalizeAttributeValue	xml-valid-ctxt-normalize-attribute-value)
     (xmlValidateAttributeDecl			xml-validate-attribute-decl)
     (xmlValidateAttributeValue			xml-validate-attribute-value)
     (xmlValidateNotationDecl			xml-validate-notation-decl)
     (xmlValidateDtd				xml-validate-dtd)
     (xmlValidateDtdFinal			xml-validate-dtd-final)
     (xmlValidateDocument			xml-validate-document)
     (xmlValidateElement			xml-validate-element)
     (xmlValidateOneElement			xml-validate-one-element)
     (xmlValidateOneAttribute			xml-validate-one-attribute)
     (xmlValidateOneNamespace			xml-validate-one-namespace)
     (xmlValidateDocumentFinal			xml-validate-document-final)
     (xmlValidateNotationUse			xml-validate-notation-use)
     (xmlIsMixedElement				xml-is-mixed-element)
     (xmlGetDtdAttrDesc				xml-get-dtd-attr-desc)
     (xmlGetDtdQAttrDesc			xml-get-dtd-qattr-desc)
     (xmlGetDtdNotationDesc			xml-get-dtd-notation-desc)
     (xmlGetDtdQElementDesc			xml-get-dtd-qelement-desc)
     (xmlGetDtdElementDesc			xml-get-dtd-element-desc)
     (xmlValidGetPotentialChildren		xml-valid-get-potential-children)
     (xmlValidGetValidElements			xml-valid-get-valid-elements)
     (xmlValidateNameValue			xml-validate-name-value)
     (xmlValidateNamesValue			xml-validate-names-value)
     (xmlValidateNmtokenValue			xml-validate-nmtoken-value)
     (xmlValidateNmtokensValue			xml-validate-nmtokens-value)
     (xmlValidBuildContentModel			xml-valid-build-content-model)
     (xmlValidatePushElement			xml-validate-push-element)
     (xmlValidatePushCData			xml-validate-push-cdata)
     (xmlValidatePopElement			xml-validate-pop-element))

    ;; implementation of XInclude
    (rename
     (xmlXIncludeProcess			xml-xinclude-process)
     (xmlXIncludeProcessFlags			xml-xinclude-process-flags)
     (xmlXIncludeProcessFlagsData		xml-xinclude-process-flags-data)
     (xmlXIncludeProcessTreeFlagsData		xml-xinclude-process-tree-flags-data)
     (xmlXIncludeProcessTree			xml-xinclude-process-tree)
     (xmlXIncludeProcessTreeFlags		xml-xinclude-process-tree-flags)
     (xmlXIncludeNewContext			xml-xinclude-new-context)
     (xmlXIncludeSetFlags			xml-xinclude-set-flags)
     (xmlXIncludeFreeContext			xml-xinclude-free-context)
     (xmlXIncludeProcessNode			xml-xinclude-process-node))

    ;; API to build regexp automata
    (rename
     (xmlNewAutomata				xml-new-automata)
     (xmlFreeAutomata				xml-free-automata)
     (xmlAutomataGetInitState			xml-automata-get-init-state)
     (xmlAutomataSetFinalState			xml-automata-set-final-state)
     (xmlAutomataNewState			xml-automata-new-state)
     (xmlAutomataNewTransition			xml-automata-new-transition)
     (xmlAutomataNewTransition2			xml-automata-new-transition2)
     (xmlAutomataNewNegTrans			xml-automata-new-neg-trans)
     (xmlAutomataNewCountTrans			xml-automata-new-count-trans)
     (xmlAutomataNewCountTrans2			xml-automata-new-count-trans2)
     (xmlAutomataNewOnceTrans			xml-automata-new-once-trans)
     (xmlAutomataNewOnceTrans2			xml-automata-new-once-trans2)
     (xmlAutomataNewAllTrans			xml-automata-new-all-trans)
     (xmlAutomataNewEpsilon			xml-automata-new-epsilon)
     (xmlAutomataNewCountedTrans		xml-automata-new-counted-trans)
     (xmlAutomataNewCounterTrans		xml-automata-new-counter-trans)
     (xmlAutomataNewCounter			xml-automata-new-counter)
     (xmlAutomataCompile			xml-automata-compile)
     (xmlAutomataIsDeterminist			xml-automata-is-determinist))

    ;; error handling
    (rename
     (xmlSetGenericErrorFunc			xml-set-generic-error-func)
     (initGenericErrorDefaultFunc		init-generic-error-default-func)
     (xmlSetStructuredErrorFunc			xml-set-structured-error-func)
     (xmlParserPrintFileInfo			xml-parser-print-file-info)
     (xmlParserPrintFileContext			xml-parser-print-file-context)
     (xmlGetLastError				xml-get-last-error)
     (xmlResetLastError				xml-reset-last-error)
     (xmlCtxtGetLastError			xml-ctxt-get-last-error)
     (xmlCtxtResetLastError			xml-ctxt-reset-last-error)
     (xmlResetError				xml-reset-error)
     (xmlCopyError				xml-copy-error))

    ;; interface for the I/O interfaces used by the parser
    (rename
     (xmlCleanupInputCallbacks			xml-cleanup-input-callbacks)
     (xmlPopInputCallbacks			xml-pop-input-callbacks)
     (xmlRegisterDefaultInputCallbacks		xml-register-default-input-callbacks)
     (xmlAllocParserInputBuffer			xml-alloc-parser-input-buffer)
     (xmlParserInputBufferCreateFilename	xml-parser-input-buffer-create-filename)
     (xmlParserInputBufferCreateFile		xml-parser-input-buffer-create-file)
     (xmlParserInputBufferCreateFd		xml-parser-input-buffer-create-fd)
     (xmlParserInputBufferCreateMem		xml-parser-input-buffer-create-mem)
     (xmlParserInputBufferCreateStatic		xml-parser-input-buffer-create-static)
     (xmlParserInputBufferCreateIO		xml-parser-input-buffer-create-io)
     (xmlParserInputBufferRead			xml-parser-input-buffer-read)
     (xmlParserInputBufferGrow			xml-parser-input-buffer-grow)
     (xmlParserInputBufferPush			xml-parser-input-buffer-push)
     (xmlFreeParserInputBuffer			xml-free-parser-input-buffer)
     (xmlParserGetDirectory			xml-parser-get-directory)
     (xmlRegisterInputCallbacks			xml-register-input-callbacks)
     (__xmlParserInputBufferCreateFilename	__xml-parser-input-buffer-create-filename)
     (xmlCleanupOutputCallbacks			xml-cleanup-output-callbacks)
     (xmlRegisterDefaultOutputCallbacks		xml-register-default-output-callbacks)
     (xmlAllocOutputBuffer			xml-alloc-output-buffer)
     (xmlOutputBufferCreateFilename		xml-output-buffer-create-filename)
     (xmlOutputBufferCreateFile			xml-output-buffer-create-file)
     (xmlOutputBufferCreateBuffer		xml-output-buffer-create-buffer)
     (xmlOutputBufferCreateFd			xml-output-buffer-create-fd)
     (xmlOutputBufferCreateIO			xml-output-buffer-create-io)
     (xmlOutputBufferWrite			xml-output-buffer-write)
     (xmlOutputBufferWriteString		xml-output-buffer-write-string)
     (xmlOutputBufferWriteEscape		xml-output-buffer-write-escape)
     (xmlOutputBufferFlush			xml-output-buffer-flush)
     (xmlOutputBufferClose			xml-output-buffer-close)
     (xmlRegisterOutputCallbacks		xml-register-output-callbacks)
     (__xmlOutputBufferCreateFilename		__xml-output-buffer-create-filename)
     (xmlRegisterHTTPPostCallbacks		xml-register-http-post-callbacks)
     (xmlCheckHTTPInput				xml-check-http-input)
     (xmlNoNetExternalEntityLoader		xml-no-net-external-entity-loader)
     (xmlNormalizeWindowsPath			xml-normalize-windows-path)
     (xmlCheckFilename				xml-check-filename)
     (xmlFileMatch				xml-file-match)
     (xmlFileOpen				xml-file-open)
     (xmlFileRead				xml-file-read)
     (xmlFileClose				xml-file-close)
     (xmlIOHTTPMatch				xml-io-http-match)
     (xmlIOHTTPOpen				xml-io-http-open)
     (xmlIOHTTPOpenW				xml-io-http-open-w)
     (xmlIOHTTPRead				xml-io-http-read)
     (xmlIOHTTPClose				xml-io-http-close)
     (xmlIOFTPMatch				xml-io-ftp-match)
     (xmlIOFTPOpen				xml-io-ftp-open)
     (xmlIOFTPRead				xml-io-ftp-read)
     (xmlIOFTPClose				xml-io-ftp-close))

    ;; interface for the memory allocator
    (rename
     (xmlMemSetup				xml-mem-setup)
     (xmlMemGet					xml-mem-get)
     (xmlGcMemSetup				xml-gc-mem-setup)
     (xmlGcMemGet				xml-gc-mem-get)
     (xmlInitMemory				xml-init-memory)
     (xmlCleanupMemory				xml-cleanup-memory)
     (xmlMemUsed				xml-mem-used)
     (xmlMemBlocks				xml-mem-blocks)
     (xmlMemDisplay				xml-mem-display)
     (xmlMemDisplayLast				xml-mem-display-last)
     (xmlMemShow				xml-mem-show)
     (xmlMemoryDump				xml-memory-dump)
     (xmlMemMalloc				xml-mem-malloc)
     (xmlMemRealloc				xml-mem-realloc)
     (xmlMemFree				xml-mem-free)
     (xmlMemoryStrdup				xml-memory-strdup)
     (xmlMallocLoc				xml-malloc-loc)
     (xmlReallocLoc				xml-realloc-loc)
     (xmlMallocAtomicLoc			xml-malloc-atomic-loc)
     (xmlMemStrdupLoc				xml-mem-strdup-loc))

    ;; dynamic module loading
    (rename
     (xmlModuleOpen				xml-module-open)
     (xmlModuleSymbol				xml-module-symbol)
     (xmlModuleClose				xml-module-close)
     (xmlModuleFree				xml-module-free))

    ;; the XMLReader implementation
    (rename
     (xmlNewTextReader				xml-new-text-reader)
     (xmlNewTextReaderFilename			xml-new-text-reader-filename)
     (xmlFreeTextReader				xml-free-text-reader)
     (xmlTextReaderSetup			xml-text-reader-setup)
     (xmlTextReaderRead				xml-text-reader-read)
     (xmlTextReaderReadInnerXml			xml-text-reader-read-inner-xml)
     (xmlTextReaderReadOuterXml			xml-text-reader-read-outer-xml)
     (xmlTextReaderReadString			xml-text-reader-read-string)
     (xmlTextReaderReadAttributeValue		xml-text-reader-read-attribute-value)
     (xmlTextReaderAttributeCount		xml-text-reader-attribute-count)
     (xmlTextReaderDepth			xml-text-reader-depth)
     (xmlTextReaderHasAttributes		xml-text-reader-has-attributes)
     (xmlTextReaderHasValue			xml-text-reader-has-value)
     (xmlTextReaderIsDefault			xml-text-reader-is-default)
     (xmlTextReaderIsEmptyElement		xml-text-reader-is-empty-element)
     (xmlTextReaderNodeType			xml-text-reader-node-type)
     (xmlTextReaderQuoteChar			xml-text-reader-quote-char)
     (xmlTextReaderReadState			xml-text-reader-read-state)
     (xmlTextReaderIsNamespaceDecl		xml-text-reader-is-namespace-decl)
     (xmlTextReaderConstBaseUri			xml-text-reader-const-base-uri)
     (xmlTextReaderConstLocalName		xml-text-reader-const-local-name)
     (xmlTextReaderConstName			xml-text-reader-const-name)
     (xmlTextReaderConstNamespaceUri		xml-text-reader-const-namespace-uri)
     (xmlTextReaderConstPrefix			xml-text-reader-const-prefix)
     (xmlTextReaderConstXmlLang			xml-text-reader-const-xml-lang)
     (xmlTextReaderConstString			xml-text-reader-const-string)
     (xmlTextReaderConstValue			xml-text-reader-const-value)
     (xmlTextReaderBaseUri			xml-text-reader-base-uri)
     (xmlTextReaderLocalName			xml-text-reader-local-name)
     (xmlTextReaderName				xml-text-reader-name)
     (xmlTextReaderNamespaceUri			xml-text-reader-namespace-uri)
     (xmlTextReaderPrefix			xml-text-reader-prefix)
     (xmlTextReaderXmlLang			xml-text-reader-xml-lang)
     (xmlTextReaderValue			xml-text-reader-value)
     (xmlTextReaderClose			xml-text-reader-close)
     (xmlTextReaderGetAttributeNo		xml-text-reader-get-attribute-no)
     (xmlTextReaderGetAttribute			xml-text-reader-get-attribute)
     (xmlTextReaderGetAttributeNs		xml-text-reader-get-attribute-ns)
     (xmlTextReaderGetRemainder			xml-text-reader-get-remainder)
     (xmlTextReaderLookupNamespace		xml-text-reader-lookup-namespace)
     (xmlTextReaderMoveToAttributeNo		xml-text-reader-move-to-attribute-no)
     (xmlTextReaderMoveToAttribute		xml-text-reader-move-to-attribute)
     (xmlTextReaderMoveToAttributeNs		xml-text-reader-move-to-attribute-ns)
     (xmlTextReaderMoveToFirstAttribute		xml-text-reader-move-to-first-attribute)
     (xmlTextReaderMoveToNextAttribute		xml-text-reader-move-to-next-attribute)
     (xmlTextReaderMoveToElement		xml-text-reader-move-to-element)
     (xmlTextReaderNormalization		xml-text-reader-normalization)
     (xmlTextReaderConstEncoding		xml-text-reader-const-encoding)
     (xmlTextReaderSetParserProp		xml-text-reader-set-parser-prop)
     (xmlTextReaderGetParserProp		xml-text-reader-get-parser-prop)
     (xmlTextReaderCurrentNode			xml-text-reader-current-node)
     (xmlTextReaderGetParserLineNumber		xml-text-reader-get-parser-line-number)
     (xmlTextReaderGetParserColumnNumber	xml-text-reader-get-parser-column-number)
     (xmlTextReaderPreserve			xml-text-reader-preserve)
     (xmlTextReaderPreservePattern		xml-text-reader-preserve-pattern)
     (xmlTextReaderCurrentDoc			xml-text-reader-current-doc)
     (xmlTextReaderExpand			xml-text-reader-expand)
     (xmlTextReaderNext				xml-text-reader-next)
     (xmlTextReaderNextSibling			xml-text-reader-next-sibling)
     (xmlTextReaderIsValid			xml-text-reader-is-valid)
     (xmlTextReaderRelaxNGValidate		xml-text-reader-relax-ng-validate)
     (xmlTextReaderRelaxNGSetSchema		xml-text-reader-relax-ng-set-schema)
     (xmlTextReaderSchemaValidate		xml-text-reader-schema-validate)
     (xmlTextReaderSchemaValidateCtxt		xml-text-reader-schema-validate-ctxt)
     (xmlTextReaderSetSchema			xml-text-reader-set-schema)
     (xmlTextReaderConstXmlVersion		xml-text-reader-const-xml-version)
     (xmlTextReaderStandalone			xml-text-reader-standalone)
     (xmlTextReaderByteConsumed			xml-text-reader-byte-consumed)
     (xmlReaderWalker				xml-reader-walker)
     (xmlReaderForDoc				xml-reader-for-doc)
     (xmlReaderForFile				xml-reader-for-file)
     (xmlReaderForMemory			xml-reader-for-memory)
     (xmlReaderForFd				xml-reader-for-fd)
     (xmlReaderForIO				xml-reader-for-io)
     (xmlReaderNewWalker			xml-reader-new-walker)
     (xmlReaderNewDoc				xml-reader-new-doc)
     (xmlReaderNewFile				xml-reader-new-file)
     (xmlReaderNewMemory			xml-reader-new-memory)
     (xmlReaderNewFd				xml-reader-new-fd)
     (xmlReaderNewIO				xml-reader-new-io)
     (xmlTextReaderLocatorLineNumber		xml-text-reader-locator-line-number)
     (xmlTextReaderLocatorBaseURI		xml-text-reader-locator-base-uri)
     (xmlTextReaderSetErrorHandler		xml-text-reader-set-error-handler)
     (xmlTextReaderSetStructuredErrorHandler	xml-text-reader-set-structured-error-handler)
     (xmlTextReaderGetErrorHandler		xml-text-reader-get-error-handler))

    ;; regular expressions handling
    (rename
     (xmlRegexpCompile				xml-regexp-compile)
     (xmlRegFreeRegexp				xml-reg-free-regexp)
     (xmlRegexpExec				xml-regexp-exec)
     (xmlRegexpPrint				xml-regexp-print)
     (xmlRegexpIsDeterminist			xml-regexp-is-determinist)
     (xmlRegNewExecCtxt				xml-reg-new-exec-ctxt)
     (xmlRegFreeExecCtxt			xml-reg-free-exec-ctxt)
     (xmlRegExecPushString			xml-reg-exec-push-string)
     (xmlRegExecPushString2			xml-reg-exec-push-string2)
     (xmlRegExecNextValues			xml-reg-exec-next-values)
     (xmlRegExecErrInfo				xml-reg-exec-err-info)
     (xmlExpFreeCtxt				xml-exp-free-ctxt)
     (xmlExpNewCtxt				xml-exp-new-ctxt)
     (xmlExpCtxtNbNodes				xml-exp-ctxt-nb-nodes)
     (xmlExpCtxtNbCons				xml-exp-ctxt-nb-cons)
     (xmlExpFree				xml-exp-free)
     (xmlExpRef					xml-exp-ref)
     (xmlExpParse				xml-exp-parse)
     (xmlExpNewAtom				xml-exp-new-atom)
     (xmlExpNewOr				xml-exp-new-or)
     (xmlExpNewSeq				xml-exp-new-seq)
     (xmlExpNewRange				xml-exp-new-range)
     (xmlExpIsNillable				xml-exp-is-nillable)
     (xmlExpMaxToken				xml-exp-max-token)
     (xmlExpGetLanguage				xml-exp-get-language)
     (xmlExpGetStart				xml-exp-get-start)
     (xmlExpStringDerive			xml-exp-string-derive)
     (xmlExpExpDerive				xml-exp-exp-derive)
     (xmlExpSubsume				xml-exp-subsume)
     (xmlExpDump				xml-exp-dump))

    ;; the xml document serializer
    (rename
     (xmlSaveToFd				xml-save-to-fd)
     (xmlSaveToFilename				xml-save-to-filename)
     (xmlSaveToBuffer				xml-save-to-buffer)
     (xmlSaveToIO				xml-save-to-io)
     (xmlSaveDoc				xml-save-doc)
     (xmlSaveTree				xml-save-tree)
     (xmlSaveFlush				xml-save-flush)
     (xmlSaveClose				xml-save-close)
     (xmlSaveSetEscape				xml-save-set-escape)
     (xmlSaveSetAttrEscape			xml-save-set-attr-escape))

    ;; internal interfaces for XML Schemas
    (rename
     (xmlSchemaFreeType				xml-schema-free-type)
     (xmlSchemaFreeWildcard			xml-schema-free-wildcard))

    ;; incomplete XML Schemas structure implementation
    (rename
     (xmlSchemaNewParserCtxt			xml-schema-new-parser-ctxt)
     (xmlSchemaNewMemParserCtxt			xml-schema-new-mem-parser-ctxt)
     (xmlSchemaNewDocParserCtxt			xml-schema-new-doc-parser-ctxt)
     (xmlSchemaFreeParserCtxt			xml-schema-free-parser-ctxt)
     (xmlSchemaSetParserErrors			xml-schema-set-parser-errors)
     (xmlSchemaSetParserStructuredErrors	xml-schema-set-parser-structured-errors)
     (xmlSchemaGetParserErrors			xml-schema-get-parser-errors)
     (xmlSchemaIsValid				xml-schema-is-valid)
     (xmlSchemaParse				xml-schema-parse)
     (xmlSchemaFree				xml-schema-free)
     (xmlSchemaDump				xml-schema-dump)
     (xmlSchemaSetValidErrors			xml-schema-set-valid-errors)
     (xmlSchemaSetValidStructuredErrors		xml-schema-set-valid-structured-errors)
     (xmlSchemaGetValidErrors			xml-schema-get-valid-errors)
     (xmlSchemaSetValidOptions			xml-schema-set-valid-options)
     (xmlSchemaValidCtxtGetOptions		xml-schema-valid-ctxt-get-options)
     (xmlSchemaNewValidCtxt			xml-schema-new-valid-ctxt)
     (xmlSchemaFreeValidCtxt			xml-schema-free-valid-ctxt)
     (xmlSchemaValidateDoc			xml-schema-validate-doc)
     (xmlSchemaValidateOneElement		xml-schema-validate-one-element)
     (xmlSchemaValidateStream			xml-schema-validate-stream)
     (xmlSchemaValidateFile			xml-schema-validate-file)
     (xmlSchemaValidCtxtGetParserCtxt		xml-schema-valid-ctxt-get-parser-ctxt)
     (xmlSchemaSAXPlug				xml-schema-sax-plug)
     (xmlSchemaSAXUnplug			xml-schema-sax-unplug))

    ;; implementation of XML Schema Datatypes
    (rename
     (xmlSchemaInitTypes			xml-schema-init-types)
     (xmlSchemaCleanupTypes			xml-schema-cleanup-types)
     (xmlSchemaGetPredefinedType		xml-schema-get-predefined-type)
     (xmlSchemaValidatePredefinedType		xml-schema-validate-predefined-type)
     (xmlSchemaValPredefTypeNode		xml-schema-val-predef-type-node)
     (xmlSchemaValidateFacet			xml-schema-validate-facet)
     (xmlSchemaValidateFacetWhtsp		xml-schema-validate-facet-whtsp)
     (xmlSchemaFreeValue			xml-schema-free-value)
     (xmlSchemaNewFacet				xml-schema-new-facet)
     (xmlSchemaCheckFacet			xml-schema-check-facet)
     (xmlSchemaFreeFacet			xml-schema-free-facet)
     (xmlSchemaCompareValues			xml-schema-compare-values)
     (xmlSchemaGetBuiltInListSimpleTypeItemType	xml-schema-get-built-in-list-simple-type-item-Type)
     (xmlSchemaValidateListSimpleTypeFacet	xml-schema-validate-list-simple-type-facet)
     (xmlSchemaGetBuiltInType			xml-schema-get-built-in-type)
     (xmlSchemaIsBuiltInTypeFacet		xml-schema-is-built-in-type-facet)
     (xmlSchemaCollapseString			xml-schema-collapse-string)
     (xmlSchemaWhiteSpaceReplace		xml-schema-white-space-replace)
     (xmlSchemaGetFacetValueAsULong		xml-schema-get-facet-value-as-u-long)
     (xmlSchemaValidateLengthFacet		xml-schema-validate-length-facet)
     (xmlSchemaValidateLengthFacetWhtsp		xml-schema-validate-length-facet-whtsp)
     (xmlSchemaValPredefTypeNodeNoNorm		xml-schema-val-predef-type-node-no-norm)
     (xmlSchemaGetCanonValue			xml-schema-get-canon-value)
     (xmlSchemaGetCanonValueWhtsp		xml-schema-get-canon-value-whtsp)
     (xmlSchemaValueAppend			xml-schema-value-append)
     (xmlSchemaValueGetNext			xml-schema-value-get-next)
     (xmlSchemaValueGetAsString			xml-schema-value-get-as-string)
     (xmlSchemaValueGetAsBoolean		xml-schema-value-get-as-boolean)
     (xmlSchemaNewStringValue			xml-schema-new-string-value)
     (xmlSchemaNewNOTATIONValue			xml-schema-new-notation-value)
     (xmlSchemaNewQNameValue			xml-schema-new-qname-value)
     (xmlSchemaCompareValuesWhtsp		xml-schema-compare-values-whtsp)
     (xmlSchemaCopyValue			xml-schema-copy-value)
     (xmlSchemaGetValType			xml-schema-get-val-type))

    ;; set of routines to process strings
    (rename
     (xmlStrdup					xml-strdup)
     (xmlStrndup				xml-strndup)
     (xmlCharStrndup				xml-char-strndup)
     (xmlCharStrdup				xml-char-strdup)
     (xmlStrsub					xml-strsub)
     (xmlStrchr					xml-strchr)
     (xmlStrstr					xml-strstr)
     (xmlStrcasestr				xml-strcasestr)
     (xmlStrcmp					xml-strcmp)
     (xmlStrncmp				xml-strncmp)
     (xmlStrcasecmp				xml-strcasecmp)
     (xmlStrncasecmp				xml-strncasecmp)
     (xmlStrEqual				xml-str-equal)
     (xmlStrQEqual				xml-str-qequal)
     (xmlStrlen					xml-strlen)
     (xmlStrcat					xml-strcat)
     (xmlStrncat				xml-strncat)
     (xmlStrncatNew				xml-strncat-new)
     (xmlGetUTF8Char				xml-get-utf8-char)
     (xmlCheckUTF8				xml-check-utf8)
     (xmlUTF8Strsize				xml-utf8-strsize)
     (xmlUTF8Strndup				xml-utf8-strndup)
     (xmlUTF8Strpos				xml-utf8-strpos)
     (xmlUTF8Strloc				xml-utf8-strloc)
     (xmlUTF8Strsub				xml-utf8-strsub)
     (xmlUTF8Strlen				xml-utf8-strlen)
     (xmlUTF8Size				xml-utf8-size)
     (xmlUTF8Charcmp				xml-utf8-charcmp))

    ;; Unicode character APIs
    (rename
     (xmlUCSIsAegeanNumbers				xml-ucs-is-aegean-numbers)
     (xmlUCSIsAlphabeticPresentationForms		xml-ucs-is-alphabetic-presentation-forms)
     (xmlUCSIsArabic					xml-ucs-is-arabic)
     (xmlUCSIsArabicPresentationFormsA			xml-ucs-is-arabic-presentation-forms-a)
     (xmlUCSIsArabicPresentationFormsB			xml-ucs-is-arabic-presentation-forms-b)
     (xmlUCSIsArmenian					xml-ucs-is-armenian)
     (xmlUCSIsArrows					xml-ucs-is-arrows)
     (xmlUCSIsBasicLatin				xml-ucs-is-basic-latin)
     (xmlUCSIsBengali					xml-ucs-is-bengali)
     (xmlUCSIsBlockElements				xml-ucs-is-block-elements)
     (xmlUCSIsBopomofo					xml-ucs-is-bopomofo)
     (xmlUCSIsBopomofoExtended				xml-ucs-is-bopomofo-extended)
     (xmlUCSIsBoxDrawing				xml-ucs-is-box-drawing)
     (xmlUCSIsBraillePatterns				xml-ucs-is-braille-patterns)
     (xmlUCSIsBuhid					xml-ucs-is-buhid)
     (xmlUCSIsByzantineMusicalSymbols			xml-ucs-is-byzantine-musical-symbols)
     (xmlUCSIsCJKCompatibility				xml-ucs-is-cjk-compatibility)
     (xmlUCSIsCJKCompatibilityForms			xml-ucs-is-cjk-compatibility-forms)
     (xmlUCSIsCJKCompatibilityIdeographs		xml-ucs-is-cjk-compatibility-ideographs)
     (xmlUCSIsCJKCompatibilityIdeographsSupplement	xml-ucs-is-cjk-compatibility-ideographs-supplement)
     (xmlUCSIsCJKRadicalsSupplement			xml-ucs-is-cjk-radicals-supplement)
     (xmlUCSIsCJKSymbolsandPunctuation			xml-ucs-is-cjk-symbolsand-punctuation)
     (xmlUCSIsCJKUnifiedIdeographs			xml-ucs-is-cjk-unified-ideographs)
     (xmlUCSIsCJKUnifiedIdeographsExtensionA		xml-ucs-is-cjk-unified-ideographs-extension-a)
     (xmlUCSIsCJKUnifiedIdeographsExtensionB		xml-ucs-is-cjk-unified-ideographs-extension-b)
     (xmlUCSIsCherokee					xml-ucs-is-cherokee)
     (xmlUCSIsCombiningDiacriticalMarks			xml-ucs-is-combining-diacritical-marks)
     (xmlUCSIsCombiningDiacriticalMarksforSymbols	xml-ucs-is-combining-diacritical-marksfor-symbols)
     (xmlUCSIsCombiningHalfMarks			xml-ucs-is-combining-half-marks)
     (xmlUCSIsCombiningMarksforSymbols			xml-ucs-is-combining-marksfor-symbols)
     (xmlUCSIsControlPictures				xml-ucs-is-control-pictures)
     (xmlUCSIsCurrencySymbols				xml-ucs-is-currency-symbols)
     (xmlUCSIsCypriotSyllabary				xml-ucs-is-cypriot-syllabary)
     (xmlUCSIsCyrillic					xml-ucs-is-cyrillic)
     (xmlUCSIsCyrillicSupplement			xml-ucs-is-cyrillic-supplement)
     (xmlUCSIsDeseret					xml-ucs-is-deseret)
     (xmlUCSIsDevanagari				xml-ucs-is-devanagari)
     (xmlUCSIsDingbats					xml-ucs-is-dingbats)
     (xmlUCSIsEnclosedAlphanumerics			xml-ucs-is-enclosed-alphanumerics)
     (xmlUCSIsEnclosedCJKLettersandMonths		xml-ucs-is-enclosed-cjk-lettersand-months)
     (xmlUCSIsEthiopic					xml-ucs-is-ethiopic)
     (xmlUCSIsGeneralPunctuation			xml-ucs-is-general-punctuation)
     (xmlUCSIsGeometricShapes				xml-ucs-is-geometric-shapes)
     (xmlUCSIsGeorgian					xml-ucs-is-georgian)
     (xmlUCSIsGothic					xml-ucs-is-gothic)
     (xmlUCSIsGreek					xml-ucs-is-greek)
     (xmlUCSIsGreekExtended				xml-ucs-is-greek-extended)
     (xmlUCSIsGreekandCoptic				xml-ucs-is-greekand-coptic)
     (xmlUCSIsGujarati					xml-ucs-is-gujarati)
     (xmlUCSIsGurmukhi					xml-ucs-is-gurmukhi)
     (xmlUCSIsHalfwidthandFullwidthForms		xml-ucs-is-halfwidthand-fullwidth-forms)
     (xmlUCSIsHangulCompatibilityJamo			xml-ucs-is-hangul-compatibility-jamo)
     (xmlUCSIsHangulJamo				xml-ucs-is-hangul-jamo)
     (xmlUCSIsHangulSyllables				xml-ucs-is-hangul-syllables)
     (xmlUCSIsHanunoo					xml-ucs-is-hanunoo)
     (xmlUCSIsHebrew					xml-ucs-is-hebrew)
     (xmlUCSIsHighPrivateUseSurrogates			xml-ucs-is-high-private-use-surrogates)
     (xmlUCSIsHighSurrogates				xml-ucs-is-high-surrogates)
     (xmlUCSIsHiragana					xml-ucs-is-hiragana)
     (xmlUCSIsIPAExtensions				xml-ucs-is-ipa-extensions)
     (xmlUCSIsIdeographicDescriptionCharacters		xml-ucs-is-ideographic-description-characters)
     (xmlUCSIsKanbun					xml-ucs-is-kanbun)
     (xmlUCSIsKangxiRadicals				xml-ucs-is-kangxi-radicals)
     (xmlUCSIsKannada					xml-ucs-is-kannada)
     (xmlUCSIsKatakana					xml-ucs-is-katakana)
     (xmlUCSIsKatakanaPhoneticExtensions		xml-ucs-is-katakana-phonetic-extensions)
     (xmlUCSIsKhmer					xml-ucs-is-khmer)
     (xmlUCSIsKhmerSymbols				xml-ucs-is-khmer-symbols)
     (xmlUCSIsLao					xml-ucs-is-lao)
     (xmlUCSIsLatin1Supplement				xml-ucs-is-latin1-supplement)
     (xmlUCSIsLatinExtendedA				xml-ucs-is-latin-extended-a)
     (xmlUCSIsLatinExtendedB				xml-ucs-is-latin-extended-b)
     (xmlUCSIsLatinExtendedAdditional			xml-ucs-is-latin-extended-additional)
     (xmlUCSIsLetterlikeSymbols				xml-ucs-is-letterlike-symbols)
     (xmlUCSIsLimbu					xml-ucs-is-limbu)
     (xmlUCSIsLinearBIdeograms				xml-ucs-is-linear-b-ideograms)
     (xmlUCSIsLinearBSyllabary				xml-ucs-is-linear-b-syllabary)
     (xmlUCSIsLowSurrogates				xml-ucs-is-low-surrogates)
     (xmlUCSIsMalayalam					xml-ucs-is-malayalam)
     (xmlUCSIsMathematicalAlphanumericSymbols		xml-ucs-is-mathematical-alphanumeric-symbols)
     (xmlUCSIsMathematicalOperators			xml-ucs-is-mathematical-operators)
     (xmlUCSIsMiscellaneousMathematicalSymbolsA		xml-ucs-is-miscellaneous-mathematical-symbols-a)
     (xmlUCSIsMiscellaneousMathematicalSymbolsB		xml-ucs-is-miscellaneous-mathematical-symbols-b)
     (xmlUCSIsMiscellaneousSymbols			xml-ucs-is-miscellaneous-symbols)
     (xmlUCSIsMiscellaneousSymbolsandArrows		xml-ucs-is-miscellaneous-symbolsand-arrows)
     (xmlUCSIsMiscellaneousTechnical			xml-ucs-is-miscellaneous-technical)
     (xmlUCSIsMongolian					xml-ucs-is-mongolian)
     (xmlUCSIsMusicalSymbols				xml-ucs-is-musical-symbols)
     (xmlUCSIsMyanmar					xml-ucs-is-myanmar)
     (xmlUCSIsNumberForms				xml-ucs-is-number-forms)
     (xmlUCSIsOgham					xml-ucs-is-ogham)
     (xmlUCSIsOldItalic					xml-ucs-is-old-italic)
     (xmlUCSIsOpticalCharacterRecognition		xml-ucs-is-optical-character-recognition)
     (xmlUCSIsOriya					xml-ucs-is-oriya)
     (xmlUCSIsOsmanya					xml-ucs-is-osmanya)
     (xmlUCSIsPhoneticExtensions			xml-ucs-is-phonetic-extensions)
     (xmlUCSIsPrivateUse				xml-ucs-is-private-use)
     (xmlUCSIsPrivateUseArea				xml-ucs-is-private-use-area)
     (xmlUCSIsRunic					xml-ucs-is-runic)
     (xmlUCSIsShavian					xml-ucs-is-shavian)
     (xmlUCSIsSinhala					xml-ucs-is-sinhala)
     (xmlUCSIsSmallFormVariants				xml-ucs-is-small-form-variants)
     (xmlUCSIsSpacingModifierLetters			xml-ucs-is-spacing-modifier-letters)
     (xmlUCSIsSpecials					xml-ucs-is-specials)
     (xmlUCSIsSuperscriptsandSubscripts			xml-ucs-is-superscriptsand-subscripts)
     (xmlUCSIsSupplementalArrowsA			xml-ucs-is-supplemental-arrows-a)
     (xmlUCSIsSupplementalArrowsB			xml-ucs-is-supplemental-arrows-b)
     (xmlUCSIsSupplementalMathematicalOperators		xml-ucs-is-supplemental-mathematical-operators)
     (xmlUCSIsSupplementaryPrivateUseAreaA		xml-ucs-is-supplementary-private-use-area-a)
     (xmlUCSIsSupplementaryPrivateUseAreaB		xml-ucs-is-supplementary-private-use-area-b)
     (xmlUCSIsSyriac					xml-ucs-is-syriac)
     (xmlUCSIsTagalog					xml-ucs-is-tagalog)
     (xmlUCSIsTagbanwa					xml-ucs-is-tagbanwa)
     (xmlUCSIsTags					xml-ucs-is-tags)
     (xmlUCSIsTaiLe					xml-ucs-is-tai-le)
     (xmlUCSIsTaiXuanJingSymbols			xml-ucs-is-tai-xuan-jing-symbols)
     (xmlUCSIsTamil					xml-ucs-is-tamil)
     (xmlUCSIsTelugu					xml-ucs-is-telugu)
     (xmlUCSIsThaana					xml-ucs-is-thaana)
     (xmlUCSIsThai					xml-ucs-is-thai)
     (xmlUCSIsTibetan					xml-ucs-is-tibetan)
     (xmlUCSIsUgaritic					xml-ucs-is-ugaritic)
     (xmlUCSIsUnifiedCanadianAboriginalSyllabics	xml-ucs-is-unified-canadian-aboriginal-syllabics)
     (xmlUCSIsVariationSelectors			xml-ucs-is-variation-selectors)
     (xmlUCSIsVariationSelectorsSupplement		xml-ucs-is-variation-selectors-supplement)
     (xmlUCSIsYiRadicals				xml-ucs-is-yi-radicals)
     (xmlUCSIsYiSyllables				xml-ucs-is-yi-syllables)
     (xmlUCSIsYijingHexagramSymbols			xml-ucs-is-yijing-hexagram-symbols)
     (xmlUCSIsBlock					xml-ucs-is-block)
     (xmlUCSIsCatC					xml-ucs-is-cat-c)
     (xmlUCSIsCatCc					xml-ucs-is-cat-cc)
     (xmlUCSIsCatCf					xml-ucs-is-cat-cf)
     (xmlUCSIsCatCo					xml-ucs-is-cat-co)
     (xmlUCSIsCatCs					xml-ucs-is-cat-cs)
     (xmlUCSIsCatL					xml-ucs-is-cat-l)
     (xmlUCSIsCatLl					xml-ucs-is-cat-ll)
     (xmlUCSIsCatLm					xml-ucs-is-cat-lm)
     (xmlUCSIsCatLo					xml-ucs-is-cat-lo)
     (xmlUCSIsCatLt					xml-ucs-is-cat-lt)
     (xmlUCSIsCatLu					xml-ucs-is-cat-lu)
     (xmlUCSIsCatM					xml-ucs-is-cat-m)
     (xmlUCSIsCatMc					xml-ucs-is-cat-mc)
     (xmlUCSIsCatMe					xml-ucs-is-cat-me)
     (xmlUCSIsCatMn					xml-ucs-is-cat-mn)
     (xmlUCSIsCatN					xml-ucs-is-cat-n)
     (xmlUCSIsCatNd					xml-ucs-is-cat-nd)
     (xmlUCSIsCatNl					xml-ucs-is-cat-nl)
     (xmlUCSIsCatNo					xml-ucs-is-cat-no)
     (xmlUCSIsCatP					xml-ucs-is-cat-p)
     (xmlUCSIsCatPc					xml-ucs-is-cat-pc)
     (xmlUCSIsCatPd					xml-ucs-is-cat-pd)
     (xmlUCSIsCatPe					xml-ucs-is-cat-pe)
     (xmlUCSIsCatPf					xml-ucs-is-cat-pf)
     (xmlUCSIsCatPi					xml-ucs-is-cat-pi)
     (xmlUCSIsCatPo					xml-ucs-is-cat-po)
     (xmlUCSIsCatPs					xml-ucs-is-cat-ps)
     (xmlUCSIsCatS					xml-ucs-is-cat-s)
     (xmlUCSIsCatSc					xml-ucs-is-cat-sc)
     (xmlUCSIsCatSk					xml-ucs-is-cat-sk)
     (xmlUCSIsCatSm					xml-ucs-is-cat-sm)
     (xmlUCSIsCatSo					xml-ucs-is-cat-so)
     (xmlUCSIsCatZ					xml-ucs-is-cat-z)
     (xmlUCSIsCatZl					xml-ucs-is-cat-zl)
     (xmlUCSIsCatZp					xml-ucs-is-cat-zp)
     (xmlUCSIsCatZs					xml-ucs-is-cat-zs)
     (xmlUCSIsCat					xml-ucs-is-cat))

    ;; compile-time version informations
    (rename
     (xmlCheckVersion				xml-check-version))

    ;; text writing API for XML
    (rename
     (xmlNewTextWriter				xml-new-text-writer)
     (xmlNewTextWriterFilename			xml-new-text-writer-filename)
     (xmlNewTextWriterMemory			xml-new-text-writer-memory)
     (xmlNewTextWriterPushParser		xml-new-text-writer-push-parser)
     (xmlNewTextWriterDoc			xml-new-text-writer-doc)
     (xmlNewTextWriterTree			xml-new-text-writer-tree)
     (xmlFreeTextWriter				xml-free-text-writer)
     (xmlTextWriterStartDocument		xml-text-writer-start-document)
     (xmlTextWriterEndDocument			xml-text-writer-end-document)
     (xmlTextWriterStartComment			xml-text-writer-start-comment)
     (xmlTextWriterEndComment			xml-text-writer-end-comment)
     (xmlTextWriterWriteComment			xml-text-writer-write-comment)
     (xmlTextWriterStartElement			xml-text-writer-start-element)
     (xmlTextWriterStartElementNS		xml-text-writer-start-element-ns)
     (xmlTextWriterEndElement			xml-text-writer-end-element)
     (xmlTextWriterFullEndElement		xml-text-writer-full-end-element)
     (xmlTextWriterWriteElement			xml-text-writer-write-element)
     (xmlTextWriterWriteElementNS		xml-text-writer-write-element-ns)
     (xmlTextWriterWriteRawLen			xml-text-writer-write-raw-len)
     (xmlTextWriterWriteRaw			xml-text-writer-write-raw)
     (xmlTextWriterWriteString			xml-text-writer-write-string)
     (xmlTextWriterWriteBase64			xml-text-writer-write-base64)
     (xmlTextWriterWriteBinHex			xml-text-writer-write-bin-hex)
     (xmlTextWriterStartAttribute		xml-text-writer-start-attribute)
     (xmlTextWriterStartAttributeNS		xml-text-writer-start-attribute-ns)
     (xmlTextWriterEndAttribute			xml-text-writer-end-attribute)
     (xmlTextWriterWriteAttribute		xml-text-writer-write-attribute)
     (xmlTextWriterWriteAttributeNS		xml-text-writer-write-attribute-ns)
     (xmlTextWriterStartPI			xml-text-writer-start-pi)
     (xmlTextWriterEndPI			xml-text-writer-end-pi)
     (xmlTextWriterWritePI			xml-text-writer-write-pi)
     (xmlTextWriterStartCDATA			xml-text-writer-start-cdata)
     (xmlTextWriterEndCDATA			xml-text-writer-end-cdata)
     (xmlTextWriterWriteCDATA			xml-text-writer-write-cdata)
     (xmlTextWriterStartDTD			xml-text-writer-start-dtd)
     (xmlTextWriterEndDTD			xml-text-writer-end-dtd)
     (xmlTextWriterWriteDTD			xml-text-writer-write-dtd)
     (xmlTextWriterStartDTDElement		xml-text-writer-start-dtd-element)
     (xmlTextWriterEndDTDElement		xml-text-writer-end-dtd-element)
     (xmlTextWriterWriteDTDElement		xml-text-writer-write-dtd-element)
     (xmlTextWriterStartDTDAttlist		xml-text-writer-start-dtd-attlist)
     (xmlTextWriterEndDTDAttlist		xml-text-writer-end-dtd-attlist)
     (xmlTextWriterWriteDTDAttlist		xml-text-writer-write-dtd-attlist)
     (xmlTextWriterStartDTDEntity		xml-text-writer-start-dtd-entity)
     (xmlTextWriterEndDTDEntity			xml-text-writer-end-dtd-entity)
     (xmlTextWriterWriteDTDInternalEntity	xml-text-writer-write-dtd-internal-entity)
     (xmlTextWriterWriteDTDExternalEntity	xml-text-writer-write-dtd-external-entity)
     (xmlTextWriterWriteDTDExternalEntityContents xml-text-writer-write-dtd-external-entity-contents)
     (xmlTextWriterWriteDTDEntity		xml-text-writer-write-dtd-entity)
     (xmlTextWriterWriteDTDNotation		xml-text-writer-write-dtd-notation)
     (xmlTextWriterSetIndent			xml-text-writer-set-indent)
     (xmlTextWriterSetIndentString		xml-text-writer-set-indent-string)
     (xmlTextWriterFlush			xml-text-writer-flush))

    ;; XML Path Language implementation
    (rename
     (xmlXPathFreeObject			xml-xpath-free-object)
     (xmlXPathNodeSetCreate			xml-xpath-node-set-create)
     (xmlXPathFreeNodeSetList			xml-xpath-free-node-set-list)
     (xmlXPathFreeNodeSet			xml-xpath-free-node-set)
     (xmlXPathObjectCopy			xml-xpath-object-copy)
     (xmlXPathCmpNodes				xml-xpath-cmp-nodes)
     (xmlXPathCastNumberToBoolean		xml-xpath-cast-number-to-boolean)
     (xmlXPathCastStringToBoolean		xml-xpath-cast-string-to-boolean)
     (xmlXPathCastNodeSetToBoolean		xml-xpath-cast-node-set-to-boolean)
     (xmlXPathCastToBoolean			xml-xpath-cast-to-boolean)
     (xmlXPathCastBooleanToNumber		xml-xpath-cast-boolean-to-number)
     (xmlXPathCastStringToNumber		xml-xpath-cast-string-to-number)
     (xmlXPathCastNodeToNumber			xml-xpath-cast-node-to-number)
     (xmlXPathCastNodeSetToNumber		xml-xpath-cast-node-set-to-number)
     (xmlXPathCastToNumber			xml-xpath-cast-to-number)
     (xmlXPathCastBooleanToString		xml-xpath-cast-boolean-to-string)
     (xmlXPathCastNumberToString		xml-xpath-cast-number-to-string)
     (xmlXPathCastNodeToString			xml-xpath-cast-node-to-string)
     (xmlXPathCastNodeSetToString		xml-xpath-cast-node-set-to-string)
     (xmlXPathCastToString			xml-xpath-cast-to-string)
     (xmlXPathConvertBoolean			xml-xpath-convert-boolean)
     (xmlXPathConvertNumber			xml-xpath-convert-number)
     (xmlXPathConvertString			xml-xpath-convert-string)
     (xmlXPathNewContext			xml-xpath-new-context)
     (xmlXPathFreeContext			xml-xpath-free-context)
     (xmlXPathContextSetCache			xml-xpath-context-set-cache)
     (xmlXPathOrderDocElems			xml-xpath-order-doc-elems)
     (xmlXPathEval				xml-xpath-eval)
     (xmlXPathEvalExpression			xml-xpath-eval-expression)
     (xmlXPathEvalPredicate			xml-xpath-eval-predicate)
     (xmlXPathCompile				xml-xpath-compile)
     (xmlXPathCtxtCompile			xml-xpath-ctxt-compile)
     (xmlXPathCompiledEval			xml-xpath-compiled-eval)
     (xmlXPathCompiledEvalToBoolean		xml-xpath-compiled-eval-to-boolean)
     (xmlXPathFreeCompExpr			xml-xpath-free-comp-expr)
     (xmlXPathInit				xml-xpath-init)
     (xmlXPathIsNaN				xml-xpath-is-nan)
     (xmlXPathIsInf				xml-xpath-is-inf))

    ;; API to handle XML Pointers
    (rename
     (xmlXPtrLocationSetCreate			xml-xptr-location-set-create)
     (xmlXPtrFreeLocationSet			xml-xptr-free-location-set)
     (xmlXPtrLocationSetMerge			xml-xptr-location-set-merge)
     (xmlXPtrNewRange				xml-xptr-new-range)
     (xmlXPtrNewRangePoints			xml-xptr-new-range-points)
     (xmlXPtrNewRangeNodePoint			xml-xptr-new-range-node-point)
     (xmlXPtrNewRangePointNode			xml-xptr-new-range-point-node)
     (xmlXPtrNewRangeNodes			xml-xptr-new-range-nodes)
     (xmlXPtrNewLocationSetNodes		xml-xptr-new-location-set-nodes)
     (xmlXPtrNewLocationSetNodeSet		xml-xptr-new-location-set-node-set)
     (xmlXPtrNewRangeNodeObject			xml-xptr-new-range-node-object)
     (xmlXPtrNewCollapsedRange			xml-xptr-new-collapsed-range)
     (xmlXPtrLocationSetAdd			xml-xptr-location-set-add)
     (xmlXPtrWrapLocationSet			xml-xptr-wrap-location-set)
     (xmlXPtrLocationSetDel			xml-xptr-location-set-del)
     (xmlXPtrLocationSetRemove			xml-xptr-location-set-remove)
     (xmlXPtrNewContext				xml-xptr-new-context)
     (xmlXPtrEval				xml-xptr-eval)
     (xmlXPtrRangeToFunction			xml-xptr-range-to-function)
     (xmlXPtrBuildNodeList			xml-xptr-build-node-list)
     (xmlXPtrEvalRangePredicate			xml-xptr-eval-range-predicate))

    )
  (import (rnrs)
    (compensations)
    (foreign ffi)
    (foreign ffi sizeof)
    (foreign memory)
    (foreign cstrings)
    (xml libxml2 platform)
    (xml libxml2 sizeof))


;;;; callback makers

(define (make-xml-c14n-is-visible-callback scheme-function)
  (make-c-callback* int
		    scheme-function
		    (void* xmlNodePtr xmlNodePtr)))


(define (make-xml-shell-readline-func scheme-function)
  (make-c-callback* char*
		    scheme-function
		    (char*)))

(define (make-xml-shell-cmd scheme-function)
  (make-c-callback* int
		    scheme-function
		    (xmlShellCtxtPtr char* xmlNodePtr xmlNodePtr)))

(define (make-xml-char-encoding-input-func scheme-function)
  (make-c-callback* int
		    scheme-function
		    (void* void* void* void*)))

(define (make-xml-char-encoding-output-func scheme-function)
  (make-c-callback* int
		    scheme-function
		    (void* void* void* void*)))

(define (make-xml-parser-input-buffer-create-filename-func scheme-function)
  (make-c-callback* xmlParserInputBufferPtr
		    scheme-function
		    (char* xmlCharEncoding)))

(define (make-xml-output-buffer-create-filename-func scheme-function)
  (make-c-callback* xmlOutputBufferPtr
		    scheme-function
		    (char* xmlCharEncodingHandlerPtr int)))

(define (make-xml-register-node-func scheme-function)
  (make-c-callback* void
		    scheme-function
		    (xmlNodePtr)))

(define (make-xml-deregister-node-func scheme-function)
  (make-c-callback* void
		    scheme-function
		    (xmlNodePtr)))

(define (make-xml-hash-deallocator scheme-function)
  (make-c-callback* void
		    scheme-function
		    (void* xmlChar*)))

(define (make-xml-hash-copier scheme-function)
  (make-c-callback* void*
		    scheme-function
		    (void* xmlChar*)))

(define (make-xml-hash-scanner scheme-function)
  (make-c-callback* void
		    scheme-function
		    (void* void* xmlChar*)))

(define (make-xml-hash-scanner-full scheme-function)
  (make-c-callback* void
		    scheme-function
		    (void* void* xmlChar* xmlChar* xmlChar*)))

(define (make-xml-list-deallocator scheme-function)
  (make-c-callback* void
		    scheme-function
		    (xmlLinkPtr)))

(define (make-xml-list-data-compare scheme-function)
  (make-c-callback* int
		    scheme-function
		    (void* void*)))

(define (make-xml-list-walker scheme-function)
  (make-c-callback* int
		    scheme-function
		    (void* void*)))

(define (make-ftp-list-callback scheme-function)
  (make-c-callback* void
		    scheme-function
		    (void* char* char* char* char* unsigned-long int int char* int int int)))

(define (make-ftp-data-callback scheme-function)
  (make-c-callback* void
		    ftpDataCallback
		    (void* char* int)))

(define (make-xml-parser-input-deallocate scheme-function)
  (make-c-callback* void
		    scheme-function
		    (xmlChar*)))

(define (make-resolve-entity-sax-func scheme-function)
  (make-c-callback* xmlParserInputPtr
		    scheme-function
		    (void* xmlChar* xmlChar*)))

(define (make-internal-subset-sax-func scheme-function)
  (make-c-callback* void
		    scheme-function
		    (void* xmlChar* xmlChar* xmlChar*)))

(define (make-external-subset-sax-func scheme-function)
  (make-c-callback* void
		    scheme-function
		    (void* xmlChar* xmlChar* xmlChar*)))

(define (make-get-entity-sax-func scheme-function)
  (make-c-callback* xmlEntityPtr
		    scheme-function
		    (void* xmlChar*)))

(define (make-get-parameter-entity-sax-func scheme-function)
  (make-c-callback* xmlEntityPtr
		    scheme-function
		    (void* xmlChar*)))

(define (make-entity-decl-sax-func scheme-function)
  (make-c-callback* void
		    scheme-function
		    (void* xmlChar* int xmlChar* xmlChar* xmlChar*)))

(define (make-notation-decl-sax-func scheme-function)
  (make-c-callback* void
		    scheme-function
		    (void* xmlChar* xmlChar* xmlChar*)))

(define (make-attribute-decl-sax-func scheme-function)
  (make-c-callback* void
		    scheme-function
		    (void* xmlChar* xmlChar* int int xmlChar* xmlEnumerationPtr)))

(define (make-element-decl-sax-func scheme-function)
  (make-c-callback* void
		    scheme-function
		    (void* xmlChar* int xmlElementContentPtr)))

(define (make-unparsed-entity-decl-sax-func scheme-function)
  (make-c-callback* void
		    scheme-function
		    (void* xmlChar* xmlChar* xmlChar* xmlChar*)))

(define (make-set-document-locator-sax-func scheme-function)
  (make-c-callback* void
		    scheme-function
		    (void* xmlSAXLocatorPtr)))

(define (make-start-document-sax-func scheme-function)
  (make-c-callback* void
		    scheme-function
		    (void*)))

(define (make-end-document-sax-func scheme-function)
  (make-c-callback* void
		    scheme-function
		    (void*)))

(define (make-start-element-sax-func scheme-function)
  (make-c-callback* void
		    scheme-function
		    (void* xmlChar* xmlChar**)))

(define (make-end-element-sax-func scheme-function)
  (make-c-callback* void
		    scheme-function
		    (void* xmlChar*)))

(define (make-attribute-sax-func scheme-function)
  (make-c-callback* void
		    scheme-function
		    (void* xmlChar* xmlChar*)))

(define (make-reference-sax-func scheme-function)
  (make-c-callback* void
		    scheme-function
		    (void* xmlChar*)))

(define (make-characters-sax-func scheme-function)
  (make-c-callback* void
		    scheme-function
		    (void* xmlChar* int)))

(define (make-ignorable-whitespace-sax-func scheme-function)
  (make-c-callback* void
		    scheme-function
		    (void* xmlChar* int)))

(define (make- scheme-function)
  (make-c-callback* void
		    processingInstructionSAXFunc
		    (void* xmlChar* xmlChar*)))

(define (make-comment-sax-func scheme-function)
  (make-c-callback* void
		    scheme-function
		    (void* xmlChar*)))

(define (make-cdata-block-sax-func scheme-function)
  (make-c-callback* void
		    scheme-function
		    (void* xmlChar* int)))

;;Variadic!!!
;;
;; (define (make-warning-sax-func scheme-function)
;;   (make-c-callback* void
;; 		    scheme-function
;; 		    (void* char* ...)))

;;Variadic!!!
;;
;; (define (make-error-sax-func scheme-function)
;;   (make-c-callback* void
;; 		    scheme-function
;; 		    (void* char* ...)))

;;Variadic!!!
;;
;; (define (make-fatal-error-sax-func scheme-function)
;;   (make-c-callback* void
;; 		    scheme-function
;; 		    (void* char* ...)))

(define (make-is-standalone-sax-func scheme-function)
  (make-c-callback* int
		    scheme-function
		    (void*)))

(define (make-has-internal-subset-sax-func scheme-function)
  (make-c-callback* int
		    scheme-function
		    (void*)))

(define (make-has-external-subset-sax-func scheme-function)
  (make-c-callback* int
		    scheme-function
		    (void*)))

(define (make-start-element-ns-sax2-func scheme-function)
  (make-c-callback* void
		    scheme-function
		    (void* xmlChar* xmlChar* xmlChar* int xmlChar** int int xmlChar**)))

(define (make-end-element-ns-sax2-func scheme-function)
  (make-c-callback* void
		    scheme-function
		    (void* xmlChar* xmlChar* xmlChar*)))

(define (make-xml-external-entity-loader scheme-function)
  (make-c-callback* xmlParserInputPtr
		    scheme-function
		    (char* char* xmlParserCtxtPtr)))


;;Variadic!!!
;;
;; (define (make-xml-relax-ng-validity-error-func scheme-function)
;;   (make-c-callback* void
;; 		    scheme-function
;; 		    (void* char* ...)))

;;Variadic!!!
;;
;; (define (make-xml-relax-ng-validity-warning-func scheme-function)
;;   (make-c-callback* void
;; 		    scheme-function
;; 		    (void* char* ...)))

;;Variadic!!!
;;
;; (define (make-xml-schematron-validity-error-func scheme-function)
;;   (make-c-callback* void
;; 		    scheme-function
;; 		    (void* char* ...)))

;;Variadic!!!
;;
;; (define (make-xml-schematron-validity-warning-func scheme-function)
;;   (make-c-callback* void
;; 		    scheme-function
;; 		    (void* char* ...)))

(define (make-xml-dom-wrap-acquire-ns-function scheme-function)
  (make-c-callback* xmlNsPtr
		    scheme-function
		    (xmlDOMWrapCtxtPtr xmlNodePtr xmlChar* xmlChar*)))

;;Variadic!!!
;;
;; (define (make-xml-validity-error-func scheme-function)
;;   (make-c-callback* void
;; 		    scheme-function
;; 		    (void* char* ...)))

;;Variadic!!!
;;
;; (define (make-xml-validity-warning-func scheme-function)
;;   (make-c-callback* void
;; 		    scheme-function
;; 		    (void* char* ...)))

;;Variadic!!!
;;
;; (define (make-xml-generic-error-func scheme-function)
;;   (make-c-callback* void
;; 		    scheme-function
;; 		    (void* char* ...)))

(define (make-xml-structured-error-func scheme-function)
  (make-c-callback* void
		    scheme-function
		    (void* xmlErrorPtr)))

(define (make-xml-input-match-callback scheme-function)
  (make-c-callback* int
		    scheme-function
		    (char*)))

(define (make-xml-input-open-callback scheme-function)
  (make-c-callback* void*
		    scheme-function
		    (char*)))

(define (make-xml-input-read-callback scheme-function)
  (make-c-callback* int
		    scheme-function
		    (void* char* int)))

(define (make-xml-input-close-callback scheme-function)
  (make-c-callback* int
		    scheme-function
		    (void*)))

(define (make-xml-output-match-callback scheme-function)
  (make-c-callback* int
		    scheme-function
		    (char*)))

(define (make-xml-output-open-callback scheme-function)
  (make-c-callback* void*
		    scheme-function
		    (char*)))

(define (make-xml-output-write-callback scheme-function)
  (make-c-callback* int
		    scheme-function
		    (void* char* int)))

(define (make-xml-output-close-callback scheme-function)
  (make-c-callback* int
		    scheme-function
		    (void*)))

(define (make-xml-free-func scheme-function)
  (make-c-callback* void
		    scheme-function
		    (void*)))

(define (make-xml-malloc-func scheme-function)
  (make-c-callback* void*
		    scheme-function
		    (size_t)))

(define (make-xml-realloc-func scheme-function)
  (make-c-callback* void*
		    scheme-function
		    (void* size_t)))

(define (make-xml-strdup-func scheme-function)
  (make-c-callback* char*
		    scheme-function
		    (char*)))

(define (make-xml-text-reader-error-func scheme-function)
  (make-c-callback* void
		    scheme-function
		    (void* char* xmlParserSeverities xmlTextReaderLocatorPtr)))

(define (make-xml-reg-exec-callbacks scheme-function)
  (make-c-callback* void
		    scheme-function
		    (xmlRegExecCtxtPtr xmlChar* void* void*)))

;;Variadic!!!
;;
;; (define (make-xml-schema-validity-error-func scheme-function)
;;   (make-c-callback* void
;; 		    scheme-function
;; 		    (void* char* ...)))

;;Variadic!!!
;;
;; (define (make-xml-schema-validity-warning-func scheme-function)
;;   (make-c-callback* void
;; 		    scheme-function
;; 		    (void* char* ...)))

(define (make-xml-xpath-convert-func scheme-function)
  (make-c-callback* int
		    scheme-function
		    (xmlXPathObjectPtr int)))

(define (make-xml-xpath-eval-func scheme-function)
  (make-c-callback* void
		    scheme-function
		    (xmlXPathParserContextPtr int)))

(define (make-xml-xpath-axis-func scheme-function)
  (make-c-callback* xmlXPathObjectPtr
		    scheme-function
		    (xmlXPathParserContextPtr xmlXPathObjectPtr)))


(define (make-xml-xpath-function scheme-function)
  (make-c-callback* void
		    scheme-function
		    (xmlXPathParserContextPtr int)))

(define (make-xml-xpath-variable-lookup-func scheme-function)
  (make-c-callback* xmlXPathObjectPtr
		    scheme-function
		    (void* xmlChar* xmlChar*)))

(define (make-xml-xpath-func-lookup-func scheme-function)
  (make-c-callback* xmlXPathFunction
		    scheme-function
		    (void* xmlChar* xmlChar*)))



;;;; identifier syntaxes


;;; --------------------------------------------------------------------

;; (define-struct-fields xmlChSRange
;;   (low low)
;;   (high high))

;; (define-struct-fields xmlChLRange
;;   (low low)
;;   (high high))

;; (define-struct-fields xmlChRangeGroup
;;   (nbShortRange nbShortRange)
;;   (nbLongRange nbLongRange)
;;   ;; struct-xmlChRangeGroup-shortRange-set!
;;     ;; struct-xmlChRangeGroup-shortRange-ref
;;     ;; struct-xmlChRangeGroup-longRange-set!
;;     ;; struct-xmlChRangeGroup-longRange-ref

;;     ;; struct-xmlShellCtxt-filename-set!
;;     ;; struct-xmlShellCtxt-filename-ref
;;     ;; struct-xmlShellCtxt-doc-set!
;;     ;; struct-xmlShellCtxt-doc-ref
;;     ;; struct-xmlShellCtxt-node-set!
;;     ;; struct-xmlShellCtxt-node-ref
;;     ;; struct-xmlShellCtxt-pctxt-set!
;;     ;; struct-xmlShellCtxt-pctxt-ref
;;     ;; struct-xmlShellCtxt-loaded-set!
;;     ;; struct-xmlShellCtxt-loaded-ref
;;     ;; struct-xmlShellCtxt-output-set!
;;     ;; struct-xmlShellCtxt-output-ref
;;     ;; struct-xmlShellCtxt-input-set!
;;     ;; struct-xmlShellCtxt-input-ref

;;     ;; struct-xmlCharEncodingHandler-name-set!
;;     ;; struct-xmlCharEncodingHandler-name-ref
;;     ;; struct-xmlCharEncodingHandler-input-set!
;;     ;; struct-xmlCharEncodingHandler-input-ref
;;     ;; struct-xmlCharEncodingHandler-output-set!
;;     ;; struct-xmlCharEncodingHandler-output-ref
;;     ;; struct-xmlCharEncodingHandler-iconv_in-set!
;;     ;; struct-xmlCharEncodingHandler-iconv_in-ref
;;     ;; struct-xmlCharEncodingHandler-iconv_out-set!
;;     ;; struct-xmlCharEncodingHandler-iconv_out-ref

;;     ;; struct-xmlEntity-_private-set!
;;     ;; struct-xmlEntity-_private-ref
;;     ;; struct-xmlEntity-type-set!
;;     ;; struct-xmlEntity-type-ref
;;     ;; struct-xmlEntity-name-set!
;;     ;; struct-xmlEntity-name-ref
;;     ;; struct-xmlEntity-children-set!
;;     ;; struct-xmlEntity-children-ref
;;     ;; struct-xmlEntity-last-set!
;;     ;; struct-xmlEntity-last-ref
;;     ;; struct-xmlEntity-parent-set!
;;     ;; struct-xmlEntity-parent-ref
;;     ;; struct-xmlEntity-next-set!
;;     ;; struct-xmlEntity-next-ref
;;     ;; struct-xmlEntity-prev-set!
;;     ;; struct-xmlEntity-prev-ref
;;     ;; struct-xmlEntity-doc-set!
;;     ;; struct-xmlEntity-doc-ref
;;     ;; struct-xmlEntity-orig-set!
;;     ;; struct-xmlEntity-orig-ref
;;     ;; struct-xmlEntity-content-set!
;;     ;; struct-xmlEntity-content-ref
;;     ;; struct-xmlEntity-length-set!
;;     ;; struct-xmlEntity-length-ref
;;     ;; struct-xmlEntity-etype-set!
;;     ;; struct-xmlEntity-etype-ref
;;     ;; struct-xmlEntity-ExternalID-set!
;;     ;; struct-xmlEntity-ExternalID-ref
;;     ;; struct-xmlEntity-SystemID-set!
;;     ;; struct-xmlEntity-SystemID-ref
;;     ;; struct-xmlEntity-nexte-set!
;;     ;; struct-xmlEntity-nexte-ref
;;     ;; struct-xmlEntity-URI-set!
;;     ;; struct-xmlEntity-URI-ref
;;     ;; struct-xmlEntity-owner-set!
;;     ;; struct-xmlEntity-owner-ref
;;     ;; struct-xmlEntity-checked-set!
;;     ;; struct-xmlEntity-checked-ref
;;     ;; struct-htmlElemDesc-name-set!
;;     ;; struct-htmlElemDesc-name-ref
;;     ;; struct-htmlElemDesc-startTag-set!
;;     ;; struct-htmlElemDesc-startTag-ref
;;     ;; struct-htmlElemDesc-endTag-set!
;;     ;; struct-htmlElemDesc-endTag-ref
;;     ;; struct-htmlElemDesc-saveEndTag-set!
;;     ;; struct-htmlElemDesc-saveEndTag-ref
;;     ;; struct-htmlElemDesc-empty-set!
;;     ;; struct-htmlElemDesc-empty-ref
;;     ;; struct-htmlElemDesc-depr-set!
;;     ;; struct-htmlElemDesc-depr-ref
;;     ;; struct-htmlElemDesc-dtd-set!
;;     ;; struct-htmlElemDesc-dtd-ref
;;     ;; struct-htmlElemDesc-isinline-set!
;;     ;; struct-htmlElemDesc-isinline-ref
;;     ;; struct-htmlElemDesc-desc-set!
;;     ;; struct-htmlElemDesc-desc-ref
;;     ;; struct-htmlElemDesc-subelts-set!
;;     ;; struct-htmlElemDesc-subelts-ref
;;     ;; struct-htmlElemDesc-defaultsubelt-set!
;;     ;; struct-htmlElemDesc-defaultsubelt-ref
;;     ;; struct-htmlElemDesc-attrs_opt-set!
;;     ;; struct-htmlElemDesc-attrs_opt-ref
;;     ;; struct-htmlElemDesc-attrs_depr-set!
;;     ;; struct-htmlElemDesc-attrs_depr-ref
;;     ;; struct-htmlElemDesc-attrs_req-set!
;;     ;; struct-htmlElemDesc-attrs_req-ref
;;     ;; struct-htmlEntityDesc-value-set!
;;     ;; struct-htmlEntityDesc-value-ref
;;     ;; struct-htmlEntityDesc-name-set!
;;     ;; struct-htmlEntityDesc-name-ref
;;     ;; struct-htmlEntityDesc-desc-set!
;;     ;; struct-htmlEntityDesc-desc-ref

;;     ;; struct-xmlParserInput-buf-set!
;;     ;; struct-xmlParserInput-buf-ref
;;     ;; struct-xmlParserInput-filename-set!
;;     ;; struct-xmlParserInput-filename-ref
;;     ;; struct-xmlParserInput-directory-set!
;;     ;; struct-xmlParserInput-directory-ref
;;     ;; struct-xmlParserInput-base-set!
;;     ;; struct-xmlParserInput-base-ref
;;     ;; struct-xmlParserInput-cur-set!
;;     ;; struct-xmlParserInput-cur-ref
;;     ;; struct-xmlParserInput-end-set!
;;     ;; struct-xmlParserInput-end-ref
;;     ;; struct-xmlParserInput-length-set!
;;     ;; struct-xmlParserInput-length-ref
;;     ;; struct-xmlParserInput-line-set!
;;     ;; struct-xmlParserInput-line-ref
;;     ;; struct-xmlParserInput-col-set!
;;     ;; struct-xmlParserInput-col-ref
;;     ;; struct-xmlParserInput-consumed-set!
;;     ;; struct-xmlParserInput-consumed-ref
;;     ;; struct-xmlParserInput-free-set!
;;     ;; struct-xmlParserInput-free-ref
;;     ;; struct-xmlParserInput-encoding-set!
;;     ;; struct-xmlParserInput-encoding-ref
;;     ;; struct-xmlParserInput-version-set!
;;     ;; struct-xmlParserInput-version-ref
;;     ;; struct-xmlParserInput-standalone-set!
;;     ;; struct-xmlParserInput-standalone-ref
;;     ;; struct-xmlParserInput-id-set!
;;     ;; struct-xmlParserInput-id-ref
;;     ;; struct-xmlParserNodeInfo-node-set!
;;     ;; struct-xmlParserNodeInfo-node-ref
;;     ;; struct-xmlParserNodeInfo-begin_pos-set!
;;     ;; struct-xmlParserNodeInfo-begin_pos-ref
;;     ;; struct-xmlParserNodeInfo-begin_line-set!
;;     ;; struct-xmlParserNodeInfo-begin_line-ref
;;     ;; struct-xmlParserNodeInfo-end_pos-set!
;;     ;; struct-xmlParserNodeInfo-end_pos-ref
;;     ;; struct-xmlParserNodeInfo-end_line-set!
;;     ;; struct-xmlParserNodeInfo-end_line-ref
;;     ;; struct-xmlParserNodeInfoSeq-maximum-set!
;;     ;; struct-xmlParserNodeInfoSeq-maximum-ref
;;     ;; struct-xmlParserNodeInfoSeq-length-set!
;;     ;; struct-xmlParserNodeInfoSeq-length-ref
;;     ;; struct-xmlParserNodeInfoSeq-buffer-set!
;;     ;; struct-xmlParserNodeInfoSeq-buffer-ref

;; (define-struct-fields xmlParserCtxt
;;   (sax			sax)
;;   (userData 		userData)
;;   (myDoc 		myDoc)
;;   (wellFormed 		wellFormed)
;;   (replaceEntities 	replaceEntities)
;;   (version 		version)
;;   (encoding 		encoding)
;;   (standalone 		standalone)
;;   (html 		html)
;;   (input 		input)
;;   (inputNr 		inputNr)
;;   (inputMax 		inputMax)
;;   (inputTab 		inputTab)
;;   (node 		node)
;;   (nodeNr 		nodeNr)
;;   (nodeMax 		nodeMax)
;;   (nodeTab 		nodeTab)
;;   (record_info 	record_info)
;;   (node_seq)
;;   (errNo 		errNo)
;;   (hasExternalSubset 	hasExternalSubset)
;;   (hasPErefs 		hasPErefs)
;;   (external 		external)
;;   (valid 		valid)
;;   (validate 		validate)
;;   (vctxt)
;;   (instate)
;;   (token 		token)
;;   (directory 		directory)
;;   (name 		name)
;;   (nameNr 		nameNr)
;;   (nameMax 		nameMax)
;;   (nameTab 		nameTab)
;;   (nbChars 		nbChars)
;;   (checkIndex 		checkIndex)
;;   (keepBlanks 		keepBlanks)
;;   (disableSAX 		disableSAX)
;;   (inSubset 		inSubset)
;;   (intSubName 		intSubName)
;;   (extSubURI 		extSubURI)
;;   (extSubSystem 	extSubSystem)
;;   (space 		space)
;;   (spaceNr 		spaceNr)
;;   (spaceMax 		spaceMax)
;;   (spaceTab 		spaceTab)
;;   (depth 		depth)
;;   (entity 		entity)
;;   (charset 		charset)
;;   (nodelen 		nodelen)
;;   (nodemem 		nodemem)
;;   (pedantic 		pedantic)
;;   (_private 		_private)
;;   (loadsubset 		loadsubset)
;;   (linenumbers 	linenumbers)
;;   (catalogs 		catalogs)
;;   (recovery 		recovery)
;;   (progressive 	progressive)
;;   (dict 		dict)
;;   (atts 		atts)
;;   (maxatts 		maxatts)
;;   (docdict 		docdict)
;;   (str_xml 		str_xml)
;;   (str_xmlns 		str_xmlns)
;;   (str_xml_ns 		str_xml_ns)
;;   (sax2 		sax2)
;;   (nsNr 		nsNr)
;;   (nsMax 		nsMax)
;;   (nsTab 		nsTab)
;;   (attallocs 		attallocs)
;;   (pushTab 		pushTab)
;;   (attsDefault 	attsDefault)
;;   (attsSpecial 	attsSpecial)
;;   (nsWellFormed 	nsWellFormed)
;;   (options 		options)
;;   (dictNames 		dictNames)
;;   (freeElemsNr 	freeElemsNr)
;;   (freeElems 		freeElems)
;;   (freeAttrsNr 	freeAttrsNr)
;;   (freeAttrs 		freeAttrs)
;;   (lastError)
;;   (xmlParserMode)
;;   (nbentities 		nbentities)
;;   (sizeentities 	sizeentities)
;;   (getPublicId 	getPublicId)
;;   (getSystemId 	getSystemId)
;;   (getLineNumber 	getLineNumber)
;;   (getColumnNumber 	getColumnNumber))

;;     ;; struct-xmlParserCtxt-sax-set!
;;     ;; struct-xmlParserCtxt-sax-ref
;;     ;; struct-xmlParserCtxt-userData-set!
;;     ;; struct-xmlParserCtxt-userData-ref
;;     ;; struct-xmlParserCtxt-myDoc-set!
;;     ;; struct-xmlParserCtxt-myDoc-ref
;;     ;; struct-xmlParserCtxt-wellFormed-set!
;;     ;; struct-xmlParserCtxt-wellFormed-ref
;;     ;; struct-xmlParserCtxt-replaceEntities-set!
;;     ;; struct-xmlParserCtxt-replaceEntities-ref
;;     ;; struct-xmlParserCtxt-version-set!
;;     ;; struct-xmlParserCtxt-version-ref
;;     ;; struct-xmlParserCtxt-encoding-set!
;;     ;; struct-xmlParserCtxt-encoding-ref
;;     ;; struct-xmlParserCtxt-standalone-set!
;;     ;; struct-xmlParserCtxt-standalone-ref
;;     ;; struct-xmlParserCtxt-html-set!
;;     ;; struct-xmlParserCtxt-html-ref
;;     ;; struct-xmlParserCtxt-input-set!
;;     ;; struct-xmlParserCtxt-input-ref
;;     ;; struct-xmlParserCtxt-inputNr-set!
;;     ;; struct-xmlParserCtxt-inputNr-ref
;;     ;; struct-xmlParserCtxt-inputMax-set!
;;     ;; struct-xmlParserCtxt-inputMax-ref
;;     ;; struct-xmlParserCtxt-inputTab-set!
;;     ;; struct-xmlParserCtxt-inputTab-ref
;;     ;; struct-xmlParserCtxt-node-set!
;;     ;; struct-xmlParserCtxt-node-ref
;;     ;; struct-xmlParserCtxt-nodeNr-set!
;;     ;; struct-xmlParserCtxt-nodeNr-ref
;;     ;; struct-xmlParserCtxt-nodeMax-set!
;;     ;; struct-xmlParserCtxt-nodeMax-ref
;;     ;; struct-xmlParserCtxt-nodeTab-set!
;;     ;; struct-xmlParserCtxt-nodeTab-ref
;;     ;; struct-xmlParserCtxt-record_info-set!
;;     ;; struct-xmlParserCtxt-record_info-ref
;;     ;; struct-xmlParserCtxt-node_seq-ref
;;     ;; struct-xmlParserCtxt-errNo-set!
;;     ;; struct-xmlParserCtxt-errNo-ref
;;     ;; struct-xmlParserCtxt-hasExternalSubset-set!
;;     ;; struct-xmlParserCtxt-hasExternalSubset-ref
;;     ;; struct-xmlParserCtxt-hasPErefs-set!
;;     ;; struct-xmlParserCtxt-hasPErefs-ref
;;     ;; struct-xmlParserCtxt-external-set!
;;     ;; struct-xmlParserCtxt-external-ref
;;     ;; struct-xmlParserCtxt-valid-set!
;;     ;; struct-xmlParserCtxt-valid-ref
;;     ;; struct-xmlParserCtxt-validate-set!
;;     ;; struct-xmlParserCtxt-validate-ref
;;     ;; struct-xmlParserCtxt-vctxt-ref
;;     ;; struct-xmlParserCtxt-instate-ref
;;     ;; struct-xmlParserCtxt-token-set!
;;     ;; struct-xmlParserCtxt-token-ref
;;     ;; struct-xmlParserCtxt-directory-set!
;;     ;; struct-xmlParserCtxt-directory-ref
;;     ;; struct-xmlParserCtxt-name-set!
;;     ;; struct-xmlParserCtxt-name-ref
;;     ;; struct-xmlParserCtxt-nameNr-set!
;;     ;; struct-xmlParserCtxt-nameNr-ref
;;     ;; struct-xmlParserCtxt-nameMax-set!
;;     ;; struct-xmlParserCtxt-nameMax-ref
;;     ;; struct-xmlParserCtxt-nameTab-set!
;;     ;; struct-xmlParserCtxt-nameTab-ref
;;     ;; struct-xmlParserCtxt-nbChars-set!
;;     ;; struct-xmlParserCtxt-nbChars-ref
;;     ;; struct-xmlParserCtxt-checkIndex-set!
;;     ;; struct-xmlParserCtxt-checkIndex-ref
;;     ;; struct-xmlParserCtxt-keepBlanks-set!
;;     ;; struct-xmlParserCtxt-keepBlanks-ref
;;     ;; struct-xmlParserCtxt-disableSAX-set!
;;     ;; struct-xmlParserCtxt-disableSAX-ref
;;     ;; struct-xmlParserCtxt-inSubset-set!
;;     ;; struct-xmlParserCtxt-inSubset-ref
;;     ;; struct-xmlParserCtxt-intSubName-set!
;;     ;; struct-xmlParserCtxt-intSubName-ref
;;     ;; struct-xmlParserCtxt-extSubURI-set!
;;     ;; struct-xmlParserCtxt-extSubURI-ref
;;     ;; struct-xmlParserCtxt-extSubSystem-set!
;;     ;; struct-xmlParserCtxt-extSubSystem-ref
;;     ;; struct-xmlParserCtxt-space-set!
;;     ;; struct-xmlParserCtxt-space-ref
;;     ;; struct-xmlParserCtxt-spaceNr-set!
;;     ;; struct-xmlParserCtxt-spaceNr-ref
;;     ;; struct-xmlParserCtxt-spaceMax-set!
;;     ;; struct-xmlParserCtxt-spaceMax-ref
;;     ;; struct-xmlParserCtxt-spaceTab-set!
;;     ;; struct-xmlParserCtxt-spaceTab-ref
;;     ;; struct-xmlParserCtxt-depth-set!
;;     ;; struct-xmlParserCtxt-depth-ref
;;     ;; struct-xmlParserCtxt-entity-set!
;;     ;; struct-xmlParserCtxt-entity-ref
;;     ;; struct-xmlParserCtxt-charset-set!
;;     ;; struct-xmlParserCtxt-charset-ref
;;     ;; struct-xmlParserCtxt-nodelen-set!
;;     ;; struct-xmlParserCtxt-nodelen-ref
;;     ;; struct-xmlParserCtxt-nodemem-set!
;;     ;; struct-xmlParserCtxt-nodemem-ref
;;     ;; struct-xmlParserCtxt-pedantic-set!
;;     ;; struct-xmlParserCtxt-pedantic-ref
;;     ;; struct-xmlParserCtxt-_private-set!
;;     ;; struct-xmlParserCtxt-_private-ref
;;     ;; struct-xmlParserCtxt-loadsubset-set!
;;     ;; struct-xmlParserCtxt-loadsubset-ref
;;     ;; struct-xmlParserCtxt-linenumbers-set!
;;     ;; struct-xmlParserCtxt-linenumbers-ref
;;     ;; struct-xmlParserCtxt-catalogs-set!
;;     ;; struct-xmlParserCtxt-catalogs-ref
;;     ;; struct-xmlParserCtxt-recovery-set!
;;     ;; struct-xmlParserCtxt-recovery-ref
;;     ;; struct-xmlParserCtxt-progressive-set!
;;     ;; struct-xmlParserCtxt-progressive-ref
;;     ;; struct-xmlParserCtxt-dict-set!
;;     ;; struct-xmlParserCtxt-dict-ref
;;     ;; struct-xmlParserCtxt-atts-set!
;;     ;; struct-xmlParserCtxt-atts-ref
;;     ;; struct-xmlParserCtxt-maxatts-set!
;;     ;; struct-xmlParserCtxt-maxatts-ref
;;     ;; struct-xmlParserCtxt-docdict-set!
;;     ;; struct-xmlParserCtxt-docdict-ref
;;     ;; struct-xmlParserCtxt-str_xml-set!
;;     ;; struct-xmlParserCtxt-str_xml-ref
;;     ;; struct-xmlParserCtxt-str_xmlns-set!
;;     ;; struct-xmlParserCtxt-str_xmlns-ref
;;     ;; struct-xmlParserCtxt-str_xml_ns-set!
;;     ;; struct-xmlParserCtxt-str_xml_ns-ref
;;     ;; struct-xmlParserCtxt-sax2-set!
;;     ;; struct-xmlParserCtxt-sax2-ref
;;     ;; struct-xmlParserCtxt-nsNr-set!
;;     ;; struct-xmlParserCtxt-nsNr-ref
;;     ;; struct-xmlParserCtxt-nsMax-set!
;;     ;; struct-xmlParserCtxt-nsMax-ref
;;     ;; struct-xmlParserCtxt-nsTab-set!
;;     ;; struct-xmlParserCtxt-nsTab-ref
;;     ;; struct-xmlParserCtxt-attallocs-set!
;;     ;; struct-xmlParserCtxt-attallocs-ref
;;     ;; struct-xmlParserCtxt-pushTab-set!
;;     ;; struct-xmlParserCtxt-pushTab-ref
;;     ;; struct-xmlParserCtxt-attsDefault-set!
;;     ;; struct-xmlParserCtxt-attsDefault-ref
;;     ;; struct-xmlParserCtxt-attsSpecial-set!
;;     ;; struct-xmlParserCtxt-attsSpecial-ref
;;     ;; struct-xmlParserCtxt-nsWellFormed-set!
;;     ;; struct-xmlParserCtxt-nsWellFormed-ref
;;     ;; struct-xmlParserCtxt-options-set!
;;     ;; struct-xmlParserCtxt-options-ref
;;     ;; struct-xmlParserCtxt-dictNames-set!
;;     ;; struct-xmlParserCtxt-dictNames-ref
;;     ;; struct-xmlParserCtxt-freeElemsNr-set!
;;     ;; struct-xmlParserCtxt-freeElemsNr-ref
;;     ;; struct-xmlParserCtxt-freeElems-set!
;;     ;; struct-xmlParserCtxt-freeElems-ref
;;     ;; struct-xmlParserCtxt-freeAttrsNr-set!
;;     ;; struct-xmlParserCtxt-freeAttrsNr-ref
;;     ;; struct-xmlParserCtxt-freeAttrs-set!
;;     ;; struct-xmlParserCtxt-freeAttrs-ref
;;     ;; struct-xmlParserCtxt-lastError-ref
;;     ;; struct-xmlParserCtxt-xmlParserMode-ref
;;     ;; struct-xmlParserCtxt-nbentities-set!
;;     ;; struct-xmlParserCtxt-nbentities-ref
;;     ;; struct-xmlParserCtxt-sizeentities-set!
;;     ;; struct-xmlParserCtxt-sizeentities-ref
;;     ;; struct-xmlSAXLocator-getPublicId-set!
;;     ;; struct-xmlSAXLocator-getPublicId-ref
;;     ;; struct-xmlSAXLocator-getSystemId-set!
;;     ;; struct-xmlSAXLocator-getSystemId-ref
;;     ;; struct-xmlSAXLocator-getLineNumber-set!
;;     ;; struct-xmlSAXLocator-getLineNumber-ref
;;     ;; struct-xmlSAXLocator-getColumnNumber-set!
;;     ;; struct-xmlSAXLocator-getColumnNumber-ref





;;     ;; struct-xmlBuffer-content-set!
;;     ;; struct-xmlBuffer-content-ref
;;     ;; struct-xmlBuffer-use-set!
;;     ;; struct-xmlBuffer-use-ref
;;     ;; struct-xmlBuffer-size-set!
;;     ;; struct-xmlBuffer-size-ref
;;     ;; struct-xmlBuffer-alloc-ref
;;     ;; struct-xmlBuffer-contentIO-set!
;;     ;; struct-xmlBuffer-contentIO-ref

;;     ;; struct-xmlNotation-name-set!
;;     ;; struct-xmlNotation-name-ref
;;     ;; struct-xmlNotation-PublicID-set!
;;     ;; struct-xmlNotation-PublicID-ref
;;     ;; struct-xmlNotation-SystemID-set!
;;     ;; struct-xmlNotation-SystemID-ref

;;     ;; struct-xmlEnumeration-next-set!
;;     ;; struct-xmlEnumeration-next-ref
;;     ;; struct-xmlEnumeration-name-set!
;;     ;; struct-xmlEnumeration-name-ref
;;     ;; struct-xmlAttribute-_private-set!
;;     ;; struct-xmlAttribute-_private-ref
;;     ;; struct-xmlAttribute-type-ref
;;     ;; struct-xmlAttribute-name-set!
;;     ;; struct-xmlAttribute-name-ref
;;     ;; struct-xmlAttribute-children-set!
;;     ;; struct-xmlAttribute-children-ref
;;     ;; struct-xmlAttribute-last-set!
;;     ;; struct-xmlAttribute-last-ref
;;     ;; struct-xmlAttribute-parent-set!
;;     ;; struct-xmlAttribute-parent-ref
;;     ;; struct-xmlAttribute-next-set!
;;     ;; struct-xmlAttribute-next-ref
;;     ;; struct-xmlAttribute-prev-set!
;;     ;; struct-xmlAttribute-prev-ref
;;     ;; struct-xmlAttribute-doc-set!
;;     ;; struct-xmlAttribute-doc-ref
;;     ;; struct-xmlAttribute-nexth-set!
;;     ;; struct-xmlAttribute-nexth-ref
;;     ;; struct-xmlAttribute-atype-ref
;;     ;; struct-xmlAttribute-def-ref
;;     ;; struct-xmlAttribute-defaultValue-set!
;;     ;; struct-xmlAttribute-defaultValue-ref
;;     ;; struct-xmlAttribute-tree-set!
;;     ;; struct-xmlAttribute-tree-ref
;;     ;; struct-xmlAttribute-prefix-set!
;;     ;; struct-xmlAttribute-prefix-ref
;;     ;; struct-xmlAttribute-elem-set!
;;     ;; struct-xmlAttribute-elem-ref

;;     ;; struct-xmlElementContent-type-ref
;;     ;; struct-xmlElementContent-ocur-ref
;;     ;; struct-xmlElementContent-name-set!
;;     ;; struct-xmlElementContent-name-ref
;;     ;; struct-xmlElementContent-c1-set!
;;     ;; struct-xmlElementContent-c1-ref
;;     ;; struct-xmlElementContent-c2-set!
;;     ;; struct-xmlElementContent-c2-ref
;;     ;; struct-xmlElementContent-parent-set!
;;     ;; struct-xmlElementContent-parent-ref
;;     ;; struct-xmlElementContent-prefix-set!
;;     ;; struct-xmlElementContent-prefix-ref

;;     ;; struct-xmlElement-_private-set!
;;     ;; struct-xmlElement-_private-ref
;;     ;; struct-xmlElement-type-ref
;;     ;; struct-xmlElement-name-set!
;;     ;; struct-xmlElement-name-ref
;;     ;; struct-xmlElement-children-set!
;;     ;; struct-xmlElement-children-ref
;;     ;; struct-xmlElement-last-set!
;;     ;; struct-xmlElement-last-ref
;;     ;; struct-xmlElement-parent-set!
;;     ;; struct-xmlElement-parent-ref
;;     ;; struct-xmlElement-next-set!
;;     ;; struct-xmlElement-next-ref
;;     ;; struct-xmlElement-prev-set!
;;     ;; struct-xmlElement-prev-ref
;;     ;; struct-xmlElement-doc-set!
;;     ;; struct-xmlElement-doc-ref
;;     ;; struct-xmlElement-etype-ref
;;     ;; struct-xmlElement-content-set!
;;     ;; struct-xmlElement-content-ref
;;     ;; struct-xmlElement-attributes-set!
;;     ;; struct-xmlElement-attributes-ref
;;     ;; struct-xmlElement-prefix-set!
;;     ;; struct-xmlElement-prefix-ref
;;     ;; struct-xmlElement-contModel-set!
;;     ;; struct-xmlElement-contModel-ref
;;     ;; struct-xmlNs-next-set!
;;     ;; struct-xmlNs-next-ref
;;     ;; struct-xmlNs-type-ref
;;     ;; struct-xmlNs-href-set!
;;     ;; struct-xmlNs-href-ref
;;     ;; struct-xmlNs-prefix-set!
;;     ;; struct-xmlNs-prefix-ref
;;     ;; struct-xmlNs-_private-set!
;;     ;; struct-xmlNs-_private-ref
;;     ;; struct-xmlNs-context-set!
;;     ;; struct-xmlNs-context-ref
;;     ;; struct-xmlDtd-_private-set!
;;     ;; struct-xmlDtd-_private-ref
;;     ;; struct-xmlDtd-type-ref
;;     ;; struct-xmlDtd-name-set!
;;     ;; struct-xmlDtd-name-ref
;;     ;; struct-xmlDtd-children-set!
;;     ;; struct-xmlDtd-children-ref
;;     ;; struct-xmlDtd-last-set!
;;     ;; struct-xmlDtd-last-ref
;;     ;; struct-xmlDtd-parent-set!
;;     ;; struct-xmlDtd-parent-ref
;;     ;; struct-xmlDtd-next-set!
;;     ;; struct-xmlDtd-next-ref
;;     ;; struct-xmlDtd-prev-set!
;;     ;; struct-xmlDtd-prev-ref
;;     ;; struct-xmlDtd-doc-set!
;;     ;; struct-xmlDtd-doc-ref
;;     ;; struct-xmlDtd-notations-set!
;;     ;; struct-xmlDtd-notations-ref
;;     ;; struct-xmlDtd-elements-set!
;;     ;; struct-xmlDtd-elements-ref
;;     ;; struct-xmlDtd-attributes-set!
;;     ;; struct-xmlDtd-attributes-ref
;;     ;; struct-xmlDtd-entities-set!
;;     ;; struct-xmlDtd-entities-ref
;;     ;; struct-xmlDtd-ExternalID-set!
;;     ;; struct-xmlDtd-ExternalID-ref
;;     ;; struct-xmlDtd-SystemID-set!
;;     ;; struct-xmlDtd-SystemID-ref
;;     ;; struct-xmlDtd-pentities-set!
;;     ;; struct-xmlDtd-pentities-ref
;;     ;; struct-xmlAttr-_private-set!
;;     ;; struct-xmlAttr-_private-ref
;;     ;; struct-xmlAttr-type-ref
;;     ;; struct-xmlAttr-name-set!
;;     ;; struct-xmlAttr-name-ref
;;     ;; struct-xmlAttr-children-set!
;;     ;; struct-xmlAttr-children-ref
;;     ;; struct-xmlAttr-last-set!
;;     ;; struct-xmlAttr-last-ref
;;     ;; struct-xmlAttr-parent-set!
;;     ;; struct-xmlAttr-parent-ref
;;     ;; struct-xmlAttr-next-set!
;;     ;; struct-xmlAttr-next-ref
;;     ;; struct-xmlAttr-prev-set!
;;     ;; struct-xmlAttr-prev-ref
;;     ;; struct-xmlAttr-doc-set!
;;     ;; struct-xmlAttr-doc-ref
;;     ;; struct-xmlAttr-ns-set!
;;     ;; struct-xmlAttr-ns-ref
;;     ;; struct-xmlAttr-atype-ref
;;     ;; struct-xmlAttr-psvi-set!
;;     ;; struct-xmlAttr-psvi-ref
;;     ;; struct-xmlID-next-set!
;;     ;; struct-xmlID-next-ref
;;     ;; struct-xmlID-value-set!
;;     ;; struct-xmlID-value-ref
;;     ;; struct-xmlID-attr-ref
;;     ;; struct-xmlID-name-set!
;;     ;; struct-xmlID-name-ref
;;     ;; struct-xmlID-lineno-set!
;;     ;; struct-xmlID-lineno-ref
;;     ;; struct-xmlID-doc-set!
;;     ;; struct-xmlID-doc-ref
;;     ;; struct-xmlRef-next-set!
;;     ;; struct-xmlRef-next-ref
;;     ;; struct-xmlRef-value-set!
;;     ;; struct-xmlRef-value-ref
;;     ;; struct-xmlRef-attr-ref
;;     ;; struct-xmlRef-name-set!
;;     ;; struct-xmlRef-name-ref
;;     ;; struct-xmlRef-lineno-set!
;;     ;; struct-xmlRef-lineno-ref

;; (define)

;;     ;; struct-xmlNode-_private-set!
;;     ;; struct-xmlNode-_private-ref
;;     ;; struct-xmlNode-type-ref
;;     ;; struct-xmlNode-name-set!
;;     ;; struct-xmlNode-name-ref
;;     ;; struct-xmlNode-children-set!
;;     ;; struct-xmlNode-children-ref
;;     ;; struct-xmlNode-last-set!
;;     ;; struct-xmlNode-last-ref
;;     ;; struct-xmlNode-parent-set!
;;     ;; struct-xmlNode-parent-ref
;;     ;; struct-xmlNode-next-set!
;;     ;; struct-xmlNode-next-ref
;;     ;; struct-xmlNode-prev-set!
;;     ;; struct-xmlNode-prev-ref
;;     ;; struct-xmlNode-doc-set!
;;     ;; struct-xmlNode-doc-ref
;;     ;; struct-xmlNode-ns-set!
;;     ;; struct-xmlNode-ns-ref
;;     ;; struct-xmlNode-content-set!
;;     ;; struct-xmlNode-content-ref
;;     ;; struct-xmlNode-properties-set!
;;     ;; struct-xmlNode-properties-ref
;;     ;; struct-xmlNode-nsDef-set!
;;     ;; struct-xmlNode-nsDef-ref
;;     ;; struct-xmlNode-psvi-set!
;;     ;; struct-xmlNode-psvi-ref
;;     ;; struct-xmlNode-line-set!
;;     ;; struct-xmlNode-line-ref
;;     ;; struct-xmlNode-extra-set!
;;     ;; struct-xmlNode-extra-ref

;;     ;; struct-xmlDoc-_private-set!
;;     ;; struct-xmlDoc-_private-ref
;;     ;; struct-xmlDoc-type-ref
;;     ;; struct-xmlDoc-name-set!
;;     ;; struct-xmlDoc-name-ref
;;     ;; struct-xmlDoc-children-set!
;;     ;; struct-xmlDoc-children-ref
;;     ;; struct-xmlDoc-last-set!
;;     ;; struct-xmlDoc-last-ref
;;     ;; struct-xmlDoc-parent-set!
;;     ;; struct-xmlDoc-parent-ref
;;     ;; struct-xmlDoc-next-set!
;;     ;; struct-xmlDoc-next-ref
;;     ;; struct-xmlDoc-prev-set!
;;     ;; struct-xmlDoc-prev-ref
;;     ;; struct-xmlDoc-doc-set!
;;     ;; struct-xmlDoc-doc-ref
;;     ;; struct-xmlDoc-compression-set!
;;     ;; struct-xmlDoc-compression-ref
;;     ;; struct-xmlDoc-standalone-set!
;;     ;; struct-xmlDoc-standalone-ref
;;     ;; struct-xmlDoc-intSubset-set!
;;     ;; struct-xmlDoc-intSubset-ref
;;     ;; struct-xmlDoc-extSubset-set!
;;     ;; struct-xmlDoc-extSubset-ref
;;     ;; struct-xmlDoc-oldNs-set!
;;     ;; struct-xmlDoc-oldNs-ref
;;     ;; struct-xmlDoc-version-set!
;;     ;; struct-xmlDoc-version-ref
;;     ;; struct-xmlDoc-encoding-set!
;;     ;; struct-xmlDoc-encoding-ref
;;     ;; struct-xmlDoc-ids-set!
;;     ;; struct-xmlDoc-ids-ref
;;     ;; struct-xmlDoc-refs-set!
;;     ;; struct-xmlDoc-refs-ref
;;     ;; struct-xmlDoc-URL-set!
;;     ;; struct-xmlDoc-URL-ref
;;     ;; struct-xmlDoc-charset-set!
;;     ;; struct-xmlDoc-charset-ref
;;     ;; struct-xmlDoc-dict-set!
;;     ;; struct-xmlDoc-dict-ref
;;     ;; struct-xmlDoc-psvi-set!
;;     ;; struct-xmlDoc-psvi-ref
;;     ;; struct-xmlDoc-parseFlags-set!
;;     ;; struct-xmlDoc-parseFlags-ref
;;     ;; struct-xmlDoc-properties-set!
;;     ;; struct-xmlDoc-properties-ref
;;     ;; struct-xmlDOMWrapCtxt-_private-set!
;;     ;; struct-xmlDOMWrapCtxt-_private-ref
;;     ;; struct-xmlDOMWrapCtxt-type-set!
;;     ;; struct-xmlDOMWrapCtxt-type-ref
;;     ;; struct-xmlDOMWrapCtxt-namespaceMap-set!
;;     ;; struct-xmlDOMWrapCtxt-namespaceMap-ref
;;     ;; struct-xmlDOMWrapCtxt-getNsForNodeFunc-set!
;;     ;; struct-xmlDOMWrapCtxt-getNsForNodeFunc-ref
;;     ;; struct-xmlURI-scheme-set!
;;     ;; struct-xmlURI-scheme-ref
;;     ;; struct-xmlURI-opaque-set!
;;     ;; struct-xmlURI-opaque-ref
;;     ;; struct-xmlURI-authority-set!
;;     ;; struct-xmlURI-authority-ref
;;     ;; struct-xmlURI-server-set!
;;     ;; struct-xmlURI-server-ref
;;     ;; struct-xmlURI-user-set!
;;     ;; struct-xmlURI-user-ref
;;     ;; struct-xmlURI-port-set!
;;     ;; struct-xmlURI-port-ref
;;     ;; struct-xmlURI-path-set!
;;     ;; struct-xmlURI-path-ref
;;     ;; struct-xmlURI-query-set!
;;     ;; struct-xmlURI-query-ref
;;     ;; struct-xmlURI-fragment-set!
;;     ;; struct-xmlURI-fragment-ref
;;     ;; struct-xmlURI-cleanup-set!
;;     ;; struct-xmlURI-cleanup-ref
;;     ;; struct-xmlURI-query_raw-set!
;;     ;; struct-xmlURI-query_raw-ref
;;     ;; struct-xmlValidCtxt-userData-set!
;;     ;; struct-xmlValidCtxt-userData-ref
;;     ;; struct-xmlValidCtxt-error-set!
;;     ;; struct-xmlValidCtxt-error-ref
;;     ;; struct-xmlValidCtxt-warning-set!
;;     ;; struct-xmlValidCtxt-warning-ref
;;     ;; struct-xmlValidCtxt-node-set!
;;     ;; struct-xmlValidCtxt-node-ref
;;     ;; struct-xmlValidCtxt-nodeNr-set!
;;     ;; struct-xmlValidCtxt-nodeNr-ref
;;     ;; struct-xmlValidCtxt-nodeMax-set!
;;     ;; struct-xmlValidCtxt-nodeMax-ref
;;     ;; struct-xmlValidCtxt-nodeTab-set!
;;     ;; struct-xmlValidCtxt-nodeTab-ref
;;     ;; struct-xmlValidCtxt-finishDtd-set!
;;     ;; struct-xmlValidCtxt-finishDtd-ref
;;     ;; struct-xmlValidCtxt-doc-set!
;;     ;; struct-xmlValidCtxt-doc-ref
;;     ;; struct-xmlValidCtxt-valid-set!
;;     ;; struct-xmlValidCtxt-valid-ref
;;     ;; struct-xmlValidCtxt-vstate-set!
;;     ;; struct-xmlValidCtxt-vstate-ref
;;     ;; struct-xmlValidCtxt-vstateNr-set!
;;     ;; struct-xmlValidCtxt-vstateNr-ref
;;     ;; struct-xmlValidCtxt-vstateMax-set!
;;     ;; struct-xmlValidCtxt-vstateMax-ref
;;     ;; struct-xmlValidCtxt-vstateTab-set!
;;     ;; struct-xmlValidCtxt-vstateTab-ref
;;     ;; struct-xmlValidCtxt-am-set!
;;     ;; struct-xmlValidCtxt-am-ref
;;     ;; struct-xmlValidCtxt-state-set!
;;     ;; struct-xmlValidCtxt-state-ref

;;     ;; struct-xmlError-domain-set!
;;     ;; struct-xmlError-domain-ref
;;     ;; struct-xmlError-code-set!
;;     ;; struct-xmlError-code-ref
;;     ;; struct-xmlError-message-set!
;;     ;; struct-xmlError-message-ref
;;     ;; struct-xmlError-level-set!
;;     ;; struct-xmlError-level-ref
;;     ;; struct-xmlError-file-set!
;;     ;; struct-xmlError-file-ref
;;     ;; struct-xmlError-line-set!
;;     ;; struct-xmlError-line-ref
;;     ;; struct-xmlError-str1-set!
;;     ;; struct-xmlError-str1-ref
;;     ;; struct-xmlError-str2-set!
;;     ;; struct-xmlError-str2-ref
;;     ;; struct-xmlError-str3-set!
;;     ;; struct-xmlError-str3-ref
;;     ;; struct-xmlError-int1-set!
;;     ;; struct-xmlError-int1-ref
;;     ;; struct-xmlError-int2-set!
;;     ;; struct-xmlError-int2-ref
;;     ;; struct-xmlError-ctxt-set!
;;     ;; struct-xmlError-ctxt-ref
;;     ;; struct-xmlError-node-set!
;;     ;; struct-xmlError-node-ref

;;     ;; struct-xmlParserInputBuffer-context-set!
;;     ;; struct-xmlParserInputBuffer-context-ref
;;     ;; struct-xmlParserInputBuffer-readcallback-set!
;;     ;; struct-xmlParserInputBuffer-readcallback-ref
;;     ;; struct-xmlParserInputBuffer-closecallback-set!
;;     ;; struct-xmlParserInputBuffer-closecallback-ref
;;     ;; struct-xmlParserInputBuffer-encoder-set!
;;     ;; struct-xmlParserInputBuffer-encoder-ref
;;     ;; struct-xmlParserInputBuffer-buffer-set!
;;     ;; struct-xmlParserInputBuffer-buffer-ref
;;     ;; struct-xmlParserInputBuffer-raw-set!
;;     ;; struct-xmlParserInputBuffer-raw-ref
;;     ;; struct-xmlParserInputBuffer-compressed-set!
;;     ;; struct-xmlParserInputBuffer-compressed-ref
;;     ;; struct-xmlParserInputBuffer-error-set!
;;     ;; struct-xmlParserInputBuffer-error-ref
;;     ;; struct-xmlParserInputBuffer-rawconsumed-set!
;;     ;; struct-xmlParserInputBuffer-rawconsumed-ref
;;     ;; struct-xmlOutputBuffer-context-set!
;;     ;; struct-xmlOutputBuffer-context-ref
;;     ;; struct-xmlOutputBuffer-writecallback-set!
;;     ;; struct-xmlOutputBuffer-writecallback-ref
;;     ;; struct-xmlOutputBuffer-closecallback-set!
;;     ;; struct-xmlOutputBuffer-closecallback-ref
;;     ;; struct-xmlOutputBuffer-encoder-set!
;;     ;; struct-xmlOutputBuffer-encoder-ref
;;     ;; struct-xmlOutputBuffer-buffer-set!
;;     ;; struct-xmlOutputBuffer-buffer-ref
;;     ;; struct-xmlOutputBuffer-conv-set!
;;     ;; struct-xmlOutputBuffer-conv-ref
;;     ;; struct-xmlOutputBuffer-written-set!
;;     ;; struct-xmlOutputBuffer-written-ref
;;     ;; struct-xmlOutputBuffer-error-set!
;;     ;; struct-xmlOutputBuffer-error-ref







;;     ;; struct-xmlSchemaAnnot-next-set!
;;     ;; struct-xmlSchemaAnnot-next-ref
;;     ;; struct-xmlSchemaAnnot-content-set!
;;     ;; struct-xmlSchemaAnnot-content-ref
;;     ;; struct-xmlSchemaAttribute-type-set!
;;     ;; struct-xmlSchemaAttribute-type-ref
;;     ;; struct-xmlSchemaAttribute-next-set!
;;     ;; struct-xmlSchemaAttribute-next-ref
;;     ;; struct-xmlSchemaAttribute-name-set!
;;     ;; struct-xmlSchemaAttribute-name-ref
;;     ;; struct-xmlSchemaAttribute-id-set!
;;     ;; struct-xmlSchemaAttribute-id-ref
;;     ;; struct-xmlSchemaAttribute-ref-set!
;;     ;; struct-xmlSchemaAttribute-ref-ref
;;     ;; struct-xmlSchemaAttribute-refNs-set!
;;     ;; struct-xmlSchemaAttribute-refNs-ref
;;     ;; struct-xmlSchemaAttribute-typeName-set!
;;     ;; struct-xmlSchemaAttribute-typeName-ref
;;     ;; struct-xmlSchemaAttribute-typeNs-set!
;;     ;; struct-xmlSchemaAttribute-typeNs-ref
;;     ;; struct-xmlSchemaAttribute-annot-set!
;;     ;; struct-xmlSchemaAttribute-annot-ref
;;     ;; struct-xmlSchemaAttribute-base-set!
;;     ;; struct-xmlSchemaAttribute-base-ref
;;     ;; struct-xmlSchemaAttribute-occurs-set!
;;     ;; struct-xmlSchemaAttribute-occurs-ref
;;     ;; struct-xmlSchemaAttribute-defValue-set!
;;     ;; struct-xmlSchemaAttribute-defValue-ref
;;     ;; struct-xmlSchemaAttribute-subtypes-set!
;;     ;; struct-xmlSchemaAttribute-subtypes-ref
;;     ;; struct-xmlSchemaAttribute-node-set!
;;     ;; struct-xmlSchemaAttribute-node-ref
;;     ;; struct-xmlSchemaAttribute-targetNamespace-set!
;;     ;; struct-xmlSchemaAttribute-targetNamespace-ref
;;     ;; struct-xmlSchemaAttribute-flags-set!
;;     ;; struct-xmlSchemaAttribute-flags-ref
;;     ;; struct-xmlSchemaAttribute-refPrefix-set!
;;     ;; struct-xmlSchemaAttribute-refPrefix-ref
;;     ;; struct-xmlSchemaAttribute-defVal-set!
;;     ;; struct-xmlSchemaAttribute-defVal-ref
;;     ;; struct-xmlSchemaAttribute-refDecl-set!
;;     ;; struct-xmlSchemaAttribute-refDecl-ref
;;     ;; struct-xmlSchemaAttributeLink-next-set!
;;     ;; struct-xmlSchemaAttributeLink-next-ref
;;     ;; struct-xmlSchemaAttributeLink-attr-set!
;;     ;; struct-xmlSchemaAttributeLink-attr-ref
;;     ;; struct-xmlSchemaWildcardNs-next-set!
;;     ;; struct-xmlSchemaWildcardNs-next-ref
;;     ;; struct-xmlSchemaWildcardNs-value-set!
;;     ;; struct-xmlSchemaWildcardNs-value-ref
;;     ;; struct-xmlSchemaWildcard-type-set!
;;     ;; struct-xmlSchemaWildcard-type-ref
;;     ;; struct-xmlSchemaWildcard-id-set!
;;     ;; struct-xmlSchemaWildcard-id-ref
;;     ;; struct-xmlSchemaWildcard-annot-set!
;;     ;; struct-xmlSchemaWildcard-annot-ref
;;     ;; struct-xmlSchemaWildcard-xmlNodePtr-set!
;;     ;; struct-xmlSchemaWildcard-xmlNodePtr-ref
;;     ;; struct-xmlSchemaWildcard-minOccurs-set!
;;     ;; struct-xmlSchemaWildcard-minOccurs-ref
;;     ;; struct-xmlSchemaWildcard-maxOccurs-set!
;;     ;; struct-xmlSchemaWildcard-maxOccurs-ref
;;     ;; struct-xmlSchemaWildcard-processContents-set!
;;     ;; struct-xmlSchemaWildcard-processContents-ref
;;     ;; struct-xmlSchemaWildcard-any-set!
;;     ;; struct-xmlSchemaWildcard-any-ref
;;     ;; struct-xmlSchemaWildcard-nsSet-set!
;;     ;; struct-xmlSchemaWildcard-nsSet-ref
;;     ;; struct-xmlSchemaWildcard-negNsSet-set!
;;     ;; struct-xmlSchemaWildcard-negNsSet-ref
;;     ;; struct-xmlSchemaWildcard-flags-set!
;;     ;; struct-xmlSchemaWildcard-flags-ref
;;     ;; struct-xmlSchemaAttributeGroup-type-set!
;;     ;; struct-xmlSchemaAttributeGroup-type-ref
;;     ;; struct-xmlSchemaAttributeGroup-next-set!
;;     ;; struct-xmlSchemaAttributeGroup-next-ref
;;     ;; struct-xmlSchemaAttributeGroup-name-set!
;;     ;; struct-xmlSchemaAttributeGroup-name-ref
;;     ;; struct-xmlSchemaAttributeGroup-id-set!
;;     ;; struct-xmlSchemaAttributeGroup-id-ref
;;     ;; struct-xmlSchemaAttributeGroup-ref-set!
;;     ;; struct-xmlSchemaAttributeGroup-ref-ref
;;     ;; struct-xmlSchemaAttributeGroup-refNs-set!
;;     ;; struct-xmlSchemaAttributeGroup-refNs-ref
;;     ;; struct-xmlSchemaAttributeGroup-annot-set!
;;     ;; struct-xmlSchemaAttributeGroup-annot-ref
;;     ;; struct-xmlSchemaAttributeGroup-attributes-set!
;;     ;; struct-xmlSchemaAttributeGroup-attributes-ref
;;     ;; struct-xmlSchemaAttributeGroup-node-set!
;;     ;; struct-xmlSchemaAttributeGroup-node-ref
;;     ;; struct-xmlSchemaAttributeGroup-flags-set!
;;     ;; struct-xmlSchemaAttributeGroup-flags-ref
;;     ;; struct-xmlSchemaAttributeGroup-attributeWildcard-set!
;;     ;; struct-xmlSchemaAttributeGroup-attributeWildcard-ref
;;     ;; struct-xmlSchemaAttributeGroup-refPrefix-set!
;;     ;; struct-xmlSchemaAttributeGroup-refPrefix-ref
;;     ;; struct-xmlSchemaAttributeGroup-refItem-set!
;;     ;; struct-xmlSchemaAttributeGroup-refItem-ref
;;     ;; struct-xmlSchemaAttributeGroup-targetNamespace-set!
;;     ;; struct-xmlSchemaAttributeGroup-targetNamespace-ref
;;     ;; struct-xmlSchemaAttributeGroup-attrUses-set!
;;     ;; struct-xmlSchemaAttributeGroup-attrUses-ref
;;     ;; struct-xmlSchemaTypeLink-next-set!
;;     ;; struct-xmlSchemaTypeLink-next-ref
;;     ;; struct-xmlSchemaTypeLink-type-set!
;;     ;; struct-xmlSchemaTypeLink-type-ref
;;     ;; struct-xmlSchemaFacetLink-next-set!
;;     ;; struct-xmlSchemaFacetLink-next-ref
;;     ;; struct-xmlSchemaFacetLink-facet-set!
;;     ;; struct-xmlSchemaFacetLink-facet-ref
;;     ;; struct-xmlSchemaElement-type-set!
;;     ;; struct-xmlSchemaElement-type-ref
;;     ;; struct-xmlSchemaElement-next-set!
;;     ;; struct-xmlSchemaElement-next-ref
;;     ;; struct-xmlSchemaElement-name-set!
;;     ;; struct-xmlSchemaElement-name-ref
;;     ;; struct-xmlSchemaElement-id-set!
;;     ;; struct-xmlSchemaElement-id-ref
;;     ;; struct-xmlSchemaElement-ref-set!
;;     ;; struct-xmlSchemaElement-ref-ref
;;     ;; struct-xmlSchemaElement-refNs-set!
;;     ;; struct-xmlSchemaElement-refNs-ref
;;     ;; struct-xmlSchemaElement-annot-set!
;;     ;; struct-xmlSchemaElement-annot-ref
;;     ;; struct-xmlSchemaElement-subtypes-set!
;;     ;; struct-xmlSchemaElement-subtypes-ref
;;     ;; struct-xmlSchemaElement-attributes-set!
;;     ;; struct-xmlSchemaElement-attributes-ref
;;     ;; struct-xmlSchemaElement-node-set!
;;     ;; struct-xmlSchemaElement-node-ref
;;     ;; struct-xmlSchemaElement-minOccurs-set!
;;     ;; struct-xmlSchemaElement-minOccurs-ref
;;     ;; struct-xmlSchemaElement-maxOccurs-set!
;;     ;; struct-xmlSchemaElement-maxOccurs-ref
;;     ;; struct-xmlSchemaElement-flags-set!
;;     ;; struct-xmlSchemaElement-flags-ref
;;     ;; struct-xmlSchemaElement-targetNamespace-set!
;;     ;; struct-xmlSchemaElement-targetNamespace-ref
;;     ;; struct-xmlSchemaElement-namedType-set!
;;     ;; struct-xmlSchemaElement-namedType-ref
;;     ;; struct-xmlSchemaElement-namedTypeNs-set!
;;     ;; struct-xmlSchemaElement-namedTypeNs-ref
;;     ;; struct-xmlSchemaElement-substGroup-set!
;;     ;; struct-xmlSchemaElement-substGroup-ref
;;     ;; struct-xmlSchemaElement-substGroupNs-set!
;;     ;; struct-xmlSchemaElement-substGroupNs-ref
;;     ;; struct-xmlSchemaElement-scope-set!
;;     ;; struct-xmlSchemaElement-scope-ref
;;     ;; struct-xmlSchemaElement-value-set!
;;     ;; struct-xmlSchemaElement-value-ref
;;     ;; struct-xmlSchemaElement-refDecl-set!
;;     ;; struct-xmlSchemaElement-refDecl-ref
;;     ;; struct-xmlSchemaElement-contModel-set!
;;     ;; struct-xmlSchemaElement-contModel-ref
;;     ;; struct-xmlSchemaElement-contentType-set!
;;     ;; struct-xmlSchemaElement-contentType-ref
;;     ;; struct-xmlSchemaElement-refPrefix-set!
;;     ;; struct-xmlSchemaElement-refPrefix-ref
;;     ;; struct-xmlSchemaElement-defVal-set!
;;     ;; struct-xmlSchemaElement-defVal-ref
;;     ;; struct-xmlSchemaElement-idcs-set!
;;     ;; struct-xmlSchemaElement-idcs-ref
;;     ;; struct-xmlSchemaNotation-type-set!
;;     ;; struct-xmlSchemaNotation-type-ref
;;     ;; struct-xmlSchemaNotation-name-set!
;;     ;; struct-xmlSchemaNotation-name-ref
;;     ;; struct-xmlSchemaNotation-annot-set!
;;     ;; struct-xmlSchemaNotation-annot-ref
;;     ;; struct-xmlSchemaNotation-identifier-set!
;;     ;; struct-xmlSchemaNotation-identifier-ref
;;     ;; struct-xmlSchemaNotation-targetNamespace-set!
;;     ;; struct-xmlSchemaNotation-targetNamespace-ref



;;     ;; struct-xmlNodeSet-nodeNr-set!
;;     ;; struct-xmlNodeSet-nodeNr-ref
;;     ;; struct-xmlNodeSet-nodeMax-set!
;;     ;; struct-xmlNodeSet-nodeMax-ref
;;     ;; struct-xmlNodeSet-nodeTab-set!
;;     ;; struct-xmlNodeSet-nodeTab-ref

;;     ;; struct-xmlXPathObject-type-set!
;;     ;; struct-xmlXPathObject-type-ref
;;     ;; struct-xmlXPathObject-nodesetval-set!
;;     ;; struct-xmlXPathObject-nodesetval-ref
;;     ;; struct-xmlXPathObject-boolval-set!
;;     ;; struct-xmlXPathObject-boolval-ref
;;     ;; struct-xmlXPathObject-floatval-set!
;;     ;; struct-xmlXPathObject-floatval-ref
;;     ;; struct-xmlXPathObject-stringval-set!
;;     ;; struct-xmlXPathObject-stringval-ref
;;     ;; struct-xmlXPathObject-user-set!
;;     ;; struct-xmlXPathObject-user-ref
;;     ;; struct-xmlXPathObject-index-set!
;;     ;; struct-xmlXPathObject-index-ref
;;     ;; struct-xmlXPathObject-user2-set!
;;     ;; struct-xmlXPathObject-user2-ref
;;     ;; struct-xmlXPathObject-index2-set!
;;     ;; struct-xmlXPathObject-index2-ref
;;     ;; struct-xmlXPathType-name-set!
;;     ;; struct-xmlXPathType-name-ref
;;     ;; struct-xmlXPathType-func-set!
;;     ;; struct-xmlXPathType-func-ref
;;     ;; struct-xmlXPathVariable-name-set!
;;     ;; struct-xmlXPathVariable-name-ref
;;     ;; struct-xmlXPathVariable-value-set!
;;     ;; struct-xmlXPathVariable-value-ref
;;     ;; struct-xmlXPathFunct-name-set!
;;     ;; struct-xmlXPathFunct-name-ref
;;     ;; struct-xmlXPathFunct-func-set!
;;     ;; struct-xmlXPathFunct-func-ref
;;     ;; struct-xmlXPathAxis-name-set!
;;     ;; struct-xmlXPathAxis-name-ref
;;     ;; struct-xmlXPathAxis-func-set!
;;     ;; struct-xmlXPathAxis-func-ref
;;     ;; struct-xmlXPathContext-doc-set!
;;     ;; struct-xmlXPathContext-doc-ref
;;     ;; struct-xmlXPathContext-node-set!
;;     ;; struct-xmlXPathContext-node-ref
;;     ;; struct-xmlXPathContext-nb_variables_unused-set!
;;     ;; struct-xmlXPathContext-nb_variables_unused-ref
;;     ;; struct-xmlXPathContext-max_variables_unused-set!
;;     ;; struct-xmlXPathContext-max_variables_unused-ref
;;     ;; struct-xmlXPathContext-varHash-set!
;;     ;; struct-xmlXPathContext-varHash-ref
;;     ;; struct-xmlXPathContext-nb_types-set!
;;     ;; struct-xmlXPathContext-nb_types-ref
;;     ;; struct-xmlXPathContext-max_types-set!
;;     ;; struct-xmlXPathContext-max_types-ref
;;     ;; struct-xmlXPathContext-types-set!
;;     ;; struct-xmlXPathContext-types-ref
;;     ;; struct-xmlXPathContext-nb_funcs_unused-set!
;;     ;; struct-xmlXPathContext-nb_funcs_unused-ref
;;     ;; struct-xmlXPathContext-max_funcs_unused-set!
;;     ;; struct-xmlXPathContext-max_funcs_unused-ref
;;     ;; struct-xmlXPathContext-funcHash-set!
;;     ;; struct-xmlXPathContext-funcHash-ref
;;     ;; struct-xmlXPathContext-nb_axis-set!
;;     ;; struct-xmlXPathContext-nb_axis-ref
;;     ;; struct-xmlXPathContext-max_axis-set!
;;     ;; struct-xmlXPathContext-max_axis-ref
;;     ;; struct-xmlXPathContext-axis-set!
;;     ;; struct-xmlXPathContext-axis-ref
;;     ;; struct-xmlXPathContext-namespaces-set!
;;     ;; struct-xmlXPathContext-namespaces-ref
;;     ;; struct-xmlXPathContext-nsNr-set!
;;     ;; struct-xmlXPathContext-nsNr-ref
;;     ;; struct-xmlXPathContext-user-set!
;;     ;; struct-xmlXPathContext-user-ref
;;     ;; struct-xmlXPathContext-contextSize-set!
;;     ;; struct-xmlXPathContext-contextSize-ref
;;     ;; struct-xmlXPathContext-proximityPosition-set!
;;     ;; struct-xmlXPathContext-proximityPosition-ref
;;     ;; struct-xmlXPathContext-xptr-set!
;;     ;; struct-xmlXPathContext-xptr-ref
;;     ;; struct-xmlXPathContext-here-set!
;;     ;; struct-xmlXPathContext-here-ref
;;     ;; struct-xmlXPathContext-origin-set!
;;     ;; struct-xmlXPathContext-origin-ref
;;     ;; struct-xmlXPathContext-nsHash-set!
;;     ;; struct-xmlXPathContext-nsHash-ref
;;     ;; struct-xmlXPathContext-varLookupFunc-set!
;;     ;; struct-xmlXPathContext-varLookupFunc-ref
;;     ;; struct-xmlXPathContext-varLookupData-set!
;;     ;; struct-xmlXPathContext-varLookupData-ref
;;     ;; struct-xmlXPathContext-extra-set!
;;     ;; struct-xmlXPathContext-extra-ref
;;     ;; struct-xmlXPathContext-function-set!
;;     ;; struct-xmlXPathContext-function-ref
;;     ;; struct-xmlXPathContext-functionURI-set!
;;     ;; struct-xmlXPathContext-functionURI-ref
;;     ;; struct-xmlXPathContext-funcLookupFunc-set!
;;     ;; struct-xmlXPathContext-funcLookupFunc-ref
;;     ;; struct-xmlXPathContext-funcLookupData-set!
;;     ;; struct-xmlXPathContext-funcLookupData-ref
;;     ;; struct-xmlXPathContext-tmpNsList-set!
;;     ;; struct-xmlXPathContext-tmpNsList-ref
;;     ;; struct-xmlXPathContext-tmpNsNr-set!
;;     ;; struct-xmlXPathContext-tmpNsNr-ref
;;     ;; struct-xmlXPathContext-userData-set!
;;     ;; struct-xmlXPathContext-userData-ref
;;     ;; struct-xmlXPathContext-error-set!
;;     ;; struct-xmlXPathContext-error-ref
;;     ;; struct-xmlXPathContext-lastError-ref
;;     ;; struct-xmlXPathContext-debugNode-set!
;;     ;; struct-xmlXPathContext-debugNode-ref
;;     ;; struct-xmlXPathContext-dict-set!
;;     ;; struct-xmlXPathContext-dict-ref
;;     ;; struct-xmlXPathContext-flags-set!
;;     ;; struct-xmlXPathContext-flags-ref
;;     ;; struct-xmlXPathContext-cache-set!
;;     ;; struct-xmlXPathContext-cache-ref
;;     ;; struct-xmlXPathParserContext-cur-set!
;;     ;; struct-xmlXPathParserContext-cur-ref
;;     ;; struct-xmlXPathParserContext-base-set!
;;     ;; struct-xmlXPathParserContext-base-ref
;;     ;; struct-xmlXPathParserContext-error-set!
;;     ;; struct-xmlXPathParserContext-error-ref
;;     ;; struct-xmlXPathParserContext-context-set!
;;     ;; struct-xmlXPathParserContext-context-ref
;;     ;; struct-xmlXPathParserContext-value-set!
;;     ;; struct-xmlXPathParserContext-value-ref
;;     ;; struct-xmlXPathParserContext-valueNr-set!
;;     ;; struct-xmlXPathParserContext-valueNr-ref
;;     ;; struct-xmlXPathParserContext-valueMax-set!
;;     ;; struct-xmlXPathParserContext-valueMax-ref
;;     ;; struct-xmlXPathParserContext-valueTab-set!
;;     ;; struct-xmlXPathParserContext-valueTab-ref
;;     ;; struct-xmlXPathParserContext-comp-set!
;;     ;; struct-xmlXPathParserContext-comp-ref
;;     ;; struct-xmlXPathParserContext-xptr-set!
;;     ;; struct-xmlXPathParserContext-xptr-ref
;;     ;; struct-xmlXPathParserContext-ancestor-set!
;;     ;; struct-xmlXPathParserContext-ancestor-ref
;;     ;; struct-xmlLocationSet-locNr-set!
;;     ;; struct-xmlLocationSet-locNr-ref
;;     ;; struct-xmlLocationSet-locMax-set!
;;     ;; struct-xmlLocationSet-locMax-ref
;;     ;; struct-xmlLocationSet-locTab-set!
;;     ;; struct-xmlLocationSet-locTab-ref


;;;; done

)

;;; end of file
