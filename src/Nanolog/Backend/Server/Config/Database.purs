module Nanolog.Backend.Server.Config.Database where

import Data.Codec.Argonaut as CA
import Data.Codec.Argonaut.Compat (maybe)
import Data.Codec.Argonaut.Record as CAR
import Data.Maybe (Maybe)

type DatabaseConfig =
  { postgres ::
    { pool ::
      { host :: String
      , port :: Int
      , database :: String
      , user :: String
      , password :: String
      , connectionTimeoutMillis :: Maybe Int
      , idleTimeoutMillis :: Maybe Int
      , max :: Maybe Int
      }
    }
  }

codec :: CA.JsonCodec DatabaseConfig
codec = CAR.object "DatabaseConfig"
  { postgres: CAR.object "Postgres"
    { pool: CAR.object "Pool"
      { host: CA.string
      , port: CA.int
      , database: CA.string
      , user: CA.string
      , password: CA.string
      , connectionTimeoutMillis: maybe CA.int
      , idleTimeoutMillis: maybe CA.int
      , max: maybe CA.int
      }
    }
  }