require 'evaluator'

class Bacon::Context
  def e(*args)
    Evaluator(*args)
  end
end

describe Evaluator do
  it 'should parse binary operators' do
    e('42 || false').should.equal 42
    e('false || nil || true').should.equal true
    e('42 or false').should.equal 42
    e('false or nil or true').should.equal true

    e('true && 42').should.equal 42
    e('nil && 1').should.equal nil
    e('true and 42').should.equal 42
    e('nil and 1').should.equal nil

    e('1+1==2').should.equal true
    e("'abc' == 'a'+'b'+'c'").should.equal true

    e('1+1 != 3').should.equal true
    e("'xxx' != 'a'+'b'+'c'").should.equal true

    e('1<=1').should.equal true
    e('1<=2').should.equal true
    e('1>=1').should.equal true
    e('2>=1').should.equal true
    e('1<1').should.equal false
    e('1<2').should.equal true
    e('1>1').should.equal false
    e('2>1').should.equal true

    e('1+2').should.equal 3
    e('"x"+"yz"').should.equal 'xyz'
    e("'a'+string 1+'b'").should.equal 'a1b'
    e("'a'+string(1)+'b'").should.equal 'a1b'

    e('5-2').should.equal 3
    e('3-4').should.equal -1

    e('3*4').should.equal 12
    e('"ab"*3').should.equal 'ababab'

    e('12/4').should.equal 3

    e('103. div 10.').should.equal 10

    e('7 mod 4').should.equal 3
    e('7 % 4').should.equal 3

    e('2 ** 10').should.equal 1024

    e('2 << 2').should.equal 8
    e('256 >> 3').should.equal 32

    e('6 & 2').should.equal 2
    e('1 | 2 | 4').should.equal 7
    e('9 ^ 8').should.equal 1
  end

  it 'should parse unary operators' do
    e('-1').should.equal -1
    e('-(1+1)').should.equal -2
    e('---42').should.equal -42
    e('----42').should.equal 42
    e('3*-3').should.equal -9
    e('3*+3').should.equal 9
  end

  it 'should respect precendence' do
    e('1+3*5').should.equal 16
    e('3*5+1').should.equal 16
    e('3*5+2**3').should.equal 23
  end

  it 'should parse constants' do
    e('PI').should.equal Math::PI
    e('E').should.equal Math::E
    e('I').should.equal Complex::I
    e('trUe').should.equal true
    e('fAlSe').should.equal false
    e('niL').should.equal nil
  end

  it 'should parse numeric functions' do
    e('gcd(26, 39)').should.equal 13
    e('lcm(26, 39)').should.equal 78
    e('cos 42').should.equal Math.cos(42)
    e('sin 42').should.equal Math.sin(42)
    e('cos 42').should.equal Math.cos(42)
    e('tan 42').should.equal Math.tan(42)
    e('sinh 42').should.equal Math.sinh(42)
    e('cosh 42').should.equal Math.cosh(42)
    e('tanh 42').should.equal Math.tanh(42)
    e('asin .5').should.equal Math.asin(0.5)
    e('acos .5').should.equal Math.acos(0.5)
    e('atan .5').should.equal Math.atan(0.5)
    e('asinh .5').should.equal Math.asinh(0.5)
    e('atanh .5').should.equal Math.atanh(0.5)
    e('sqrt 42 + 1').should.equal Math.sqrt(42) + 1
    e('log 42 + 3').should.equal Math.log(42) + 3
    e('ln 42 + 3').should.equal Math.log(42) + 3
    e('log10 42 + 3').should.equal Math.log10(42) + 3
    e('log2 42 + 3').should.equal Math.log(42)/Math.log(2) + 3
    e('3 * exp 42').should.equal 3 * Math.exp(42)
    e('erf 2').should.equal Math.erf(2)
    e('erfc 2').should.equal Math.erfc(2)
    e('floor 42.3').should.equal 42
    e('ceil 41.6').should.equal 42
    e('float("3.5")').should.equal 3.5
    e('string(3.5)').should.equal "3.5"
    e('int("3.5")').should.equal 3
    e('int(3.6)').should.equal 3
    srand(42); x = rand; srand(42)
    e('rand').should.equal x
    e('conj(1+2*i)').should.equal Complex(1,-2)
    e('Im(1+2*i)').should.equal 2
    e('Re(1+2*i)').should.equal 1
    e('round(3.4)').should.equal 3
    e('round(3.5)').should.equal 4
    e('abs -6').should.equal 6
    e('plus 3').should.equal 3
    e('minus 3').should.equal -3
    e('!3').should.equal false
    e('~3').should.equal ~3
  end

  it 'should parse string_functions' do
    e('substr("abcde", 1, 3)').should.equal 'bcd'
    e('len("abcd")').should.equal 4
    e('strip "  abc "').should.equal 'abc'
    e('reverse "abc"').should.equal 'cba'
    e('index("abcdefg", "cde")').should.equal 2
    e('rindex("abcdefgcdef", "cde")').should.equal 7
  end

  it 'should parse variables' do
    e('a+b*c', :a => 2, :b => 3, :c => 4).should.equal 14
    e('a+b*C', 'A' => 2, 'b' => 3, :c => 4).should.equal 14
    e('alpha+beta*GAMMA', 'ALPHA' => 2, 'bEtA' => 3, 'gamma' => 4).should.equal 14
  end

  it 'should parse errors' do
    lambda { e('(((((((((((((3+3))') }.should.raise SyntaxError
    lambda { e('1+2)') }.should.raise SyntaxError
    lambda { e('1+2+3+') }.should.raise SyntaxError
    lambda { e('1 + floor') }.should.raise SyntaxError
    lambda { e('42*a+3') }.should.raise NameError
    lambda { e('abc10') }.should.raise NameError
    lambda { e('abc10d') }.should.raise NameError
  end

  it 'should parse numbers' do
    e('0xABCDEF123').should.equal 0xABCDEF123
    e('01234').should.equal 01234
    e('234 ').should.equal 234
    e('.123').should.equal 0.123
    e('0.123').should.equal 0.123
    e('123.').should.equal 123.0
    e('123e-42').should.equal 123e-42
    e('.123e-42').should.equal 0.123e-42
    e('2.123e-42').should.equal 2.123e-42
  end

  it 'should parse strings' do
    e('"abc\'a"').should.equal "abc'a"
    e('"abc\"a"').should.equal 'abc"a'
    e("'abc\"a'").should.equal 'abc"a'
    e("'abc\\'a'").should.equal "abc'a"
  end
end
