var assert = require("assert");
var events = require("events");
var util = require("util");

exports.createNorn = createNorn;
exports.createConsensus = createConsensus;

function Norn(norn, mark) {
  this._norn = norn;
  this._mark = mark || -1;
}

Norn.prototype.propose = function (consensus, skuld, cb) {
  consensus.once("learn", cb).prepare(this, skuld);
};

Norn.prototype.prepare = function (mark, promise) {
  if (mark < this._mark) {
    promise("nack", this._wyrd);
  } else {
    this._mark = mark;
    promise(null, this._wyrd);
  }
};

Norn.prototype.accept = function (mark, verdandi, ack) {
  if (mark < this._mark) return;
  this._mark = mark;
  ack(this._wyrd = {
    mark : mark,
    wyrd : verdandi
  });
};

function createNorn(norn) {
  return (new Norn(norn));
}

function Consensus(norns) {
  events.EventEmitter.call(this);
  this._norns = norns || [];
}
util.inherits(Consensus, events.EventEmitter);

Consensus.prototype.add = function (norn) {
  const id = this._norns.length;
  var proposal = this._norns.length;

  return (new Consensus(
    this._norns.concat({
      get id() {
        return id;
      },
      get norn() {
        return norn;
      },
      proposal : proposal
    })));
};

Consensus.prototype.prepare = function (leader, skuld) {
  var count = 0;
  var quorum = Math.floor(((this.length) / 2) + 1);
  var learners = [];
  var wyrd = undefined;
  console.log(leader, "preparing", leader);
  this._norns.forEach(function (n, i) {
    learners.unshift(n);
    n.norn.prepare(leader.mark, function (err, verdandi) {
      console.log("[", leader.mark, "]", n.name, err, verdandi);
      if (err) {
        console.log("[", leader.mark, "]", "abandoned by", leader.name);
        //TODO: Optimize?
        return;
      }
      if (++count >= quorum) {
        if (count == quorum) {
          if (wyrd === undefined)
            wyrd = {
              mark : leader.mark,
              wyrd : skuld
            };
          console.log("[", leader.mark, "]", leader.name, "has a quorum");
          console.log("[", leader.mark, "]", leader.name, "chooses", wyrd.wyrd);
        }
        while(learners.length) {
          learners.pop()(wyrd.mark, wyrd.wyrd);
        }
      } else {
        if (verdandi)
          if (!wyrd || verdandi.mark > wyrd.mark)
            wyrd = verdandi;
      }
    });
  });
};

Consensus.prototype.choose = function (a, b) {
  return (a && (b && (a.mark > b.mark ? a : b)) || b);
};

Consensus.prototype.next = function () {
  return this.reduce(function (consensus, norn) {
    return consensus.add(norn.norn);
  }, new Consensus());
};

function createConsensus(norns) {
  if (Array.isArray(norns)) {
    return norns.reduce(function (consensus, norn) {
      console.log(consensus);
      return consensus.add(norn);
    }, (new Consensus()));
  } else {
    return (new Consensus());
  }
}
