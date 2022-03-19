module Nanolog.Shared.Foreign.UUID
  ( UUID
  , codec
  , fromString
  , genUUID
  , toString
  , validate
  )
  where

import Prelude

import Control.Monad.Except (except, runExcept)
import Data.Codec.Argonaut (prismaticCodec)
import Data.Codec.Argonaut as CA
import Data.Either (note)
import Data.Function.Uncurried (Fn0, Fn1, runFn0, runFn1)
import Data.Lens (_Left, over)
import Data.List.NonEmpty as NEL
import Data.Maybe (Maybe(..))
import Data.Semigroup.Foldable (intercalateMap)
import Database.PostgreSQL (class FromSQLValue, class ToSQLValue)
import Effect (Effect)
import Foreign (ForeignError(..), readString, renderForeignError)
import Payload.Server.Params (class DecodeParam)
import Simple.JSON (class ReadForeign, class WriteForeign, readImpl)

newtype UUID = UUID String

derive newtype instance Eq UUID

instance Show UUID where
  show (UUID v) = "(UUID " <> v <> ")"

instance ReadForeign UUID where
  readImpl = readString >=> fromString >>> note e >>> except
    where
      e = NEL.singleton $ ForeignError "Invalid UUID."
  
derive newtype instance WriteForeign UUID

instance DecodeParam UUID where
  decodeParam = fromString >>> note "Not a valid UUID"
  
instance FromSQLValue UUID where
  fromSQLValue = readImpl >>> runExcept >>> (over _Left $ intercalateMap "\n" renderForeignError)

derive newtype instance ToSQLValue UUID

codec :: CA.JsonCodec UUID
codec = prismaticCodec "UUID" fromString toString CA.string

toString :: UUID -> String
toString (UUID v) = v

fromString :: String -> Maybe UUID
fromString s = if validate s then Just $ UUID s else Nothing

validate :: String -> Boolean
validate = runFn1 _validate

genUUID :: Effect UUID
genUUID = runFn0 _genUUID

foreign import _validate :: Fn1 String Boolean

foreign import _genUUID :: Fn0 (Effect UUID)