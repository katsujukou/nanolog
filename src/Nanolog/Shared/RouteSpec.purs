module Nanolog.Shared.RouteSpec where


import Nanolog.Shared.RouteSpec.Authentication as Authentication
import Payload.Spec (type (:), GNil, Guards, Routes)

type RouteSpec r = 
  ( v1 :: Routes "/v1"
    { guards :: Guards ("csrf" : GNil)
    , auth :: Authentication.RouteSpec
    }
  | r
  )
