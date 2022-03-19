module Nanolog.Shared.Foreign.Bcrypt
  ( compare
  , hash
  , hash'
  )
  where

import Prelude

import Control.Promise (Promise, toAffE)
import Effect.Aff (Aff)
import Effect.Uncurried (EffectFn2, runEffectFn2)


hash :: String -> Int -> Aff String
hash data_ rounds = toAffE $ runEffectFn2 _hash data_ rounds

hash' :: String -> Aff String
hash' = flip hash 10

compare :: String -> String -> Aff Boolean
compare data_ hashed = toAffE $ runEffectFn2 _compare data_ hashed

foreign import _hash :: EffectFn2 String Int (Promise String)

foreign import _compare :: EffectFn2 String String (Promise Boolean)