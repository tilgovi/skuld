# Monads!

Trait = (require 'traits').Trait
util = require 'util'

#Monads are awesome.
TMonad = Trait
  unit : Trait.required #Constructable!
  bind : Trait.required #Bindable!
  toString : () ->      #Presentable!
    @bind (value) ->
      try
        switch (Object.getOwnPropertyDescriptor(value, 'toString'))
          when undefined then util.inspect value
          else value.toString()
      catch error
        value
  log : () ->           #Loggable!
    util.log @toString()
    @bind (value) => @unit value

#Actual!
Just = (value) ->
  Trait.compose (Trait {
    unit : (value) -> Trait.create Object.prototype, (Just value)
    bind : (fn) -> fn value
  }), TMonad

#Nacktual!!
None = Trait.override {
  unit : () -> None
  bind : (fn) -> None
  toString : () -> "<None>"
}, TMonad

#or quietly, possibly nothing at all...
Maybe = (value) -> if value then Just value else None

# Toto, I don't think we're in JavaScript anymore.
List = (items = []) ->
  Trait.override (Trait {
    unit : (items) -> List items
    toString : () -> "List([#{items}])"
  })
  , (Just items)

exports.TMonad = TMonad
exports.Just = Just
exports.None = None
exports.List = List