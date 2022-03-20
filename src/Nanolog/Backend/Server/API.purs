module Nanolog.Backend.Server.API where

import Prelude

import Biscotti.Cookie (SameSite(..))
import Biscotti.Cookie as C
import Data.Array as Array
import Data.Bifunctor (bimap)
import Data.Either (Either(..))
import Data.Lens (_Right, over)
import Data.List (List)
import Data.Map as Map
import Data.Maybe (Maybe(..))
import Data.String (joinWith)
import Effect.Aff (Aff)
import Effect.Aff.Class (liftAff)
import Nanolog.Backend.Server.API.Login (login)
import Nanolog.Backend.Server.API.Misc (provideAuthUser)
import Nanolog.Backend.Server.API.Utils (ApiResponse', BODY, CSRF_AUTH_GUARD, CSRF_GUARD, GUARD, PARAMS, csrfViolationError, defaultServerError, failedWith, ok, unwrapBody)
import Nanolog.Backend.Server.API.Utils as Utils
import Nanolog.Backend.Server.AppM (AppM, runAppM)
import Nanolog.Backend.Server.Env (Env)
import Nanolog.Shared.Data.Email (Email)
import Nanolog.Shared.Data.Types (AuthUserInfo)
import Node.HTTP as HTTP
import Payload.Headers as Headers
import Payload.ResponseTypes (Empty(..), Response)
import Payload.ResponseTypes as PRT
import Payload.Server.Cookies (requestCookies)
import Payload.Server.Guards as Request
import Payload.Server.Response (unauthorized)
import Payload.Server.Response as PR
import Payload.Spec (type (:), Guards, Nil, OPTIONS)
import Type.Row (type (+))

runAppM' :: forall a. Env -> AppM (ApiResponse' a) -> Aff (ApiResponse' a)
runAppM' env@{ config: { auth }} = runAppM defaultServerError env
  <<< map (bimap
      (Utils.addCorsHeaders (joinWith "," auth.cors.allowedOrigin))
      (Utils.addCorsHeaders (joinWith "," auth.cors.allowedOrigin))
    )

loginAPI :: Env
         -> {| CSRF_GUARD + BODY { email :: Email, password :: String } + ()}
         -> Aff (ApiResponse' AuthUserInfo)
loginAPI env = _.body >>> login >>> map (over _Right toResponse) >>> runAppM' env
  where
    toResponse (PRT.Response res) = 
      let
        cookie = C.stringify
          $ C.setDomain "test-nanolog.local" <<< C.setPath "/"
            <<< C.setSameSite Lax <<< C.setSecure <<< C.setHttpOnly
          $ C.new "token" res.body.accessToken
      in
        PRT.Response
          { body: res.body.authUser
          , headers: Headers.set "Set-Cookie" cookie res.headers
          , status: res.status
          }

getSelfAPI :: Env
           -> {| CSRF_AUTH_GUARD + ()}
           -> Aff (ApiResponse' AuthUserInfo)
getSelfAPI env { guards: { authUser }} = runAppM' env $ ok authUser

type CorsRouteSpec r =
  ( cors :: OPTIONS "/<..path>"
    { guards :: Guards ("cors" : Nil)
    , params :: { path :: List String }
    , response :: Empty
    }
  | r
  ) 

handleCorsPreflight :: Env
                    -> {| GUARD { cors :: Unit } + PARAMS { path :: List String } + ()}
                    -> Aff (ApiResponse' Empty)
handleCorsPreflight env _ = runAppM' env $ pure $ Right (PR.noContent Empty) 


type GuardSpec =
  { csrf :: Unit
  , cors :: Unit
  , authUser :: AuthUserInfo
  }

csrfGuard :: Env -> HTTP.Request -> Aff (Either (Response String) Unit)
csrfGuard env req = map (over _Right unwrapBody) do
  headers <- liftAff $ Request.headers req
  -- Check for mandatory custom header "X-Requested-With" (any value is acceptable)
  runAppM' env $ case Headers.lookup "X-Requested-With" headers of
    Nothing -> failedWith csrfViolationError
    Just _ -> ok unit

corsGuard :: Env -> HTTP.Request -> Aff (Either (Response String) Unit)
corsGuard env@{ config } req = (over _Right unwrapBody) <$> runAppM' env do
  headers <- liftAff $ Request.headers req
  -- 1. Host check (must match with hostname of api server)
  if (Headers.lookup "Host" headers) /= Just config.app.listen.hostname
    then failedWith csrfViolationError
    else do
      -- 2. Origin check (must match with hostname of web server (nanolog.com))
      case Headers.lookup "Origin" headers of
        Nothing -> failedWith csrfViolationError
        Just origin ->
          if origin `Array.elem` config.auth.cors.allowedOrigin
            then ok unit
            else failedWith csrfViolationError 

provideAuthUserGuard :: Env -> HTTP.Request -> Aff (Either (PRT.Response String) AuthUserInfo)
provideAuthUserGuard env req = over _Right unwrapBody <$> runAppM' env do
  case Map.lookup "token" $ requestCookies $ req of
    Nothing -> failedWith $ unauthorized "ログインしてください"
    Just token -> do
      provideAuthUser token