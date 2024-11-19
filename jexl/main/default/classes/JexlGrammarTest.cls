@IsTest
private class JexlGrammarTest {

	private static final Integer TestPrecedence = 10;

	@IsTest
	static void operatorPlus_Test() {

		final JexlGrammar.IGrammarEval operator = new JexlGrammar.OperatorPlus(TestPrecedence);

		Test.startTest();

		final Object resultInteger = operator.eval(3, 4);
		final Object resultIntegerAndDouble = operator.eval(3, 4.5);
		final Object resultDoubleAndInteger = operator.eval(3.5, 4);
		final Object resultDouble = operator.eval(3.5, 4.3);
		final Object resultString = operator.eval('abc', 'def');
		final Object resultStringInteger = operator.eval('abc', 123);

		Boolean hasError = false;
		try {
			operator.eval(new User(), 'abc');
		} catch (JexlException ex) {
			hasError = true;
		}
		Assert.isTrue(hasError, 'Expected a bad input error to be thrown.');

		Test.stopTest();

		Assert.areEqual(TestPrecedence, operator.getPrecedence());

		Assert.areEqual(true, resultInteger instanceof Long, '' + resultInteger);
		Assert.areEqual(7, resultInteger);

		Assert.areEqual(false, resultIntegerAndDouble instanceof Long, '' + resultIntegerAndDouble);
		Assert.areEqual(true, resultIntegerAndDouble instanceof Double, '' + resultIntegerAndDouble);
		Assert.areEqual(7.5, resultIntegerAndDouble);

		Assert.areEqual(false, resultDoubleAndInteger instanceof Long, '' + resultDoubleAndInteger);
		Assert.areEqual(true, resultDoubleAndInteger instanceof Double, '' + resultDoubleAndInteger);
		Assert.areEqual(7.5, resultDoubleAndInteger);

		Assert.areEqual(true, resultDouble instanceof Double, '' + resultDouble);
		Assert.areEqual(7.8, resultDouble);

		Assert.areEqual(true, resultString instanceof String, '' + resultString);
		Assert.areEqual('abcdef', resultString);

		Assert.areEqual(true, resultStringInteger instanceof String, '' + resultStringInteger);
		Assert.areEqual('abc123', resultStringInteger);

	}

	@IsTest
	static void operatorMinus_Test() {

		final JexlGrammar.IGrammarEval operator = new JexlGrammar.OperatorMinus(TestPrecedence);

		Test.startTest();

		final Object resultInteger = operator.eval(3, 4);
		final Object resultIntegerAndDouble = operator.eval(3, 4.5);
		final Object resultDoubleAndInteger = operator.eval(3.5, 4);
		final Object resultDouble = operator.eval(3.5, 4.5);

		Boolean hasError = false;
		try {
			operator.eval('abc', new User());
		} catch (JexlException ex) {
			hasError = true;
		}
		Assert.isTrue(hasError, 'Expected a bad input error to be thrown.');

		Test.stopTest();

		Assert.areEqual(TestPrecedence, operator.getPrecedence());

		Assert.areEqual(true, resultInteger instanceof Long, '' + resultInteger);
		Assert.areEqual(-1, resultInteger);

		Assert.areEqual(true, resultIntegerAndDouble instanceof Double, '' + resultIntegerAndDouble);
		Assert.areEqual(-1.5, resultIntegerAndDouble);

		Assert.areEqual(true, resultDoubleAndInteger instanceof Double, '' + resultDoubleAndInteger);
		Assert.areEqual(-0.5, resultDoubleAndInteger);

		Assert.areEqual(true, resultDouble instanceof Double, '' + resultDouble);
		Assert.areEqual(-1, resultDouble);

	}

	@IsTest
	static void operatorMultiply_Test() {

		final JexlGrammar.IGrammarEval operator = new JexlGrammar.OperatorMultiply(TestPrecedence);

		Test.startTest();

		final Object resultInteger = operator.eval(3, 4);
		final Object resultIntegerAndDouble = operator.eval(2, 4.5);
		final Object resultDoubleAndInteger = operator.eval(3.5, 4);
		final Object resultDouble = operator.eval(10.5, 0.1);

		Boolean hasError = false;
		try {
			operator.eval('abc', 'xyz');
		} catch (JexlException ex) {
			hasError = true;
		}
		Assert.isTrue(hasError, 'Expected a bad input error to be thrown.');

		Test.stopTest();

		Assert.areEqual(TestPrecedence, operator.getPrecedence());

		Assert.areEqual(true, resultInteger instanceof Long, '' + resultInteger);
		Assert.areEqual(12, resultInteger);

		Assert.areEqual(true, resultIntegerAndDouble instanceof Double, '' + resultIntegerAndDouble);
		Assert.areEqual(9, resultIntegerAndDouble);

		Assert.areEqual(true, resultDoubleAndInteger instanceof Double, '' + resultDoubleAndInteger);
		Assert.areEqual(14, resultDoubleAndInteger);

		Assert.areEqual(true, resultDouble instanceof Double, '' + resultDouble);
		Assert.areEqual(1.05, resultDouble);

	}

