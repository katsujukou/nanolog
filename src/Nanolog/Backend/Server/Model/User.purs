module Nanolog.Backend.Server.Model.User where

import Data.Maybe (Maybe)
import Nanolog.Shared.Data.Email (Email)
import Nanolog.Shared.Data.Types (UserId)
import Nanolog.Shared.Foreign.Day (DateTime)

type UserWithMetadata =
  { id :: UserId
  , email :: Email
  , password :: String
  , createdAt :: DateTime
  , updatedAt :: Maybe DateTime
  }