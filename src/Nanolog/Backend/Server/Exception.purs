module Nanolog.Backend.Server.Exception
  ( Exception
  , ExceptionRow
  , databaseError
  )
  where


import Data.Variant (Variant, inj)
import Database.PostgreSQL (PGError)
import Type.Proxy (Proxy(..))


type ExceptionRow =
  ( database :: PGError
  )

type Exception = Variant ExceptionRow

databaseError :: PGError -> Exception
databaseError = inj (Proxy :: Proxy "database")