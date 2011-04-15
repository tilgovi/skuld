Trait = (require 'traits').Trait
util = require 'util'

{TMonad, Just, None, List} = require './monad'

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

#roles = [TProposer, TAcceptor, TLearner]
roles = [TAcceptor]
Norn = (base = {}) ->
  Trait.create Object.prototype, (Trait.override (Trait base)
    , (Trait.compose (TMonad base), roles..., Trait { unit: Norn }))

TConsensus = (norns = (List [])) -> Trait.compose (Trait {
  prepare : Trait.required
  add : Trait.required
  remove : Trait.required })
  , (TMonad norns)

Consensus = (norns) -> Trait.create Object.prototype, (Trait.compose (Trait {
  unit : Consensus
  add : (norn) -> @bind (norns) => @unit norns.concat (Norn norn)
  prepare : (skuld) -> throw "NI"
  remove : (norn) -> throw "NI" })
  , (TConsensus norns))

# Exports
exports.createNorn = Norn
exports.createConsensus = Consensus
