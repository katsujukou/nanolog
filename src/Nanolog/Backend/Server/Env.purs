module Nanolog.Backend.Server.Env where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Database.PostgreSQL as PG
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Nanolog.Backend.Server.Config (Config)


type Env =
  { config :: Config
  , database :: 
    { connection :: PG.Connection
    }
  }

mkEnv :: Config -> Aff (Either String Env)
mkEnv config@{ database: { postgres } } = do
  -- DB connection  
  dbConn <- do
    let
      poolConf = 
        { database: postgres.pool.database
        , host: Just postgres.pool.host
        , port: Just postgres.pool.port
        , user: Just postgres.pool.user
        , password: Just postgres.pool.password
        -- , connectionTimeoutMillis: postgres.pool.connectionTimeoutMillis
        , idleTimeoutMillis: postgres.pool.idleTimeoutMillis
        , max: postgres.pool.max
        }
    pool <- liftEffect $ PG.new poolConf
    connRes <- PG.connect pool
    case connRes of
      Left _ -> do
        pure $ Left "DBに接続できませんでした。"
      Right { connection } -> do
        pure $ Right connection

  pure $ ado
    connection <- dbConn
    in
      { config
      , database:
        { connection
        }
      }