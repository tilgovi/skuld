# Monads!

Trait = (require 'traits').Trait
util = require 'util'

# Monads are awesome!
TMonad = (value) -> Trait
  unit : Trait.required               # Constructable!
  bind : (fn) -> fn.call this, value  # Bindable!

  # These could break out into top level traits but now this is useful.
  inspect : () -> util.inspect value  # Presentable!
  log : () ->                         # Loggable!
    util.log @inspect()
    this

# Just a simple value monad.
Just = (value) -> Trait.create Object.prototype, (Trait.compose (Trait {
  unit : Just })
  , (TMonad value))

# Not a value.
None = Trait.create Object.prototype, (Trait.override (Trait {
  inspect: () -> "<None>"
  unit : () -> None
  bind : (fn) -> None })
  , (TMonad null))

# Possibly a value or possibly, quietly nothing at all...
Maybe = (value) -> if value then Just value else None

# There comes a time in every coder's life when...
List = (items = []) -> Trait.create Object.prototype, (Trait.override (Trait {
  unit : List
  length : items.length # Safe because the value is copied
  concat : (va...) -> @bind (array) => @unit (array.concat va...)
  sort : (fn) -> @unit ((Array items...).sort fn) })
  , (TMonad items.slice()))

exports.TMonad = TMonad
exports.Just = Just
exports.None = None
exports.List = List