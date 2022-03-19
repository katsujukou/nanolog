module Nanolog.Frontend.Store where

type Store =
  {}

data Action = None

reduce :: Store -> Action -> Store
reduce store _ = store 