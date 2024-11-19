/*
 * Ported from original Javascript by The Last Byte Consulting.
 * Original Jexl Javascript code is Copyright 2020 Tom Shawver
 */
@IsTest
private class JexlEvaluatorTest {

	//@todo Transforms

	private static final JexlGrammar Grammar = new JexlGrammar();
	private static final JexlLexer Lexer = new JexlLexer(Grammar);

	@IsTest
	static void arithmetic_Test() {

		final JexlEvaluator evaluator = new JexlEvaluator(Grammar, null, null);

		Test.startTest();

		Assert.areEqual(
			20,
			evaluator.eval(expressionToTree('(2 + 3) * 4'))
		);

		//Applies the DivFloor operator
		Assert.areEqual(
			3,
			evaluator.eval(expressionToTree('7 // 2'))
		);

		Test.stopTest();
	}

	@IsTest
	static void stringConcatenation_Test() {

		final JexlEvaluator evaluator = new JexlEvaluator(Grammar, null, null);

		Test.startTest();

		Assert.areEqual(
			'Hello8Wo"rld',
			evaluator.eval(expressionToTree('"Hello" + (4+4) + "Wo\\\\"rld"'))
		);

		Test.stopTest();
	}

	@IsTest
	static void binaryComparisonExpression_Test() {

		final JexlEvaluator evaluator = new JexlEvaluator(Grammar, null, null);

		Test.startTest();

		//Evaluates a true comparison expression
		Assert.areEqual(
			true,
			evaluator.eval(expressionToTree('2 > 1'))
		);

		//Evaluates a false comparison expression
		Assert.areEqual(
			false,
			evaluator.eval(expressionToTree('2 <= 1'))
		);

		//Evaluates a complex expression
		Assert.areEqual(
			true,
			evaluator.eval(expressionToTree('"foo" && 6 >= 6 && 0 + 1 && true'))
		);

		Test.stopTest();
	}

	@IsTest
	static void identifierChain_map_Test() {

		Test.startTest();

		Assert.areEqual(
			123,
			new JexlEvaluator(
				Grammar,
				new Map<String, Object> {
					'level1' => new Map<String, Object> {
						'level2' => new Map<String, Object> {
							'level3' => 123
						}
					}
				},
				null
			).eval(expressionToTree('level1.level2.level3'))
		);

		Test.stopTest();
	}

	@IsTest
	static void identifierChain_sObject_Test() {

		Test.startTest();

		Assert.areEqual(
			'TestName',
			new JexlEvaluator(
				Grammar,
				new Account(
					Parent = new Account(
						Owner = new User(
							FirstName = 'TestName'
						)
					)
				),
				null
			).eval(expressionToTree('Parent.Owner.FirstName'))
		);

		Test.stopTest();
	}

	@IsTest
	static void array_filterByField_Test() {
		Map<String, Object> objectMap = new Map<String, Object> {
			'tek' => 'baz'
		};

		Test.startTest();

		final Object obj = new JexlEvaluator(
			Grammar,
			new Map<String, Object> {
				'foo' => new Map<String, Object> {
					'bar' => new List<Object> {
						new Map<String, Object> {
							'tek' => 'hello'
						},
						objectMap,
						new Map<String, Object> {
							'tok' => 'baz'
						}
					}
				}
			},
			null
		).eval(expressionToTree('foo.bar[.tek == "baz"]'));

		Test.stopTest();

		Assert.isTrue(obj instanceof List<Object>, 'Expected a list, got: ' + JSON.serialize(obj));
		Assert.areEqual(
			objectMap,
			((List<Object>) obj)[0]
		);

	}

	@IsTest
	static void array_assumedZeroIndex_Test() {

		Test.startTest();

		Assert.areEqual(
			'world',
			new JexlEvaluator(
				Grammar,
				new Map<String, Object> {
					'foo' => new Map<String, Object> {
						'bar' => new List<Object> {
							new Map<String, Object> {
								'tek' => new Map<String, Object> {
									'hello' => 'world'
								}
							},
							new Map<String, Object> {
								'tek' => new Map<String, Object> {
									'hello' => 'universe'
								}
							}
						}
					}
				},
				null
			).eval(expressionToTree('foo.bar.tek.hello'))
		);

		Test.stopTest();
	}

	@IsTest
	static void array_filterByIndex_Test() {

		Test.startTest();

		Assert.areEqual(
			'baz',
			new JexlEvaluator(
				Grammar,
				new Map<String, Object> {
					'foo' => new Map<String, Object> {
						'bar' => new List<Object> {
							new Map<String, Object> {
								'tek' => 'tok'
							},
							new Map<String, Object> {
								'tek' => 'baz'
							},
							new Map<String, Object> {
								'tek' => 'foz'
							}
						}
					}
				},
				null
			).eval(expressionToTree('foo.bar[1].tek'))
		);

		Test.stopTest();
	}

	@IsTest
	static void object_filterOnProperties_Test() {

		Test.startTest();

		Assert.areEqual(
			'tek',
			new JexlEvaluator(
				Grammar,
				new Map<String, Object> {
					'foo' => new Map<String, Object> {
						'baz' => new Map<String, Object> {
							'bar' => 'tek'
						}
					}
				},
				null
			).eval(expressionToTree('foo["ba" + "z"].bar'))
		);

		Test.stopTest();

	}

