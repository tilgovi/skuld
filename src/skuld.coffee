Trait = (require 'traits').Trait
util = require 'util'

TEventEmitter = Trait { emit : Trait.required }

###
Basic monadic stuff
###

#Bindable!
TMonad = Trait
  unit : Trait.required
  bind : Trait.required
  toString : () ->
    @bind (value) ->
      switch (Object.getOwnPropertyDescriptor(value, 'toString'))
        when undefined then util.inspect value
        else value.toString()
  log : () ->
    util.log @toString()
    @unit (@bind (value) -> value)

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

#Maybe?
Maybe = (value) -> if value then Just value else None

# Really? Lists?
List = (items = []) ->
  Trait.override (Trait {
    unit : (items) -> List items
    toString : () -> "List([#{items}])"
  })
  , (Just items)

#TComparable = Trait { compareTo : Trait.required }

#Skuld = (mark, value) ->
#  Trait.create {
#    bind : (fn) -> fn value
#    compareTo : (other) ->
#      if mark is other then 0 else if mark < other then -1 else 1
#  }
#  , (Trait.compose TMonad, TComparable)

TProposer = Trait
  propose : Trait.required

TAcceptor = (mark, verdandi) -> Trait
  mark : mark
  verdandi : verdandi
  prepare : (mark, promise) ->
    promise ('nack' unless mark >= @mark), @wyrd
  #TODO accept : (mark, verdandi, ack) ->

TLearner = Trait
  learn : Trait.required

roles = [TProposer, TAcceptor, TLearner]
exports.createNorn = createNorn = (prototype = Object.prototype) ->
  traits =
  roles.reduce (traits, role) ->
    try
      Trait.create prototype, (Trait.compose traits, role)
      traits.concat role
    catch error
      traits
  , []
  Trait.create Object.prototype, Trait.compose (Just prototype), traits...

TConsensus = Trait {
  prepare : Trait.required
  add : Trait.required
  remove : Trait.required
}

Consensus = (norns) ->
  Trait.create Object.prototype
  , (Trait.override (Trait {
    unit : (norns) ->
      Consensus norns
    add : (norn) ->
      @bind (old) ->
        Consensus old.concat norn
    prepare : (skuld) -> throw "NI"
    remove : (norns) -> throw "NI"
#    toString : () -> @bind (norns) -> "Consensus(#{norns})"
  })
  , (List norns), TConsensus)

exports.createConsensus = Consensus
