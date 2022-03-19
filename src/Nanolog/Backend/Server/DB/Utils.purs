module Nanolog.Backend.Server.DB.Postgres.Utils where

import Prelude

import Control.Monad.Error.Class (class MonadError)
import Control.Monad.Except (ExceptT, runExceptT)
import Control.Monad.Reader (class MonadReader, ReaderT, asks, runReaderT)
import Data.Either (either)
import Data.Maybe (maybe)
import Database.PostgreSQL as PG
import Effect.Aff (Aff, error, throwError)
import Effect.Aff.Class (class MonadAff, liftAff)
import Nanolog.Backend.Server.Env (Env)
import Nanolog.Backend.Server.Exception (Exception, databaseError)
import Selda (FullQuery, showQuery)
import Selda.Col (class GetCols)
import Selda.PG (showPG)

class
  ( MonadAff m
  , MonadError Exception m
  , MonadReader Env m
  ) <= MonadDB m

hoistSeldaWith :: forall e m r
                . MonadAff m
               => MonadError e m
               => MonadReader r m
               => (PG.PGError -> e)
               -> (r -> PG.Connection)
               -> ExceptT PG.PGError (ReaderT PG.Connection Aff)
               ~> m
hoistSeldaWith fe fr m = do
  conn <- asks fr
  runReaderT (runExceptT m) conn # liftAff
    >>= either (throwError <<< fe) pure

hoistSelda :: forall m
            . MonadAff m
           => MonadReader Env m
           => MonadError Exception m
           => ExceptT PG.PGError (ReaderT PG.Connection Aff)
           ~> m
hoistSelda = hoistSeldaWith databaseError _.database.connection

execute ∷ PG.Connection → String → Aff Unit
execute conn sql = do
  PG.execute conn (PG.Query sql) PG.Row0
    >>= maybe (pure unit) (throwError <<< error <<< show)

generateSQLStringFromQuery
  ∷ ∀ s r
  . GetCols r
  ⇒ FullQuery s { | r }
  → String
generateSQLStringFromQuery = showQuery >>> showPG >>> _.strQuery
