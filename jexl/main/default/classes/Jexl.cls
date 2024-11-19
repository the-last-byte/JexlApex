public with sharing class Jexl {

	private final JexlGrammar grammar { get; set; }

	public Jexl() {
		grammar = new JexlGrammar();
	}

	public JexlExpression createExpression(String expressionString) {
		return new JexlExpression(grammar, expressionString);
	}

	public Object eval(String expressionString) {
		return evalObject(expressionString, null);
	}

	public Object eval(String expressionString, Map<String, Object> context) {
		return evalObject(expressionString, context);
	}

	public Object eval(String expressionString, SObject context) {
		return evalObject(expressionString, context);
	}

	private Object evalObject(String expressionString, Object context) {
		final JexlExpression exp = createExpression(expressionString);
		return exp.eval(context ?? new Map<String, Object>());
	}

}