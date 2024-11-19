/*
 * Ported from original Javascript by The Last Byte Consulting.
 * Original Jexl Javascript code is Copyright 2020 Tom Shawver
 */
@IsTest
private class JexlParserTest {

	private static final JexlGrammar Grammar = new JexlGrammar();
	private static final JexlLexer Lexer = new JexlLexer(Grammar);

	@IsTest
	static void tree_binaryOp_Test() {

		final JexlParser parser = new JexlParser(Grammar, null, null);

		Test.startTest();

		parser.addTokens(Lexer.tokenize('1+2'));

		final JexlNode node = parser.complete();

		Test.stopTest();

		/*
			{
		      type: 'BinaryExpression',
		      operator: '+',
		      left: { type: 'Literal', value: 1 },
		      right: { type: 'Literal', value: 2 }
		    }
		 */

		Assert.areEqual(JexlNode.Type.BinaryExpression, node.type);
		Assert.areEqual('+', node.operator);
		Assert.areNotEqual(null, node.left);
		Assert.areNotEqual(null, node.right);
		Assert.areEqual(JexlNode.Type.Literal, node.left.type);
		Assert.areEqual(JexlNode.Type.Literal, node.right.type);
		Assert.areEqual(1, node.left.value);
		Assert.areEqual(2, node.right.value);

	}

	@IsTest
	static void tree_binaryOp_orderOfOperation_heavyRight_Test() {

		final JexlParser parser = new JexlParser(Grammar, null, null);

		Test.startTest();

		parser.addTokens(Lexer.tokenize('2+3*4'));

		final JexlNode node = parser.complete();

		Test.stopTest();

		/*
			{
		      type: 'BinaryExpression',
		      operator: '+',
		      left: { type: 'Literal', value: 2 },
		      right: {
		        type: 'BinaryExpression',
		        operator: '*',
		        left: { type: 'Literal', value: 3 },
		        right: { type: 'Literal', value: 4 }
		      }
		    }
		 */

		Assert.areEqual(JexlNode.Type.BinaryExpression, node.type);
		Assert.areEqual('+', node.operator);

		Assert.areNotEqual(null, node.left);
		Assert.areEqual(JexlNode.Type.Literal, node.left.type);
		Assert.areEqual(2, node.left.value);

		Assert.areNotEqual(null, node.right);
		Assert.areEqual(JexlNode.Type.BinaryExpression, node.right.type);
		Assert.areEqual('*', node.right.operator);

		Assert.areNotEqual(null, node.right.left);
		Assert.areEqual(JexlNode.Type.Literal, node.right.left.type);
		Assert.areEqual(3, node.right.left.value);

		Assert.areNotEqual(null, node.right.right);
		Assert.areEqual(JexlNode.Type.Literal, node.right.right.type);
		Assert.areEqual(4, node.right.right.value);

	}

	@IsTest
	static void tree_binaryOp_orderOfOperation_heavyLeft_Test() {

		final JexlParser parser = new JexlParser(Grammar, null, null);

		Test.startTest();

		parser.addTokens(Lexer.tokenize('2*3+4'));

		final JexlNode node = parser.complete();

		Test.stopTest();

		/*
		{
	      type: 'BinaryExpression',
	      operator: '+',
	      left: {
	        type: 'BinaryExpression',
	        operator: '*',
	        left: { type: 'Literal', value: 2 },
	        right: { type: 'Literal', value: 3 }
	      },
	      right: { type: 'Literal', value: 4 }
	    }
		 */

		Assert.areEqual(JexlNode.Type.BinaryExpression, node.type);
		Assert.areEqual('+', node.operator);

		Assert.areNotEqual(null, node.left);
		Assert.areEqual(JexlNode.Type.BinaryExpression, node.left.type);
		Assert.areEqual('*', node.left.operator);

		Assert.areNotEqual(null, node.right);
		Assert.areEqual(JexlNode.Type.Literal, node.right.type);
		Assert.areEqual(4, node.right.value);

		Assert.areNotEqual(null, node.left.left);
		Assert.areEqual(JexlNode.Type.Literal, node.left.left.type);
		Assert.areEqual(2, node.left.left.value);

		Assert.areNotEqual(null, node.left.right);
		Assert.areEqual(JexlNode.Type.Literal, node.left.right.type);
		Assert.areEqual(3, node.left.right.value);

	}

