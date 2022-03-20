module Nanolog.Backend.Server.AppM where

import Prelude

import Control.Monad.Error.Class (class MonadError, class MonadThrow)
import Control.Monad.Except.Checked (ExceptV, handleError, safe)
import Control.Monad.Reader (class MonadAsk, ReaderT, ask, runReaderT)
import Data.Bifunctor (bimap)
import Data.Codec.Argonaut as CA
import Data.Either (Either(..))
import Data.Lens (_Left, over)
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class (class MonadEffect)
import Foreign (unsafeFromForeign)
import Nanolog.Backend.Server.API.Utils (ApiResponse, mapBody)
import Nanolog.Backend.Server.Capability.Authentication (class Authentication, class ManageAccessToken, class ManageAuthUser, class VerifyPassword)
import Nanolog.Backend.Server.DB.AccessTokens (insertNewToken, queryAccessTokenById, updateRevokedAtToCurrentTimeByUserId)
import Nanolog.Backend.Server.DB.Postgres.Utils (hoistSelda)
import Nanolog.Backend.Server.DB.Users (queryUserByEmail, queryUserById)
import Nanolog.Backend.Server.Data.Token (TokenError(..), fromJwtVerifyError, tokenPayloadCodec)
import Nanolog.Backend.Server.Env (Env)
import Nanolog.Backend.Server.Exception (ExceptionRow, Exception)
import Nanolog.Shared.Foreign.Bcrypt as Bcrypt
import Nanolog.Shared.Foreign.JsonWebToken as JWT
import Nanolog.Shared.Foreign.UUID as UUID
import Payload.ResponseTypes as PRT

newtype AppM a = AppM (ReaderT Env (ExceptV ExceptionRow Aff) a)

derive newtype instance Functor AppM
derive newtype instance Apply AppM
derive newtype instance Applicative AppM
derive newtype instance Bind AppM
derive newtype instance Monad AppM
derive newtype instance MonadEffect AppM
derive newtype instance MonadAff AppM
derive newtype instance MonadAsk Env AppM
derive newtype instance MonadThrow Exception AppM
derive newtype instance MonadError Exception AppM

instance ManageAccessToken AppM where
  createNewToken userId = AppM do
    { config: { auth } } <- ask
    { id: tokenId } <- hoistSelda $ insertNewToken { userId, revokedAt: Nothing }
    let 
      opts = JWT.defaultSignOpts
        { algorithm = Just auth.token.algorithm
        , expiresIn = Just auth.token.expiresIn
        , issuer = Just auth.token.issuer
        , audience = Just "localhost"
        , jwtid = Just $ (UUID.toString) tokenId
        }
    liftAff $ JWT.sign opts auth.token.secret { uid: userId }

  findAccessTokenById tokenId = AppM do
    hoistSelda $ queryAccessTokenById tokenId

  revokeAllTokensByUser userId = AppM do
    hoistSelda $ updateRevokedAtToCurrentTimeByUserId userId
    
  verifyToken token = AppM do
    { config: { auth }} <- ask
    let
      opts = JWT.defaultVerifyOpts
        { algorithm = [auth.token.algorithm]
        , issuer = Just [auth.token.issuer]
        }

    liftAff $ token
      #   (JWT.verify opts auth.token.secret >>> map (over _Left fromJwtVerifyError))
      <#> (_ >>= unsafeFromForeign >>> CA.decode tokenPayloadCodec >>> over _Left DecodeFailed)
    

instance ManageAuthUser AppM where
  findAuthUserByEmail email = AppM do
    hoistSelda $ queryUserByEmail email
  findAuthUserById userId = AppM do
    hoistSelda $ queryUserById userId

instance VerifyPassword AppM where
  verifyPassword password user = AppM do
    liftAff $ Bcrypt.compare password user.password
    
instance Authentication AppM

-- runAppMWith :: forall a b. (PRT.Response a -> PRT.Response b) -> Env -> AppM (ApiResponse' a) -> Aff (ApiResponse' b)
-- runAppMWith f env = map (over _Right f) <<< runAppM env

runAppM :: forall a b. PRT.Response a -> Env -> AppM (ApiResponse a b) -> Aff (ApiResponse a b)
runAppM panic env (AppM m) = safe $ (runReaderT m env) # handleError
  { database: \_ -> pure $ Left $ panic
  }

mapAppM :: forall a b c d
         . (a -> c)
        -> (b -> d)
        -> AppM (ApiResponse a b)
        -> AppM (ApiResponse c d)
mapAppM f g = map $ bimap (mapBody f) (mapBody g)
