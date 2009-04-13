require 'test/unit'
require 'evaluator'

class TestEvaluator < Test::Unit::TestCase
  def test_binary_operators
    assert_equal 42, Evaluator('42 || false')
    assert_equal true, Evaluator('false || nil || true')
    assert_equal 42, Evaluator('42 or false')
    assert_equal true, Evaluator('false or nil or true')

    assert_equal 42, Evaluator('true && 42')
    assert_equal nil, Evaluator('nil && 1')
    assert_equal 42, Evaluator('true and 42')
    assert_equal nil, Evaluator('nil and 1')

    assert Evaluator('1+1==2')
    assert Evaluator("'abc' == 'a'+'b'+'c'")

    assert Evaluator('1+1 != 3')
    assert Evaluator("'xxx' != 'a'+'b'+'c'")

    assert Evaluator('1<=1')
    assert Evaluator('1<=2')
    assert Evaluator('1>=1')
    assert Evaluator('2>=1')
    assert(!Evaluator('1<1'))
    assert Evaluator('1<2')
    assert(!Evaluator('1>1'))
    assert Evaluator('2>1')

    assert_equal 3, Evaluator('1+2')
    assert_equal 'xyz', Evaluator('"x"+"yz"')

    assert_equal 3, Evaluator('5-2')
    assert_equal(-1, Evaluator('3-4'))

    assert_equal 12, Evaluator('3*4')
    assert_equal 'ababab', Evaluator('"ab"*3')

    assert_equal 3, Evaluator('12/4')

    assert_equal 10, Evaluator('103. div 10.')

    assert_equal 3, Evaluator('7 mod 4')
    assert_equal 3, Evaluator('7 % 4')

    assert_equal 1024, Evaluator('2 ** 10')

    assert_equal 8, Evaluator('2 << 2')
    assert_equal 32, Evaluator('256 >> 3')

    assert_equal 2, Evaluator('6 & 2')
    assert_equal 7, Evaluator('1 | 2 | 4')
    assert_equal 1, Evaluator('9 ^ 8')
  end

  def test_unary_operators
    assert_equal(-1, Evaluator('-1'))
    assert_equal(-2, Evaluator('-(1+1)'))
    assert_equal(-42, Evaluator('---42'))
    assert_equal 42, Evaluator('----42')
    assert_equal(-9, Evaluator('3*-3'))
    assert_equal(9, Evaluator('3*+3'))
  end

  def test_precendence
    assert_equal 16, Evaluator('1+3*5')
    assert_equal 16, Evaluator('3*5+1')
    assert_equal 23, Evaluator('3*5+2**3')
  end

  def test_constants
    assert_equal Math::PI, Evaluator('PI')
    assert_equal Math::E, Evaluator('E')
    assert_equal Complex::I, Evaluator('I')
    assert_equal true, Evaluator('trUe')
    assert_equal false, Evaluator('fAlSe')
    assert_equal nil, Evaluator('niL')
  end

  def test_functions
    assert_equal Math.sin(42), Evaluator('sin 42')
    assert_equal Math.cos(42), Evaluator('cos 42')
    assert_equal Math.tan(42), Evaluator('tan 42')
    assert_equal Math.sinh(42), Evaluator('sinh 42')
    assert_equal Math.cosh(42), Evaluator('cosh 42')
    assert_equal Math.tanh(42), Evaluator('tanh 42')
    assert_equal Math.asin(0.5), Evaluator('asin .5')
    assert_equal Math.acos(0.5), Evaluator('acos .5')
    assert_equal Math.atan(0.5), Evaluator('atan .5')
    assert_equal Math.asinh(0.5), Evaluator('asinh .5')
    assert_equal Math.atanh(0.5), Evaluator('atanh .5')
    assert_equal Math.sqrt(42) + 1, Evaluator('sqrt 42 + 1')
    assert_equal Math.log(42) + 3, Evaluator('log 42 + 3')
    assert_equal Math.log(42) + 3, Evaluator('ln 42 + 3')
    assert_equal Math.log10(42) + 3, Evaluator('log10 42 + 3')
    assert_equal Math.log(42)/Math.log(2) + 3, Evaluator('log2 42 + 3')
    assert_equal 3 * Math.exp(42), Evaluator('3 * exp 42')
    assert_equal 42, Evaluator('floor 42.3')
    assert_equal 42, Evaluator('ceil 41.6')
    assert_equal 3.5, Evaluator('float("3.5")')
    assert_equal "3.5", Evaluator('string(3.5)')
    assert_equal 3, Evaluator('int("3.5")')
    assert_equal 3, Evaluator('int(3.6)')
    srand(42); x = rand; srand(42)
    assert_equal x, Evaluator('rand')
    assert_equal Complex(1,-2), Evaluator('conj(1+2*i)')
    assert_equal 2, Evaluator('Im(1+2*i)')
    assert_equal 1, Evaluator('Re(1+2*i)')
    assert_equal 3, Evaluator('round(3.4)')
    assert_equal 4, Evaluator('round(3.5)')
    assert_equal 6, Evaluator('abs -6')
    assert_equal 3, Evaluator('plus 3')
    assert_equal(-3, Evaluator('minus 3'))
    assert_equal false, Evaluator('!3')
    assert_equal 'bcd', Evaluator('substr("abcde", 1, 3)')
    assert_equal 4, Evaluator('len("abcd")')
  end

  def test_variables
    assert_equal 14, Evaluator('a+b*c', :a => 2, :b => 3, :c => 4)
    assert_equal 14, Evaluator('a+b*C', 'A' => 2, 'b' => 3, :c => 4)
    assert_equal 14, Evaluator('alpha+beta*GAMMA', 'ALPHA' => 2, 'bEtA' => 3, 'gamma' => 4)
  end

  def test_errors
    assert_raise(SyntaxError) { Evaluator('(((((((((((((3+3))') }
    assert_raise(SyntaxError) { Evaluator('1+2)') }
    assert_raise(SyntaxError) { Evaluator('1+2+3+') }
    assert_raise(SyntaxError) { Evaluator('1 + floor') }
    assert_raise(NameError) { Evaluator('42*a+3') }
    assert_raise(NameError) { Evaluator('abc10') }
    assert_raise(NameError) { Evaluator('abc10d') }
  end

  def test_numbers
    assert_equal 0xABCDEF123, Evaluator('0xABCDEF123')
    assert_equal 01234, Evaluator('01234')
    assert_equal 234, Evaluator('234 ')
  end
end
