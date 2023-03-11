
## Core Lightning Plug

Create core lightning ([lightningd](https://lightning.readthedocs.io/PLUGINS.html)) plugins in haskell. 

To get started you need to import the Library. It is on hackage as [clplug](https://hackage.haskell.org/package/clplug) or you can load it from github in the stack.yaml: 
```
extra-deps:
- git: https://github.com/autonomousorganization/blitz.git
  commit: a916dd3d74780e1023b161b4e85773ccc06051d4
```
Once the library is imported there are two external modules. Data.Lightning is all of the data types for the manifest, the notification and the hooks. Control.Plugin contains the monadic context and interface to your node. 

A [manifest](https://lightning.readthedocs.io/PLUGINS.html#the-getmanifest-method) defines the interface your plugin will have with core lightning. 

```
import Data.Aeson
import Data.Lightning
manifest = object [
       "dynamic" .= True
     , "subscriptions" .= ([] :: [Text] )
     , "options" .= ([]::[Option])
     , "rpcmethods" .= ([
         , RpcMethod "command" "[label]" "description" Nothing False
         ])
     , "hooks" .= ([Hook "invoice_payment" Nothing])
     , "featurebits" .= object [ ]
     , "notifications" .= ([]::[Notification])
     ]
```

A start function runs in the InitMonad, it has access to a reader (ask) and to lightningCli. The data that returns from this function will initialize the state that is shared in the PluginMonad. If you want to run a service fork a thread within this function. 
The lightningCli function interfaces to core lightnings rpc. The available functions depend on your version of core lightning and the set of plugins you have installed. You need to pass a Command that defines the data you want returned in a [filter](https://lightning.readthedocs.io/lightningd-rpc.7.html?highlight=filter#field-filtering). 

```
import Control.Plugin 
import Control.Client
start = do 
    (rpcHandle, Init options config) <- ask
    Just response <- lightningCli (Command "getinfo" filter params)
    _ <- liftIO . forkIO $ < service > 
    return < state >
```

An app function runs every time data comes in from the plugin. You define handlers that processes the data. If an id is present that means that core lightning is expecting a response and default node operation or the operation of other plugins may be pending your response. Use release to allow default to continue, reject to abort default behavior, and respond to send a custom response which in the case of custom rpcmethods will pass through back to the user. 

```
app :: (Maybe Id, Method, Params) -> PluginMonad a b
app (Just i, "method", params) = 
    if contition 
        then release i 
        else reject i      
``` 

Finally use the plugin function to create an executable that can be installed as a plugin! 

```
main :: IO ()
main = plugin manifest start app

```

##### tipjar: bc1q5xx9mathvsl0unfwa3jlph379n46vu9cletshr

