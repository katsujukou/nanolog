module Nanolog.Frontend.Component.LoginForm where

import Prelude

import Data.Either (Either(..), isRight, note)
import Data.Maybe (Maybe(..))
import Effect.Class (class MonadEffect)
import Formless as F
import Halogen (ClassName(..), HalogenM)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties (ButtonType(..), InputType(..))
import Halogen.HTML.Properties as HP
import Nanolog.Frontend.Data.Types (LoginCredential)
import Nanolog.Shared.Data.Email (Email)
import Nanolog.Shared.Data.Email as Email

type Form :: (Type -> Type -> Type -> Type) -> Row Type
type Form f =
  ( email    :: f String String Email
  , password :: f String Void   String
  --              iput   error  output
  )

initialValues :: { email :: String, password :: String }
initialValues = { email: "", password: "" }

type FormInputs = { | Form F.FieldInput }

type FormContext = F.FormContext (Form F.FieldState) (Form (F.FieldAction Action)) Input Action

type FormlessAction = F.FormlessAction (Form F.FieldState)

type Input = {} 

data Action
  = Receive FormContext
  | Eval FormlessAction

type State = 
  { form :: FormContext
  , done :: Boolean
  }

loginForm :: forall q m
           . MonadEffect m
          => H.Component q Input LoginCredential m 
loginForm = F.formless { liftAction: Eval } mempty $ H.mkComponent
  { initialState: { done: false, form: _ }
  , render
  , eval: H.mkEval $ H.defaultEval
    { receive = Just <<< Receive
    , handleAction = handleAction
    , handleQuery = handleQuery
    }
  }
  where
    handleAction :: Action -> HalogenM _ _ _ _ _ _
    handleAction = case _ of
      Receive ctx@{formState, fields} -> do
        H.modify_ \st -> st
          { done = formState.allTouched && (isRight <$> fields.email.result) == Just true 
          , form = ctx
          }
          
      Eval act ->
        F.eval act
      
    handleQuery :: forall a. F.FormQuery _ _ _ _ a -> H.HalogenM _ _ _ _ _ (Maybe a)
    handleQuery = F.handleSubmitValidate F.raise F.validate
      { email: Email.fromString >>> note "有効なメールアドレスを入力してください"
      , password: Right
      }

    render :: { done :: Boolean, form :: FormContext } -> H.ComponentHTML Action () m
    render { done, form: { formActions, fields, actions }} = 
      HH.form
        [ HP.class_ $ ClassName "login-form"
        , HE.onSubmit formActions.handleSubmit
        ]
        [ HH.div []
          [ HH.div []
            [ HH.input 
              [ HP.type_ $ InputText
              , HP.placeholder "めーるあどれす"
              , HP.value fields.email.value
              , HE.onValueInput actions.email.handleChange
              , HE.onBlur actions.email.handleBlur
              ]
            , ( case fields.email.result of
                Just (Left error) -> 
                  HH.div [HP.class_ $ ClassName "validation-error-desc-area"]
                    [ HH.span_ [HH.text error]
                    ]
                _ -> HH.text ""
              )
            ]
          , HH.div []
            [ HH.input 
              [ HP.type_ $ InputPassword
              , HP.placeholder "ぱすわーど"
              , HP.value fields.password.value
              , HP.max 100.0
              , HE.onValueInput actions.password.handleChange
              , HE.onBlur actions.password.handleBlur
              ]
            ]
          , HH.div []
            [ HH.button
              [ HP.disabled (not done) 
              , HP.type_ ButtonSubmit
              ]
              [ HH.text "ろぐいん"]
            ]
          ]
        ]