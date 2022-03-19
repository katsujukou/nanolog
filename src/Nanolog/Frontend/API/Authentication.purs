module Nanolog.Frontend.API.Authentication where

import Prelude

import Data.Either (Either(..))
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Nanolog.Frontend.API.Client (handleError, mkClient)
import Nanolog.Frontend.Data.Types (LoginCredential)
import Nanolog.Shared.Data.Types (AuthUserInfo)
import Payload.ResponseTypes (Response(..))


login :: LoginCredential -> Aff (Either String AuthUserInfo)
login cred = do
  client <- liftEffect mkClient
  res <- client.v1.auth.login {body: cred}
  case res of
    Right (Response {body}) -> pure $ Right body
    Left err -> pure $ Left $ handleError err