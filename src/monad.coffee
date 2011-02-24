# Monads!

Trait = (require 'traits').Trait
util = require 'util'

# Monads are awesome!
TMonad = (value) -> Trait
  unit : Trait.required               # Constructable!
  bind : (fn) -> fn.call this, value  # Bindable!
  valueOf : () -> value.valueOf()     # Uwrappable!
  inspect : () -> util.inspect value  # Presentable!
  log : () ->                         # Loggable!
    util.log @inspect()
    this

# Just a simple value monad.
Just = (value) -> Trait.create Object.prototype, (Trait.compose (Trait {
  unit : Just })
  , (TMonad value))

# Not a value.
Nothing = Trait.create Object.prototype, (Trait.override (Trait {
  inspect: () -> "<Nothing>"
  unit : () -> Nothing
  bind : (fn) -> Nothing })
  , (TMonad null))

# Possibly a value or possibly, quietly nothing at all...
Maybe = (value) -> if value then Just value else None

# Haskell-style List with indeterminate binding!
List = (items) ->
  items = if items then items.slice() else [] # Nasty Mutability, begone!
  Trait.create Object.prototype, (Trait.override (Trait {
  unit : List
  bind : (fn) ->
    @unit (Array.prototype.concat (
        items.map (item) =>
          (fn.call this, item).valueOf()
      )... ) })
  , (TMonad items))

exports.TMonad = TMonad
exports.Just = Just
exports.Nothing = Nothing
exports.List = List
