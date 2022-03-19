module Nanolog.Shared.Foreign.Utils.StringUtils
  ( toHankaku
  )
  where

import Data.Function.Uncurried (Fn1, runFn1)

toHankaku :: String -> String
toHankaku = runFn1 _toHankaku

foreign import _toHankaku :: Fn1 String String
