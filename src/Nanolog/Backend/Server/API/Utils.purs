module Nanolog.Backend.Server.API.Utils where

import Prelude

import Data.Either (Either(..))
import Payload.ResponseTypes as PRT
import Payload.Server.Response as PR

type ApiResponse a b = Either (PRT.Response a) (PRT.Response b)

type ApiResponse' a = ApiResponse String a

ok :: forall m a b. Monad m => b -> m (ApiResponse a b)
ok = pure <<< Right <<< PR.ok

failedWith :: forall m a. Monad m => PRT.Response String -> m (Either (PRT.Response String) a)
failedWith = pure <<< Left

csrfViolationError :: PRT.Response String
csrfViolationError = PR.badRequest "csrf violation refused."
