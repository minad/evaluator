#!/usr/bin/ruby -w
require 'lib/evaluator'
require 'readline'

vars = {}
loop do
  begin
    line = Readline::readline('> ')
    if !line
      puts
      break
    end
    Readline::HISTORY.push(line)
    break if line == 'exit' || line == 'quit'
    if line =~ /^(\w+)\s*:=\s*(.*)$/
      puts vars[$1] = Evaluator($2, vars)
    else
      puts Evaluator(line, vars)
    end
  rescue Exception => ex
    puts ex.message
  end
end

