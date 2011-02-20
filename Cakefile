{spawn, exec} = require 'child_process'

# riak-js inspired

print = (data) -> console.log data.toString().trim()

task 'dev', 'Live Development', ->
  coffee = spawn 'coffee', '-wc --bare -o lib src'.split(' ')
  coffee.stdout.on 'data', print
  coffee.stderr.on 'data', print