	@IsTest
	static void operatorDivide_Test() {

		final JexlGrammar.IGrammarEval operator = new JexlGrammar.OperatorDivide(TestPrecedence);

		Test.startTest();

		final Object resultInteger = operator.eval(10, 2);
		final Object resultIntegerAndDouble = operator.eval(10, -2.5);
		final Object resultDoubleAndInteger = operator.eval(10.5, 3);
		final Object resultDouble = operator.eval(5.5, 2.5);

		Boolean hasError = false;
		try {
			operator.eval('abc', 'xyz');
		} catch (JexlException ex) {
			hasError = true;
		}
		Assert.isTrue(hasError, 'Expected a bad input error to be thrown.');

		Test.stopTest();

		Assert.areEqual(TestPrecedence, operator.getPrecedence());

		Assert.areEqual(true, resultInteger instanceof Long, '' + resultInteger);
		Assert.areEqual(5, resultInteger);

		Assert.areEqual(true, resultIntegerAndDouble instanceof Double, '' + resultIntegerAndDouble);
		Assert.areEqual(-4, resultIntegerAndDouble);

		Assert.areEqual(true, resultDoubleAndInteger instanceof Double, '' + resultDoubleAndInteger);
		Assert.areEqual(3.5, resultDoubleAndInteger);

		Assert.areEqual(true, resultDouble instanceof Double, '' + resultDouble);
		Assert.areEqual(2.2, resultDouble);

	}

	@IsTest
	static void operatorDivideFlr_Test() {

		final JexlGrammar.IGrammarEval operator = new JexlGrammar.OperatorDivideFlr(TestPrecedence);

		Test.startTest();

		final Object resultInteger = operator.eval(10, 2);
		final Object resultIntegerAndDouble = operator.eval(10, -2.5);
		final Object resultDoubleAndInteger = operator.eval(10.5, 3);
		final Object resultDouble = operator.eval(5.5, 2.5);

		Boolean hasError = false;
		try {
			operator.eval('abc', 'xyz');
		} catch (JexlException ex) {
			hasError = true;
		}
		Assert.isTrue(hasError, 'Expected a bad input error to be thrown.');

		Test.stopTest();

		Assert.areEqual(TestPrecedence, operator.getPrecedence());

		Assert.areEqual(5, resultInteger);
		Assert.areEqual(-4, resultIntegerAndDouble);
		Assert.areEqual(3.0, resultDoubleAndInteger);
		Assert.areEqual(2.0, resultDouble);

	}

	@IsTest
	static void operatorModulus_Test() {

		final JexlGrammar.IGrammarEval operator = new JexlGrammar.OperatorModulus(TestPrecedence);

		Test.startTest();

		final Object result = operator.eval(10, 7);

		Boolean hasError = false;
		try {
			operator.eval('abc', 'xyz');
		} catch (JexlException ex) {
			hasError = true;
		}
		Assert.isTrue(hasError, 'Expected a bad input error to be thrown.');

		Test.stopTest();

		Assert.areEqual(TestPrecedence, operator.getPrecedence());

		Assert.areEqual(3, result);

	}

	@IsTest
	static void operatorExponent_Test() {

		final JexlGrammar.IGrammarEval operator = new JexlGrammar.OperatorExponent(TestPrecedence);

		Test.startTest();

		final Object result = operator.eval(5, 3);

		Boolean hasError = false;
		try {
			operator.eval('abc', 'xyz');
		} catch (JexlException ex) {
			hasError = true;
		}
		Assert.isTrue(hasError, 'Expected a bad input error to be thrown.');

		Test.stopTest();

		Assert.areEqual(TestPrecedence, operator.getPrecedence());

		Assert.areEqual(125, result);

	}

