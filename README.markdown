README
======

Evaluator is a mathematical expression evaluator for infix notation. It supports variables and functions.

Usage
-----

    require 'evaluator'
    puts Evaluator('1+1')
    puts Evaluator('sin pi')

See the test cases for more examples.

Calculator
----------

A small calculator program (calc.rb) is provided with this library. You can use
it as follows:

    $ ./calc.rb
    > number := 10
    10
    > number * 3
    30
    > 1 [joule] in [MeV]
    6241509647120.42 MeV

The calculator loads a few natural constants at startup (calc.startup). For unit support
my minad-units library is used. Units are denoted in brackets e.g. [meter], [kV] etc

Authors
-------

Daniel Mendler
