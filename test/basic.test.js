require("./test.js");
var assert = require("assert");
var util = require("util");
var skuld = require("skuld");

var alice = skuld.createNorn({name : "Alice"});
var bob = skuld.createNorn({name : "Bob"});
var charlie = skuld.createNorn({name : "Charlie"});

//alice.log();
var consensus =
  skuld.createConsensus()
  .add(alice)
  .add(bob)
  .add(charlie).log();

/*

/*var propose = function (leader, skuld, cb) {
  setTimeout(
    leader.propose.bind(leader),
    Math.random() * 100,
    consensus,
    skuld,
    cb
  );
};

propose(alice, "Hello, World!");
propose(bob, "Goodbye, cruel World!");
propose(charlie, "Bacon?");

process.on("exit", function () {
  assert.equal(alice.wyrd, bob.wyrd, "Alice and Bob agree");
  assert.equal(bob.wyrd, charlie.wyrd, "Bob and Charlie agree");
  console.log(alice.wyrd);
});*/
