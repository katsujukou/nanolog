{-
Welcome to a Spago project!
You can edit this file as you like.

Need help? See the following resources:
- Spago documentation: https://github.com/purescript/spago
- Dhall language tour: https://docs.dhall-lang.org/tutorials/Language-Tour.html

When creating a new Spago project, you can use
`spago init --no-comments` or `spago init -C`
to generate this file without the comments in this block.
-}
{ name = "my-project"
, dependencies =
  [ "aff"
  , "aff-promise"
  , "argonaut"
  , "arrays"
  , "biscotti-cookie"
  , "checked-exceptions"
  , "codec-argonaut"
  , "console"
  , "effect"
  , "either"
  , "exceptions"
  , "foldable-traversable"
  , "foreign"
  , "functions"
  , "halogen"
  , "halogen-formless"
  , "halogen-hooks"
  , "halogen-router"
  , "halogen-store"
  , "js-date"
  , "lists"
  , "maybe"
  , "newtype"
  , "node-buffer"
  , "node-fs-aff"
  , "node-http"
  , "node-path"
  , "node-process"
  , "nullable"
  , "optparse"
  , "payload"
  , "posix-types"
  , "postgresql-client"
  , "prelude"
  , "profunctor-lenses"
  , "routing-duplex"
  , "safe-coerce"
  , "selda"
  , "simple-json"
  , "strings"
  , "transformers"
  , "tuples"
  , "typelevel-prelude"
  , "variant"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
