{-# LANGUAGE OverloadedStrings #-}
{- |
   Module      : Text.Pandoc.Readers.Docx.StyleMaps
   Copyright   : © 2014-2020 Jesse Rosenthal <jrosenthal@jhu.edu>,
                   2014-2021 John MacFarlane <jgm@berkeley.edu>,
                   2015 Nikolay Yakimov <root@livid.pp.ru>
   License     : GNU GPL, version 2 or above

   Maintainer  : Jesse Rosenthal <jrosenthal@jhu.edu>
   Stability   : alpha
   Portability : portable

Docx reader utility functions.
-}
module Text.Pandoc.Readers.Docx.Util (
                                        NameSpaces
                                      , elemName
                                      , isElem
                                      , elemToNameSpaces
                                      , findChildByName
                                      , findChildrenByName
                                      , findAttrByName
                                      ) where

import Data.Maybe (mapMaybe)
import qualified Data.Text as T
import Data.Text (Text)
import Text.Pandoc.XML.Light

type NameSpaces = [(Text, Text)]

elemToNameSpaces :: Element -> NameSpaces
elemToNameSpaces = mapMaybe attrToNSPair . elAttribs

attrToNSPair :: Attr -> Maybe (Text, Text)
attrToNSPair (Attr (QName s _ (Just "xmlns")) val) = Just (s, val)
attrToNSPair _                                     = Nothing

elemName :: NameSpaces -> Text -> Text -> QName
elemName ns prefix name =
  QName name (lookup prefix ns) (if T.null prefix then Nothing else Just prefix)

isElem :: NameSpaces -> Text -> Text -> Element -> Bool
isElem ns prefix name element =
  let ns' = ns ++ elemToNameSpaces element
  in qName (elName element) == name &&
     qURI (elName element) == lookup prefix ns'

findChildByName :: NameSpaces -> Text -> Text -> Element -> Maybe Element
findChildByName ns pref name el =
  let ns' = ns ++ elemToNameSpaces el
  in  findChild (elemName ns' pref name) el

findChildrenByName :: NameSpaces -> Text -> Text -> Element -> [Element]
findChildrenByName ns pref name el =
  let ns' = ns ++ elemToNameSpaces el
  in  findChildren (elemName ns' pref name) el

findAttrByName :: NameSpaces -> Text -> Text -> Element -> Maybe Text
findAttrByName ns pref name el =
  let ns' = ns ++ elemToNameSpaces el
  in  findAttr (elemName ns' pref name) el

