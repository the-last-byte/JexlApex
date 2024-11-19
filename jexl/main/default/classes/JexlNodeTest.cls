@IsTest
private class JexlNodeTest {

	@IsTest
	static void constructor_Test() {

		final JexlNode relatedNode1 = new JexlNode(JexlNode.Type.Literal, '"a"');
		final JexlNode relatedNode2 = new JexlNode(JexlNode.Type.Literal, '"b"');

		final JexlLexer.Token token = new JexlLexer.Token(new JexlGrammar(), '"el"');

		Test.startTest();

		//Single argument constructor
		JexlNode node = new JexlNode(JexlNode.Type.BinaryExpression);
		Assert.areEqual(node.type, JexlNode.Type.BinaryExpression);

		//Two argument constructor
		node = new JexlNode(
			JexlNode.Type.BinaryExpression,
			123
		);
		Assert.areEqual(JexlNode.Type.BinaryExpression, node.type);
		Assert.areEqual(123, node.value);

		//createBinaryExpression
		node = JexlNode.createBinaryExpression(
			relatedNode1,
			123
		);
		Assert.areEqual(JexlNode.Type.BinaryExpression, node.type);
		Assert.areEqual(relatedNode1, node.left);
		Assert.areEqual(123, node.operator);

		//createFilterExpression
		node = JexlNode.createFilterExpression(
			relatedNode1,
			relatedNode2,
			true
		);
		Assert.areEqual(JexlNode.Type.FilterExpression, node.type);
		Assert.areEqual(relatedNode1, node.subject);
		Assert.areEqual(relatedNode2, node.expr);
		Assert.areEqual(true, node.relative);

		//createFunctionCall
		node = JexlNode.createFunctionCall(
			relatedNode1
		);
		Assert.areEqual(JexlNode.Type.FunctionCall, node.type);
		Assert.areEqual(relatedNode1.value, node.name);
		Assert.areEqual(JexlPool.Functions, node.pool);

		//createTransform
		node = JexlNode.createTransform(
			relatedNode1,
			token
		);
		Assert.areEqual(JexlNode.Type.FunctionCall, node.type);
		Assert.areEqual(token.value, node.name);
		Assert.areEqual(1, node.args.size());
		Assert.areEqual(relatedNode1, node.args[0]);
		Assert.areEqual(JexlPool.Transforms, node.pool);

		//createTernaryStart
		node = JexlNode.createTernaryStart(
			relatedNode1
		);
		Assert.areEqual(JexlNode.Type.ConditionalExpression, node.type);
		Assert.areEqual(relatedNode1, node.testNode);

		//createUnaryExpression
		node = JexlNode.createUnaryExpression(
			token
		);
		Assert.areEqual(JexlNode.Type.UnaryExpression, node.type);
		Assert.areEqual(token.value, node.operator);

		Test.stopTest();

	}

}