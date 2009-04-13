require 'complex'

module Evaluator

  VERSION = "0.1"
  INTEGER = /\d+/
  REAL = /(?:\d*\.\d+(?:[eE][-+]?\d+)?|\d+[eE][-+]?\d+)/
  STRING = /'(?:[^']|\\')+'|"(?:[^"]|\\")+"/
  SYMBOL = /[\w_]+/
  FUNCTIONS = {
    'sin' => 1, 'cos' => 1, 'tan' => 1, 'sinh' => 1, 'cosh' => 1, 'tanh' => 1, 'asin' => 1, 'acos' => 1, 'atan' => 1,
    'asinh' => 1, 'atanh' => 1, 'sqrt' => 1, 'log' => 1, 'ln' => 1, 'log10' => 1, 'log2' => 1, 'exp' => 1,
    'floor' => 1, 'ceil' => 1, 'string' => 1, 'int' => 1, 'float' => 1, 'rand' => 0, 'conj' => 1, 'im' => 1, 're' => 1, 'round' => 1,
    'abs' => 1, 'minus' => 1, 'plus' => 1, 'not' => 1 }
  OPERATOR = [ %w(|| or), %w(&& and), %w(== != <= >= < >), %w(+ -),
             %w(<< >>), %w(& | ^), %w(* / % div mod), %w(**), %w(!) ]
  UNARY = {
    '+' => 'plus',
    '-' => 'minus',
    '!' => 'not'
  }
  CONSTANTS = {
    'true'  => true,
    'false' => false,
    'nil'   => nil,
    'e'     => Math::E,
    'pi'    => Math::PI,
    'i'     => Complex::I
  }

  OP = {}
  (OPERATOR + [FUNCTIONS.keys]).each_with_index do |ops,i|
    ops.each { |op| OP[op] = i }
  end

  TOKENIZER = Regexp.new("#{REAL.source}|#{INTEGER.source}|#{STRING.source}|#{SYMBOL.source}|\\(|\\)|,|" +
                         (OPERATOR + FUNCTIONS.keys).flatten.sort { |a,b| b.length <=> a.length}.map { |op| Regexp.quote(op) }.join('|'))

  def self.eval(expr, vars = {})
    table = CONSTANTS.dup
    vars.each_pair {|k,v| table[k.to_s.downcase] = v }
    tokens = expr.scan(TOKENIZER)
    stack, post = [], []
    prev = nil
    tokens.each do |tok|
      if tok == '('
        stack << '('
      elsif tok == ')'
        op(post, stack.pop) while !stack.empty? && stack.last != '('
        raise(SyntaxError, "Unexpected token )") if stack.empty?
        stack.pop
      elsif tok == ','
        op(post, stack.pop) while !stack.empty? && stack.last != '('
      elsif FUNCTIONS.include?(tok.downcase)
        stack << tok.downcase
      elsif OP.include?(tok)
        if (prev == nil || OP.include?(prev)) && UNARY.include?(tok)
          stack << UNARY[tok]
        else
          op(post, stack.pop) while !stack.empty? && stack.last != '(' && OP[stack.last] >= OP[tok]
          stack << tok
        end
      elsif tok =~ STRING
        post << tok[1..-2]
      elsif tok =~ REAL
        post << tok.to_f
      elsif tok =~ INTEGER
        post << tok.to_i
      else
        tok.downcase!
        raise(NameError, "Symbol #{tok} is undefined") if !table.include?(tok)
        post << table[tok]
      end
      prev = tok
    end
    op(post, stack.pop) while !stack.empty?
    post[0]
  end

  def self.op(stack, op)
    stack << \
    if FUNCTIONS.include?(op)
      args = FUNCTIONS[op]
      raise(SyntaxError, "Not enough operands on the stack") if stack.size < args
      a = stack.slice!(-args, args)
      case op
      when 'sin'    then Math.sin(a[0])
      when 'cos'    then Math.cos(a[0])
      when 'tan'    then Math.tan(a[0])
      when 'sinh'   then Math.sinh(a[0])
      when 'cosh'   then Math.cosh(a[0])
      when 'tanh'   then Math.tanh(a[0])
      when 'asin'   then Math.asin(a[0])
      when 'acos'   then Math.acos(a[0])
      when 'atan'   then Math.atan(a[0])
      when 'asinh'  then Math.asinh(a[0])
      when 'atanh'  then Math.atanh(a[0])
      when 'sqrt'   then Math.sqrt(a[0])
      when 'log'    then Math.log(a[0])
      when 'ln'     then Math.log(a[0])
      when 'log10'  then Math.log10(a[0])
      when 'log2'   then Math.log(a[0])/Math.log(2)
      when 'exp'    then Math.exp(a[0])
      when 'floor'  then a[0].floor
      when 'ceil'   then a[0].ceil
      when 'string' then a[0].to_s
      when 'float'  then a[0].to_f
      when 'int'    then a[0].to_i
      when 'rand'   then rand
      when 'conj'   then a[0].conj
      when 'im'     then a[0].imag
      when 're'     then a[0].real
      when 'round'  then a[0].round
      when 'abs'    then a[0].abs
      when 'plus'   then a[0]
      when 'minus'  then -a[0]
      when 'not'    then !a[0]
      end
    else
      raise(SyntaxError, "Not enough operands on the stack") if stack.size < 2
      b = stack.pop
      a = stack.pop
      case op
      when '||'  then a || b
      when 'or'  then a || b
      when '&&'  then a && b
      when 'and' then a && b
      when '=='  then a == b
      when '!='  then a != b
      when '<='  then a <= b
      when '>='  then a >= b
      when '<'   then a < b
      when '>'   then a > b
      when '+'   then a + b
      when '-'   then a - b
      when '*'   then a * b
      when '/'   then a / b
      when 'div' then a.div(b)
      when '%'   then a % b
      when 'mod' then a % b
      when '**'  then a ** b
      when '<<'  then a << b
      when '>>'  then a >> b
      when '&'   then a & b
      when '|'   then a | b
      when '^'   then a ^ b
      else
        raise(SyntaxError, "Unexpected token #{op}")
      end
    end
  end

  private_class_method :op

end

def Evaluator(expr, vars = {})
  Evaluator.eval(expr, vars)
end
