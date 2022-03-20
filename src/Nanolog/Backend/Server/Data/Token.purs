module Nanolog.Backend.Server.Data.Token where

import Data.Codec.Argonaut (JsonCodec)
import Data.Codec.Argonaut as CA
import Data.Codec.Argonaut.Record as CAR
import Nanolog.Shared.Data.Types (UserId)
import Nanolog.Shared.Foreign.JsonWebToken as JWT
import Nanolog.Shared.Foreign.UUID (UUID)
import Nanolog.Shared.Foreign.UUID as UUID

type TokenId = UUID

data TokenError
  = Expired
  | NotActive
  | VerifyFailed String
  | DecodeFailed CA.JsonDecodeError
  | Invalid

fromJwtVerifyError :: JWT.VerifyError -> TokenError
fromJwtVerifyError = case _ of
  JWT.Expired -> Expired
  JWT.NotActive -> NotActive
  JWT.Invalid str -> VerifyFailed str
  _ -> Invalid

type TokenPayload = 
  { uid :: UserId
  , jti :: TokenId
  }

tokenPayloadCodec :: JsonCodec TokenPayload
tokenPayloadCodec = CAR.object "Nanolog.Backend.Server.Data.Token.TokenPayload"
  { uid: UUID.codec
  , jti: UUID.codec
  }