module Nanolog.Backend.Server.Main where

import Prelude

import Data.Either (Either(..))
import Effect.Aff (Aff, error, throwError)
import Nanolog.Backend.Server.API (CorsRouteSpec, GuardSpec, guardCsrf, guardUntrustedCors, handleCorsPreflight, loginAPI)
import Nanolog.Backend.Server.Config (Config)
import Nanolog.Backend.Server.Env (mkEnv)
import Nanolog.Shared.RouteSpec (RouteSpec)
import Payload.Server (Server, startGuarded_)
import Payload.Spec (Spec(..))
import Type.Row (type (+))

main :: Config -> Aff (Either String Server)
main config = do
  mkEnv config >>= case _ of
    Left e -> pure $ Left e
    Right env -> do          
      startGuarded_ spec api
        >>= case _ of
          Right srv -> pure $ Right srv
          Left mes -> throwError $ error mes
          
      where
        spec :: Spec
          { guards :: GuardSpec
          , routes :: {| RouteSpec + CorsRouteSpec ()}
          }
        spec = Spec

        api = 
          { guards:
            { csrf: guardCsrf
            , cors: guardUntrustedCors env
            }
          , handlers:
            { v1:
              { auth:
                { login: loginAPI env
                }
              }
            , cors: handleCorsPreflight
            }
          }