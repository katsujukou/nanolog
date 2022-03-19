module Nanolog.Frontend.Route where

import Prelude hiding ((/))

import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe)
import Data.Show.Generic (genericShow)
import Routing.Duplex (RouteDuplex', optional, root, string)
import Routing.Duplex.Generic (noArgs, sum)
import Routing.Duplex.Generic.Syntax ((?), (/))

data Route
  = Welcome
  | SignUp
  | SignIn { redirectTo :: Maybe String }
  | Main MainRoute

derive instance Eq Route
derive instance Generic Route _

instance Show Route where
  show = genericShow

data MainRoute 
  = Home

derive instance Eq MainRoute
derive instance Generic MainRoute _

instance Show MainRoute where
  show = genericShow

requireAuth :: Route -> Boolean
requireAuth = case _ of
  Main mainRoute -> case mainRoute of 
    Home -> true
  _ -> false

notAuthOnly :: Route -> Boolean
notAuthOnly = case _ of
  Welcome -> true
  SignIn _ -> true
  SignUp -> true
  Main mainRoute -> case mainRoute of
    Home -> false 

routeCodec :: RouteDuplex' Route
routeCodec = root $ sum
  { "Welcome": noArgs
  , "SignIn": "accounts" / "signin" ? { redirectTo: optional <<< string }
  , "SignUp": "accounts" / "signup" / noArgs
  , "Main": (sum
    { "Home": "home" / noArgs
    } :: RouteDuplex' MainRoute)
  }
