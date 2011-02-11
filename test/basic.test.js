require("./test.js");
var assert = require("assert");
var util = require("util");
var skuld = require("skuld");

var consensus = new skuld.createConsensus();

var alice = skuld.createNorn(consensus);
alice.name = "Alice";

var bob = skuld.createNorn(consensus);
bob.name = "Bob";

var charlie = skuld.createNorn(consensus);
charlie.name = "Charlie";

var propose = function (leader, skuld) {
  setTimeout(
    leader.propose.bind(leader),
    Math.random() * 100,
    skuld,
    consensus.prepare.bind(consensus));
}

propose(alice, "Hello, World!");
propose(bob, "Goodbye, cruel World!");
propose(charlie, "Bacon?");

process.on("exit", function () {
  assert.equal(alice.wyrd, bob.wyrd, "Alice and Bob agree");
  assert.equal(bob.wyrd, charlie.wyrd, "Bob and Charlie agree");
  console.log(alice.wyrd);
});
