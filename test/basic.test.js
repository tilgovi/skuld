require('./test.js');
var assert = require("assert");
var util = require("util");
var Norn = require('norn').Norn;

var alice = new Norn();
alice.name = "Alice";
var bob = new Norn();
bob.name = "Bob";
var charlie = new Norn();
charlie.name = "Charlie";

var consensus = {
  norns : [],

  propose : function(leader, skuld) {
    leader.propose(skuld, this.prepare.bind(this, leader, skuld));
  },

  prepare : function(leader, skuld, mark) {
    var count = 0;
    var quorum = Math.floor(((this.norns.length) / 2) + 1);
    var learners = [];
    this.norns.forEach(function (n, i) {
      n.prepare(mark, function (err, verdandi, accept) {
        if (err) {
          skuld = verdandi;
          leader.accept(mark, verdandi);
          return;
        }
        console.log("[", mark, "]", n.name, "promised", verdandi);
        learners.unshift(accept);
        if (++count >= quorum) {
          while(learners.length) {
            learners.pop()(skuld);
          }
        }
      });
    });
  }
};
consensus.norns.push(alice, bob, charlie);

var propose = function(leader, skuld) {
  setTimeout(
    consensus.propose.bind(consensus),
    Math.random() * 1000,
    leader,
    skuld);
};

propose(alice, "Hello, World!");
propose(bob, "Goodbye, cruel World!");
propose(charlie, "Bacon?");


process.on("exit", function () {
  console.log("Alice:", alice);
  console.log("Bob:", bob);
  console.log("Charlie:", charlie)
});
