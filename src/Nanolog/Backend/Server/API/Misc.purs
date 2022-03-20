module Nanolog.Backend.Server.API.Misc where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe(..), isJust)
import Effect.Class (liftEffect)
import Nanolog.Backend.Server.API.Utils (ApiResponse', failedWith, ok)
import Nanolog.Backend.Server.Capability.Authentication (class Authentication, findAccessTokenById, findAuthUserById, verifyToken)
import Nanolog.Backend.Server.Data.Token (TokenError(..))
import Nanolog.Shared.Data.Types (AccessToken, AuthUserInfo)
import Nanolog.Shared.Foreign.Day as Day
import Payload.Server.Response (badRequest, unauthorized)


provideAuthUser :: forall m
                 . Authentication m
                => AccessToken -> m (ApiResponse' AuthUserInfo)
provideAuthUser accessToken = do
  verifyToken accessToken >>= case _ of
    Left e -> failedWith $ toErrorResponse e
    Right {jti: tokenId, uid: userId} -> do
      maybeToken <- findAccessTokenById tokenId
      case maybeToken of
        Nothing -> failedWith $ badRequest "認証に失敗しました"
        Just token -> do
          now <- liftEffect Day.now
          if isJust token.revokedAt && token.revokedAt <= Just now
            then failedWith $ unauthorized "認証情報の有効期限が切れています。再度ログインしてください。"
            else do
              findAuthUserById userId >>= case _ of
                Nothing -> pure $ Left $ badRequest "ユーザ情報が見つかりませんでした"
                Just { id, email, createdAt } -> ok { id, email, createdAt }

  where
    toErrorResponse = case _ of
      Expired -> unauthorized "認証情報の有効期限が切れています。再度ログインしてください。"
      _ -> badRequest "認証に失敗しました"

