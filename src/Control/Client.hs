{-# LANGUAGE
      LambdaCase
    , OverloadedStrings
    , DeriveGeneric
    , DeriveAnyClass
    , GeneralizedNewtypeDeriving
    #-}

module Control.Client (
    lightningCli,
    Command(..),
    PartialCommand
    ) 
    where 

import Control.Plugin
import Control.Conduit
import Data.Lightning 
import Data.ByteString.Lazy as L 
import System.IO
import System.IO.Unsafe
import Data.IORef
import Network.Socket 
import Data.Conduit hiding (connect) 
import Data.Conduit.Combinators hiding (stdout, stderr, stdin) 
import Data.Aeson
import Data.Text

type Cln a = IO (Maybe (ParseResult (Res a)))
type PartialCommand = Id -> Command 

{-# NOINLINE idref #-} 
idref :: IORef Int
idref = unsafePerformIO $ newIORef 1

data Command = Command { 
      method :: Text
    , reqFilter :: Value
    -- ^ filter specifies which data fields you want to be retured.
    , params :: Value 
    , ____id :: Value 
    } deriving (Show) 

instance ToJSON Command where 
    toJSON (Command m f p i) = 
        object [ "jsonrpc" .= ("2.0" :: Text)
               , "id" .= i
               , "filter" .= toJSON f
               , "method"  .= m 
               , "params" .= toJSON p
               ]

-- | Function to interface with lightning-rpc commands. First argument is a Handle to rpcfile from the readerT, second is a Command withholding Id which will automatically increment.  
lightningCli :: Handle -> PartialCommand -> IO (Maybe (Res Value))
lightningCli h v = do 
    i <- atomicModifyIORef idref $ (\x -> (x,x)).(+1)
    L.hPutStr h . encode $ v (toJSON i) 
    runConduit $ sourceHandle h .| inConduit .| await >>= \case 
        (Just (Correct x)) -> pure $ Just x
        _ -> pure Nothing 

