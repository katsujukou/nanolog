module Nanolog.Shared.Foreign.Utils.Debug where

import Prelude

import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Foreign (Foreign, unsafeToForeign)
import Prim.TypeError (class Warn, Above, Text)

infixr 1 type Above as |>

class IsDebug
instance Warn
  ( Text "There still remains those functions that have IsDebug constraint."
  |> Text "These functions are not supposed to be contained in production code."
  ) => IsDebug

debugLog :: forall a m. MonadEffect m => IsDebug => a -> m Unit
debugLog a = _debugLog (unsafeToForeign a) # liftEffect

foreign import _debugLog :: Foreign -> Effect Unit
