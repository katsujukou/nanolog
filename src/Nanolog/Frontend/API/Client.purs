module Nanolog.Frontend.API.Client where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Nanolog.Shared.RouteSpec (RouteSpec)
import Payload.Client (ClientError, defaultOpts)
import Payload.Client as P
import Payload.Client.ClientApi (class ClientApi)
import Payload.Headers as Headers
import Payload.Spec (Spec(..))

mkClient :: forall client. ClientApi {| RouteSpec ()} client => Effect client
mkClient = do
  let clientOpts = defaultOpts
        { baseUrl = "https://api.test-nanolog.local"
        , extraHeaders = Headers.fromFoldable
          [ "X-Requested-With" /\ "XMLHttpRequest"
          ]
        , withCredentials = true
        }
      client = P.mkClient clientOpts (Spec :: Spec {| RouteSpec ()})
  pure client

handleError :: ClientError -> String
handleError = ("通信に失敗しました: \n" <> _) <<< show