{-# LANGUAGE   
      DeriveGeneric
    , DuplicateRecordFields
#-}

module Data.Lightning.Manifest where 

import GHC.Generics
import Data.Lightning.Generic
import Data.Aeson
import Data.Text (Text) 

type Manifest = Value 

data Option = Option {
    name :: Text 
  , _type :: Text
  , _default :: Text 
  , description :: Text
  , deprecated :: Bool
  } deriving Generic 
instance ToJSON Option where 
    toJSON = genericToJSON defaultOptions{fieldLabelModifier = dropWhile (=='_')}

data RpcMethod = RpcMethod {
      name :: Text
    , usage  :: Text
    , description :: Text
    , long_description :: Maybe Text 
    , deprecated :: Bool
    } deriving Generic 
instance ToJSON RpcMethod where 
    toJSON = genericToJSON defaultOptions{omitNothingFields = True}
    
data Hook = Hook { 
    name :: Text 
  , before :: Maybe Value
  } deriving Generic 
instance ToJSON Hook where 
    toJSON = genericToJSON defaultOptions{omitNothingFields = True}

data Notification = Notification { 
    __method :: Text
  } deriving Generic
instance ToJSON Notification where 
    toJSON = genericToJSON defaultOptions{fieldLabelModifier = dropWhile (=='_')}

data Features = Features {
      __init :: String
    , node :: String 
    , channel :: String 
    , invoice :: String 
    } deriving (Generic, Show)
instance ToJSON Features 
instance FromJSON Features where  
    parseJSON = defaultParse