	@IsTest
	static void operatorEquals_Test() {

		final JexlGrammar.IGrammarEval operator = new JexlGrammar.OperatorEquals(TestPrecedence);

		Test.startTest();

		final Object result1 = operator.eval(5, 3);
		final Object result2 = operator.eval(5, 5);
		final Object result3 = operator.eval(true, false);
		final Object result4 = operator.eval(true, true);
		final Object result5 = operator.eval('abc', 'abc');
		final Object result6 = operator.eval('abc', 'def');

		Test.stopTest();

		Assert.areEqual(TestPrecedence, operator.getPrecedence());

		Assert.areEqual(false, result1);
		Assert.areEqual(true, result2);
		Assert.areEqual(false, result3);
		Assert.areEqual(true, result4);
		Assert.areEqual(true, result5);
		Assert.areEqual(false, result6);

	}

	@IsTest
	static void operatorNotEquals_Test() {

		final JexlGrammar.IGrammarEval operator = new JexlGrammar.OperatorNotEquals(TestPrecedence);

		Test.startTest();

		final Object result1 = operator.eval(5, 3);
		final Object result2 = operator.eval(5, 5);
		final Object result3 = operator.eval(true, false);
		final Object result4 = operator.eval(true, true);
		final Object result5 = operator.eval('abc', 'abc');
		final Object result6 = operator.eval('abc', 'def');

		Test.stopTest();

		Assert.areEqual(TestPrecedence, operator.getPrecedence());

		Assert.areEqual(true, result1);
		Assert.areEqual(false, result2);
		Assert.areEqual(true, result3);
		Assert.areEqual(false, result4);
		Assert.areEqual(false, result5);
		Assert.areEqual(true, result6);

	}

	@IsTest
	static void operatorGreaterThan_Test() {

		final JexlGrammar.IGrammarEval operator = new JexlGrammar.OperatorGreaterThan(TestPrecedence);

		Test.startTest();

		final Object result1 = operator.eval(5, 3);
		final Object result2 = operator.eval(5, 5);
		final Object result3 = operator.eval(5, 7);
		final Object result4 = operator.eval('aa', 'ff');
		final Object result5 = operator.eval('ff', 'ff');
		final Object result6 = operator.eval('ff', 'aa');

		Boolean hasError = false;
		try {
			operator.eval(true, 'xyz');
		} catch (JexlException ex) {
			hasError = true;
		}
		Assert.isTrue(hasError, 'Expected a bad input error to be thrown.');

		Test.stopTest();

		Assert.areEqual(TestPrecedence, operator.getPrecedence());

		Assert.areEqual(true, result1);
		Assert.areEqual(false, result2);
		Assert.areEqual(false, result3);
		Assert.areEqual(false, result4);
		Assert.areEqual(false, result5);
		Assert.areEqual(true, result6);

	}

	@IsTest
	static void operatorGreaterThanEquals_Test() {

		final JexlGrammar.IGrammarEval operator = new JexlGrammar.OperatorGreaterThanEquals(TestPrecedence);

		Test.startTest();

		final Object result1 = operator.eval(5, 3);
		final Object result2 = operator.eval(5, 5);
		final Object result3 = operator.eval(5, 7);
		final Object result4 = operator.eval('aa', 'ff');
		final Object result5 = operator.eval('ff', 'ff');
		final Object result6 = operator.eval('ff', 'aa');

		Boolean hasError = false;
		try {
			operator.eval(true, 'xyz');
		} catch (JexlException ex) {
			hasError = true;
		}
		Assert.isTrue(hasError, 'Expected a bad input error to be thrown.');

		Test.stopTest();

		Assert.areEqual(TestPrecedence, operator.getPrecedence());

		Assert.areEqual(true, result1);
		Assert.areEqual(true, result2);
		Assert.areEqual(false, result3);
		Assert.areEqual(false, result4);
		Assert.areEqual(true, result5);
		Assert.areEqual(true, result6);

	}

	@IsTest
	static void operatorLessThan_Test() {

		final JexlGrammar.IGrammarEval operator = new JexlGrammar.OperatorLessThan(TestPrecedence);

		Test.startTest();

		final Object result1 = operator.eval(5, 3);
		final Object result2 = operator.eval(5, 5);
		final Object result3 = operator.eval(5, 7);
		final Object result4 = operator.eval('aa', 'ff');
		final Object result5 = operator.eval('ff', 'ff');
		final Object result6 = operator.eval('ff', 'aa');

		Boolean hasError = false;
		try {
			operator.eval(true, 'xyz');
		} catch (JexlException ex) {
			hasError = true;
		}
		Assert.isTrue(hasError, 'Expected a bad input error to be thrown.');

		Test.stopTest();

		Assert.areEqual(TestPrecedence, operator.getPrecedence());

		Assert.areEqual(false, result1);
		Assert.areEqual(false, result2);
		Assert.areEqual(true, result3);
		Assert.areEqual(true, result4);
		Assert.areEqual(false, result5);
		Assert.areEqual(false, result6);

	}

