#!/usr/bin/ruby -w
require 'lib/evaluator'
require 'readline'

def process(line, vars, quiet = false)
  exit if line == 'exit' || line == 'quit'
  if line =~ /^(\w+)\s*:=?\s*(.*)$/
    vars[$1] = Evaluator($2, vars)
  else
    Evaluator(line, vars)
  end
rescue Exception => ex
  quiet ? nil : ex.message
end

vars = {}
File.read('calc.startup').split("\n").each { |line| process(line, vars, true) }

loop do
  line = Readline::readline('> ')
  if !line
    puts
    break
  end
  Readline::HISTORY.push(line)
  puts process(line, vars)
end
