module Nanolog.Frontend.Views.SignUpPage where

import Prelude

import Halogen as H
import Halogen.HTML as HH
import Halogen.Hooks as Hooks


signUpPage :: forall q i o m
            . Monad m
           => H.Component q i o m
signUpPage = Hooks.component \_ _ -> Hooks.do
  Hooks.pure do
    HH.div []
      [ HH.text "sign up"
      ]