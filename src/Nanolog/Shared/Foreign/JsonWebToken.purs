module Nanolog.Shared.Foreign.JsonWebToken
  ( SignOptions
  , VerifyError(..)
  , VerifyOptions
  , defaultSignOpts
  , defaultVerifyOpts
  , describe
  , sign
  , verify
  )
  where

import Prelude

import Control.Promise (Promise, toAffE)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Nullable (Nullable, toNullable)
import Data.Tuple (Tuple(..))
import Data.Tuple.Nested (type (/\), (/\))
import Effect.Aff (Aff, error, throwError)
import Effect.Uncurried (EffectFn3, EffectFn6, runEffectFn3, runEffectFn6)
import Foreign (Foreign)
import Simple.JSON (class WriteForeign, writeJSON)

type SignOptions =
  { algorithm :: Maybe String
  , expiresIn :: Maybe String
  , issuer :: Maybe String
  , audience :: Maybe String
  , subject :: Maybe String
  , jwtid :: Maybe String
  }

defaultSignOpts :: SignOptions
defaultSignOpts = 
  { algorithm: Nothing
  , expiresIn: Nothing
  , issuer: Nothing
  , audience: Nothing
  , subject: Nothing
  , jwtid: Nothing
  }

sign :: forall payload. WriteForeign payload => SignOptions -> String -> payload -> Aff String
sign o s p = runEffectFn3 _sign (writeJSON p) s (toSignOptions' o) # toAffE

type SignOptions' =
  { algorithm :: Nullable String
  , expiresIn :: Nullable String
  , issuer :: Nullable String
  , audience :: Nullable String
  , subject :: Nullable String
  , jwtid :: Nullable String
  }

toSignOptions' :: SignOptions -> SignOptions'
toSignOptions' opts = 
  { algorithm: toNullable opts.algorithm
  , expiresIn: toNullable opts.expiresIn
  , issuer: toNullable opts.issuer
  , audience: toNullable opts.audience
  , subject: toNullable opts.subject
  , jwtid: toNullable opts.jwtid
  }

foreign import _sign :: EffectFn3 String String SignOptions' (Promise String)

type VerifyOptions =
  { algorithm :: Array String
  , audience :: Maybe (Array String)
  , complete :: Boolean
  , issuer :: Maybe (Array String)
  , jwtid :: Maybe String
  , ignoreExpiration :: Boolean
  , ignoreNotBefore :: Boolean
  , subject :: Maybe String
  , clockTolerance :: Maybe Number
  , maxAge :: Maybe String
  , clockTimestamp :: Maybe String
  , nonce :: Maybe String
  }

defaultVerifyOpts :: VerifyOptions
defaultVerifyOpts = 
  { algorithm: ["HS256"]
  , audience: Nothing
  , complete: false
  , issuer: Nothing
  , jwtid: Nothing
  , ignoreExpiration: false
  , ignoreNotBefore: false
  , subject: Nothing
  , clockTolerance: Nothing
  , maxAge: Nothing
  , clockTimestamp: Nothing
  , nonce: Nothing
  }

data VerifyError
  = Malformed
  | Expired
  | NotActive
  | Invalid String

describe :: VerifyError -> String
describe = case _ of
  Malformed -> "jwt malformed"
  Expired -> "jwt expired"
  NotActive -> "jwt not active"
  Invalid mes -> mes

verify :: VerifyOptions -> String -> String -> Aff (Either VerifyError Foreign)
verify opts secret token = do
  res <- toAffE $ runEffectFn6 _verify Left Right Tuple token secret (toVerifyOptions' opts)
  case res of
    Right f -> pure $ Right f
    Left (err /\ notJwtErr) -> case err, notJwtErr of
      "jwt malformed", false -> pure <<< Left $ Malformed
      "jwt expired", false -> pure <<< Left $ Expired
      "jwt not active", false -> pure <<< Left $ NotActive
      mes, false -> pure <<< Left $ Invalid mes
      mes, true -> throwError $ error mes

type VerifyOptions' =
  { algorithm :: Array String
  , audience :: Nullable (Array String)
  , complete :: Boolean
  , issuer :: Nullable (Array String)
  , jwtid :: Nullable String
  , ignoreExpiration :: Boolean
  , ignoreNotBefore :: Boolean
  , subject :: Nullable String
  , clockTolerance :: Nullable Number
  , maxAge :: Nullable String
  , clockTimestamp :: Nullable String
  , nonce :: Nullable String
  }

toVerifyOptions' :: VerifyOptions -> VerifyOptions'
toVerifyOptions' opts = 
  { algorithm: opts.algorithm
  , audience: toNullable opts.audience
  , complete: opts.complete
  , issuer: toNullable opts.issuer
  , jwtid: toNullable opts.jwtid
  , ignoreExpiration: opts.ignoreExpiration
  , ignoreNotBefore: opts.ignoreNotBefore
  , subject: toNullable opts.subject
  , clockTolerance: toNullable opts.clockTolerance
  , maxAge: toNullable opts.maxAge
  , clockTimestamp: toNullable opts.clockTimestamp
  , nonce: toNullable opts.nonce
  }


foreign import _verify ::
  EffectFn6
    (forall a b. a -> Either a b)
    (forall a b. b -> Either a b)
    (forall a b. a -> b -> a /\ b)
    String
    String
    VerifyOptions'
    (Promise (Either (String /\ Boolean) Foreign))