	@IsTest
	static void operatorLessThanEquals_Test() {

		final JexlGrammar.IGrammarEval operator = new JexlGrammar.OperatorLessThanEquals(TestPrecedence);

		Test.startTest();

		final Object result1 = operator.eval(5, 3);
		final Object result2 = operator.eval(5, 5);
		final Object result3 = operator.eval(5, 7);
		final Object result4 = operator.eval('aa', 'ff');
		final Object result5 = operator.eval('ff', 'ff');
		final Object result6 = operator.eval('ff', 'aa');

		Boolean hasError = false;
		try {
			operator.eval(true, 'xyz');
		} catch (JexlException ex) {
			hasError = true;
		}
		Assert.isTrue(hasError, 'Expected a bad input error to be thrown.');

		Test.stopTest();

		Assert.areEqual(TestPrecedence, operator.getPrecedence());

		Assert.areEqual(false, result1);
		Assert.areEqual(true, result2);
		Assert.areEqual(true, result3);
		Assert.areEqual(true, result4);
		Assert.areEqual(true, result5);
		Assert.areEqual(false, result6);

	}

	@IsTest
	static void operatorAnd_Test() {

		final JexlGrammar.IGrammarEval operator = new JexlGrammar.OperatorAnd(TestPrecedence);

		Test.startTest();

		final Object result1 = operator.eval(false, false);
		final Object result2 = operator.eval(true, false);
		final Object result3 = operator.eval(false, true);
		final Object result4 = operator.eval(true, true);

		Test.stopTest();

		Assert.areEqual(TestPrecedence, operator.getPrecedence());

		Assert.areEqual(false, result1);
		Assert.areEqual(false, result2);
		Assert.areEqual(false, result3);
		Assert.areEqual(true, result4);

	}

	@IsTest
	static void operatorOr_Test() {

		final JexlGrammar.IGrammarEval operator = new JexlGrammar.OperatorOr(TestPrecedence);

		Test.startTest();

		final Object result1 = operator.eval(false, false);
		final Object result2 = operator.eval(true, false);
		final Object result3 = operator.eval(false, true);
		final Object result4 = operator.eval(true, true);
		final Object result5 = operator.eval(1, 0);

		Test.stopTest();

		Assert.areEqual(TestPrecedence, operator.getPrecedence());

		Assert.areEqual(false, result1);
		Assert.areEqual(true, result2);
		Assert.areEqual(true, result3);
		Assert.areEqual(true, result4);
		Assert.areEqual(true, result5);

	}

	@IsTest
	static void operatorIn_Test() {

		final JexlGrammar.IGrammarEval operator = new JexlGrammar.OperatorIn(TestPrecedence);

		final List<Integer> values = new List<Integer> {
			2, 4, 6, 8
		};

		Test.startTest();

		final Object result1 = operator.eval(6, values);
		final Object result2 = operator.eval(7, values);
		final Object result3 = operator.eval('fgh', 'abcdefg');
		final Object result4 = operator.eval('def', 'abcdefg');

		Boolean hasError = false;
		try {
			operator.eval(true, 700);
		} catch (JexlException ex) {
			hasError = true;
		}
		Assert.isTrue(hasError, 'Expected a bad input error to be thrown.');

		Test.stopTest();

		Assert.areEqual(TestPrecedence, operator.getPrecedence());

		Assert.areEqual(true, result1);
		Assert.areEqual(false, result2);
		Assert.areEqual(false, result3);
		Assert.areEqual(true, result4);

	}

	@IsTest
	static void operatorNot_Test() {

		final JexlGrammar.IGrammarUnaryEval operator = new JexlGrammar.OperatorNot(TestPrecedence);

		Test.startTest();

		final Object result1 = operator.eval(false);
		final Object result2 = operator.eval(true);
		final Object result3 = operator.eval('true');
		final Object result4 = operator.eval('');

		Test.stopTest();

		Assert.areEqual(TestPrecedence, operator.getPrecedence());

		Assert.areEqual(true, result1);
		Assert.areEqual(false, result2);
		Assert.areEqual(false, result3);
		Assert.areEqual(true, result4);

	}

}