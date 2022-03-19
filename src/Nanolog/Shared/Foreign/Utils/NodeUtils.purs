module Nanolog.Shared.Foreign.Utils.NodeUtils
  ( loadEnvFile
  , packageVersion
  , removeForceRecursive
  )
  where


import Prelude

import Control.Promise (Promise, toAffE)
import Data.Function.Uncurried (Fn0, runFn0)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Uncurried (EffectFn1, runEffectFn1)
import Node.Path (FilePath)


packageVersion :: Effect String
packageVersion = runFn0 _packageVersion

foreign import _packageVersion :: Fn0 (Effect String)

loadEnvFile :: FilePath -> Effect Unit
loadEnvFile = runEffectFn1 _loadEnvFile

foreign import _loadEnvFile :: EffectFn1 String Unit

removeForceRecursive :: FilePath -> Aff Unit
removeForceRecursive = runEffectFn1 _removeForceRecursive >>> toAffE

foreign import _removeForceRecursive :: EffectFn1 String (Promise Unit)