	@IsTest
	static void tree_binaryOp_complexTree_Test() {

		final JexlParser parser = new JexlParser(Grammar, null, null);

		Test.startTest();

		parser.addTokens(Lexer.tokenize('2+3*4==5/6-7'));

		final JexlNode node = parser.complete();

		Test.stopTest();

		/*
		{
	      type: 'BinaryExpression',
	      operator: '==',
	      left: {
	        type: 'BinaryExpression',
	        operator: '+',
	        left: { type: 'Literal', value: 2 },
	        right: {
	          type: 'BinaryExpression',
	          operator: '*',
	          left: { type: 'Literal', value: 3 },
	          right: { type: 'Literal', value: 4 }
	        }
	      },
	      right: {
	        type: 'BinaryExpression',
	        operator: '-',
	        left: {
	          type: 'BinaryExpression',
	          operator: '/',
	          left: { type: 'Literal', value: 5 },
	          right: { type: 'Literal', value: 6 }
	        },
	        right: { type: 'Literal', value: 7 }
	      }
	    }
		 */

		Assert.areEqual(JexlNode.Type.BinaryExpression, node.type);
		Assert.areEqual('==', node.operator);

		final JexlNode left = node.left;

		Assert.areNotEqual(null, left);
		Assert.areEqual(JexlNode.Type.BinaryExpression, left.type);
		Assert.areEqual('+', left.operator);

		Assert.areNotEqual(null, left.left);
		Assert.areEqual(JexlNode.Type.Literal, left.left.type);
		Assert.areEqual(2, left.left.value);

		Assert.areNotEqual(null, left.right);
		Assert.areEqual(JexlNode.Type.BinaryExpression, left.right.type);
		Assert.areEqual('*', left.right.operator);

		Assert.areNotEqual(null, left.right.left);
		Assert.areEqual(JexlNode.Type.Literal, left.right.left.type);
		Assert.areEqual(3, left.right.left.value);

		Assert.areNotEqual(null, left.right.right);
		Assert.areEqual(JexlNode.Type.Literal, left.right.right.type);
		Assert.areEqual(4, left.right.right.value);

		final JexlNode right = node.right;
		Assert.areNotEqual(null, right);
		Assert.areEqual(JexlNode.Type.BinaryExpression, right.type);
		Assert.areEqual('-', right.operator);

		Assert.areNotEqual(null, right.left);
		Assert.areEqual(JexlNode.Type.BinaryExpression, right.left.type);
		Assert.areEqual('/', right.left.operator);

		Assert.areNotEqual(null, right.left.left);
		Assert.areEqual(JexlNode.Type.Literal, right.left.left.type);
		Assert.areEqual(5, right.left.left.value);

		Assert.areNotEqual(null, right.left.right);
		Assert.areEqual(JexlNode.Type.Literal, right.left.right.type);
		Assert.areEqual(6, right.left.right.value);

		Assert.areNotEqual(null, right.right);
		Assert.areEqual(JexlNode.Type.Literal, right.right.type);
		Assert.areEqual(7, right.right.value);

	}

	@IsTest
	static void tree_unary_Test() {

		final JexlParser parser = new JexlParser(Grammar, null, null);

		Test.startTest();

		parser.addTokens(Lexer.tokenize('1*!!true-2'));

		final JexlNode node = parser.complete();

		Test.stopTest();

		/*
		{
	      type: 'BinaryExpression',
	      operator: '-',
	      left: {
	        type: 'BinaryExpression',
	        operator: '*',
	        left: { type: 'Literal', value: 1 },
	        right: {
	          type: 'UnaryExpression',
	          operator: '!',
	          right: {
	            type: 'UnaryExpression',
	            operator: '!',
	            right: { type: 'Literal', value: true }
	          }
	        }
	      },
	      right: { type: 'Literal', value: 2 }
	    })
		 */

		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.BinaryExpression, node.type);
		Assert.areEqual('-', node.operator);

		JexlNode currentNode = node.left;
		Assert.areNotEqual(null, currentNode);
		Assert.areEqual(JexlNode.Type.BinaryExpression, currentNode.type);
		Assert.areEqual('*', currentNode.operator);

		Assert.areNotEqual(null, currentNode.left);
		Assert.areEqual(JexlNode.Type.Literal, currentNode.left.type);
		Assert.areEqual(1, currentNode.left.value);

		currentNode = currentNode.right;
		Assert.areNotEqual(null, currentNode);
		Assert.areEqual(JexlNode.Type.UnaryExpression, currentNode.type);
		Assert.areEqual('!', currentNode.operator);

		currentNode = currentNode.right;
		Assert.areNotEqual(null, currentNode);
		Assert.areEqual(JexlNode.Type.UnaryExpression, currentNode.type);
		Assert.areEqual('!', currentNode.operator);

		Assert.areEqual(null, currentNode.left);
		Assert.areNotEqual(null, currentNode.right);
		Assert.areEqual(JexlNode.Type.Literal, currentNode.right.type);
		Assert.areEqual(true, currentNode.right.value);

