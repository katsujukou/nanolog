module Nanolog.Backend.Server.DB.AccessTokens where

import Prelude

import Data.Maybe (Maybe(..))
import Effect.Aff.Class (liftAff)
import Effect.Class (liftEffect)
import Nanolog.Backend.Server.Model.AccessTokenInfo (AccessTokenInfo, AccessTokenInfoWithMetadata)
import Nanolog.Shared.Data.Types (UserId)
import Nanolog.Shared.Foreign.Day (DateTime)
import Nanolog.Shared.Foreign.Day as Day
import Nanolog.Shared.Foreign.UUID (UUID)
import Selda (Table(..), (.==))
import Selda.PG (litPG)
import Selda.PG.Class (class MonadSeldaPG, insert1, update)
import Selda.Table.Constraint (Auto, Default)


accessTokens :: Table
  ( id :: Auto UUID
  , userId :: UUID
  , createdAt :: Auto DateTime
  , revokedAt :: Default (Maybe DateTime)
  , updatedAt :: Default (Maybe DateTime)
  )
accessTokens = Table { name: "access_tokens" }

insertNewToken :: forall m. MonadSeldaPG m => AccessTokenInfo -> m AccessTokenInfoWithMetadata
insertNewToken tokenInfo = do
  insert1 accessTokens tokenInfo

updateRevokedAtToCurrentTimeByUserId :: forall m. MonadSeldaPG m => UserId -> m Unit
updateRevokedAtToCurrentTimeByUserId userId = do
  now <- liftAff $ liftEffect Day.now
  update accessTokens
    (\row -> row.userId .== (litPG userId))
    (\row -> row { revokedAt = litPG (Just now) })