module Nanolog.Shared.Foreign.Day
  ( DateTime
  , Format(..)
  , format
  , fromForeign
  , fromString
  , now
  , parseFormat
  , parseFormatStrict
  , toString
  , toUnix
  , toUnixMilliseconds
  )
  where

import Prelude

import Control.Monad.Except (except)
import Data.Either (note)
import Data.Function.Uncurried (Fn0, Fn2, Fn3, Fn5, Fn1, runFn0, runFn1, runFn2, runFn3, runFn5)
import Data.JSDate (JSDate, readDate)
import Data.List.NonEmpty as NEL
import Data.Maybe (Maybe(..))
import Database.PostgreSQL (class FromSQLValue, class ToSQLValue, toSQLValue)
import Effect (Effect)
import Foreign (Foreign, ForeignError(..))
import Simple.JSON (class ReadForeign, class WriteForeign, writeImpl)

foreign import data DateTime :: Type

instance Eq DateTime where
  eq lhs rhs = (toUnixMilliseconds lhs) == (toUnixMilliseconds rhs)

instance Ord DateTime where
  compare lhs rhs = (toUnixMilliseconds lhs) `compare` (toUnixMilliseconds rhs)

instance Show DateTime where
  show = toString

instance ReadForeign DateTime where
  readImpl = fromForeign >>> note e >>> except
    where
      e = NEL.singleton $ ForeignError "Not a valid datetime"

instance WriteForeign DateTime where
  writeImpl = toString >>> writeImpl

instance FromSQLValue DateTime where
  fromSQLValue = fromForeign >>> note "Not a valid datetime"

instance ToSQLValue DateTime where
  toSQLValue = toJSDate >>> toSQLValue

toJSDate :: DateTime -> JSDate
toJSDate = runFn1 _toJSDate

foreign import _toJSDate :: Fn1 DateTime JSDate

toUnix :: DateTime -> Int
toUnix = runFn1 _toUnix

toUnixMilliseconds :: DateTime -> Int
toUnixMilliseconds = runFn1 _toUnixMilliseconds

toString :: DateTime -> String
toString = format (Format "YYYY-MM-DDThh:mm:ss.SSSZ")

fromString :: String -> Maybe DateTime
fromString = parseFormat (Format "YYYY-MM-DDThh:mm:ss.SSSZ")

now :: Effect DateTime
now = runFn0 _now

newtype Format = Format String

format :: Format -> DateTime -> String
format (Format f) = runFn2 _format f

parseFormat :: Format -> String -> Maybe DateTime
parseFormat (Format f) = runFn5 _parseFormat Nothing Just f false

parseFormatStrict :: Format -> String -> Maybe DateTime
parseFormatStrict (Format f) = runFn5 _parseFormat Nothing Just f true

fromForeign :: Foreign -> Maybe DateTime
fromForeign = runFn3 _fromForeign Nothing Just

foreign import _fromForeign :: Fn3 (forall a. Maybe a) (forall a. a -> Maybe a) Foreign (Maybe DateTime)

foreign import _toUnix :: Fn1 DateTime Int

foreign import _toUnixMilliseconds :: Fn1 DateTime Int

foreign import _parseFormat ::
  Fn5
    (forall a. Maybe a)
    (forall a. a -> Maybe a)
    String
    Boolean
    String
    (Maybe DateTime)

foreign import _now :: Fn0 (Effect DateTime)

foreign import _format :: Fn2 String DateTime String