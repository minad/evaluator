require 'complex'

module Evaluator
  def self.infix(priority, unary = nil, &block) [false, priority, lambda(&block), unary] end
  def self.prefix(&block) [true, 1e5, lambda(&block)] end

  VERSION = "0.1"
  OPERATOR = {
    '||'     => infix(0) {|a,b| a || b },
    'or'     => infix(0) {|a,b| a || b },
    '&&'     => infix(1) {|a,b| a && b },
    'and'    => infix(1) {|a,b| a && b },
    '=='     => infix(2) {|a,b| a == b },
    '!='     => infix(2) {|a,b| a != b },
    '<='     => infix(2) {|a,b| a <= b },
    '>='     => infix(2) {|a,b| a >= b },
    '<'      => infix(2) {|a,b| a < b },
    '>'      => infix(2) {|a,b| a > b },
    '+'      => infix(3, 'plus') {|a,b| a + b },
    '-'      => infix(3, 'minus') {|a,b| a - b },
    '>>'     => infix(4) {|a,b| a >> b },
    '<<'     => infix(4) {|a,b| a << b },
    '&'      => infix(5) {|a,b| a & b },
    '|'      => infix(5) {|a,b| a | b },
    '^'      => infix(5) {|a,b| a ^ b },
    '*'      => infix(6) {|a,b| a * b },
    '/'      => infix(6) {|a,b| a / b },
    '%'      => infix(6) {|a,b| a % b },
    'div'    => infix(6) {|a,b| a.div b },
    'mod'    => infix(6) {|a,b| a % b },
    '**'     => infix(7) {|a,b| a ** b },
    'sin'    => prefix {|x| Math.sin(x) },
    'cos'    => prefix {|x| Math.cos(x) },
    'tan'    => prefix {|x| Math.tan(x) },
    'sinh'   => prefix {|x| Math.sinh(x) },
    'cosh'   => prefix {|x| Math.cosh(x) },
    'tanh'   => prefix {|x| Math.tanh(x) },
    'asin'   => prefix {|x| Math.asin(x) },
    'acos'   => prefix {|x| Math.acos(x) },
    'atan'   => prefix {|x| Math.atan(x) },
    'asinh'  => prefix {|x| Math.asinh(x) },
    'atanh'  => prefix {|x| Math.atanh(x) },
    'sqrt'   => prefix {|x| Math.sqrt(x) },
    'log'    => prefix {|x| Math.log(x) },
    'ln'     => prefix {|x| Math.log(x) },
    'log10'  => prefix {|x| Math.log10(x) },
    'log2'   => prefix {|x| Math.log(x)/Math.log(2) },
    'exp'    => prefix {|x| Math.exp(x) },
    'floor'  => prefix {|x| x.floor },
    'ceil'   => prefix {|x| x.ceil },
    'string' => prefix {|x| x.to_s },
    'int'    => prefix {|x| x.to_i },
    'float'  => prefix {|x| x.to_f },
    'rand'   => prefix {|| rand },
    'conj'   => prefix {|x| x.conj },
    'im'     => prefix {|x| x.imag },
    're'     => prefix {|x| x.real },
    'round'  => prefix {|x| x.round },
    'abs'    => prefix {|x| x.abs },
    'minus'  => prefix {|x| -x },
    'plus'   => prefix {|x| x },
    '!'      => prefix {|x| !x },
    'substr' => prefix {|x,a,b| x.slice(a,b) },
    'len'    => prefix {|x| x.length }
  }
  CONSTANTS = {
    'true'  => true,
    'false' => false,
    'nil'   => nil,
    'e'     => Math::E,
    'pi'    => Math::PI,
    'i'     => Complex::I
  }
  TOKENS = [
            [ /^'(?:[^']|\\')+'|"(?:[^"]|\\")+"$/,               lambda {|tok, vars| tok[1..-2]   } ],
            [ /^(?:\d*\.\d+(?:[eE][-+]?\d+)?|\d+[eE][-+]?\d+)$/, lambda {|tok, vars| tok.to_f     } ],
            [ /^0[xX][\dA-Fa-f]+$/,                              lambda {|tok, vars| tok.to_i(16) } ],
            [ /^0[0-7]+$/,                                       lambda {|tok, vars| tok.to_i(8)  } ],
            [ /^\d+$/,                                           lambda {|tok, vars| tok.to_i(10) } ],
            [ /^[a-zA-Z_][\w_]*$/,                               lambda {|tok, vars|
                tok.downcase!
                raise(NameError, "Symbol #{tok} is undefined") if !vars.include?(tok)
                vars[tok]
              }
            ]
           ]
  TOKENIZER = Regexp.new((TOKENS.map {|x| x[0].source[1..-2] } +
                          OPERATOR.keys.flatten.sort { |a,b| b.length <=> a.length}.map { |op| Regexp.quote(op) }).
                         join('|') + '|\\(|\\)|,')

  def self.eval(expr, vars = {})
    vars = Hash[*vars.map {|k,v| [k.to_s.downcase, v] }.flatten].merge(CONSTANTS)
    stack, result, unary = [], [], true
    expr.scan(TOKENIZER).each do |tok|
      if tok == '('
        stack << '('
      elsif tok == ')'
        exec(result, stack.pop) while !stack.empty? && stack.last != '('
        raise(SyntaxError, "Unexpected token )") if stack.empty?
        stack.pop
      elsif tok == ','
        exec(result, stack.pop) while !stack.empty? && stack.last != '('
      elsif OPERATOR.include?(tok.downcase)
        tok.downcase!
        if OPERATOR[tok][0]
          stack << tok
        elsif unary && OPERATOR[tok][3]
          stack << OPERATOR[tok][3]
        else
          exec(result, stack.pop) while !stack.empty? && stack.last != '(' && OPERATOR[stack.last][1] >= OPERATOR[tok][1]
          stack << tok
        end
      else
        result << TOKENS.find {|x| tok =~ x[0] }[1][tok, vars]
        unary = false
        next
      end
      unary = true
    end
    exec(result, stack.pop) while !stack.empty?
    raise(SyntaxError, "Unexpected operands") if result.size != 1
    result[0]
  end

  def self.exec(result, op)
    raise(SyntaxError, "Unexpected token #{op}") if !OPERATOR.include?(op)
    op = OPERATOR[op][2]
    raise(SyntaxError, "Not enough operands for #{op}") if result.size < op.arity
    result << op[*result.slice!(-op.arity, op.arity)]
  end

  private_class_method :infix, :prefix, :exec
end

def Evaluator(expr, vars = {})
  Evaluator.eval(expr, vars)
end
