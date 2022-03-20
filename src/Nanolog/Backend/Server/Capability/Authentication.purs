module Nanolog.Backend.Server.Capability.Authentication where

import Prelude

import Data.Either (Either)
import Data.Maybe (Maybe)
import Effect.Aff.Class (class MonadAff)
import Nanolog.Backend.Server.Data.AccessTokenInfo (AccessTokenInfoWithMetadata)
import Nanolog.Backend.Server.Data.Token (TokenError, TokenPayload, TokenId)
import Nanolog.Backend.Server.Data.User (UserWithMetadata)
import Nanolog.Shared.Data.Email (Email)
import Nanolog.Shared.Data.Types (AccessToken, UserId)

class MonadAff m <= ManageAccessToken m where
  createNewToken :: UserId -> m AccessToken
  revokeAllTokensByUser :: UserId -> m Unit
  findAccessTokenById :: TokenId -> m (Maybe AccessTokenInfoWithMetadata)
  verifyToken :: AccessToken -> m (Either TokenError TokenPayload)

class MonadAff m <= ManageAuthUser m where
  findAuthUserByEmail :: Email -> m (Maybe UserWithMetadata)
  findAuthUserById :: UserId -> m (Maybe UserWithMetadata) 

class MonadAff m <= VerifyPassword m where
  verifyPassword :: String -> UserWithMetadata -> m Boolean

class
  ( ManageAccessToken m
  , ManageAuthUser m
  , VerifyPassword m
  ) <= Authentication m 