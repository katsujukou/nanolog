module Nanolog.Shared.Data.Types where

import Nanolog.Shared.Data.Email (Email)
import Nanolog.Shared.Foreign.Day (DateTime)
import Nanolog.Shared.Foreign.UUID (UUID)

type UserId = UUID

type AuthUserInfo =
  { id :: UserId
  , email :: Email
  , createdAt :: DateTime
  }

type AccessToken = String
