;;;
;;;Part of: Nausicaa/Expat
;;;Contents: low level interface to Expat
;;;Date: Sun Jan  4, 2009
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


(library (foreign xml expat platform)
  (export
    XML_SetElementDeclHandler
    XML_SetAttlistDeclHandler
    XML_SetXmlDeclHandler
    XML_ParserCreate
    XML_ParserCreateNS
    XML_ParserCreate_MM
    XML_ParserReset
    XML_SetEntityDeclHandler
    XML_SetElementHandler
    XML_SetStartElementHandler
    XML_SetEndElementHandler
    XML_SetCharacterDataHandler
    XML_SetProcessingInstructionHandler
    XML_SetCommentHandler
    XML_SetCdataSectionHandler
    XML_SetStartCdataSectionHandler
    XML_SetEndCdataSectionHandler
    XML_SetDefaultHandler
    XML_SetDefaultHandlerExpand
    XML_SetDoctypeDeclHandler
    XML_SetStartDoctypeDeclHandler
    XML_SetEndDoctypeDeclHandler
    XML_SetUnparsedEntityDeclHandler
    XML_SetNotationDeclHandler
    XML_SetNamespaceDeclHandler
    XML_SetStartNamespaceDeclHandler
    XML_SetEndNamespaceDeclHandler
    XML_SetNotStandaloneHandler
    XML_SetExternalEntityRefHandler
    XML_SetExternalEntityRefHandlerArg
    XML_SetSkippedEntityHandler
    XML_SetUnknownEncodingHandler
    XML_DefaultCurrent
    XML_SetReturnNSTriplet
    XML_SetUserData
    XML_SetEncoding
    XML_UseParserAsHandlerArg
    XML_UseForeignDTD
    XML_SetBase
    XML_GetBase
    XML_GetSpecifiedAttributeCount
    XML_GetIdAttributeIndex
    XML_Parse
    XML_GetBuffer
    XML_ParseBuffer
    XML_StopParser
    XML_ResumeParser
    XML_GetParsingStatus
    XML_ExternalEntityParserCreate
    XML_SetParamEntityParsing
    XML_GetErrorCode
    XML_GetCurrentLineNumber
    XML_GetCurrentColumnNumber
    XML_GetCurrentByteIndex
    XML_GetCurrentByteCount
    XML_GetInputContext
    XML_FreeContentModel
    XML_MemMalloc
    XML_MemRealloc
    XML_MemFree
    XML_ParserFree
    XML_ErrorString
    XML_ExpatVersion
    XML_GetFeatureList)
  (import (rnrs)
    (foreign ffi)
    (foreign xml expat shared-object)
    (foreign xml expat sizeof))


(define-c-functions expat-shared-object
  (XML_SetElementDeclHandler
   (void XML_SetElementDeclHandler (XML_Parser callback)))

  (XML_SetAttlistDeclHandler
   (void XML_SetAttlistDeclHandler (XML_Parser callback)))

  (XML_SetXmlDeclHandler
   (void XML_SetXmlDeclHandler (XML_Parser callback)))

  (XML_ParserCreate
   (XML_Parser XML_ParserCreate (pointer)))

  (XML_ParserCreateNS
   (XML_Parser XML_ParserCreateNS (pointer XML_Char)))

  (XML_ParserCreate_MM
   (XML_Parser XML_ParserCreate_MM (pointer pointer pointer)))

  (XML_ParserReset
   (XML_Bool XML_ParserReset (XML_Parser pointer)))

  (XML_SetEntityDeclHandler
   (void XML_SetEntityDeclHandler (XML_Parser callback)))

  (XML_SetElementHandler
   (void XML_SetElementHandler (XML_Parser callback callback)))

  (XML_SetStartElementHandler
   (void XML_SetStartElementHandler (XML_Parser callback)))

  (XML_SetEndElementHandler
   (void XML_SetEndElementHandler (XML_Parser callback)))

  (XML_SetCharacterDataHandler
   (void XML_SetCharacterDataHandler (XML_Parser callback)))

  (XML_SetProcessingInstructionHandler
   (void XML_SetProcessingInstructionHandler (XML_Parser callback)))

  (XML_SetCommentHandler
   (void XML_SetCommentHandler (XML_Parser callback)))

  (XML_SetCdataSectionHandler
   (void XML_SetCdataSectionHandler (XML_Parser callback callback)))

  (XML_SetStartCdataSectionHandler
   (void XML_SetStartCdataSectionHandler (XML_Parser callback)))

  (XML_SetEndCdataSectionHandler
   (void XML_SetEndCdataSectionHandler (XML_Parser callback)))

  (XML_SetDefaultHandler
   (void XML_SetDefaultHandler (XML_Parser callback)))

  (XML_SetDefaultHandlerExpand
   (void XML_SetDefaultHandlerExpand (XML_Parser callback)))

  (XML_SetDoctypeDeclHandler
   (void XML_SetDoctypeDeclHandler (XML_Parser callback callback)))

  (XML_SetStartDoctypeDeclHandler
   (void XML_SetStartDoctypeDeclHandler (XML_Parser callback)))

  (XML_SetEndDoctypeDeclHandler
   (void XML_SetEndDoctypeDeclHandler (XML_Parser callback)))

  (XML_SetUnparsedEntityDeclHandler
   (void XML_SetUnparsedEntityDeclHandler (XML_Parser callback)))

  (XML_SetNotationDeclHandler
   (void XML_SetNotationDeclHandler (XML_Parser callback)))

  (XML_SetNamespaceDeclHandler
   (void XML_SetNamespaceDeclHandler (XML_Parser callback callback)))

  (XML_SetStartNamespaceDeclHandler
   (void XML_SetStartNamespaceDeclHandler (XML_Parser callback)))

  (XML_SetEndNamespaceDeclHandler
   (void XML_SetEndNamespaceDeclHandler (XML_Parser callback)))

  (XML_SetNotStandaloneHandler
   (void XML_SetNotStandaloneHandler (XML_Parser callback)))

  (XML_SetExternalEntityRefHandler
   (void XML_SetExternalEntityRefHandler (XML_Parser callback)))

  (XML_SetExternalEntityRefHandlerArg
   (void XML_SetExternalEntityRefHandlerArg (XML_Parser pointer)))

  (XML_SetSkippedEntityHandler
   (void XML_SetSkippedEntityHandler (XML_Parser callback)))

  (XML_SetUnknownEncodingHandler
   (void XML_SetUnknownEncodingHandler (XML_Parser callback pointer)))

  (XML_DefaultCurrent
   (void XML_DefaultCurrent (XML_Parser)))

  (XML_SetReturnNSTriplet
   (void XML_SetReturnNSTriplet (XML_Parser int)))

  (XML_SetUserData
   (void XML_SetUserData (XML_Parser pointer)))

  (XML_SetEncoding
   (XML_Status XML_SetEncoding (XML_Parser pointer)))

  (XML_UseParserAsHandlerArg
   (void XML_UseParserAsHandlerArg (XML_Parser)))

  (XML_UseForeignDTD
   (XML_Error XML_UseForeignDTD (XML_Parser XML_Bool)))

  (XML_SetBase
   (XML_Status XML_SetBase (XML_Parser pointer)))

  (XML_GetBase
   (pointer XML_GetBase (XML_Parser)))

  (XML_GetSpecifiedAttributeCount
   (int XML_GetSpecifiedAttributeCount (XML_Parser)))

  (XML_GetIdAttributeIndex
   (int XML_GetIdAttributeIndex (XML_Parser)))

  (XML_Parse
   (XML_Status XML_Parse (XML_Parser pointer int int)))

  (XML_GetBuffer
   (pointer XML_GetBuffer (XML_Parser int)))

  (XML_ParseBuffer
   (XML_Status XML_ParseBuffer (XML_Parser int int)))

  (XML_StopParser
   (XML_Status XML_StopParser (XML_Parser XML_Bool)))

  (XML_ResumeParser
   (XML_Status XML_ResumeParser (XML_Parser)))

  (XML_GetParsingStatus
   (void XML_GetParsingStatus (XML_Parser pointer)))

  (XML_ExternalEntityParserCreate
   (XML_Parser XML_ExternalEntityParserCreate (XML_Parser pointer pointer)))

  (XML_SetParamEntityParsing
   (int XML_SetParamEntityParsing (XML_Parser XML_ParamEntityParsing)))

  (XML_GetErrorCode
   (XML_Error XML_GetErrorCode (XML_Parser)))

  (XML_GetCurrentLineNumber
   (XML_Size XML_GetCurrentLineNumber (XML_Parser)))

  (XML_GetCurrentColumnNumber
   (XML_Size XML_GetCurrentColumnNumber (XML_Parser)))

  (XML_GetCurrentByteIndex
   (XML_Index XML_GetCurrentByteIndex (XML_Parser)))

  (XML_GetCurrentByteCount
   (int XML_GetCurrentByteCount (XML_Parser)))

  (XML_GetInputContext
   (pointer XML_GetInputContext (XML_Parser pointer pointer)))

  (XML_FreeContentModel
   (void XML_FreeContentModel (XML_Parser pointer)))

  (XML_MemMalloc
   (pointer XML_MemMalloc (XML_Parser size_t)))

  (XML_MemRealloc
   (pointer XML_MemRealloc (XML_Parser pointer size_t)))

  (XML_MemFree
   (void XML_MemFree (XML_Parser pointer)))

  (XML_ParserFree
   (void XML_ParserFree (XML_Parser)))

  (XML_ErrorString
   (pointer XML_ErrorString (XML_Error)))

  (XML_ExpatVersion
   (pointer XML_ExpatVersion (void)))

;;; This returns a whole structure, which is not supported by the FFI.
;;;
;;;   (XML_ExpatVersionInfo
;;;   (XML_Expat_Version XML_ExpatVersionInfo (void)))

  (XML_GetFeatureList
   (pointer XML_GetFeatureList (void))))


;;;; done

)

;;; end of file
