module Nanolog.Frontend.AppM where

import Prelude

import Control.Monad.Reader (class MonadAsk, ReaderT, lift, runReaderT)
import Effect.Aff (Aff)
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class (class MonadEffect)
import Halogen as H
import Halogen.Router.Class (class MonadNavigate, class MonadRouter, current, emitMatched, navigate, print)
import Halogen.Router.Trans.PushState (RouterInstance, RouterT, runRouterT)
import Halogen.Store.Monad (class MonadStore, StoreT, emitSelected, getStore, runStoreT, updateStore)
import Nanolog.Frontend.API.Authentication as API
import Nanolog.Frontend.Capability.Authentication (class Authentication)
import Nanolog.Frontend.Env (Env)
import Nanolog.Frontend.Route (Route)
import Nanolog.Frontend.Store (Action, Store, reduce)
import Safe.Coerce (coerce)

newtype AppM a = AppM (ReaderT Env (RouterT Route (StoreT Action Store Aff)) a)

derive newtype instance Functor AppM
derive newtype instance Apply AppM
derive newtype instance Applicative AppM
derive newtype instance Bind AppM
derive newtype instance Monad AppM
derive newtype instance MonadEffect AppM
derive newtype instance MonadAff AppM
derive newtype instance MonadAsk Env AppM 


instance MonadStore Action Store AppM where
  getStore = AppM $ lift getStore
  updateStore = AppM <<< lift <<< updateStore
  emitSelected = AppM <<< lift <<< emitSelected
     
instance MonadNavigate Route AppM where
  current = AppM $ lift current
  navigate = AppM <<< lift <<< navigate

instance MonadRouter Route AppM where
  print = AppM <<< lift <<< print
  emitMatched = AppM $ lift emitMatched


instance Authentication AppM where
  signIn cred = AppM do
    liftAff $ API.login cred

runAppM :: forall q i o
         . Env
        -> RouterInstance Route
        -> Store 
        -> H.Component q i o AppM
        -> Aff (H.Component q i o Aff)
runAppM env router initialStore = runStoreT initialStore reduce
  <<< H.hoist (runRouterT router <<< (flip runReaderT env) <<< coerce)
