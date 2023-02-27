
{-# LANGUAGE FlexibleContexts #-}

module Data.Lightning.Generic (defaultParse, singleField) where 

import GHC.Generics
import Data.Aeson.Types 

defaultParse :: (Generic a, GFromJSON Zero (Rep a)) => Value -> Parser a
defaultParse = genericParseJSON def
    where 
        def = defaultOptions{
              fieldLabelModifier = dropWhile (=='_') . map hyphen 
            , omitNothingFields = True
            } 
        hyphen '5' = '-'
        hyphen o = o

singleField :: (Generic a, GFromJSON Zero (Rep a)) => Key -> Value -> Parser a 
singleField k1 (Object v) = v .: k1 >>= defaultParse 
singleField _ _ = parseFail "Object is expected"
