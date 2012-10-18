# -*- encoding: utf-8 -*-
require File.dirname(__FILE__) + '/lib/evaluator'
require 'date'

Gem::Specification.new do |s|
  s.name              = 'evaluator'
  s.version           = Evaluator::VERSION
  s.date              = Date.today.to_s
  s.authors           = ['Daniel Mendler']
  s.email             = ['mail@daniel-mendler.de']
  s.summary           = 'Mathematical expression evaluator'
  s.description       = 'Mathematical expression evaluator for infix notation'
  s.homepage          = 'http://github.com/minad/evaluator'
  s.rubyforge_project = s.name

  s.files         = `git ls-files`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = %w(lib)

  s.add_development_dependency('bacon')
  s.add_development_dependency('rake')
  s.add_development_dependency('unit')
end
