module Nanolog.Backend.CLI.Config
  ( Config
  , ConfigError(..)
  , codec
  , describe
  , readConfig
  )
  where

import Prelude

import Data.Argonaut (Json)
import Data.Codec.Argonaut as CA
import Data.Codec.Argonaut.Record as CAR
import Data.Either (Either(..))
import Data.Lens (_Left, over)
import Effect (Effect)
import Effect.Exception (message)
import Effect.Exception as Exception
import Effect.Uncurried (EffectFn3, runEffectFn3)
import Nanolog.Backend.Server.Config as ServerConfig
import Node.Path (FilePath)


type Config =
  { process ::
    { pidFile :: FilePath
    }
  , server :: ServerConfig.Config
  }

codec :: CA.JsonCodec Config
codec = CAR.object "Nanolog.Backend.CLI.Config"
  { process: CAR.object "ProcessConfig"
    { pidFile: CA.string
    }
  , server: ServerConfig.codec
  }

data ConfigError
  = ImportError FilePath Exception.Error
  | DecodeError CA.JsonDecodeError

describe :: ConfigError -> String
describe = case _ of
  ImportError path error ->
    "\x1b[31m[ERROR]\x1b[0m " <> path <> "の読み取りに失敗しました。 error: \n" <> message error
  DecodeError e -> "\x1b[31m[ERROR]\x1b[0m 設定の読み取りに失敗しました。 error: \n" <> CA.printJsonDecodeError e

readConfig :: FilePath -> Effect (Either ConfigError Config)
readConfig path = 
  let
    importConfigJS = runEffectFn3 _importConfigJS Left Right >>> (_ <#> over _Left $ ImportError path)
    decodeJson = CA.decode codec >>> over _Left DecodeError
  in
    path # (importConfigJS >=> (_ >>= decodeJson) >>> pure)

foreign import _importConfigJS ::
  EffectFn3
    (forall a b. a -> Either a b)
    (forall a b. b -> Either a b)
    String
    (Either Exception.Error Json)