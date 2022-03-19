module Nanolog.Frontend.Views.WelcomePage where

import Prelude

import Halogen (ClassName(..))
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import Halogen.Hooks as Hooks

welcomePage :: forall q i o m
             . Monad m
            => H.Component q i o m
welcomePage = Hooks.component \_ _ -> Hooks.do
  Hooks.pure do
    HH.div [HP.class_ $ ClassName "welcome-page"]
      [ HH.text "😸なのろぐへようこそ！😸"
      ]