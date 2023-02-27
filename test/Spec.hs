
{-# LANGUAGE 
      OverloadedStrings 
    , FlexibleContexts 
#-} 

module Tally (main) where


import Data.Lightning 
import Control.Conduit 
import Control.Plugin  
import Control.Client (getinfo) 
import Data.Aeson
import Data.Text
import Data.Conduit 
import Control.Monad.Trans.Class 
import Control.Monad.IO.Class 
import Control.Monad.Trans.State.Lazy 
import Control.Monad.Reader

-- plugin function to build core lightning plugin
main :: IO () 
main = plugin manifest appState app

-- define plugin options:  
manifest :: Value 
manifest = object [
      "dynamic" .= True
    , "subscriptions" .= (["channel_opened"] :: [Text] ) 
    , "options" .= ([]::[Option])
    , "rpcmethods" .= ([ RpcMethod "firethemissiles" "" "" Nothing False ]::[RpcMethod]) 
    , "hooks" .= ([]::[Hook])
    , "featurebits" .= object [ ]
    , "notifications" .= ([]::[Notification])
    ] 

-- can pattern match on tuple of data from plugin
app :: PluginApp () 
app (Nothing, "channel_opened", v) = do
    -- 
    -- -- state any type
    -- tea <- lift.lift $ get 
    -- -- reader Handle connected to cln-rpc
    -- rpc <- lift ask
    -- 
    -- liftIO $ getinfo rpc
    pure () 

-- if id then core lightning is expecting a response, use yield from conduit  
app (Just i, "firethemissiles", v) = do
    -- if handling hook allow default behavior to continue: 
    yield $ Res (object ["result" .= ("continue" :: Text)]) i


app _ = pure () 
-- polymorphic 
appState = () 

  


