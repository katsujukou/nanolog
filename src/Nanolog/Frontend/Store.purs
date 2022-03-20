module Nanolog.Frontend.Store where

import Prelude

import Data.Lens (Lens', set)
import Data.Lens.Record (prop)
import Data.Maybe (Maybe(..))
import Nanolog.Shared.Data.Types (AuthUserInfo)
import Type.Proxy (Proxy(..))

type Store =
  { app ::
    { boot :: Boolean
    , auth :: Maybe AuthUserInfo
    }
  }

_app :: forall a r. Lens' { app :: a | r } a 
_app = prop (Proxy :: Proxy "app")

_boot :: forall r a. Lens' { boot :: a | r } a
_boot = prop (Proxy :: Proxy "boot")

_auth :: forall a r. Lens' { auth :: a | r} a
_auth = prop (Proxy :: Proxy "auth")

data Action
  = SetBoot
  | SetAuthUser AuthUserInfo

reduce :: Store -> Action -> Store
reduce store = case _ of
  SetBoot -> store # set (_app <<< _boot) true
  SetAuthUser authUser -> store # set (_app <<< _auth) (Just authUser)