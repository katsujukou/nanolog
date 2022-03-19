module Nanolog.Shared.RouteSpec.Authentication where

import Nanolog.Shared.Data.Email (Email)
import Nanolog.Shared.Data.Types (AuthUserInfo)
import Payload.Spec (POST, Routes)

type RouteSpec = Routes "/auth"
  { login :: POST "/login"
    { body :: { email :: Email, password :: String }
    , response :: AuthUserInfo
    }
  }