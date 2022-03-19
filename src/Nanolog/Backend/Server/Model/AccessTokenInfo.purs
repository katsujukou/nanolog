module Nanolog.Backend.Server.Model.AccessTokenInfo where

import Data.Maybe (Maybe)
import Nanolog.Shared.Data.Types (UserId)
import Nanolog.Shared.Foreign.Day (DateTime)
import Nanolog.Shared.Foreign.UUID (UUID)

type TokenId = UUID

type AccessTokenInfo =
  { userId :: UserId
  , revokedAt :: Maybe DateTime
  }

type AccessTokenInfoWithMetadata =
  { userId :: UserId
  , revokedAt :: Maybe DateTime
  , id :: TokenId
  , createdAt :: DateTime
  , updatedAt :: Maybe DateTime
  }
