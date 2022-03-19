module Nanolog.Frontend.Layouts.MainLayout where

import Prelude

import Halogen (ClassName(..))
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import Halogen.Hooks as Hooks
import Nanolog.Frontend.Route (MainRoute(..))


type Input =
  { route :: MainRoute
  }

mainLayout :: forall q o m
            . H.Component q Input o m
mainLayout = Hooks.component \_ { route } -> Hooks.do
  Hooks.pure do 
    HH.div [HP.class_ $ ClassName "main-layout"]
      [ HH.text "メインレイアウト"
      , HH.div [HP.class_ $ ClassName "page-view-container"]
        [ routerView route
        ]
      ]
  where
    routerView :: MainRoute -> HH.HTML _ _
    routerView = case _ of
      Home -> HH.text "ほぉーむ"