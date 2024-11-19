@IsTest
private class JexlExpressionTest {

	private static final Jexl j = new Jexl();

	@IsTest
	static void compile_Test() {

		final JexlExpression expr = j.createExpression('2/2');
		final JexlExpression badExpr = j.createExpression('2 & 2');

		Test.startTest();

		final JexlExpression compiled = expr.compile();
		final JexlExpression compiled2 = expr.compile();

		Boolean hasError = false;
		try {
			badExpr.compile();
		} catch (JexlException ex) {
			hasError = true;
		}

		Test.stopTest();

		Assert.areEqual(expr, compiled);
		Assert.areEqual(expr, compiled2);
		Assert.isTrue(hasError, 'Expected a compilation error');

	}

	@IsTest
	static void eval_Test() {

		final JexlExpression expr = j.createExpression('2/2');
		final JexlExpression exprContext = j.createExpression('foo');
		final JexlExpression badExpr = j.createExpression('2++2');

		Test.startTest();

		final Object result1 = expr.eval();
		final Object result2 = expr.eval();
		final Object result3 = exprContext.eval(new Map<String, Object> {
			'foo' => 'bar'
		});

		Boolean hasError = false;
		try {
			badExpr.eval();
		} catch (JexlException ex) {
			hasError = true;
		}

		Test.stopTest();

		Assert.areEqual(1, result1);
		Assert.areEqual(1, result2);
		Assert.areEqual('bar', result3);
		Assert.isTrue(hasError, 'Expected a compilation error');

	}

}