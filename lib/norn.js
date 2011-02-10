var assert = require("assert");

function Norn() {
  this._mark = -1;
  this._wyrd = {};
}

Norn.prototype.propose = function (skuld, prepare) {
  var mark = this._mark + 1;
  this._wyrd[mark] = skuld;
  prepare(mark);
}

Norn.prototype.prepare = function (mark, promise) {
  if (mark <= this._mark) {
    promise("nack", this._wyrd[mark]);
  } else {
    this._mark = mark;
    promise(null, this._wyrd[mark], this.accept.bind(this, mark));
  }
}

Norn.prototype.accept = function (mark, wyrd) {
  if (mark >= this._mark) {
    this._wyrd[mark] = wyrd;
  }
}

exports.createNorn = function (consensus) {
  var norn = new Norn();
  return {
    propose : function (skuld) {
      norn.propose(skuld, consensus.prepare.bind(consensus));
    }
  };
}

exports.Norn = Norn;