module Nanolog.Frontend.Data.Types where

import Prelude

import Nanolog.Shared.Data.Email (Email)


type LoginCredential = 
  { email :: Email
  , password :: String
  }