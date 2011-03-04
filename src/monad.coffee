# Monads!

Trait = (require 'traits').Trait
util = require 'util'

# Monads are awesome!
TMonad = (value) -> Trait
  unit : Trait.required                               # Constructable!
  bind : (fn) -> fn.call this, value                  # Bindable!
  toString : () ->                                    # Stringable!
    if value and typeof value.toString == 'function'
      value.toString()
    else
      value
  valueOf : () ->                                     # Uwrappable!
    if value and typeof value.valueOf == 'function'
      value.valueOf()
    else
      value
  inspect : () -> util.inspect value                  # Inspectable!
  log : () ->                                         # Loggable!
    util.log this
    this

# Just a simple value monad.
Just = (value) -> Trait.create Object.prototype, (Trait.compose (Trait {
  unit : Just })
  , (TMonad value))

# Not a value.
Nothing = Trait.create null, (Trait.override (Trait {
  unit : () -> Nothing
  bind : (fn) -> Nothing
  valueOf : () -> null })
  , (TMonad null))

# Possibly a value or possibly, quietly nothing at all...
Maybe = (value) -> if value then Just value else None

# Haskell-style List with indeterminate binding!
List = (items...) -> Trait.create items, (Trait.override (Trait {
  unit : List
  bind : (fn) -> concatMap fn, this })
  , (TMonad items))

# Basic functions
append = (left, right) -> List left..., right...

head = (list) -> list.valueOf()[0]

last = (list) -> list.valueOf()[list.length-1]

tail = (list) -> List list[1..list.length]...

init = (list) -> List list[1..list.length-1]...

length = (list) -> list.length

# List transformations

map = (fn, list) -> List (list.map fn)...

reverse = (list) ->
  list = list.valueOf()
  list.reverse()
  List list...

intersperse = (element, list) ->
  List (list.valueOf().reduce ((acc, item) -> (Array acc..., element, item)))...

intercalate = (list, lists) ->
  (concat (intersperse list, lists).valueOf()...)

# Special folds

concat = (lists...) ->
  List (Array.prototype.concat.call [], (list.valueOf() for list in lists)...)...

concatMap = (fn, list) ->
  concat (map fn, list).valueOf()...

exports.TMonad = TMonad
exports.Just = Just
exports.Nothing = Nothing
exports.List = List
