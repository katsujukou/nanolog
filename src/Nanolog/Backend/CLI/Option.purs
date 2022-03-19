module Nanolog.Backend.CLI.Option where

import Prelude

import Data.Foldable (fold)
import Options.Applicative (Parser, ParserInfo, command, fullDesc, help, helper, hsubparser, info, int, long, metavar, option, progDesc, short, showDefault, strOption, switch, value, (<**>))


type Options =
  { version :: Boolean
  , config :: String
  , envFile :: String
  , command :: Command
  }

data Command
  = Start
  | Stop
  | Check

parser :: ParserInfo Options
parser = info (opts <**> helper)
   ( fullDesc
  <> progDesc "Nanolog CLI tools"
   )
  where
    opts :: Parser Options
    opts = ado
      version <- switch $ fold
        [ long "version"
        , short 'v'
        , help "Display version"
        ]

      envFile <- strOption $ fold
        [ long "env-file"
        , short 'e'
        , value ".env"
        , showDefault
        , help "Path to environment variables file"
        , metavar "ENV_FILE"
        ]

      config <- strOption $ fold
        [ long "config"
        , short 'c'
        , help "Path to config.js file"
        , value "/var/nanolog/config.js"
        , showDefault
        , metavar "CONFIG"
        ]

      command <- hsubparser
         ( command "start" (info (pure Start) (progDesc "Start a nanolog server"))
        <> command "stop" (info (pure Stop) (progDesc "Stop running server"))
        <> command "check" (info (pure Check) (progDesc "Check if config.js contains valid config object"))
         )

      in { version, envFile, config, command }