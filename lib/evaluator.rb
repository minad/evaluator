require 'complex'

module Evaluator
  def self.infix(priority, unary = nil, &block) [false, priority, lambda(&block), unary] end
  def self.prefix(&block) [true, 1e5, lambda(&block)] end

  VERSION = "0.1.2"
  OPERATOR = {
    '||'       => infix(0) {|a,b| a || b },
    '&&'       => infix(1) {|a,b| a && b },
    '=='       => infix(2) {|a,b| a == b },
    '!='       => infix(2) {|a,b| a != b },
    '<='       => infix(2) {|a,b| a <= b },
    '>='       => infix(2) {|a,b| a >= b },
    '<'        => infix(2) {|a,b| a < b },
    '>'        => infix(2) {|a,b| a > b },
    '+'        => infix(3, 'plus') {|a,b| a + b },
    '-'        => infix(3, 'minus') {|a,b| a - b },
    '>>'       => infix(4) {|a,b| a >> b },
    '<<'       => infix(4) {|a,b| a << b },
    '&'        => infix(5) {|a,b| a & b },
    '|'        => infix(5) {|a,b| a | b },
    '^'        => infix(5) {|a,b| a ^ b },
    '*'        => infix(6) {|a,b| a * b },
    '/'        => infix(6) {|a,b| a / b },
    '%'        => infix(6) {|a,b| a % b },
    'div'      => infix(6) {|a,b| a.div b },
    '**'       => infix(7) {|a,b| a ** b },
    'gcd'      => prefix   {|x,y| x.gcd(y) },
    'lcm'      => prefix   {|x,y| x.lcm(y) },
    'sin'      => prefix   {|x| Math.sin(x) },
    'cos'      => prefix   {|x| Math.cos(x) },
    'tan'      => prefix   {|x| Math.tan(x) },
    'sinh'     => prefix   {|x| Math.sinh(x) },
    'cosh'     => prefix   {|x| Math.cosh(x) },
    'tanh'     => prefix   {|x| Math.tanh(x) },
    'asin'     => prefix   {|x| Math.asin(x) },
    'acos'     => prefix   {|x| Math.acos(x) },
    'atan'     => prefix   {|x| Math.atan(x) },
    'asinh'    => prefix   {|x| Math.asinh(x) },
    'atanh'    => prefix   {|x| Math.atanh(x) },
    'sqrt'     => prefix   {|x| Math.sqrt(x) },
    'log'      => prefix   {|x| Math.log(x) },
    'log10'    => prefix   {|x| Math.log10(x) },
    'log2'     => prefix   {|x| Math.log(x)/Math.log(2) },
    'exp'      => prefix   {|x| Math.exp(x) },
    'erf'      => prefix   {|x| Math.erf(x) },
    'erfc'     => prefix   {|x| Math.erfc(x) },
    'floor'    => prefix   {|x| x.floor },
    'ceil'     => prefix   {|x| x.ceil },
    'string'   => prefix   {|x| x.to_s },
    'int'      => prefix   {|x| x.to_i },
    'float'    => prefix   {|x| x.to_f },
    'rand'     => prefix   {|| rand },
    'conj'     => prefix   {|x| x.conj },
    'im'       => prefix   {|x| x.imag },
    're'       => prefix   {|x| x.real },
    'round'    => prefix   {|x| x.round },
    'abs'      => prefix   {|x| x.abs },
    'minus'    => prefix   {|x| -x },
    'plus'     => prefix   {|x| x },
    '!'        => prefix   {|x| !x },
    '~'        => prefix   {|x| ~x },
    'substr'   => prefix   {|x,a,b| x.slice(a,b) },
    'len'      => prefix   {|x| x.length },
    'tolower'  => prefix   {|x| x.downcase },
    'toupper'  => prefix   {|x| x.upcase },
    'strip'    => prefix   {|x| x.strip },
    'reverse'  => prefix   {|x| x.reverse },
    'index'    => prefix   {|x,y| x.index(y) },
    'rindex'   => prefix   {|x,y| x.rindex(y) },
    'or'       => '||',
    'and'      => '&&',
    'mod'      => '%',
    'ln'       => 'log',
    'imag'     => 'im',
    'real'     => 're',
    'count'    => 'len',
    'size'     => 'len',
    'length'   => 'len',
    'trim'     => 'strip',
    'downcase' => 'tolower',
    'upcase'   => 'toupper',
    'slice'    => 'substr',
  }
  CONSTANTS = {
    'true'  => true,
    'false' => false,
    'nil'   => nil,
    'e'     => Math::E,
    'pi'    => Math::PI,
    'i'     => Complex::I
  }
  STRING = /^(?:'(?:\\'|[^'])*'|"(?:\\"|[^"])*")$/
  REAL   = /^(?:(?:\d*\.\d+|\d+\.\d*)(?:[eE][-+]?\d+)?|\d+[eE][-+]?\d+)$/
  HEX    = /^0[xX][\dA-Fa-f]+$/
  OCT    = /^0[0-7]+$/
  DEC    = /^\d+$/
  SYMBOL = /^[a-zA-Z_][\w_]*$/
  VALUE_TOKENS = [STRING, REAL, HEX, OCT, DEC, SYMBOL].map {|x| x.source[1..-2] }
  OPERATOR_TOKENS = OPERATOR.keys.flatten.sort { |a,b| b.length <=> a.length}.map { |x| Regexp.quote(x) }
  TOKENIZER = Regexp.new((VALUE_TOKENS + OPERATOR_TOKENS + ['\\(', '\\)', ',']).join('|'))

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
      elsif operator = OPERATOR[tok.downcase]
        tok = String === operator ? operator : tok.downcase
        if operator[0]
          stack << tok
        elsif unary && operator[3]
          stack << operator[3]
        else
          exec(result, stack.pop) while !stack.empty? && stack.last != '(' && OPERATOR[stack.last][1] >= operator[1]
          stack << tok
        end
      else
        result << case tok
                  when STRING then tok[1..-2].gsub(/\\"/, '"').gsub(/\\'/, "'")
                  when REAL   then tok.to_f
                  when HEX    then tok.to_i(16)
                  when OCT    then tok.to_i(8)
                  when DEC    then tok.to_i(10)
                  when SYMBOL
                    tok.downcase!
                    raise(NameError, "Symbol #{tok} is undefined") if !vars.include?(tok)
                    vars[tok]
                  end
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
