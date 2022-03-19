module Nanolog.Backend.Server.API.Login where

import Prelude

import Data.Maybe (Maybe(..))
import Nanolog.Backend.Server.API.Utils (ApiResponse', failedWith, ok)
import Nanolog.Backend.Server.Capability.Authentication (class Authentication, createNewToken, findAuthUserByEmail, revokeAllTokensByUser, verifyPassword)
import Nanolog.Shared.Data.Email (Email)
import Nanolog.Shared.Data.Types (AuthUserInfo, AccessToken)
import Payload.Server.Response (badRequest, notFound)


login :: forall m
       . Authentication m
      => { email :: Email, password :: String }
      -> m (ApiResponse' { accessToken :: AccessToken, authUser :: AuthUserInfo })
login {email, password} = do
  maybeUser <- findAuthUserByEmail email
  case maybeUser of
    Nothing -> failedWith $ notFound "メールアドレスが見つかりませんでした"
    Just authUser@{id, createdAt} -> do
      verified <- verifyPassword password authUser
      if not verified
        then failedWith $ badRequest "パスワードが正しくありません。"
        else do
         revokeAllTokensByUser id
         accessToken <- createNewToken id
         ok { authUser: { id, email, createdAt }, accessToken }