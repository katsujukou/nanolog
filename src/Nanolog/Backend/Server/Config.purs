module Nanolog.Backend.Server.Config where

import Data.Codec.Argonaut as CA
import Data.Codec.Argonaut.Record as CAR
import Nanolog.Backend.Server.Config.Auth (AuthConfig)
import Nanolog.Backend.Server.Config.Auth as AuthConfig
import Nanolog.Backend.Server.Config.Database (DatabaseConfig)
import Nanolog.Backend.Server.Config.Database as DatabaseConfig
import Nanolog.Backend.Server.Config.App (AppConfig)
import Nanolog.Backend.Server.Config.App as AppConfig

type Config = 
  { app :: AppConfig
  , auth :: AuthConfig
  , database :: DatabaseConfig
  }

codec :: CA.JsonCodec Config
codec = CAR.object "Nanolog.Backend.Server.Config.Config"
  { app: AppConfig.codec
  , auth: AuthConfig.codec
  , database: DatabaseConfig.codec
  }