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

//  prepare : function(leader, skuld) {
//    function (leader, skuld, mark, promise) {

};
consensus.norns.push(alice, bob, charlie);

consensus.prepare = function (leader, skuld, mark, promise) {
  var count = 0;
  var quorum = Math.floor(((this.norns.length - 1) / 2) + 1);
  var learners = [];
  var fail = undefined;
  this.norns.filter(function (n) {
    return n != leader;
  }).forEach(function (n, i) {
    var index = i;
    n.prepare(mark, function (err, mark, verdandi, accept) {
      assert.ifError(err);
      learners.push(n);
      leader.promise(err, mark, verdandi, function(err, mark, wyrd) {
        if (++count >= quorum) {
          var l;
          while (l = learners.pop()) {
            l.accept(mark, skuld);
          };
        }
        if (count == quorum) {
          console.log("Decided:", mark, skuld);
        }
      });
    });
  });
};

function propose(leader, skuld) {
  leader.propose(skuld, function (mark, promise) {
    setTimeout(function () {
      try {
        consensus.prepare(leader, skuld, mark, promise);
      } catch (err) {
        console.log("Failed:", skuld, leader);
        propose(leader, skuld);
      }
    }, Math.random()*100);
  });
}

propose(alice, "Hello, World!");
propose(bob, "Goodbye, cruel World!");
propose(charlie, "Bacon?");

process.on("exit", function() {
  console.log("Alice:", alice);
  console.log("Bob:", bob);
  console.log("Charlie:", charlie)
});
/*
var han = norn.createNorn({
  prepare: function (mark, promise) {
    promise(null, mark);
  }
});

han.propose("Hello, World!");
*/