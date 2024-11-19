/*
 * Ported from original Javascript by The Last Byte Consulting.
 * Original Jexl Javascript code is Copyright 2020 Tom Shawver
 */
public without sharing class JexlExpression {

	private final JexlGrammar grammar { get; set; }
	private final String expressionString { get; set; }
	private JexlNode tree { get; set; }

	public JexlExpression(JexlGrammar grammar, String expressionString) {
		this.grammar = grammar;
		this.expressionString = expressionString;
	}

	public JexlExpression compile() {
		final JexlLexer lexer = new JexlLexer(grammar);
		final JexlParser parser = new JexlParser(grammar, null, null);
		final List<JexlLexer.Token> tokens = lexer.tokenize(expressionString);
		parser.addTokens(tokens);
		tree = parser.complete();
		return this;
	}

	public Object eval() {
		return eval(null);
	}
	public Object eval(Object context) {
		final JexlNode tree = getTree();
		final JexlEvaluator evaluator = new JexlEvaluator(
			grammar,
			context,
			null
		);
		return evaluator.eval(tree);
	}

	private JexlNode getTree() {
		if (tree == null) {
			compile();
		}
		return tree;
	}

}