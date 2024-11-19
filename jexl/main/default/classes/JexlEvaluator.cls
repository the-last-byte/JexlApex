public without sharing class JexlEvaluator {

	private static final Map<JexlPool, String> PoolToLabel = new Map<JexlPool, String> {
		JexlPool.Functions => 'Jexl Function',
		JexlPool.Transforms => 'Transform'
	};

	private final JexlGrammar grammar { get; set; }
	/**
	 * This will either be a `List<Object>` or a `Map<String, Object>`.
	 */
	private final Object context { get; set; }
	/**
	 * This will either be a `List<Object>` or a `Map<String, Object>`.
	 */
	private final Object relativeContext { get; set; }
	private final Handler handler { get; set; }

	public JexlEvaluator(JexlGrammar grammar, Object context, Object relativeContext) {
		this.grammar = grammar;
		this.context = context == null
			? new Map<String, Object>()
			: prepareContext(context);
		this.relativeContext = relativeContext == null
			? this.context
			: prepareContext(relativeContext);
		handler = new Handler(this);
	}

	/**
	 * Evaluates a single Jexl node/tree.
	 *
	 * @param tree The tree/node to evaluate.
	 *
	 * @return The resolved value
	 */
	public Object eval(JexlNode tree) {
		return handler.eval(tree);
	}

	/**
	 * Evaluates an array of Jexl tree Nodes and returns the results as a list in the supplied order.
	 *
	 * @param trees The trees/nodes to evaluate
	 *
	 * @return A list of resolved values
	 */
	public Object evalArray(List<Object> trees) {
		final List<Object> results = new List<Object>();
		for (Object tree : trees) {
			results.add(handler.eval((JexlNode) tree));
		}
		return results;
	}

	/**
	 * Evaluates a map of Jexl tree Nodes and returns the results mapped to their original keys.
	 *
	 * @param treeMap A map of key to Jexl tree/node
	 *
	 * @return A map of key to value
	 */
	public Map<String, Object> evalMap(Map<String, Object> treeMap) {
		final Map<String, Object> resultMap = new Map<String, Object>();
		for (String key : treeMap.keySet()) {
			resultMap.put(
				key,
				eval((JexlNode) treeMap.get(key))
			);
		}
		return resultMap;
	}

	private List<Object> filterRelative(Object subject, JexlNode expr) {
		if (subject == null) {
			return filterRelative(new List<Object>(), expr);
		}
		if (subject instanceof List<Object>) {
			return filterRelative((List<Object>) subject, expr);
		}
		return filterRelative(new List<Object> {
			subject
		}, expr);
	}

	private List<Object> filterRelative(List<Object> subject, JexlNode expr) {
		final List<Object> results = new List<Object>();
		for (Object elem : subject) {
			final JexlEvaluator ev = new JexlEvaluator(
				grammar,
				context,
				elem
			);
			if (ev.eval(expr) == true) {
				results.add(elem);
			}
		}
		return results;
	}

	private Object filterStatic(Object subject, JexlNode expr) {
		final Object result = eval(expr);
		if (result == true) {
			return subject;
		}
		if (result == false) {
			return null;
		}
		//@todo better type safety?
		if (subject instanceof List<Object>) {
			return ((List<Object>) subject)[Integer.valueOf(result)];
		}
		return ((Map<String, Object>) subject).get(String.valueOf(result));
	}

	private static Object getValueFromObject(Object o, String fieldName) {
		return ((Map<String, Object>) o).get(fieldName);
	}

	/**
	 * @param o The unsafe context
	 *
	 * @return Either a `List<Object>` or a `Map<String, Object>`
	 */
	private static Object prepareContext(Object o) {
		if (o instanceof List<Object>) {
			return (List<Object>) JSON.deserializeUntyped(JSON.serialize(o));
		}
		return (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(o));
	}

	private class Handler {

		private final JexlEvaluator evaluator { get; set; }

		public Handler(JexlEvaluator evaluator) {
			this.evaluator = evaluator;
		}

		public Object eval(JexlNode tree) {
			switch on tree?.type {
				when ArrayLiteral {
					return arrayLiteral(tree);
				}
				when BinaryExpression {
					return binaryExpression(tree);
				}
				when ConditionalExpression {
					return conditionalExpression(tree);
				}
				when FilterExpression {
					return filterExpression(tree);
				}
				when Identifier {
					return identifier(tree);
				}
				when Literal {
					return literal(tree);
				}
				when ObjectLiteral {
					return objectLiteral(tree);
				}
				when FunctionCall {
					return functionCall(tree);
				}
				when UnaryExpression {
					return unaryExpression(tree);
				}
				when else {
					throw new JexlException('Unexpected node type: ' + tree?.type);
				}
			}
		}

		private Object arrayLiteral(JexlNode tree) {
			return evaluator.evalArray((List<Object>) tree.value);
		}

		private Object binaryExpression(JexlNode tree) {
			final JexlGrammar.IGrammar operator = evaluator.grammar.elements.get(String.valueOf(tree.operator));
			//@todo Null check? Does this even matter without async?
			if (operator.isOnDemand()) {
				return ((JexlGrammar.IGrammarEvalOnDemand) operator).evalOnDemand(
					tree.left,
					tree.right
				);
			}
			//@todo Type check?
			final JexlGrammar.IGrammarEval grammarEval = (JexlGrammar.IGrammarEval) operator;
			final Object leftResult = evaluator.eval(tree.left);
			final Object rightResult = evaluator.eval(tree.right);
			return grammarEval.eval(leftResult, rightResult);
		}

		private Object conditionalExpression(JexlNode tree) {
			final Object result = evaluator.eval(tree.testNode);
			if (JexlUtil.isTruthy(result)) {
				if (tree.consequent != null) {
					return evaluator.eval(tree.consequent);
				}
				return result;
			}
			return evaluator.eval(tree.alternate);
		}

		private Object filterExpression(JexlNode tree) {
			final Object subject = evaluator.eval(tree.subject);
			if (tree.relative) {
				return evaluator.filterRelative(subject, tree.expr);
			}
			return evaluator.filterStatic(subject, tree.expr);
		}

		private Object identifier(JexlNode tree) {
			if (tree.fromNode == null) {
				return tree.relative
					? getValueFromObject(evaluator.relativeContext, String.valueOf(tree.value))
					: getValueFromObject(evaluator.context, String.valueOf(tree.value));
			}
			Object resultContext = evaluator.eval(tree.fromNode);
			if (resultContext == null) {
				return null;
			}
			if (resultContext instanceof List<Object>) {
				resultContext = ((List<Object>) resultContext)[0];
			}
			return ((Map<String, Object>) resultContext).get(String.valueOf(tree.value));
		}

		private Object literal(JexlNode tree) {
			return tree.value;
		}

		private Object objectLiteral(JexlNode tree) {
			return evaluator.evalMap((Map<String, Object>) tree.value);
		}

		private Object functionCall(JexlNode tree) {
			if (tree.pool == null) {
				throw new JexlException('Corrupt tree node: Pool ' + tree.pool?.name() + ' not found.');
			}
			//@todo later
			throw new JexlException.UnsupportedException('Function Call not supported');
		}

		private Object unaryExpression(JexlNode tree) {
			final Object result = evaluator.eval(tree.right);
			final JexlGrammar.IGrammar grammar = evaluator.grammar.elements.get(String.valueOf(tree.operator));
			return ((JexlGrammar.IGrammarUnaryEval) grammar).eval(result);
		}

	}

}