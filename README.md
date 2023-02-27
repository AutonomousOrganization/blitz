
## Core Lightning Plug

Core lightning is a daemon ([lightningd](https://lightning.readthedocs.io/PLUGINS.html)) that operates payment channels that allow you to send and receive bitcoin nearly instantly, with nearly zero fees with a high level of privacy. It does not compromise on any of the strengths of layer 1 bitcoin: no censorship, free speech, individual sovereignty, and impossible debasement. In fact it strengthens bitcoin because it encourages the operation of fully validating nodes, lightningd requires bitcoind. Clplug is a Haskell library that allows you to easily create extensions (called plugins) that extend or augment its functionality. 

To create a plugin you only need to define three arguments:
- `Manifest :: Value` - configuration of the interface with core lightning.
- `PluginInit :: PlugInfo -> IO a` - startup function that returns the starting state
- `PluginApp ::  (Maybe Id, Method, Params) -> PluginMonad` - data handler function

The transformer stack contains: 
- `ask` - a handle to lightning-rpc and environment info.
- `get/put` - polymorphic state
- `yield` - stdout to core lightning

Several examples are included that are intended to be useful for (d)evelopers and node (o)perators 
- **movelog**
    - o - specify logfile= to create a log file with fees earned and other coin movements
    - d - a notification is subscribed, an option is added, and the state monad is used
- **wallet** 
    - o - show available totals and channel balances: `lightning-cli wallet`
    - d - a new rpc method is created
- **routes** 
    - o - generate routes: `lightning-cli route` 
    - d - network graph is loaded and several rpc parameters are used

Operators: the examples require option `allow-deprecated-apis=false`. To install a plugin you must: 
    - clone this repository
    - `stack build` 
    - move or symlink the created executable file into the lightning directory (by default: `.lightning/plugins`) 
    
The main exports from the Library are `Control.Plugin`, `Control.Client`, and `Data.Lightning`. An upload and link to hackage is pending. This is a basic usage example: 
```haskell  
{-# LANGUAGE 
      OverloadedStrings 
    , FlexibleContexts 
    , ViewPatterns
    , RecordWildCards
#-} 

module Main (main) where

-- from clplug
import Data.Lightning 
import Control.Plugin  
import Control.Conduit
--

import Data.Conduit 
import Data.Aeson
import Data.Text

main = plugin manifest appState app

manifest :: Value 
manifest = object [
      "dynamic" .= True
    , "subscriptions" .= (["channel_opened"] :: [Text] ) 
    , "options" .= ([]::[Option])
    , "rpcmethods" .= ([]) 
    , "hooks" .= ([]::[Hook])
    , "featurebits" .= object [ ]
    , "notifications" .= ([]::[Notification])
    ] 

app :: PluginApp () 
app (Nothing, "channel_opened", fromJSON -> Success (ChannelOpened {..})) = do
    doublespend funding_txid 
    where doublespend _ = pure ()

appState = pure () 
```      

Useful areas of  exploration and research are:
- fee optimization
- route selection
- economic rebalancing
- accidental channel closes

##### Donation bitcoin addr: bc1q5xx9mathvsl0unfwa3jlph379n46vu9cletshr

lightning only scales bitcoin if people run nodes
