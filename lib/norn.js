var assert = require("assert");

exports.createNorn = createNorn;
exports.createConsensus = createConsensus;

function Norn() {
  this._mark = -1;
}

Norn.prototype.prepare = function (mark, promise) {
  if (mark < this._mark) {
    promise("nack", this._wyrd);
  } else {
    this._mark = mark;
    promise(null, this._wyrd);
  }
}

Norn.prototype.accept = function (mark, wyrd) {
  if (mark < this._mark) return;
  this._mark = mark;
  this._wyrd = {
    mark : mark,
    wyrd : wyrd
  };
}

function createNorn(consensus) {
  return consensus.add(new Norn());
}


function Consensus() {
  this._norns = [];
}

Consensus.prototype.add = function (norn) {
  var consensus = this;
  return (this._norns[this._norns.length] = {
    norn : norn,
    id : this._norns.length,
    mark : this._norns.length,
    propose : function (skuld) {
      consensus.propose(consensus._norns[this.id], skuld);
    },
    get wyrd() {
      if (this.norn._wyrd === undefined)
        return undefined;
      return this.norn._wyrd.wyrd;
    }
  });
}

Consensus.prototype.propose = function (leader, skuld) {
  console.log(leader.name, "proposing", skuld);
  setTimeout(
    this.prepare.bind(this),
    Math.random() * 1000,
    leader,
    skuld);
}

Consensus.prototype.prepare = function (leader, skuld) {
  var count = 0;
  var quorum = Math.floor(((this._norns.length) / 2) + 1);
  var learners = [];
  var wyrd = undefined;
  console.log(leader.name, "preparing", leader.mark);
  this._norns.forEach(function (n, i) {
    learners.unshift(n.norn.accept.bind(n.norn));
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
}

function createConsensus() {
  return (new Consensus());
}
