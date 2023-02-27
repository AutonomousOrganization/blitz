{-# LANGUAGE
      LambdaCase
    , FlexibleInstances 
    , FlexibleContexts
    , DeriveGeneric  
    , OverloadedStrings 
 #-}

module Control.Conduit (
    inConduit, 
    ParseResult(..), 
    Res(..), 
    Req(..) 
    ) where 

import Data.Lightning 
import GHC.Generics
import Data.Text (Text)
import Control.Applicative  ((<|>))
import Control.Monad.State.Lazy
import Data.Aeson.Types hiding ( parse )
import Data.Aeson 
import qualified Data.ByteString as S
import Data.Conduit 
import Data.Attoparsec.ByteString 

inConduit :: (Monad n) => (FromJSON a) => ConduitT S.ByteString (ParseResult a) n ()
inConduit = evalStateT l Nothing
    where 
    l = lift await >>= maybe (lift mempty) (r >=> h)
    r i = get  >>= \case
        Nothing -> pure $ parse json' i
        Just k  ->  pure $ k i 
    h = \case
        Fail{} -> lift (yield ParseErr) 
        Partial i -> put (Just i) >> l
        Done _ v -> lift $ yield $ fin $ parseMaybe parseJSON v 
    fin = \case
        Nothing -> InvalidReq
        Just c -> Correct c

data ParseResult x = 
    Correct !x |
    InvalidReq | 
    ParseErr 
    deriving (Show, Generic) 
instance ToJSON a => ToJSON (ParseResult a) where 
    toJSON = genericToJSON defaultOptions 
instance FromJSON a => FromJSON (ParseResult a) 
data Req x = Req { 
   getMethod :: Text,
   getParams :: x,
   getReqId :: Maybe Value }
   deriving (Show) 
   
data Res a =
    Res { getResBody :: a,
          getResId :: Value }
    | Derp  {
          errMsg :: Text,
          errId :: Maybe Value }
    deriving (Show, Generic)

instance FromJSON (Req Value) where
    parseJSON (Object v) = do
        version <- v .: "jsonrpc"
        guard (version == ("2.0" :: Text))
        Req <$> v .:  "method"
            <*> (v .:? "params") .!= emptyArray
            <*> v .:?  "id"
    parseJSON _ = mempty

instance FromJSON a => FromJSON (Res a) where
    parseJSON (Object v) = do
        version <- v .: "jsonrpc"
        guard (version == ("2.0" :: Text))
        fromResult <|> fromError
        where
            fromResult = Res <$> (v .: "result" >>= parseJSON)
                             <*> v .: "id"
            fromError = do
                err <- v .: "error"
                Derp  <$> err .: "message"
                      <*> v   .: "id"
    parseJSON (Array a) = mempty
    parseJSON _ = mempty

instance ToJSON a => ToJSON (Req a) where
    toJSON (Req m ps i) =
        object [ "jsonrpc" .= ("2.0" :: Text)
               , "method"  .= m
               , "params"  .= toJSON ps
               , "id"      .= i ]

instance ToJSON (Res Value) where
    toJSON (Res x i) = object [ 
        "jsonrpc" .= ("2.0" :: Text),
        "result"  .= x,
        "id"      .= i ]
    toJSON (Derp msg i) = object [ 
        "jsonrpc" .= ("2.0" :: Text),
        "error"   .= object ["message" .= msg],
        "id"      .= i ]

