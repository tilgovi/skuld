var assert = require("assert");

function Norn() {
  this._mark = -1;
  this._wyrd = {};
};

Norn.prototype.propose = function (skuld, prepare) {
  this._wyrd[++this._mark] = skuld;
  prepare(this._mark, this.promise.bind(this));
};

Norn.prototype.prepare = function (mark, promise) {
  if (mark < this._mark) {
    promise("NACK", mark, this._wyrd[mark], this.accept.bind(this));
  } else {
    this._mark = mark + 1;
    promise(undefined, mark, this._wyrd[mark], this.accept.bind(this));
  }
};

Norn.prototype.promise = function (err, mark, verdandi, accept) {
  if (err) this._wyrd[mark] = verdandi;
  accept(err, mark, verdandi);
};

Norn.prototype.accept = function (mark, wyrd) {
  this._wyrd[mark] = wyrd;
};

exports.createNorn = function (consensus) {
  var norn = new Norn();
  return {
    propose : function (skuld) {
      norn.propose(skuld, consensus.prepare.bind(consensus));
    }
  };
};

exports.Norn = Norn;