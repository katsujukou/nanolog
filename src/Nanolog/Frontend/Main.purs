module Nanolog.Frontend.Main where

import Prelude

import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Halogen.Aff (awaitBody, runHalogenAff)
import Halogen.Router.Trans.PushState (RouterInstance, mkRouter)
import Halogen.VDom.Driver (runUI)
import Nanolog.Frontend.Component.App (app)
import Nanolog.Frontend.AppM (runAppM)
import Nanolog.Frontend.Env (Env)
import Nanolog.Frontend.Route (Route, routeCodec)
import Nanolog.Frontend.Store (Store)

type AppBase =
  { env ::Env
  , router :: RouterInstance Route
  , store :: Store
  }

main :: Effect Unit
main = runHalogenAff do
  body <- awaitBody
  { env, router, store } <- mkAppBase
  rootComponent <- runAppM env router store app
  runUI rootComponent {} body

  where
    mkAppBase :: Aff AppBase
    mkAppBase = ado
      env <- pure {}

      router <- liftEffect $ mkRouter routeCodec

      store <- do
        pure {}
      
      in { env, router, store }