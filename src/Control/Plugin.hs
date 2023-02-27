{-# LANGUAGE 
      LambdaCase
    , OverloadedStrings 
    , BlockArguments
    , RecordWildCards
    , DuplicateRecordFields
    , DeriveAnyClass
    #-}

module Control.Plugin (
    plugin, 
    release, 
    respond, 
    PluginApp, 
    PluginMonad,
    PluginInit,
    PluginReq, 
    PlugInfo
    ) where 

import Data.Lightning
import Control.Conduit
import Control.Exception
import System.IO
import Data.Conduit
import Data.Conduit.Combinators (sourceHandle, sinkHandle) 
import qualified Data.ByteString as S
import qualified Data.ByteString.Lazy as L
import Data.Aeson 
import Data.Text (Text, unpack)  
import Control.Monad
import Control.Monad.IO.Class
import Control.Monad.State 
import Control.Monad.Reader
import Control.Concurrent hiding (yield) 
import Network.Socket as N

-- | Function called on every event subscribed to in the manifest.
type PluginApp a = PluginReq -> PluginMonad a
type PluginReq = (Maybe Id, Method, Params)

-- | Plugin stack contains ReaderT (ask - rpc handle & config), stateT (get/put - polymorphic state) and conduitT (yield - data exchange to core lightning.)
type PluginMonad a = ConduitT 
    (Either (Res Value) PluginReq) 
    (Res Value) 
    (ReaderT PlugInfo (StateT a IO))
    () 

-- | Handle connected to lightning-rpc file (use with Control.Client) & configuration object.  
type PlugInfo = (Handle, Init)

-- | Function called on initialization, returned value is the initial state.
type PluginInit a = PlugInfo -> IO a

data StartErr = ExpectManifest | ExpectInit deriving (Show, Exception) 

-- | Create main executable that can be installed as core lightning plugin. 
plugin :: Value -> PluginInit s -> PluginApp s -> IO ()
plugin manifest start app = do 
    liftIO $ mapM_ (`hSetBuffering` LineBuffering) [stdin,stdout] 
    runOnce $ await >>= \case 
        (Just (Right (Just i, "getmanifest", _))) -> yield $ Res manifest i 
        _ -> throw ExpectManifest
    runOnce $ await >>= \case      
        (Just (Right (Just i, "init", v))) -> case fromJSON v of 
            Success xi@(Init{..}) -> do 
                h  <- liftIO $ getrpc $ getRpcPath configuration
                s' <- liftIO $ start (h, xi)
                _ <- liftIO.forkIO $ runPlugin (h, xi) s' app 
                yield $ Res continue i
            _ -> throw ExpectInit 
            where getRpcPath conf = lightning5dir conf <> "/" <> rpc5file conf
    threadDelay maxBound

runPlugin :: PlugInfo -> s -> PluginApp s -> IO () 
runPlugin re st = (`evalStateT` st) . (`runReaderT` re) . forever . runConduit . runner
    where 
    runner app =  
        sourceHandle stdin .| inConduit .| entry .| appInsert app .| exit .| sinkHandle stdout 

runOnce :: ConduitT (Either (Res Value) PluginReq) (Res Value) IO () -> IO ()
runOnce = runConduit.runner
    where 
    runner d = sourceHandle stdin .| inConduit .| entry .| d .| exit .| sinkHandle stdout

entry :: (Monad n) => ConduitT (ParseResult (Req Value)) (Either (Res Value) PluginReq)  n () 
entry = await >>= maybe mempty (\case  
    Correct v -> yield $ Right (getReqId v, getMethod v, getParams v) 
    InvalidReq -> yield $ Left $ Derp ("Request Error"::Text) Nothing  
    ParseErr -> yield $ Left $ Derp ("Parser Err"::Text) Nothing )

appInsert :: PluginApp a -> PluginMonad a
appInsert app =  await >>= maybe mempty \case  
    Left er -> yield er  
    Right pr -> app pr 

exit :: (Monad n) => ConduitT (Res Value) S.ByteString n () 
exit = await >>= maybe mempty (yield. L.toStrict . encode) 

getrpc :: Text -> IO Handle
getrpc d = do 
    soc <- socket AF_UNIX Stream 0
    N.connect soc $ SockAddrUnix $ unpack d
    socketToHandle soc ReadWriteMode

-- | Helper function to allow node to continue. Hooks delay default node behaviour. 
release :: Id -> PluginMonad a
release = yield . Res continue

-- | Respond with arbitrary Value, custom rpc hooks will pass back through to terminal.
respond :: Value -> Id -> PluginMonad a
respond = (yield .) . Res


continue :: Value 
continue = object ["result" .= ("continue" :: Text)]
