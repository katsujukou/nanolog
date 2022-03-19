module Nanolog.Frontend.Capability.Authentication where

import Prelude

import Control.Monad.Trans.Class (lift)
import Data.Either (Either)
import Effect.Aff.Class (class MonadAff)
import Halogen (HalogenM)
import Halogen.Hooks (HookM)
import Nanolog.Frontend.Data.Types (LoginCredential)
import Nanolog.Shared.Data.Types (AuthUserInfo)

class MonadAff m <= Authentication m where
  signIn :: LoginCredential -> m (Either String AuthUserInfo)

instance Authentication m => Authentication (HalogenM st act sl o m) where
  signIn = lift <<< signIn
  
instance Authentication m => Authentication (HookM m) where
  signIn = lift <<< signIn