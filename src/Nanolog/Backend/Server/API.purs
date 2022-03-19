module Nanolog.Backend.Server.API where

import Prelude

import Biscotti.Cookie (SameSite(..))
import Biscotti.Cookie as C
import Data.Array as Array
import Data.Either (Either(..))
import Data.List (List)
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import Effect.Aff (Aff)
import Nanolog.Backend.Server.API.Login (login)
import Nanolog.Backend.Server.API.Utils (ApiResponse', csrfViolationError, failedWith)
import Nanolog.Backend.Server.AppM (runAppMWith)
import Nanolog.Backend.Server.Env (Env)
import Nanolog.Shared.Data.Email (Email)
import Nanolog.Shared.Data.Types (AuthUserInfo)
import Node.HTTP as HTTP
import Payload.Headers as Headers
import Payload.ResponseTypes (Empty(..), Response)
import Payload.ResponseTypes as PRT
import Payload.Server.Guards as Request
import Payload.Server.Response (setHeaders)
import Payload.Server.Response as PR
import Payload.Spec (type (:), Guards, Nil, OPTIONS)


loginAPI :: forall r
          . Env
         -> { body :: { email :: Email, password :: String } | r}
         -> Aff (ApiResponse' AuthUserInfo)
loginAPI env = _.body >>> login >>> runAppMWith setTokenCookie env
  where
    setTokenCookie (PRT.Response res) =
      let
        cookie = C.stringify
          $ C.setSameSite Lax <<< C.setSecure <<< C.setHttpOnly
          $ C.new "token" res.body.accessToken
      in
        PRT.Response
          { body: res.body.authUser
          , headers: Headers.set "Set-Cookie" cookie res.headers
          , status: res.status
          }

type CorsRouteSpec :: forall k. k -> Row Type
type CorsRouteSpec r =
  ( cors :: OPTIONS "/<..path>"
    { guards :: Guards ("cors" : Nil)
    , params :: { path :: List String }
    , response :: Empty
    }
  ) 

type GuardSpec =
  { csrf :: Unit
  , cors :: Unit
  }

guardCsrf :: HTTP.Request -> Aff (Either (Response String) Unit)
guardCsrf req = do
  headers <- Request.headers req
  -- Check for mandatory custom header "X-Requested-With" (any value is acceptable)
  case Headers.lookup "X-Requested-With" headers of
    Nothing -> failedWith csrfViolationError
    Just _ -> pure $ Right unit

guardUntrustedCors :: Env -> HTTP.Request -> Aff (Either (Response String) Unit)
guardUntrustedCors { config } req = do
  headers <- Request.headers req
  -- 1. Host check (must match with hostname of api server)
  if (Headers.lookup "Host" headers) /= Just config.app.listen.hostname
    then failedWith csrfViolationError
    else do
      -- 2. Origin check (must match with hostname of web server (nanolog.com))
      case Headers.lookup "Origin" headers of
        Nothing -> failedWith csrfViolationError
        Just origin ->
          if origin `Array.elem` config.auth.cors.allowedOrigin
            then pure $ Right unit
            else failedWith csrfViolationError 
    
handleCorsPreflight ::
  { params :: { path :: List String }
  , guards :: { cors :: Unit }
  } -> Aff (ApiResponse' Empty)
handleCorsPreflight _ = do
  let
    corsHeaders = Headers.fromFoldable
      [ Tuple "Access-Control-Allow-Origin" "https://test-nanolog.local"
      , Tuple "Access-Control-Allow-Methods" "GET,POST,PUT,DELETE"
      , Tuple "Access-Control-Allow-Headers" "X-Requested-With,Content-Type"
      , Tuple "Access-Control-Allow-Credentials" "true"
      -- , Tuple "Access-Control-Max-Age" "86400"
      -- , Tuple "Content-Type" "text/plain charset=UTF-8"
      ]
--    setCorsHeaders = Headers.toUnfoldable >>> (corsHeaders <> _) >>> Headers.fromFoldable
  pure $ Right (PR.noContent Empty # setHeaders corsHeaders)
