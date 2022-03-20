module Nanolog.Backend.Server.API.Utils
  ( ApiResponse
  , ApiResponse'
  , CSRF_AUTH_GUARD
  , CSRF_GUARD
  , BODY
  , GUARD
  , PARAMS
  , QUERY
  , addCorsHeaders
  , csrfViolationError
  , defaultServerError
  , failedWith
  , mapBody
  , ok
  , unwrapBody
  )
  where

import Prelude

import Data.Either (Either(..))
import Data.Newtype (unwrap)
import Data.Tuple.Nested ((/\))
import Nanolog.Shared.Data.Types (AuthUserInfo)
import Payload.Headers as Headers
import Payload.ResponseTypes as PRT
import Payload.Server.Response (internalError, updateHeaders)
import Payload.Server.Response as PR

type ApiResponse a b = Either (PRT.Response a) (PRT.Response b)

type ApiResponse' a = ApiResponse String a

type GUARD :: Type -> Row Type -> Row Type
type GUARD guards r = (guards :: guards | r)

type CSRF_GUARD r = GUARD { csrf :: Unit } r

type CSRF_AUTH_GUARD r = GUARD { csrf :: Unit, authUser :: AuthUserInfo } r

type PARAMS :: Type -> Row Type -> Row Type
type PARAMS params r = (params :: params | r)

type BODY :: Type -> Row Type -> Row Type
type BODY body r = (body :: body | r)

type QUERY :: Type -> Row Type -> Row Type 
type QUERY query r = (query :: query | r)

ok :: forall m a b. Monad m => b -> m (ApiResponse a b)
ok = pure <<< Right <<< PR.ok

failedWith :: forall m a. Monad m => PRT.Response String -> m (Either (PRT.Response String) a)
failedWith = pure <<< Left

csrfViolationError :: PRT.Response String
csrfViolationError = PR.badRequest "csrf violation refused."

unwrapBody :: forall a. PRT.Response a -> a
unwrapBody = unwrap >>> _.body

mapBody :: forall a b. (a -> b) -> PRT.Response a -> PRT.Response b
mapBody f res = 
  let { body, headers, status } = unwrap res
  in  PRT.Response { body: f body, headers, status }

addCorsHeaders :: forall a. String -> PRT.Response a -> PRT.Response a
addCorsHeaders origin = updateHeaders $ Headers.toUnfoldable >>> (_ <> corsHeaders) >>> Headers.fromFoldable
  where
    corsHeaders = 
      [ "Access-Control-Allow-Origin" /\ origin
      , "Access-Control-Allow-Headers" /\ "Content-Type,X-Requested-With"
      , "Access-Control-Allow-Methods" /\ "GET,POST,PUT,DELETE"
      , "Access-Control-Allow-Credentials" /\ "true"
      , "Access-Control-Expose-Headers" /\ "Set-Cookie"
      ]

defaultServerError :: PRT.Response String
defaultServerError = internalError "システムエラーが発生しました"