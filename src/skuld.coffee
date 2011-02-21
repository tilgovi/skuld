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
      switch Object.getOwnPropertyDescriptor(value, 'toString')
        when undefined then util.inspect value
        else value.toString()
  print : () ->
    @bind (value) ->
      console.log "[LOG: HH:MM:SS] #{value}"
      value.unit value

#Actual!
Just = (value) -> Trait.create {
  unit : (value) -> Just value
  bind : (fn) -> fn value
}, TMonad

#Nacktual!!
None = Trait.create {
  unit : () -> None
  bind : (fn) -> None
  toString : () -> "<None>"
}, TMonad

#Maybe?
Maybe = (value) -> if value then Just value else None

# Really? Lists?
List = (items = []) ->
  Trait.create (Just items), (Trait.override (Trait {
    unit : (items) -> List items
    toString : () -> "List([#{items}])"
  }), TMonad)

TComparable = Trait { compareTo : Trait.required }

Skuld = (mark, value) ->
  Trait.create {
    bind : (fn) -> fn value
    compareTo : (other) ->
      if mark is other then 0 else if mark < other then -1 else 1
  }
  , (Trait.compose TMonad, TComparable)

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
createNorn = (prototype = Object.prototype) ->
  traits =
  roles.reduce (traits, role) ->
    try
      Trait.create prototype, (Trait.compose traits, role)
      traits.concat role
    catch error
      traits
  , []
  Trait.create (Just prototype), (Trait.compose traits...)

TConsensus = (norns) -> Trait.compose TMonad, Trait {
  bind : (fn) -> fn norns
  norns : norns
  prepare : Trait.required
  bind : (fn) -> fn norns
  add : Trait.required
  remove : Trait.required
}

Consensus = (norns) ->
  Trait.create {
    unit : (norns) -> Consensus norns
    add : (norn) ->
      console.log "Adding #{norn} to #{@norns}"
      @norns.bind (old) ->
        Consensus old.concat (createNorn norn)
    prepare : (skuld) -> throw "NI"
    remove : (norns) -> throw "NI"
  }
  , TConsensus List norns

exports.createConsensus = Consensus
