require("./test.js");
var assert = require("assert");
var util = require("util");
var norn = require("norn");

var consensus = new norn.createConsensus();

var alice = norn.createNorn(consensus);
alice.name = "Alice";

var bob = norn.createNorn(consensus);
bob.name = "Bob";

var charlie = norn.createNorn(consensus);
charlie.name = "Charlie";

alice.propose("Hello, World!");
bob.propose("Goodbye, cruel World!");
charlie.propose("Bacon?");

process.on("exit", function () {
  console.log("Alice:", alice.wyrd);
  console.log("Bob:", bob.wyrd);
  console.log("Charlie:", charlie.wyrd);
});
