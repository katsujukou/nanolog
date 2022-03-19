module Nanolog.Backend.Server.Config.Auth where

import Data.Codec.Argonaut as CA
import Data.Codec.Argonaut.Record as CAR

type AuthConfig =
  { token ::
    { secret :: String
    , algorithm :: String
    , issuer :: String
    , expiresIn :: String
    }
  , cors :: 
    { allowedOrigin :: Array String
    }
  }

codec :: CA.JsonCodec AuthConfig
codec = CAR.object "AuthConfig"
  { token: CAR.object "AuthConfig.token"
    { secret: CA.string
    , algorithm: CA.string
    , issuer: CA.string
    , expiresIn: CA.string
    }
  , cors: CAR.object "AuthConfig.cors"
    { allowedOrigin: CA.array CA.string
    }
  } 