	@IsTest
	static void object_literal_Test() {

		final JexlEvaluator evaluator = new JexlEvaluator(Grammar, null, null);

		Test.startTest();

		Object obj = evaluator.eval(expressionToTree('{foo: {bar: "tek"}}'));

		Test.stopTest();

		Assert.isTrue(obj instanceof Map<String, Object>, 'Expected a map, got: ' + JSON.serialize(obj));
		Assert.isTrue(((Map<String, Object>) obj).containsKey('foo'), 'Expected a map with "foo" as a key, got: ' + JSON.serialize(obj));
		obj = ((Map<String, Object>) obj).get('foo');
		Assert.isTrue(((Map<String, Object>) obj).containsKey('bar'), 'Expected a map with "bar" as a key, got: ' + JSON.serialize(obj));
		Assert.areEqual(
			'tek',
			((Map<String, Object>) obj).get('bar')
		);

	}

	@IsTest
	static void object_emptyLiteral_Test() {

		final JexlEvaluator evaluator = new JexlEvaluator(Grammar, null, null);

		Test.startTest();

		Object obj = evaluator.eval(expressionToTree('{}'));

		Test.stopTest();

		Assert.isTrue(obj instanceof Map<String, Object>, 'Expected a map, got: ' + JSON.serialize(obj));
		Assert.areEqual(0, ((Map<String, Object>) obj).size(), 'Expected an empty object, got: ' + JSON.serialize(obj));

	}

	@IsTest
	static void object_literalDotNotation_Test() {

		final JexlEvaluator evaluator = new JexlEvaluator(Grammar, null, null);

		Test.startTest();

		Assert.areEqual(
			'bar',
			evaluator.eval(expressionToTree('{foo: "bar"}.foo'))
		);

		Test.stopTest();

	}

	@IsTest
	static void array_literal_Test() {

		final JexlEvaluator evaluator = new JexlEvaluator(Grammar, null, null);

		Test.startTest();

		final Object obj = evaluator.eval(expressionToTree('["foo", 1+2]'));

		Test.stopTest();

		final String jsonResult = JSON.serialize(obj);
		Assert.isTrue(obj instanceof List<Object>, 'Expected a list, got: ' + jsonResult);
		final List<Object> objList = (List<Object>) obj;
		Assert.areEqual(
			2,
			objList.size(),
			jsonResult
		);
		Assert.areEqual(
			'foo',
			objList[0],
			jsonResult
		);
		Assert.areEqual(
			3,
			objList[1],
			jsonResult
		);

	}

	@IsTest
	static void inOperator_string_Test() {

		final JexlEvaluator evaluator = new JexlEvaluator(Grammar, null, null);

		Test.startTest();

		Assert.areEqual(
			true,
			evaluator.eval(expressionToTree('"bar" in "foobartek"'))
		);
		Assert.areEqual(
			false,
			evaluator.eval(expressionToTree('"baz" in "foobartek"'))
		);

		Test.stopTest();

	}

	@IsTest
	static void inOperator_arrayLiteral_Test() {

		final JexlEvaluator evaluator = new JexlEvaluator(Grammar, null, null);

		Test.startTest();

		Assert.areEqual(
			true,
			evaluator.eval(expressionToTree('"bar" in ["foo","bar","tek"]'))
		);
		Assert.areEqual(
			false,
			evaluator.eval(expressionToTree('"baz" in ["foo","bar","tek"]'))
		);

		Test.stopTest();

	}

	@IsTest
	static void conditionalExpression_Test() {

		final JexlEvaluator evaluator = new JexlEvaluator(Grammar, null, null);

		Test.startTest();

		//Evaluates a conditional expression
		Assert.areEqual(
			1,
			evaluator.eval(expressionToTree('"foo" ? 1 : 2'))
		);
		Assert.areEqual(
			2,
			evaluator.eval(expressionToTree('"" ? 1 : 2'))
		);

		//Allows missing consequent in ternary
		Assert.areEqual(
			'foo',
			evaluator.eval(expressionToTree('"foo" ?: "bar"'))
		);

		Test.stopTest();

	}

	@IsTest
	static void filterOnMissingValue_Test() {

		final JexlEvaluator evaluator = new JexlEvaluator(Grammar, null, null);

		Test.startTest();

		final Object obj = evaluator.eval(expressionToTree(('a.b[.c == d]')));

		Test.stopTest();

		final String jsonResult = JSON.serialize(obj);
		Assert.isTrue(obj instanceof List<Object>, 'Expected a list, got: ' + jsonResult);
		Assert.areEqual(
			0,
			((List<Object>) obj).size(),
			jsonResult
		);

	}

	@IsTest
	static void whitespace_Test() {

		final JexlEvaluator evaluator = new JexlEvaluator(Grammar, null, null);

		Test.startTest();

		Assert.areEqual(
			20,
			evaluator.eval(expressionToTree('(\t2\n+\n3) *\n4\n\r\n'))
		);

		Test.stopTest();

	}

	@IsTest
	static void dollarSign_Test() {

		Test.startTest();

		Assert.areEqual(
			26,
			new JexlEvaluator(
				Grammar,
				new Map<String, Object> {
					'$' => 5,
					'$foo' => 6,
					'$foo$bar' => 7,
					'$bar' => 8
				},
				null
			).eval(expressionToTree('$+$foo+$foo$bar+$bar'))
		);

		Test.stopTest();

	}

	@IsTest
	static void unaryOperation_Test() {

		final JexlEvaluator evaluator = new JexlEvaluator(Grammar, null, null);

		Test.startTest();

		Assert.areEqual(
			true,
			evaluator.eval(expressionToTree('!false'))
		);
		Assert.areEqual(
			false,
			evaluator.eval(expressionToTree('!true'))
		);

		Test.stopTest();

	}

	private static JexlNode expressionToTree(String expression) {
		final JexlParser p = new JexlParser(Grammar, null, null);
		p.addTokens(Lexer.tokenize(expression));
		return p.complete();
	}

}