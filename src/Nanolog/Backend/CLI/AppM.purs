module Nanolog.Backend.CLI.AppM where

import Prelude

import Control.Monad.Reader (ReaderT, runReaderT)
import Effect.Aff (Aff)
import Nanolog.Backend.CLI.Config (Config)

type AppM a = ReaderT Config Aff a

runAppM :: Config -> AppM ~> Aff
runAppM conf = flip runReaderT conf