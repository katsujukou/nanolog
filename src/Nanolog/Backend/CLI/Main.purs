module Nanolog.Backend.CLI.Main where

import Prelude

import Data.Either (Either(..))
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class.Console as Console
import Nanolog.Backend.CLI.AppM (runAppM)
import Nanolog.Backend.CLI.Command.Start as Start
import Nanolog.Backend.CLI.Config (Config, describe, readConfig)
import Nanolog.Backend.CLI.Option (Command(..), parser)
import Nanolog.Shared.Foreign.Utils.NodeUtils (loadEnvFile, packageVersion)
import Node.Process as Process
import Options.Applicative (execParser)

main :: Effect Unit
main = do
  { version, envFile, config, command } <- execParser parser
  
  when (version) do
    v <- packageVersion
    Console.log v
    Process.exit 0

  loadEnvFile envFile

  readConfig config >>= case _ of
    Left e -> do
      Console.error $ describe e
      Process.exit 1

    Right conf -> launchAff_ $ handleCommand conf command

  where
    handleCommand :: Config -> Command -> Aff Unit
    handleCommand conf = runAppM conf <<< case _ of
      Start -> Start.startServer

      Stop -> pure unit

      Check -> pure unit