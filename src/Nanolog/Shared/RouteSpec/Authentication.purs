module Nanolog.Shared.RouteSpec.Authentication where

import Nanolog.Shared.Data.Email (Email)
import Nanolog.Shared.Data.Types (AuthUserInfo)
import Payload.Spec (type (:), GNil, Guards, POST, Routes, GET)

type RouteSpec = Routes "/auth"
  { newToken :: POST "/token"
    { body :: { email :: Email, password :: String }
    , response :: AuthUserInfo
    }
  , getSelf :: GET "/self"
    { guards :: Guards ("authUser" : GNil)
    , response :: AuthUserInfo
    }
  }