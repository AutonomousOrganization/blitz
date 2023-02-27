{-# LANGUAGE   
      OverloadedStrings
    , DeriveGeneric
    , DuplicateRecordFields
    , FlexibleContexts 
#-}

module Data.Lightning.Notifications where 

import Data.Lightning.Generic 
import Data.Lightning.Util  
import GHC.Generics
import Data.Aeson.Types 
import Data.Text (Text) 

data ChannelOpened = ChannelOpened {
      ___id :: Text 
    , funding_msat :: Int
    , funding_txid :: Text
    , channel_ready :: Bool
    } deriving Generic
instance FromJSON ChannelOpened where 
    parseJSON = singleField "channel_opened"

data ChannelOpenFailed = ChannelOpenFailed {
      channel_id :: Text
    } deriving Generic
instance FromJSON ChannelOpenFailed where 
    parseJSON = singleField "channel_open_failed"

data ChannelStateChanged = ChannelStateChanged {
      peer_id :: Text
    , channel_id :: Text
    , short_channel_id :: Text
    , timestamp :: Text
    , old_state :: Text
    , new_state :: Text
    , cause :: Text
    , message :: Text
    } deriving Generic
instance FromJSON ChannelStateChanged where 
    parseJSON = singleField "channel_state_changed"

data Connect = Connect {
      _id :: Text
    , direction :: Text
    , address :: Text 
    } deriving Generic  
instance FromJSON Connect where
    parseJSON = defaultParse

data Disconnect = Disconnect {
      _id :: Text
    } deriving Generic
instance FromJSON Disconnect where
    parseJSON = defaultParse

data InvoiceCreation = InvoiceCreation {
      label :: Text
    , preimage :: Text
    , amount_msat :: Msat
    } deriving Generic
instance FromJSON InvoiceCreation where
    parseJSON = singleField "invoice_creation"

data Warning = Warning {
      level :: Text
    , time :: Text
    , source :: Text
    , log :: Text
    } deriving Generic 
instance FromJSON Warning where
    parseJSON = singleField "warning"

data ForwardEvent = ForwardEvent {
      payment_hash :: Text
    , in_channel :: Text
    , out_channel :: Text
    , in_msat :: Msat
    , out_msat :: Msat
    , fee_msat :: Msat
    , status :: Text 
    , failcode :: Maybe Int
    , failreason :: Maybe Text
    , received_time :: Double 
    , resolved_time :: Maybe Double 
    } deriving Generic
instance FromJSON ForwardEvent where 
    parseJSON = singleField "forward_event"

data SendPaySuccess = SendPaySuccess {
      _id :: Int 
    , payment_hash :: Text
    , destination :: Text
    , amount_msat :: Msat
    , amount_sent_msat :: Msat
    , created_at :: Int
    , status :: Text
    , payment_preimage :: Text
    } deriving Generic 
instance FromJSON SendPaySuccess where 
    parseJSON = singleField "sendpay_success"

data SendPayFailure = SendPayFailure {
      code :: Int 
    , message :: Text
    , _data :: SPFData
    } deriving Generic 
instance FromJSON SendPayFailure where 
    parseJSON = singleField "sendpay_failure"

data SPFData = SPFData {
      _id :: Int
    , payment_hash :: Text 
    , destination :: Text 
    , amount_msat :: Msat
    , amount_sent_msat :: Msat
    , created_at :: Int 
    , status :: Text 
    , erring_index :: Int 
    , failcode :: Int 
    , failcodename :: Text 
    , erring_node :: Text
    , erring_channel :: Text 
    , erring_direction :: Int 
    } deriving Generic
instance FromJSON SPFData where
    parseJSON = defaultParse

data CoinMovement = CoinMovement {
      version :: Int 
    , node_id :: Text 
    , __type :: Text 
    , account_id :: Text
    , originating_account :: Maybe Text 
    , txid :: Maybe Text 
    , utxo_txid :: Maybe Text
    , vout :: Maybe Int 
    , part_id :: Maybe Int 
    , payment_hash :: Maybe Text 
    , credit_msat :: Maybe Int
    , debit_msat :: Maybe Int
    , output_msat :: Maybe Int
    , output_count :: Maybe Int 
    , fees_msat :: Maybe Int
    , tags :: [Text]
    , blockheight :: Maybe Int 
    , timestamp :: Int 
    , coin_type :: Text  
    } deriving (Show, Generic)
instance FromJSON CoinMovement where 
    parseJSON = singleField "coin_movement" 

data BalanceSnapshot = BalanceSnapshot { 
      balance_snapshots :: [Snapshot]
    } deriving (Generic, Show) 
instance FromJSON BalanceSnapshot 

data Snapshot = Snapshot {
      node_id :: Text
    , blockheight :: Int 
    , timestamp :: Int 
    , accounts :: Saccount 
    } deriving (Show, Generic)
instance FromJSON Snapshot 

data Saccount = Saccount {
      account_id :: Text 
    , balance :: Text 
    , coin_type :: Text
    } deriving (Show, Generic) 
instance FromJSON Saccount 

data BlockAdded = BlockAdded {
      hash :: Text
    , height :: Int
    } deriving Generic 
instance FromJSON BlockAdded where 
    parseJSON = singleField "block"

data OpenChannelPeerSigs = OpenChannelPeerSigs {
      channel_id :: Text
    , signed_psbt :: Text
    } deriving Generic 
instance FromJSON OpenChannelPeerSigs where 
    parseJSON = singleField "openchannel_peer_sigs"


