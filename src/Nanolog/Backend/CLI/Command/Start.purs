module Nanolog.Backend.CLI.Command.Start where

import Prelude

import Control.Monad.Reader (class MonadAsk, ask)
import Data.Either (Either(..))
import Data.Foldable (for_)
import Data.Newtype (unwrap)
import Data.Posix.Signal (Signal(..))
import Effect.Aff (launchAff_)
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class (liftEffect)
import Effect.Class.Console as Console
import Nanolog.Backend.CLI.Config (Config)
import Nanolog.Backend.Server.Main as Server
import Nanolog.Shared.Foreign.Utils.NodeUtils (removeForceRecursive)
import Node.Encoding (Encoding(..))
import Node.FS.Aff (exists, writeTextFile)
import Node.Process (pid)
import Node.Process as Process
import Payload.Server as P

startServer :: forall m
             . MonadAff m
            => MonadAsk Config m
            => m Unit
startServer = do
  conf <- ask

  whenM (liftAff $ exists conf.process.pidFile) do
    Console.error "Failed to start a server"
    liftEffect $ Process.exit 1
  
  liftAff $ writeTextFile UTF8 conf.process.pidFile (show <<< unwrap $ pid)

  srv <- liftAff $ Server.main conf.server >>= case _ of
    Right srv -> pure srv
    Left mes -> do
      Console.error $ "Failed to start server.\nError: " <> mes
      liftEffect $ Process.exit 1 
    

  -- Add graceful shutdown handler
  liftEffect $ for_ [SIGINT, SIGTERM] \sig -> Process.onSignal sig $ launchAff_ do
    P.close srv
    removeForceRecursive conf.process.pidFile
    Console.log "Shutdown server gracefully."
    liftEffect $ Process.exit 0