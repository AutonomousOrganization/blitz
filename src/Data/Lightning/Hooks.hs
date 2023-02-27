{-# LANGUAGE
      OverloadedStrings
    , DeriveGeneric
    , DuplicateRecordFields
    
#-}

module Data.Lightning.Hooks where 

import Data.Lightning.Manifest
import Data.Lightning.Generic
import Data.Lightning.Util 
import GHC.Generics
import Data.Aeson.Types 
import Data.Text (Text) 

data Init = Init {
      options :: Object  
    , configuration :: InitConfig
    } deriving (Show, Generic) 
instance FromJSON Init

data InitConfig = InitConfig {
      lightning5dir :: Text 
    , rpc5file :: Text 
    , startup :: Bool 
    , network :: Text 
    , feature_set :: Features 
    , proxy :: Maybe Addr 
    , torv35enabled :: Maybe Bool 
    , always_use_proxy :: Maybe Bool 
  } deriving (Show, Generic) 
instance FromJSON InitConfig where
    parseJSON = defaultParse

data Addr = Addr {
      _type :: Text
    , address :: Text
    , port :: Int
    } deriving (Show, Generic)
instance FromJSON Addr where
    parseJSON = defaultParse

data PeerConnected = PeerConnected {
      _id :: Text 
    , direction :: Text 
    , addr :: Text 
    , features :: Text
    } deriving Generic
instance FromJSON PeerConnected where 
    parseJSON = singleField "peer" 

data CommitmentRevocation = CommitmentRevocation {
      commitment_txid :: Text 
    , penalty_tx :: Text 
    , channel_id :: Text 
    , commitnum :: Int 
    } deriving Generic
instance FromJSON CommitmentRevocation

data DbWrite = DbWrite {
      data_version :: Int
    , writes :: [Text]
    } deriving Generic  
instance FromJSON DbWrite

data InvoicePayment = InvoicePayment {
      label :: Text 
    , preimage :: Text 
    , amount_msat :: Msat
    } deriving Generic 
instance FromJSON InvoicePayment where 
    parseJSON = singleField "payment"

data OpenChannel = OpenChannel {
      _id :: Text 
    , funding_msat :: Msat 
    , push_msat :: Msat 
    , dust_limit_msat :: Msat 
    , max_htlc_value_in_flight_msat :: Msat
    , channel_reserve_msat :: Msat 
    , htlc_minimum_msat :: Msat 
    , feerate_per_kw :: Int
    , to_self_delay :: Int 
    , max_accepted_htlcs :: Int 
    , channel_flags :: Int
    } deriving Generic
instance FromJSON OpenChannel where 
    parseJSON = singleField "openchannel" 

data OpenChannel2 = OpenChannel2 {
      _id :: Text 
    , channel_id :: Text
    , their_funding_msat :: Msat
    , dust_limit_msat :: Msat 
    , max_htlc_value_in_flight_msat :: Msat
    , htlc_minimum_msat :: Msat 
    , funding_feerate_per_kw :: Int
    , commitment_feerate_per_kw :: Int
    , feerate_our_max :: Int
    , feerate_our_min :: Int 
    , to_self_delay :: Int 
    , max_accepted_htlcs :: Int 
    , channel_flags :: Int
    , locktime :: Int 
    , channel_max_msat :: Msat
    , requested_lease_msat :: Msat
    , lease_blockheight_start :: Int 
    , node_blockheight :: Int
    } deriving Generic
instance FromJSON OpenChannel2 where 
    parseJSON = singleField "openchannel2" 

data OpenChannel2Changed = OpenChannel2Changed {
      channel_id :: Text 
    , psbt :: Text
    } deriving Generic
instance FromJSON OpenChannel2Changed where 
    parseJSON = singleField "openchannel2_changed"

data OpenChannel2Sign = OpenChannel2Sign {
      channel_id :: Text 
    , psbt :: Text
    } deriving Generic
instance FromJSON OpenChannel2Sign where 
    parseJSON = singleField "openchannel2_sign"

data RbfChannel = RbfChannel {
      _id :: Text 
    , channel_id :: Text 
    , their_last_funding_msat :: Msat
    , their_funding_msat :: Msat
    , our_last_funding_msat :: Msat
    , funding_feerate_per_kw :: Int 
    , feerate_our_max :: Int 
    , feerate_our_min :: Int 
    , channel_max_msat :: Msat 
    , locktime :: Int 
    , requested_lease_msat :: Msat
    } deriving Generic
instance FromJSON RbfChannel where 
    parseJSON = singleField "rbf_channel"


data HtlcAccepted = HtlcAccepted {
      onion :: HtlcOnion
    , htlc :: Htlc
    , forward_to :: Text
    } deriving Generic
instance FromJSON HtlcAccepted


data HtlcOnion = HtlcOnion {
      payload :: Text 
    , short_channel_id :: Text
    , forward_msat :: Msat 
    , outgoing_cltv_value :: Msat 
    , shared_secret :: Text 
    , next_ontion :: Text
    } deriving Generic
instance FromJSON HtlcOnion

data Htlc = Htlc {
      short_channel_id :: Text
    , _id :: Int 
    , amount_msat :: Msat 
    , cltv_expiry :: Int 
    , cltv_expiry_relative :: Int 
    , payment_hash :: Text 
    } deriving Generic
instance FromJSON Htlc where 
    parseJSON = defaultParse

data RpcCommand = RpcCommand {
      _id :: Int 
    , method :: Text 
    , params :: Value
    } deriving Generic
instance FromJSON RpcCommand where 
    parseJSON = singleField "rpc_command"

data CustomMsg = CustomMsg {
      peer_id :: Text 
    , payload :: Text
    } deriving Generic
instance FromJSON CustomMsg

data OnionMessageRecv = OnionMessageRecv {
      reply_first_node :: Text 
    , reply_blinding :: Text 
    , reply_path :: [MsgHop] 
    , invoice_request :: Text 
    , invoice :: Text 
    , invoice_error :: Text
    , unknown_fields :: Value
    } deriving Generic
instance FromJSON OnionMessageRecv

data OnionMessageRecvSecret = OnionMessageRecvSecret {
      pathsecret :: Text
    , reply_first_node :: Text 
    , reply_blinding :: Text 
    , reply_path :: [MsgHop] 
    , invoice_request :: Text 
    , invoice :: Text 
    , invoice_error :: Text
    , unknown_fields :: Value
    } deriving Generic
instance FromJSON OnionMessageRecvSecret

data MsgHop = MsgHop {
      _id :: Text 
    , encrypted_recipient_data :: Text 
    , blinding :: Text 
    } deriving Generic
instance FromJSON MsgHop where 
    parseJSON = defaultParse

