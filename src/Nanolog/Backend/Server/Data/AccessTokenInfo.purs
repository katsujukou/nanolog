module Nanolog.Backend.Server.Data.AccessTokenInfo where

import Data.Maybe (Maybe)
import Nanolog.Backend.Server.Data.Token (TokenId)
import Nanolog.Shared.Data.Types (UserId)
import Nanolog.Shared.Foreign.Day (DateTime)

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
