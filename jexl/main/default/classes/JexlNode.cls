/*
 * Ported from original Javascript by The Last Byte Consulting.
 * Original Jexl Javascript code is Copyright 2020 Tom Shawver
 */
public without sharing class JexlNode {

	public enum Type {
		ArrayLiteral,
		BinaryExpression,
		UnaryExpression,
		FilterExpression,
		FunctionCall,
		Identifier,
		Literal,
		ObjectLiteral,
		ConditionalExpression
	}

	public JexlNode.Type type { get; private set; }

	public JexlNode left { get; set; }
	public JexlNode right { get; set; }
	public transient JexlNode parent { get; set; }
	//@todo What is this?
	public JexlNode subject { get; set; }
	//@todo What is this?
	public JexlNode expr { get; set; }
	//@todo What is this?
	public JexlNode fromNode { get; set; }
	//@todo What is this?
	public JexlNode alternate { get; set; }
	//@todo What is this?
	public JexlNode consequent { get; set; }
	//The node to test against
	public JexlNode testNode { get; set; }
	public Boolean relative { get; set; }

	public Object value { get; private set; }
	public Object name { get; private set; }
	public List<JexlNode> args { get; private set; }
	public Object operator { get; private set; }
	public JexlPool pool { get; private set; }

	public JexlNode(JexlNode.Type type) {
		this.type = type;
		args = new List<JexlNode>();
	}

	public JexlNode(JexlNode.Type type, Object value) {
		this(type);
		this.value = value;
		relative = false;
	}

	public static JexlNode createBinaryExpression(JexlNode cursor, Object operator) {
		final JexlNode node = new JexlNode(Type.BinaryExpression);
		node.left = cursor;
		node.operator = operator;
		return node;
	}

	public static JexlNode createFilterExpression(JexlNode cursor, JexlNode tree, Boolean relative) {
		final JexlNode node = new JexlNode(Type.FilterExpression);
		node.expr = tree;
		node.relative = relative;
		node.subject = cursor;
		return node;
	}

	public static JexlNode createFunctionCall(JexlNode cursor) {
		final JexlNode node = new JexlNode(Type.FunctionCall);
		node.name = cursor.value;
		node.pool = JexlPool.Functions;
		return node;
	}

	public static JexlNode createTransform(JexlNode cursor, JexlLexer.Token token) {
		final JexlNode node = new JexlNode(Type.FunctionCall);
		node.name = token.value;
		node.args.add(cursor);
		node.pool = JexlPool.Transforms;
		return node;
	}

	public static JexlNode createTernaryStart(JexlNode tree) {
		final JexlNode node = new JexlNode(Type.ConditionalExpression);
		node.testNode = tree;
		return node;
	}

	public static JexlNode createUnaryExpression(JexlLexer.Token token) {
		final JexlNode node = new JexlNode(Type.UnaryExpression);
		node.operator = token.value;
		return node;
	}

}