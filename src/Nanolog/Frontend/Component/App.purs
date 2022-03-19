module Nanolog.Frontend.Component.App where


import Prelude

import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import Halogen.Hooks as Hooks
import Halogen.Router.Class (class MonadRouter)
import Halogen.Router.UseRouter (useRouter)
import Nanolog.Frontend.Capability.Authentication (class Authentication)
import Nanolog.Frontend.Layouts.MainLayout (mainLayout)
import Nanolog.Frontend.Route (Route(..))
import Nanolog.Frontend.Views.SignInPage (signInPage)
import Nanolog.Frontend.Views.SignUpPage (signUpPage)
import Nanolog.Frontend.Views.WelcomePage (welcomePage)
import Type.Proxy (Proxy(..))

app :: forall q i o m
     . MonadRouter Route m
    => Authentication m
    => H.Component q i o m
app = Hooks.component \_ _ -> Hooks.do
  route /\ routerFn <- useRouter

  Hooks.pure do
    HH.div [HP.id "app"] [routerView route]

  where
    routerView :: Maybe Route -> HH.HTML _ _
    routerView = case _ of
      Nothing -> HH.text "Not found"
      Just route -> case route of
        Welcome -> HH.slot (Proxy :: Proxy "welcomePage") unit welcomePage {} absurd
        SignUp -> HH.slot (Proxy :: Proxy "signUpPage") unit signUpPage {} absurd   
        SignIn { redirectTo } -> HH.slot (Proxy :: Proxy "signInPage") unit signInPage { redirectTo } absurd
        Main mainRoute -> HH.slot (Proxy :: Proxy "mainLayout") unit mainLayout { route: mainRoute } absurd