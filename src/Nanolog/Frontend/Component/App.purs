module Nanolog.Frontend.Component.App where


import Prelude

import Data.Either (hush)
import Data.Maybe (Maybe(..), fromMaybe, isJust, isNothing)
import Data.Tuple.Nested ((/\))
import Effect.Class.Console as Console
import Halogen (lift)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import Halogen.Hooks (HookM, useLifecycleEffect)
import Halogen.Hooks as Hooks
import Halogen.Router.Class (class MonadRouter, current, navigate)
import Halogen.Router.UseRouter (useRouter)
import Halogen.Store.Monad (class MonadStore, updateStore)
import Halogen.Store.Select (Selector, selectEq)
import Halogen.Store.UseSelector (useSelector)
import Nanolog.Frontend.Capability.Authentication (class Authentication, getSelf)
import Nanolog.Frontend.Layouts.MainLayout (mainLayout)
import Nanolog.Frontend.Route (Route(..), home, notAuthOnly, requireAuth, routeCodec)
import Nanolog.Frontend.Route as Route
import Nanolog.Frontend.Store (Action(..), Store)
import Nanolog.Frontend.Views.SignInPage (signInPage)
import Nanolog.Frontend.Views.SignInPage as SignInPage
import Nanolog.Frontend.Views.SignUpPage (signUpPage)
import Nanolog.Frontend.Views.WelcomePage (welcomePage)
import Nanolog.Shared.Data.Types (AuthUserInfo)
import Routing.Duplex as RouteDuplex
import Type.Proxy (Proxy(..))

selector :: Selector Store Context
selector = selectEq \st -> st.app

type Context =
  { auth :: Maybe AuthUserInfo
  , boot :: Boolean
  }

app :: forall q i o m
     . MonadRouter Route m
    => MonadStore Action Store m
    => Authentication m
    => H.Component q i o m
app = Hooks.component \_ _ -> Hooks.do
  route /\ routerFn <- useRouter

  ctx <- useSelector selector

  _ <- useNavGuard { route, ctx } routerFn

  -- Initializer & Finalizer
  useLifecycleEffect do
    -- 現在のログイン情報を取得する
    maybeUser <- getSelf
    case maybeUser of
      Just user -> do
        lift $ updateStore $ SetAuthUser user
      Nothing -> pure unit

    -- 初期処理完了
    lift $ updateStore SetBoot

    pure Nothing
    
  Hooks.pure do
    HH.div [HP.id "app"] [routerView route]

  where
    routerView :: Maybe Route -> HH.HTML _ _
    routerView = case _ of
      Nothing -> HH.text "Not found"
      Just route -> case route of
        Welcome -> HH.slot (Proxy :: Proxy "welcomePage") unit welcomePage {} absurd
        SignUp -> HH.slot (Proxy :: Proxy "signUpPage") unit signUpPage {} absurd   
        SignIn { redirectTo } -> HH.slot (Proxy :: Proxy "signInPage") unit signInPage { redirectTo } handleSignInPage
        Main mainRoute -> HH.slot (Proxy :: Proxy "mainLayout") unit mainLayout { route: mainRoute } absurd
         
    handleSignInPage :: SignInPage.Message -> HookM m Unit
    handleSignInPage = case _ of
      SignInPage.LoggedIn authUser -> do
        updateStore $ SetAuthUser authUser
        -- 以下はnavGuardがちゃんと動いてくれればいらないはず。。
        redirectTo <- current <#> case _ of
            Just (SignIn { redirectTo: Just to }) -> hush $ RouteDuplex.parse routeCodec to
            _ -> Nothing
        navigate $ fromMaybe home redirectTo

    -- FIXME なぜかupdateStoreとかnavigateしても呼ばれない...
    useNavGuard deps@{ route, ctx } { navigate, print } =
      Hooks.captures deps Hooks.useTickEffect do
        let auth = ctx >>= _.auth
        Console.log "route changed"
        Console.logShow auth
        case route of
          Nothing -> pure Nothing
          Just r -> do
            -- Not logged in, but current route requires authenticated -> redirect to Login page.
            when (isNothing auth && requireAuth r) do
              redirectTo <- print r <#> Just
              navigate $ Route.SignIn { redirectTo }

            -- Loggdd in, but current route is accessible only when not logged in -> redirect to home.
            when (isJust auth && notAuthOnly r) do
              navigate Route.home

            pure Nothing
