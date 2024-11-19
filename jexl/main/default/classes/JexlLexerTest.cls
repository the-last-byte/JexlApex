@IsTest
private class JexlLexerTest {

	@IsTest
	static void hasIdentifierMatch_Test() {
		Test.startTest();

		Assert.areEqual(
			true,
			JexlLexer.hasIdentifierMatch('hello$1234')
		);

		Assert.areEqual(
			false,
			JexlLexer.hasIdentifierMatch('hello 1234')
		);

		Test.stopTest();
	}

	@IsTest
	static void escapeRegexStringLiteral_Test() {
		Test.startTest();

		Assert.areEqual(
			'\\bhello\\b',
			JexlLexer.escapeRegexStringLiteral('hello')
		);

		Assert.areEqual(
			'hello \\[1234\\]',
			JexlLexer.escapeRegexStringLiteral('hello [1234]')
		);

		Test.stopTest();
	}

	@IsTest
	static void sortByStringLengthHandler_Test() {

		final List<String> unsorted = new List<String> {
			'444',
			'55555555',
			'1',
			'333',
			'22'
		};

		Test.startTest();

		unsorted.sort(new JexlLexer.SortByStringLengthHandler());

		Test.stopTest();

		final String resultJson = JSON.serializePretty(unsorted);

		for (Integer i = 0; i < unsorted.size(); i++) {
			Assert.areEqual(
				String.valueOf(i + 1),
				unsorted[i].left(1),
				'Unexpected sort order at index ' + i + ': ' + resultJson
			);
		}

	}

	@IsTest
	static void getElements_Test() {
		final String expression = 'assoc[.first == "Lana"].last';
		final List<String> expectedResults = new List<String> {
			'assoc',
			'[',
			'.',
			'first',
			' ',
			'==',
			' ',
			'"Lana"',
			']',
			'.',
			'last'
		};

		Test.startTest();

		final List<String> results = new JexlLexer(new JexlGrammar()).getElements(expression);

		Test.stopTest();

		final String resultJson = JSON.serializePretty(results);
		for (Integer i = 0; i < expectedResults.size() && i < results.size(); i++) {
			Assert.areEqual(
				expectedResults[i],
				results[i],
				resultJson
			);
		}
		Assert.areEqual(expectedResults.size(), results.size(), resultJson);

	}

	@IsTest
	static void unquoteString_Test() {
		final String singleQuoteString = '\'This is an example of \\\'single quotes\\\'.\'';
		final String singleQuoteExpected = 'This is an example of \'single quotes\'.';
		final String doubleQuoteString = '"This is an example of \\"double quotes\\"."';
		final String doubleQuoteExpected = 'This is an example of "double quotes".';

		Test.startTest();

		Assert.areEqual(
			singleQuoteExpected,
			JexlLexer.unquoteString(singleQuoteString)
		);

		Assert.areEqual(
			doubleQuoteExpected,
			JexlLexer.unquoteString(doubleQuoteString)
		);

		Test.stopTest();

	}

	@IsTest
	static void getTokens_Test() {

		final List<String> elements = new List<String> {
			//Gets dropped
			' ',
			'(',
			//Gets added to the value?
			'-',
			'1',
			//Gets merged with previous
			' ',
			'*',
			'100',
			')',
			'-'
		};
		final List<String> expectedResults = new List<String>();
		for (String element : elements) {
			if (String.isNotBlank(element) && element != '-') {
				expectedResults.add(element);
			}
		}
		//Re-add the trailing negative
		expectedResults.add('-');

		Test.startTest();

		final List<JexlLexer.Token> tokens = new JexlLexer(new JexlGrammar())
			.getTokens(elements);

		Test.stopTest();

		//The whitespace should be appended to the previous token
		Assert.areEqual(
			expectedResults.size(),
			tokens.size(),
			JSON.serializePretty(tokens)
		);
		Assert.areEqual(6, expectedResults.size());
		JexlLexer.Token token;

		//Gets dropped
		// Test token: '('
		token = tokens[0];
		Assert.areEqual('(', token.raw);
		Assert.areEqual('(', token.value);
		Assert.areEqual(JexlGrammar.GrammarType.OpenParen, token.type);

		// Test token: '1 ' (includes following whitespace)
		token = tokens[1];
		Assert.areEqual('-1 ', token.raw);
		Assert.areEqual(3, token.raw.length());
		Assert.areEqual(-1, token.value);
		Assert.areEqual(JexlGrammar.GrammarType.Literal, token.type);

		// Test token: '*'
		token = tokens[2];
		Assert.areEqual('*', token.raw);
		Assert.areEqual('*', token.value);
		Assert.areEqual(JexlGrammar.GrammarType.BinaryOp, token.type);

		// Test token: '100'
		token = tokens[3];
		Assert.areEqual('100', token.raw);
		Assert.areEqual(100, token.value);
		Assert.areEqual(JexlGrammar.GrammarType.Literal, token.type);

		// Test token: ')'
		token = tokens[4];
		Assert.areEqual(')', token.raw);
		Assert.areEqual(')', token.value);
		Assert.areEqual(JexlGrammar.GrammarType.CloseParen, token.type);

		// Test token: '-'
		token = tokens[5];
		Assert.areEqual('-', token.raw);
		Assert.areEqual('-', token.value);
		Assert.areEqual(JexlGrammar.GrammarType.BinaryOp, token.type);

	}

	@IsTest
	static void token_constructor_Test() {

		final JexlGrammar grammar = new JexlGrammar();

		final Map<String, TestToken> inputToExpectedOutput = new Map<String, TestToken> {
			'"hello"' => new TestToken(JexlGrammar.GrammarType.Literal, 'hello'),
			'1234' => new TestToken(JexlGrammar.GrammarType.Literal, 1234),
			'-1234' => new TestToken(JexlGrammar.GrammarType.Literal, -1234),
			'12.34' => new TestToken(JexlGrammar.GrammarType.Literal, 12.34),
			'true' => new TestToken(JexlGrammar.GrammarType.Literal, true),
			'false' => new TestToken(JexlGrammar.GrammarType.Literal, false),
			'(' => new TestToken(JexlGrammar.GrammarType.OpenParen, '('),
			'this fails' => null
		};

		Test.startTest();

		for (String input : inputToExpectedOutput.keySet()) {
			final TestToken expectedResult = inputToExpectedOutput.get(input);
			if (expectedResult == null) {
				Boolean hasError = false;
				try {
					new JexlLexer.Token(
						grammar,
						input
					);
				} catch (JexlException ex) {
					hasError = true;
				}
				Assert.isTrue(hasError, 'Expected an exception for input: ' + input);
			} else {
				final JexlLexer.Token result = new JexlLexer.Token(
					grammar,
					input
				);
				final String jsonResult = 'Error for input: ' + input + '\n' + JSON.serializePretty(result);
				Assert.areEqual(
					input,
					result.raw,
					jsonResult
				);
				Assert.areEqual(
					expectedResult.value,
					result.value,
					jsonResult
				);
				Assert.areEqual(
					expectedResult.type,
					result.type,
					jsonResult
				);
			}

		}

		Test.stopTest();
	}

	private class TestToken {
		public final JexlGrammar.GrammarType type { get; set; }
		public final Object value { get; set; }

		public TestToken(JexlGrammar.GrammarType type, Object value) {
			this.type = type;
			this.value = value;
		}
	}

}