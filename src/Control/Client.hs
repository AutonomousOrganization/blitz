{-# LANGUAGE
      LambdaCase
    , OverloadedStrings
    , DeriveGeneric
    , DeriveAnyClass
    , GeneralizedNewtypeDeriving
    #-}

module Control.Client (
    lightningCli,
    lightningCliDebug,
    Command(..),
    PartialCommand
    ) 
    where 

import Control.Plugin
import Control.Conduit
import Data.Lightning 
import Data.ByteString.Lazy as L 
import System.IO.Unsafe
import Data.IORef
import Control.Monad.Reader
import Data.Conduit hiding (connect) 
import Data.Conduit.Combinators hiding (stdout, stderr, stdin) 
import Data.Aeson
import Data.Text

type PartialCommand = Id -> Command 

{-# NOINLINE idref #-} 
idref :: IORef Int
idref = unsafePerformIO $ newIORef 1

-- commands to core lightning are defined by the set of plugins and version of core lightning so this is generic and you should refer to lightning-cli help <command> for the details of the command you are interested in. A filter object is used to specify the data you desire returned (i.e. {"id":True}) and params are the named fields of the command. 
data Command = Command { 
      method :: Text
    , reqFilter :: Value
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

-- interface with lightning-rpc.  
lightningCli :: PartialCommand -> PluginMonad a (Maybe (Res Value))
lightningCli v = do 
    (h, _) <- ask
    i <- liftIO $ atomicModifyIORef idref $ (\x -> (x,x)).(+1)
    liftIO $ L.hPutStr h . encode $ v (toJSON i) 
    liftIO $ runConduit $ sourceHandle h .| inConduit .| await >>= \case 
        (Just (Correct x)) -> pure $ Just x
        _ -> pure Nothing 

-- log wrapper for easier debugging during development.
lightningCliDebug :: (String -> IO ()) -> PartialCommand -> PluginMonad a (Maybe (Res Value))
lightningCliDebug logger v = do 
    res@(Just (Res x _)) <- lightningCli v 
    liftIO . logger . show $ x 
    pure res 