		Assert.areNotEqual(null, node.right);
		Assert.areEqual(JexlNode.Type.Literal, node.right.type);
		Assert.areEqual(2, node.right.value);

	}

	@IsTest
	static void tree_subexpression_Test() {

		final JexlParser parser = new JexlParser(Grammar, null, null);

		Test.startTest();

		parser.addTokens(Lexer.tokenize('(2+3)*4'));

		final JexlNode node = parser.complete();

		Test.stopTest();

		/*
		{
	      type: 'BinaryExpression',
	      operator: '*',
	      left: {
	        type: 'BinaryExpression',
	        operator: '+',
	        left: { type: 'Literal', value: 2 },
	        right: { type: 'Literal', value: 3 }
	      },
	      right: { type: 'Literal', value: 4 }
	    }
		 */

		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.BinaryExpression, node.type);
		Assert.areEqual('*', node.operator);

		Assert.areNotEqual(null, node.left);
		Assert.areEqual(JexlNode.Type.BinaryExpression, node.left.type);
		Assert.areEqual('+', node.left.operator);

		Assert.areNotEqual(null, node.left.left);
		Assert.areEqual(JexlNode.Type.Literal, node.left.left.type);
		Assert.areEqual(2, node.left.left.value);

		Assert.areNotEqual(null, node.left.right);
		Assert.areEqual(JexlNode.Type.Literal, node.left.right.type);
		Assert.areEqual(3, node.left.right.value);

		Assert.areNotEqual(null, node.right);
		Assert.areEqual(JexlNode.Type.Literal, node.right.type);
		Assert.areEqual(4, node.right.value);

	}

	@IsTest
	static void tree_nestedSubexpression_Test() {

		final JexlParser parser = new JexlParser(Grammar, null, null);

		Test.startTest();

		parser.addTokens(Lexer.tokenize('(4*(2+3))/5'));

		final JexlNode node = parser.complete();

		Test.stopTest();

		/*
		{
	      type: 'BinaryExpression',
	      operator: '/',
	      left: {
	        type: 'BinaryExpression',
	        operator: '*',
	        left: { type: 'Literal', value: 4 },
	        right: {
	          type: 'BinaryExpression',
	          operator: '+',
	          left: { type: 'Literal', value: 2 },
	          right: { type: 'Literal', value: 3 }
	        }
	      },
	      right: { type: 'Literal', value: 5 }
	    }
		 */

		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.BinaryExpression, node.type);
		Assert.areEqual('/', node.operator);

		Assert.areNotEqual(null, node.left);
		Assert.areEqual(JexlNode.Type.BinaryExpression, node.left.type);
		Assert.areEqual('*', node.left.operator);

		Assert.areNotEqual(null, node.left.left);
		Assert.areEqual(JexlNode.Type.Literal, node.left.left.type);
		Assert.areEqual(4, node.left.left.value);

		Assert.areNotEqual(null, node.left.right);
		Assert.areEqual(JexlNode.Type.BinaryExpression, node.left.right.type);
		Assert.areEqual('+', node.left.right.operator);

		Assert.areNotEqual(null, node.left.right.left);
		Assert.areEqual(JexlNode.Type.Literal, node.left.right.left.type);
		Assert.areEqual(2, node.left.right.left.value);

		Assert.areNotEqual(null, node.left.right.right);
		Assert.areEqual(JexlNode.Type.Literal, node.left.right.right.type);
		Assert.areEqual(3, node.left.right.right.value);

	}

	@IsTest
	static void tree_objectLiterals_Test() {

		final JexlParser parser = new JexlParser(Grammar, null, null);

		Test.startTest();

		parser.addTokens(Lexer.tokenize('{foo: "bar", tek: 1+2}'));

		final JexlNode node = parser.complete();

		Test.stopTest();

		/*
		{
	      type: 'ObjectLiteral',
	      value: {
	        foo: { type: 'Literal', value: 'bar' },
	        tek: {
	          type: 'BinaryExpression',
	          operator: '+',
	          left: { type: 'Literal', value: 1 },
	          right: { type: 'Literal', value: 2 }
	        }
	      }
	    }
		 */

		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.ObjectLiteral, node.type);
		Assert.areEqual(true, node.value instanceof Map<String, Object>);

		final Map<String, Object> innerNode = (Map<String, Object>) node.value;
		final JexlNode foo = (JexlNode) innerNode.get('foo');
		Assert.areNotEqual(null, foo);
		Assert.areEqual(JexlNode.Type.Literal, foo.type);
		Assert.areEqual('bar', foo.value);

		final JexlNode tek = (JexlNode) innerNode.get('tek');
		Assert.areNotEqual(null, tek);
		Assert.areEqual(JexlNode.Type.BinaryExpression, tek.type);
		Assert.areEqual('+', tek.operator);

		Assert.areNotEqual(null, tek.left);
		Assert.areEqual(JexlNode.Type.Literal, tek.left.type);
		Assert.areEqual(1, tek.left.value);

		Assert.areNotEqual(null, tek.right);
		Assert.areEqual(JexlNode.Type.Literal, tek.right.type);
		Assert.areEqual(2, tek.right.value);

	}

	@IsTest
	static void tree_objectLiterals_keyWithDashes_Test() {

		final JexlParser parser = new JexlParser(Grammar, null, null);

		Test.startTest();

		parser.addTokens(Lexer.tokenize('{\'with-dash\': "bar", tek: 1+2}'));

		final JexlNode node = parser.complete();

		Test.stopTest();

		/*
		{
	      type: 'ObjectLiteral',
	      value: {
	        'with-dash': { type: 'Literal', value: 'bar' },
	        tek: {
	          type: 'BinaryExpression',
	          operator: '+',
	          left: { type: 'Literal', value: 1 },
	          right: { type: 'Literal', value: 2 }
	        }
	      }
	    }
		 */

		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.ObjectLiteral, node.type);
		Assert.areEqual(true, node.value instanceof Map<String, Object>);

		final Map<String, Object> innerNode = (Map<String, Object>) node.value;
		final JexlNode withDash = (JexlNode) innerNode.get('with-dash');
		Assert.areNotEqual(null, withDash);
		Assert.areEqual(JexlNode.Type.Literal, withDash.type);
		Assert.areEqual('bar', withDash.value);

		final JexlNode tek = (JexlNode) innerNode.get('tek');
		Assert.areNotEqual(null, tek);
		Assert.areEqual(JexlNode.Type.BinaryExpression, tek.type);
		Assert.areEqual('+', tek.operator);

		Assert.areNotEqual(null, tek.left);
		Assert.areEqual(JexlNode.Type.Literal, tek.left.type);
		Assert.areEqual(1, tek.left.value);

		Assert.areNotEqual(null, tek.right);
		Assert.areEqual(JexlNode.Type.Literal, tek.right.type);
		Assert.areEqual(2, tek.right.value);

	}

	@IsTest
	static void tree_objectLiterals_nested_Test() {

		final JexlParser parser = new JexlParser(Grammar, null, null);

		Test.startTest();

		parser.addTokens(Lexer.tokenize('{foo: {bar: "tek"}}'));

		final JexlNode node = parser.complete();

		Test.stopTest();

		/*
		{
	      type: 'ObjectLiteral',
	      value: {
	        foo: {
	          type: 'ObjectLiteral',
	          value: {
	            bar: { type: 'Literal', value: 'tek' }
	          }
	        }
	      }
	    }
		 */

		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.ObjectLiteral, node.type);
		Assert.areEqual(true, node.value instanceof Map<String, Object>);

		final Map<String, Object> innerNode1 = (Map<String, Object>) node.value;
		final JexlNode foo = (JexlNode) innerNode1.get('foo');
		Assert.areNotEqual(null, foo);
		Assert.areEqual(JexlNode.Type.ObjectLiteral, foo.type);

		final Map<String, Object> innerNode2 = (Map<String, Object>) foo.value;
		final JexlNode bar = (JexlNode) innerNode2.get('bar');
		Assert.areNotEqual(null, bar);
		Assert.areEqual(JexlNode.Type.Literal, bar.type);
		Assert.areEqual('tek', bar.value);

	}

	@IsTest
	static void tree_objectLiterals_empty_Test() {

		final JexlParser parser = new JexlParser(Grammar, null, null);

		Test.startTest();

		parser.addTokens(Lexer.tokenize('{}'));

		final JexlNode node = parser.complete();

		Test.stopTest();

		/*
		{
	      type: 'ObjectLiteral',
	      value: {}
	    }
		 */

		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.ObjectLiteral, node.type);
		Assert.areNotEqual(null, node.value);
		Assert.areEqual(true, node.value instanceof Map<String, Object>);
		Assert.areEqual(0, ((Map<String, Object>) node.value).size());

	}

	@IsTest
	static void tree_arrayLiterals_Test() {

		final JexlParser parser = new JexlParser(Grammar, null, null);

		Test.startTest();

		parser.addTokens(Lexer.tokenize('["foo", 1+2]'));

		final JexlNode node = parser.complete();

		Test.stopTest();

		/*
		{
	      type: 'ArrayLiteral',
	      value: [
	        { type: 'Literal', value: 'foo' },
	        {
	          type: 'BinaryExpression',
	          operator: '+',
	          left: { type: 'Literal', value: 1 },
	          right: { type: 'Literal', value: 2 }
	        }
	      ]
	    }
		 */

		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.ArrayLiteral, node.type);
		Assert.areNotEqual(null, node.value);
		final String jsonValue = JSON.serializePretty(node.value);
		Assert.areEqual(true, node.value instanceof List<Object>, jsonValue);
		final List<Object> arrayValue = (List<Object>) node.value;
		Assert.areEqual(2, arrayValue.size(), jsonValue);

		JexlNode subNode = (JexlNode) arrayValue[0];
		Assert.areNotEqual(null, subNode);
		Assert.areEqual(JexlNode.Type.Literal, subNode.type);
		Assert.areEqual('foo', subNode.value, jsonValue);

		subNode = (JexlNode) arrayValue[1];
		Assert.areNotEqual(null, subNode);
		Assert.areEqual(JexlNode.Type.BinaryExpression, subNode.type);
		Assert.areEqual('+', subNode.operator, jsonValue);

		Assert.areNotEqual(null, subNode.left);
		Assert.areEqual(JexlNode.Type.Literal, subNode.left.type);
		Assert.areEqual(1, subNode.left.value, jsonValue);

		Assert.areNotEqual(null, subNode.right);
		Assert.areEqual(JexlNode.Type.Literal, subNode.right.type);
		Assert.areEqual(2, subNode.right.value, jsonValue);

	}

	@IsTest
	static void tree_arrayLiterals_nested_Test() {

		final JexlParser parser = new JexlParser(Grammar, null, null);

		Test.startTest();

		parser.addTokens(Lexer.tokenize('["foo", ["bar", "tek"]]'));

		final JexlNode node = parser.complete();

		Test.stopTest();

		/*
		{
	      type: 'ArrayLiteral',
	      value: [
	        { type: 'Literal', value: 'foo' },
	        {
	          type: 'ArrayLiteral',
	          value: [
	            { type: 'Literal', value: 'bar' },
	            { type: 'Literal', value: 'tek' }
	          ]
	        }
	      ]
	    }
		 */

		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.ArrayLiteral, node.type);
		Assert.areNotEqual(null, node.value);
		final String jsonValue = JSON.serializePretty(node.value);
		Assert.areEqual(true, node.value instanceof List<Object>, jsonValue);
		final List<Object> arrayValue1 = (List<Object>) node.value;
		Assert.areEqual(2, arrayValue1.size(), jsonValue);

		JexlNode subNode = (JexlNode) arrayValue1[0];
		Assert.areNotEqual(null, subNode);
		Assert.areEqual(JexlNode.Type.Literal, subNode.type);
		Assert.areEqual('foo', subNode.value, jsonValue);

		subNode = (JexlNode) arrayValue1[1];
		Assert.areNotEqual(null, subNode);
		Assert.areEqual(JexlNode.Type.ArrayLiteral, subNode.type);
		Assert.areEqual(true, subNode.value instanceof List<Object>, jsonValue);
		final List<Object> arrayValue2 = (List<Object>) subNode.value;
		Assert.areEqual(2, arrayValue2.size(), jsonValue);

		subNode = (JexlNode) arrayValue2[0];
		Assert.areNotEqual(null, subNode);
		Assert.areEqual(JexlNode.Type.Literal, subNode.type);
		Assert.areEqual('bar', subNode.value, jsonValue);

		subNode = (JexlNode) arrayValue2[1];
		Assert.areNotEqual(null, subNode);
		Assert.areEqual(JexlNode.Type.Literal, subNode.type);
		Assert.areEqual('tek', subNode.value, jsonValue);

	}

	@IsTest
	static void tree_arrayLiterals_empty_Test() {

		final JexlParser parser = new JexlParser(Grammar, null, null);

		Test.startTest();

		parser.addTokens(Lexer.tokenize('[]'));

		final JexlNode node = parser.complete();

		Test.stopTest();

		/*
			{
		      type: 'ArrayLiteral',
		      value: []
		    }
		 */

		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.ArrayLiteral, node.type);
		Assert.areNotEqual(null, node.value);
		final String jsonValue = JSON.serializePretty(node.value);
		Assert.areEqual(true, node.value instanceof List<Object>, jsonValue);
		Assert.areEqual(0, ((List<Object>) node.value).size(), jsonValue);

	}

	@IsTest
	static void tree_traverse_chainedIdentifiers_Test() {

		final JexlParser parser = new JexlParser(Grammar, null, null);

		Test.startTest();

		parser.addTokens(Lexer.tokenize('foo.bar.baz + 1'));

		final JexlNode initialNode = parser.complete();

		Test.stopTest();

		/*
		{
	      type: 'BinaryExpression',
	      operator: '+',
	      left: {
	        type: 'Identifier',
	        value: 'baz',
	        from: {
	          type: 'Identifier',
	          value: 'bar',
	          from: {
	            type: 'Identifier',
	            value: 'foo'
	          }
	        }
	      },
	      right: { type: 'Literal', value: 1 }
	    }
		 */

		JexlNode node = initialNode;
		final String jsonResult = JSON.serializePretty(node, true);

		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.BinaryExpression, node.type);
		Assert.areEqual('+', node.operator);

		node = node.left;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Identifier, node.type);
		Assert.areEqual('baz', node.value);

		node = node.fromNode;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Identifier, node.type);
		Assert.areEqual('bar', node.value);

		node = node.fromNode;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Identifier, node.type);
		Assert.areEqual('foo', node.value);

		node = initialNode.right;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Literal, node.type);
		Assert.areEqual(1, node.value);

	}

	@IsTest
	static void tree_filter_identifiers_Test() {

		final JexlParser parser = new JexlParser(Grammar, null, null);

		Test.startTest();

		parser.addTokens(Lexer.tokenize('foo[1][.bar[0]=="tek"].baz'));

		final JexlNode initialNode = parser.complete();

		Test.stopTest();

		/*
		{
	      type: 'Identifier',
	      value: 'baz',
	      from: {
	        type: 'FilterExpression',
	        relative: true,
	        expr: {
	          type: 'BinaryExpression',
	          operator: '==',
	          left: {
	            type: 'FilterExpression',
	            relative: false,
	            expr: { type: 'Literal', value: 0 },
	            subject: {
	              type: 'Identifier',
	              value: 'bar',
	              relative: true
	            }
	          },
	          right: { type: 'Literal', value: 'tek' }
	        },
	        subject: {
	          type: 'FilterExpression',
	          relative: false,
	          expr: { type: 'Literal', value: 1 },
	          subject: { type: 'Identifier', value: 'foo' }
	        }
	      }
	    }
	    */

		JexlNode node = initialNode;

		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Identifier, node.type);
		Assert.areEqual('baz', node.value);

		node = node.fromNode;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.FilterExpression, node.type);
		Assert.areEqual(true, node.relative);

		node = node.expr;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.BinaryExpression, node.type);
		Assert.areEqual('==', node.operator);

		Assert.areNotEqual(null, node.right);
		Assert.areEqual(JexlNode.Type.Literal, node.right.type);
		Assert.areEqual('tek', node.right.value);

		node = node.left;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.FilterExpression, node.type);
		Assert.areEqual(false, node.relative);

		Assert.areNotEqual(null, node.expr);
		Assert.areEqual(JexlNode.Type.Literal, node.expr.type);
		Assert.areEqual(0, node.expr.value);

		Assert.areNotEqual(null, node.subject);
		Assert.areEqual(JexlNode.Type.Identifier, node.subject.type);
		Assert.areEqual('bar', node.subject.value);

		node = initialNode.fromNode.subject;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.FilterExpression, node.type);
		Assert.areEqual(false, node.relative);

		Assert.areNotEqual(null, node.expr);
		Assert.areEqual(JexlNode.Type.Literal, node.expr.type);
		Assert.areEqual(1, node.expr.value);

		Assert.areNotEqual(null, node.subject);
		Assert.areEqual(JexlNode.Type.Identifier, node.subject.type);
		Assert.areEqual('foo', node.subject.value);

	}

	@IsTest
	static void tree_filter_relativeAndNonRelativeIdentifiers_Test() {

		final JexlParser parser = new JexlParser(Grammar, null, null);

		Test.startTest();

		parser.addTokens(Lexer.tokenize('foo[.bar.baz == tek]'));

		final JexlNode initialNode = parser.complete();

		Test.stopTest();

		/*
		{
	      expr: {
	        left: {
	          from: {
	            relative: true,
	            type: 'Identifier',
	            value: 'bar'
	          },
	          type: 'Identifier',
	          value: 'baz'
	        },
	        operator: '==',
	        right: {
	          type: 'Identifier',
	          value: 'tek'
	        },
	        type: 'BinaryExpression'
	      },
	      relative: true,
	      subject: {
	        type: 'Identifier',
	        value: 'foo'
	      },
	      type: 'FilterExpression'
	    }
	    */

		JexlNode node = initialNode;

		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.FilterExpression, node.type);
		Assert.areEqual(true, node.relative);

		node = node.subject;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Identifier, node.type);
		Assert.areEqual('foo', node.value);

		node = initialNode.expr;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.BinaryExpression, node.type);
		Assert.areEqual('==', node.operator);

		Assert.areNotEqual(null, node.right);
		Assert.areEqual(JexlNode.Type.Identifier, node.right.type);
		Assert.areEqual('tek', node.right.value);

		node = node.left;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Identifier, node.type);
		Assert.areEqual('baz', node.value);

		node = node.fromNode;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Identifier, node.type);
		Assert.areEqual('bar', node.value);

	}

	@IsTest
	static void tree_filter_relativeAndNonRelativeIdentifiers_complex_Test() {

		final JexlParser parser = new JexlParser(Grammar, null, null);

		Test.startTest();

		parser.addTokens(Lexer.tokenize('foo.bar[.baz == tek.tak]'));

		final JexlNode initialNode = parser.complete();

		Test.stopTest();

		/*
		{
	      expr: {
	        left: {
	          relative: true,
	          type: 'Identifier',
	          value: 'baz'
	        },
	        operator: '==',
	        right: {
	          from: {
	            type: 'Identifier',
	            value: 'tek'
	          },
	          type: 'Identifier',
	          value: 'tak'
	        },
	        type: 'BinaryExpression'
	      },
	      relative: true,
	      subject: {
	        from: {
	          type: 'Identifier',
	          value: 'foo'
	        },
	        type: 'Identifier',
	        value: 'bar'
	      },
	      type: 'FilterExpression'
	    }
	    */

		JexlNode node = initialNode;

		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.FilterExpression, node.type);
		Assert.areEqual(true, node.relative);

		node = node.subject;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Identifier, node.type);
		Assert.areEqual('bar', node.value);

		node = node.fromNode;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Identifier, node.type);
		Assert.areEqual('foo', node.value);

		node = initialNode.expr;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.BinaryExpression, node.type);
		Assert.areEqual('==', node.operator);

		Assert.areNotEqual(null, node.left);
		Assert.areEqual(JexlNode.Type.Identifier, node.left.type);
		Assert.areEqual('baz', node.left.value);

		node = node.right;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Identifier, node.type);
		Assert.areEqual('tak', node.value);

		node = node.fromNode;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Identifier, node.type);
		Assert.areEqual('tek', node.value);

	}

	@IsTest
	static void tree_dot_allOperands_Test() {

		final JexlParser parser = new JexlParser(Grammar, null, null);

		Test.startTest();

		parser.addTokens(Lexer.tokenize('"foo".length + {foo: "bar"}.foo'));

		final JexlNode initialNode = parser.complete();

		Test.stopTest();

		/*
		{
	      type: 'BinaryExpression',
	      operator: '+',
	      left: {
	        type: 'Identifier',
	        value: 'length',
	        from: { type: 'Literal', value: 'foo' }
	      },
	      right: {
	        type: 'Identifier',
	        value: 'foo',
	        from: {
	          type: 'ObjectLiteral',
	          value: {
	            foo: { type: 'Literal', value: 'bar' }
	          }
	        }
	      }
	    }
	    */

		JexlNode node = initialNode;

		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.BinaryExpression, node.type);
		Assert.areEqual('+', node.operator);

		node = initialNode.left;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Identifier, node.type);
		Assert.areEqual('length', node.value);

		node = node.fromNode;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Literal, node.type);
		Assert.areEqual('foo', node.value);

		node = initialNode.right;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Identifier, node.type);
		Assert.areEqual('foo', node.value);

		node = node.fromNode;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.ObjectLiteral, node.type);
		Assert.areNotEqual(null, node.value);

		final Map<String, Object> objMap = (Map<String, Object>) node.value;
		node = (JexlNode) objMap.get('foo');
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Literal, node.type);
		Assert.areEqual('bar', node.value);

	}

	//@todo FIX ME
	static void tree_dot_subExpressions_Test() {

		final JexlParser parser = new JexlParser(Grammar, null, null);

		Test.startTest();

		parser.addTokens(Lexer.tokenize('("foo" + "bar").length'));

		final JexlNode initialNode = parser.complete();

		Test.stopTest();

		/*
		{
	      type: 'Identifier',
	      value: 'length',
	      from: {
	        type: 'BinaryExpression',
	        operator: '+',
	        left: { type: 'Literal', value: 'foo' },
	        right: { type: 'Literal', value: 'bar' }
	      }
	    }
	    */

		JexlNode node = initialNode;

		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Identifier, node.type, JSON.serializePretty(initialNode, true));
		Assert.areEqual('length', node.value);

		node = initialNode.fromNode;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.BinaryExpression, node.type);
		Assert.areEqual('+', node.operator);

		Assert.areNotEqual(null, node.left);
		Assert.areEqual(JexlNode.Type.Literal, node.left.type);
		Assert.areEqual('foo', node.left.value);

		Assert.areNotEqual(null, node.right);
		Assert.areEqual(JexlNode.Type.Literal, node.right.type);
		Assert.areEqual('bar', node.right.value);

	}

	@IsTest
	static void tree_dot_arrays_Test() {

		final JexlParser parser = new JexlParser(Grammar, null, null);

		Test.startTest();

		parser.addTokens(Lexer.tokenize('["foo", "bar"].length'));

		final JexlNode initialNode = parser.complete();

		Test.stopTest();

		/*
		{
	      type: 'Identifier',
	      value: 'length',
	      from: {
	        type: 'ArrayLiteral',
	        value: [
	          { type: 'Literal', value: 'foo' },
	          { type: 'Literal', value: 'bar' }
	        ]
	      }
	    }
	    */

		JexlNode node = initialNode;

		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Identifier, node.type, JSON.serializePretty(initialNode, true));
		Assert.areEqual('length', node.value);

		node = initialNode.fromNode;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.ArrayLiteral, node.type);
		Assert.areNotEqual(null, node.value);
		final List<Object> arr = (List<Object>) node.value;

		node = (JexlNode) arr[0];
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Literal, node.type);
		Assert.areEqual('foo', node.value);

		node = (JexlNode) arr[1];
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Literal, node.type);
		Assert.areEqual('bar', node.value);

	}

	@IsTest
	static void tree_ternary_Test() {

		final JexlParser parser = new JexlParser(Grammar, null, null);

		Test.startTest();

		parser.addTokens(Lexer.tokenize('foo ? 1 : 0'));

		final JexlNode initialNode = parser.complete();

		Test.stopTest();

		/*
		{
	      type: 'ConditionalExpression',
	      test: { type: 'Identifier', value: 'foo' },
	      consequent: { type: 'Literal', value: 1 },
	      alternate: { type: 'Literal', value: 0 }
	    }
	    */

		JexlNode node = initialNode;

		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.ConditionalExpression, node.type);

		node = initialNode.testNode;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Identifier, node.type);
		Assert.areEqual('foo', node.value);

		node = initialNode.alternate;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Literal, node.type);
		Assert.areEqual(0, node.value);

		node = initialNode.consequent;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Literal, node.type);
		Assert.areEqual(1, node.value);

	}

	@IsTest
	static void tree_ternary_nestedAndGrouped_Test() {

		final JexlParser parser = new JexlParser(Grammar, null, null);

		Test.startTest();

		parser.addTokens(Lexer.tokenize('foo ? (bar ? 1 : 2) : 3'));

		final JexlNode initialNode = parser.complete();

		Test.stopTest();

		/*
		{
	      type: 'ConditionalExpression',
	      test: { type: 'Identifier', value: 'foo' },
	      consequent: {
	        type: 'ConditionalExpression',
	        test: { type: 'Identifier', value: 'bar' },
	        consequent: { type: 'Literal', value: 1 },
	        alternate: { type: 'Literal', value: 2 }
	      },
	      alternate: { type: 'Literal', value: 3 }
	    }
	    */

		JexlNode node = initialNode;

		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.ConditionalExpression, node.type);

		node = initialNode.testNode;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Identifier, node.type);
		Assert.areEqual('foo', node.value);

		node = initialNode.alternate;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Literal, node.type);
		Assert.areEqual(3, node.value);

		node = initialNode.consequent;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.ConditionalExpression, node.type);

		node = initialNode.consequent.testNode;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Identifier, node.type);
		Assert.areEqual('bar', node.value);

		node = initialNode.consequent.alternate;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Literal, node.type);
		Assert.areEqual(2, node.value);

		node = initialNode.consequent.consequent;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Literal, node.type);
		Assert.areEqual(1, node.value);

	}

	@IsTest
	static void tree_ternary_nestedNonGrouped_Test() {

		final JexlParser parser = new JexlParser(Grammar, null, null);

		Test.startTest();

		parser.addTokens(Lexer.tokenize('foo ? bar ? 1 : 2 : 3'));

		final JexlNode initialNode = parser.complete();

		Test.stopTest();

		/*
		{
	      type: 'ConditionalExpression',
	      test: { type: 'Identifier', value: 'foo' },
	      consequent: {
	        type: 'ConditionalExpression',
	        test: { type: 'Identifier', value: 'bar' },
	        consequent: { type: 'Literal', value: 1 },
	        alternate: { type: 'Literal', value: 2 }
	      },
	      alternate: { type: 'Literal', value: 3 }
	    }
	    */

		JexlNode node = initialNode;

		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.ConditionalExpression, node.type);

		node = initialNode.testNode;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Identifier, node.type);
		Assert.areEqual('foo', node.value);

		node = initialNode.alternate;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Literal, node.type);
		Assert.areEqual(3, node.value);

		node = initialNode.consequent;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.ConditionalExpression, node.type);

		node = initialNode.consequent.testNode;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Identifier, node.type);
		Assert.areEqual('bar', node.value);

		node = initialNode.consequent.alternate;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Literal, node.type);
		Assert.areEqual(2, node.value);

		node = initialNode.consequent.consequent;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Literal, node.type);
		Assert.areEqual(1, node.value);

	}

	@IsTest
	static void tree_ternary_object_Test() {

		final JexlParser parser = new JexlParser(Grammar, null, null);

		Test.startTest();

		parser.addTokens(Lexer.tokenize('foo ? {bar: "tek"} : "baz"'));

		final JexlNode initialNode = parser.complete();

		Test.stopTest();

		/*
		{
	      type: 'ConditionalExpression',
	      test: { type: 'Identifier', value: 'foo' },
	      consequent: {
	        type: 'ObjectLiteral',
	        value: {
	          bar: { type: 'Literal', value: 'tek' }
	        }
	      },
	      alternate: { type: 'Literal', value: 'baz' }
	    }
	    */

		JexlNode node = initialNode;

		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.ConditionalExpression, node.type);

		node = initialNode.testNode;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Identifier, node.type);
		Assert.areEqual('foo', node.value);

		node = initialNode.alternate;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Literal, node.type);
		Assert.areEqual('baz', node.value);

		node = initialNode.consequent;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.ObjectLiteral, node.type);
		Assert.areNotEqual(null, node.value);

		final Map<String, Object> mappedValue = (Map<String, Object>) node.value;

		node = (JexlNode) mappedValue.get('bar');
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Literal, node.type);
		Assert.areEqual('tek', node.value);

	}

	@IsTest
	static void tree_binaryOp_complexIdentifiers_Test() {

		final JexlParser parser = new JexlParser(Grammar, null, null);

		Test.startTest();

		parser.addTokens(Lexer.tokenize('a.b == c.d'));

		final JexlNode initialNode = parser.complete();

		Test.stopTest();

		/*
		{
	      type: 'BinaryExpression',
	      operator: '==',
	      left: {
	        type: 'Identifier',
	        value: 'b',
	        from: { type: 'Identifier', value: 'a' }
	      },
	      right: {
	        type: 'Identifier',
	        value: 'd',
	        from: { type: 'Identifier', value: 'c' }
	      }
	    }
	    */

		JexlNode node = initialNode;

		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.BinaryExpression, node.type);
		Assert.areEqual('==', node.operator);

		node = initialNode.left;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Identifier, node.type);
		Assert.areEqual('b', node.value);

		node = initialNode.left.fromNode;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Identifier, node.type);
		Assert.areEqual('a', node.value);

		node = initialNode.right;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Identifier, node.type);
		Assert.areEqual('d', node.value);

		node = initialNode.right.fromNode;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Identifier, node.type);
		Assert.areEqual('c', node.value);

	}

	@IsTest
	static void tree_withWhitespace_Test() {

		final JexlParser parser = new JexlParser(Grammar, null, null);

		Test.startTest();

		parser.addTokens(Lexer.tokenize('\t2\r\n+\n\r3\n\n'));

		final JexlNode initialNode = parser.complete();

		Test.stopTest();

		/*
		{
	      type: 'BinaryExpression',
	      operator: '+',
	      left: { type: 'Literal', value: 2 },
	      right: { type: 'Literal', value: 3 }
	    }
	    */

		JexlNode node = initialNode;

		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.BinaryExpression, node.type);
		Assert.areEqual('+', node.operator);

		node = initialNode.left;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Literal, node.type);
		Assert.areEqual(2, node.value);

		node = initialNode.right;
		Assert.areNotEqual(null, node);
		Assert.areEqual(JexlNode.Type.Literal, node.type);
		Assert.areEqual(3, node.value);

	}

}