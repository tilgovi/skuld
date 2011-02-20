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

#Actual!
Just = (value) -> Trait.create {
  unit : (value) -> Just value
  bind : (fn) -> fn value }, TMonad

#Nacktual!!
None = Trait.create {
  unit : None
  bind : (fn) -> None }, TMonad

#Maybe?
Maybe = (value) -> if value then Just value else None

# Yummy (maple) logging syrup!
# Maybe make a sick logging module here???!?!? yeah!?
IO = Trait.compose TMonad, Trait {
  toString : Trait.required
  print : () ->
    console.log "[LOG: HH:MM:SS]", this.toString()
    this
}

# Really? Lists?
List = (items = []) ->
  list = Trait.create Object.prototype, (Trait.override (Trait {
    unit : (items) -> List items
    bind : (fn) -> fn items
    toString : () -> "List([#{items}])"
  }), IO, TMonad)
  return list

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

TConsensus = (norns) -> Trait.compose TMonad, IO, Trait
  bind : (fn) -> fn norns
  norns : norns
  prepare : Trait.required
  bind : (fn) -> fn norns
  add : Trait.required
  remove : Trait.required

Consensus = (norns) ->
  Trait.create {
    unit : (norns) -> Consensus norns
    add : (norn) ->
      @norns.bind (old) ->
        Consensus old.concat (createNorn norn)
    prepare : (skuld) -> throw "NI"
    remove : (norns) -> throw "NI" }
  , TConsensus List norns

    #@bind (norns) ->
    #  new Consensus
    #    norns.concat Trait.create
    #      mark : @norns.length
    #    TNorn
    #    mark : -1
    #    verdandi : TSkuld
    #  }, TNorn(norn)

exports.createConsensus = Consensus
