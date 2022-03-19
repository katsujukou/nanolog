module Nanolog.Backend.Server.Capability.Authentication where

import Prelude

import Data.Maybe (Maybe)
import Effect.Aff.Class (class MonadAff)
import Nanolog.Backend.Server.Model.User (UserWithMetadata)
import Nanolog.Shared.Data.Email (Email)
import Nanolog.Shared.Data.Types (AccessToken, UserId)

class MonadAff m <= ManageAccessToken m where
  createNewToken :: UserId -> m AccessToken
  revokeAllTokensByUser :: UserId -> m Unit

class MonadAff m <= ManageAuthUser m where
  findAuthUserByEmail :: Email -> m (Maybe UserWithMetadata)

class MonadAff m <= VerifyPassword m where
  verifyPassword :: String -> UserWithMetadata -> m Boolean

class
  ( ManageAccessToken m
  , ManageAuthUser m
  , VerifyPassword m
  ) <= Authentication m 