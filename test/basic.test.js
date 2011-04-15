require("./test.js");
var assert = require("assert");
var util = require("util");
var skuld = require("skuld");

var alice = {name : "Alice"};
var bob = {name : "Bob"};
var charlie = ({name : "Charlie"});



/*var consensus =
  skuld.createConsensus()
  .add(alice)
  .add(bob)
  .add(charlie).log();*/

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
