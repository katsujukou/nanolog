module Nanolog.Backend.Server.DB.Users where

import Prelude

import Data.Maybe (Maybe)
import Nanolog.Backend.Server.Data.User (UserWithMetadata)
import Nanolog.Shared.Data.Email (Email)
import Nanolog.Shared.Data.Types (UserId)
import Nanolog.Shared.Foreign.Day (DateTime)
import Nanolog.Shared.Foreign.UUID (UUID)
import Selda (Table(..), restrict, selectFrom, (.==))
import Selda.PG (litPG)
import Selda.PG.Class (class MonadSeldaPG, query1)
import Selda.Table.Constraint (Auto, Default)

users :: Table
  ( id :: Auto UUID
  , email :: Email
  , password :: String
  , createdAt :: Auto DateTime
  , updatedAt :: Default (Maybe DateTime)
  )
users = Table { name: "users" }

queryUserByEmail :: forall m. MonadSeldaPG m => Email -> m (Maybe UserWithMetadata)
queryUserByEmail email = query1 do
  selectFrom users \row -> do
    restrict $ row.email .== (litPG email)
    pure row

queryUserById :: forall m. MonadSeldaPG m => UserId -> m (Maybe UserWithMetadata)
queryUserById userId = query1 do
  selectFrom users \row -> do
    restrict $ row.id .== (litPG userId)
    pure row