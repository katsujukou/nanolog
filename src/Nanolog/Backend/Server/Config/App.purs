module Nanolog.Backend.Server.Config.App where

import Data.Codec.Argonaut as CA
import Data.Codec.Argonaut.Record as CAR

type AppConfig = 
  { listen ::
    { hostname :: String
    , port :: Int
    }
  }

codec :: CA.JsonCodec AppConfig
codec = CAR.object "Nanolog.Backend.Server.Config.App"
  { listen: CAR.object "listen"
    { hostname: CA.string
    , port: CA.int
    }
  }