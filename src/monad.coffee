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
    console.log this
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

# Stateful computations!
State = (sfn) -> Trait.create sfn, (Trait.override (Trait {
  unit : (u) ->
    State ((s) -> List u, s)
  bind : (fn) ->
    State ((s) =>
      [result, state2] = runState this, s
      runState (fn.call this, result), state2) })
  , (TMonad sfn))

put = (s) -> State ((_) -> List null, s)
get = State ((s) -> List s, s)

runState = (state, input) -> state.valueOf().call state, input
evalState = (state, input) -> head (runState state, input)
execState = (state, input) -> last (runState state, input)

#
# Demonstration
#

demoTest = () ->
  # Cross product
  cross = (ls1, ls2) ->
    ls1.bind ((x) ->
      ls2.bind ((y) ->
        List [x,y]))
  (cross (List 'A','B'), (List 1, 2, 3)).log()

  # Normal iteration
  for item in (List 5, 6)
    console.log item

  # Some list operations
  (reverse (append (List 5, 6), (List 7, 8))).log()
  (intersperse 0, (List 1,2,3,4,5)).log()
  (intercalate (List 0), (List (List 1, 2), (List 3, 4), (List 5, 6))).log()

  # Simple state computations
  countdown = get.bind (i) ->
    console.log i
    (put i-1).bind ->
      @unit i

  state = 10
  while state > 0
    state = execState countdown, state
  console.log "Blast off!"
exports.test = demoTest

exports.TMonad = TMonad
exports.Just = Just
exports.Nothing = Nothing
exports.List = List
demoTest()