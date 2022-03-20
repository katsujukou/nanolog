module Nanolog.Frontend.API.Authentication where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Nanolog.Frontend.API.Client (handleError, mkClient)
import Nanolog.Frontend.Data.Types (LoginCredential)
import Nanolog.Shared.Data.Types (AuthUserInfo)
import Payload.ResponseTypes (Response(..))


login :: LoginCredential -> Aff (Either String AuthUserInfo)
login cred = do
  client <- liftEffect mkClient
  res <- client.v1.auth.newToken {body: cred}
  case res of
    Right (Response {body}) -> pure $ Right body
    Left err -> pure $ Left $ handleError err

loginWithStoredCredential :: Aff (Maybe AuthUserInfo)
loginWithStoredCredential = do
  client <- liftEffect mkClient
  res <- client.v1.auth.getSelf {}
  case res of 
    Left _ -> pure Nothing
    Right (Response {body}) -> pure $ Just body