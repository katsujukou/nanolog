module Nanolog.Frontend.Views.SignInPage where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe)
import Effect.Class (class MonadEffect)
import Effect.Class.Console as Console
import Halogen (ClassName(..), liftEffect)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.Hooks (HookM)
import Halogen.Hooks as Hooks
import Halogen.Router.Class (class MonadRouter, navigate)
import Nanolog.Frontend.Capability.Authentication (class Authentication, signIn)
import Nanolog.Frontend.Component.LoginForm (loginForm)
import Nanolog.Frontend.Data.Types (LoginCredential)
import Nanolog.Frontend.Route (Route(..))
import Type.Proxy (Proxy(..))

type Input =
  { redirectTo :: Maybe String
  }

data Action = HandleLoginForm LoginCredential

signInPage :: forall q o m
            . MonadEffect m
           => MonadRouter Route m 
           => Authentication m
           => H.Component q Input o m
signInPage = Hooks.component \_ { redirectTo: _ } -> Hooks.do

  let
    handleAction :: Action -> HookM m Unit
    handleAction = case _ of
      HandleLoginForm cred -> do
        res <- signIn cred
        case res of
          Left err -> Console.log err
          Right authUser -> Console.logShow authUser

  Hooks.pure do
    HH.div []
      [ HH.h1_ [HH.text "sign in"]
      , HH.div [HP.class_ $ ClassName "login-form-container"] 
        [ HH.slot (Proxy :: Proxy "loginForm") unit loginForm {} (handleAction <<< HandleLoginForm)
        ]
      , HH.div []
        [ HH.p_ 
          [ HH.text "まだアカウントを持ってない？"
          , HH.a
            [ HP.href "javascript:"
            , HE.onClick \_ -> navigate $ SignUp
            ]
            [ HH.text "登録してね😺" ]
          ]
        ]
      ]
