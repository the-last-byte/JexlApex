public without sharing class JexlParser {

	private static final Map<String, JexlNamedMethod> NamedMethodMap {
		get {
			if (NamedMethodMap == null) {
				NamedMethodMap = new Map<String, JexlNamedMethod>();
				for (JexlNamedMethod m : JexlNamedMethod.values()) {
					NamedMethodMap.put(m.name(), m);
				}
			}
			return NamedMethodMap;
		}
		set;
	}

	private transient final JexlGrammar grammar { get; set; }
	private final Map<JexlGrammar.GrammarType, JexlStates.TokenType> stopMap { get; set; }
	private JexlStatus status { get; set; }
	private JexlNode tree { get; set; }
	private JexlNode cursor { get; set; }
	private String expressionString { get; set; }
	private Boolean relative { get; set; }
	private Boolean parentStop { get; set; }
	private Boolean nextIdentEncapsulate { get; set; }
	private Boolean nextIdentRelative { get; set; }
	private String currentObjectKey { get; set; }

	private JexlParser subParser { get; set; }

	private transient final Handler handler { get; set; }

	public JexlParser(JexlGrammar grammar, String prefix, Map<JexlGrammar.GrammarType, JexlStates.TokenType> stopMap) {
		this.grammar = grammar;
		this.stopMap = stopMap ?? new Map<JexlGrammar.GrammarType, JexlStates.TokenType>();
		status = JexlStatus.ExpectOperand;
		expressionString = prefix ?? '';
		relative = false;
		parentStop = false;
		nextIdentEncapsulate = false;
		nextIdentRelative = false;
		handler = new Handler(this);
	}

	//Returns JexlStates.State,
	public JexlStatus addToken(JexlLexer.Token token) {

		if (status == JexlStatus.Complete) {
			throw new JexlException('Cannot add a new token to a completed Parser.');
		}
		//Get the state
		final JexlStates.State state = JexlStates.StatusToState.get(status);

		//Concatenate the expression string
		final String startExpressionString = expressionString;
		expressionString += token.raw;

		//Handle sub-expressions
		if (state.subHandlerName != null) {
			if (subParser == null) {
				startSubExpression(startExpressionString);
			}
			final JexlStatus stopState = subParser.addToken(token);
			if (stopState != null) {
				endSubExpression();
				if (parentStop) {
					return stopState;
				}
				this.status = stopState;
			}
		}

		//Check token types and execute handler if present
		else if (state.tokenTypes.containsKey(token.type)) {
			final JexlStates.TokenType tokenType = state.tokenTypes.get(token.type);

			JexlNamedMethod namedMethod = NamedMethodMap.get(token.type.name());
			if (tokenType.handler != null) {
				namedMethod = tokenType.handler;
			}

			if (namedMethod != null) {
				handler.executeNamedMethod(
					namedMethod,
					null,
					token
				);
			}

			if (tokenType.toStatus != null) {
				status = tokenType.toStatus;
			}
		}
		//Check the stop map
		else if (stopMap.containsKey(token.type)) {
			return stopMap.get(token.type).toStatus;
		}
		//Handle errors
		else {
			throw new JexlException(
				'Token ' + token.raw + ' (' + token.type.name() +
					') unexpected in expression (at ' + status + '): ' + expressionString
			);
		}
		return null;
	}

	public void addTokens(List<JexlLexer.Token> tokens) {
		for (JexlLexer.Token token : tokens) {
			addToken(token);
		}
	}

	public JexlNode complete() {
		if (cursor != null && !JexlStates.StatusToState.get(status).completable) {
			throw new JexlException('Expected end of expression: ' + expressionString);
		}
		if (subParser != null) {
			endSubExpression();
		}
		status = JexlStatus.Complete;
		return cursor == null
			? null
			: tree;
	}

	private void startSubExpression(String expression) {
		Map<JexlGrammar.GrammarType, JexlStates.TokenType> endStates = JexlStates.StatusToState.get(status)?.endStatuses;
		if (endStates?.isEmpty() != false) {
			parentStop = true;
			endStates = stopMap;
		}
		subParser = new JexlParser(grammar, expression, endStates);
	}

	private void endSubExpression() {
		final JexlStates.State state = JexlStates.StatusToState.get(status);
		handler.executeNamedMethod(state.subHandlerName, subParser.complete(), null);
		subParser = null;
	}

	private void placeAtCursor(JexlNode node) {
		if (cursor == null) {
			tree = node;
		} else {
			cursor.right = node;
			node.parent = cursor;
		}
		cursor = node;
	}

	private void placeBeforeCursor(JexlNode node) {
		cursor = cursor.parent;
		placeAtCursor(node);
	}

	private class Handler {

		private final JexlParser parser { get; set; }

		public Handler(JexlParser parser) {
			this.parser = parser;
		}

		public void executeNamedMethod(JexlNamedMethod method, JexlNode tree, JexlLexer.Token token) {
			switch on method {
				when ArgVal {
					argVal(tree);
				}
				when ArrayStart {
					arrayStart();
				}
				when ArrayVal {
					arrayVal(tree);
				}
				when BinaryOp {
					binaryOp(token);
				}
				when Dot {
					dot();
				}
				when Filter {
					filter(tree);
				}
				when FunctionCall {
					functionCall();
				}
				when Identifier {
					identifier(token);
				}
				when Literal {
					literal(token);
				}
				when ObjectKey {
					objKey(token);
				}
				when ObjectStart {
					objStart();
				}
				when ObjectValue {
					objectValue(tree);
				}
				when SubExpression {
					subExpression(tree);
				}
				when TernaryEnd {
					ternaryEnd(tree);
				}
				when TernaryMid {
					ternaryMid(tree);
				}
				when TernaryStart {
					ternaryStart();
				}
				when Transform {
					transform(token);
				}
				when UnaryOp {
					unaryOp(token);
				}
				when else {
					throw new JexlException(
						'Unexpected method (' + method + ') for ' + token.type?.name() + ' at: ' + parser.expressionString
					);
				}
			}
		}

		private void argVal(JexlNode tree) {
			if (tree != null) {
				parser.cursor.args.add(tree);
			}
		}

		public void arrayStart() {
			parser.placeAtCursor(new JexlNode(
				JexlNode.Type.ArrayLiteral,
				new List<Object>()
			));
		}

		public void arrayVal(JexlNode tree) {
			if (tree != null) {
				((List<Object>) parser.cursor.value).add(tree);
			}
		}

		public void binaryOp(JexlLexer.Token token) {
			final Integer precedence = parser.grammar.elements.get(String.valueOf(token.value))?.getPrecedence() ?? 0;
			JexlNode parent = parser.cursor.parent;
			while (
				parent != null &&
					parent.operator != null &&
					parser.grammar.elements.get(String.valueOf(parent.operator)).getPrecedence() >= precedence
			) {
				parser.cursor = parent;
				parent = parent.parent;
			}
			final JexlNode node = JexlNode.createBinaryExpression(parser.cursor, token.value);
			parser.cursor.parent = node;
			parser.cursor = parent;
			parser.placeAtCursor(node);
		}

		public void dot() {
			//Set nextIdentifierEncapsulate
			parser.nextIdentEncapsulate = parser.cursor != null
				&& parser.cursor.type != JexlNode.Type.UnaryExpression
				&& (
				parser.cursor.type != JexlNode.Type.BinaryExpression
					|| (
					parser.cursor.type != JexlNode.Type.BinaryExpression
						&& parser.cursor.right != null
				)
			);
			//Set nextIdentifierRelative
			parser.nextIdentRelative = parser.cursor == null || (parser.cursor != null && !parser.nextIdentEncapsulate);
			//Set relative
			if (parser.nextIdentRelative) {
				parser.relative = true;
			}
		}

		public void filter(JexlNode tree) {
			parser.placeBeforeCursor(JexlNode.createFilterExpression(
				parser.cursor,
				tree,
				parser.subParser.relative
			));
		}

		public void functionCall() {
			parser.placeBeforeCursor(JexlNode.createFunctionCall(parser.cursor));
		}

		public void identifier(JexlLexer.Token token) {
			final JexlNode node = new JexlNode(
				JexlNode.Type.Identifier,
				token.value
			);
			if (parser.nextIdentEncapsulate) {
				node.fromNode = parser.cursor;
				parser.placeBeforeCursor(node);
				parser.nextIdentEncapsulate = false;
			} else {
				if (parser.nextIdentRelative) {
					node.relative = true;
					parser.nextIdentRelative = false;
				}
				parser.placeAtCursor(node);
			}
		}

		public void literal(JexlLexer.Token token) {
			parser.placeAtCursor(new JexlNode(
				JexlNode.Type.Literal,
				token.value
			));
		}

		public void objKey(JexlLexer.Token token) {
			parser.currentObjectKey = String.valueOf(token.value);
		}

		public void objStart() {
			parser.placeAtCursor(new JexlNode(
				JexlNode.Type.ObjectLiteral,
				new Map<String, Object>()
			));
		}

		public void objectValue(JexlNode tree) {
			((Map<String, Object>) parser.cursor.value).put(parser.currentObjectKey, tree);
		}

		public void subExpression(JexlNode tree) {
			parser.placeAtCursor(tree);
		}

		public void ternaryEnd(JexlNode tree) {
			parser.cursor.alternate = tree;
		}

		public void ternaryMid(JexlNode tree) {
			parser.cursor.consequent = tree;
		}

		public void ternaryStart() {
			parser.tree = JexlNode.createTernaryStart(parser.tree);
			parser.cursor = parser.tree;
		}

		public void transform(JexlLexer.Token token) {
			parser.placeBeforeCursor(JexlNode.createTransform(
				parser.cursor,
				token
			));
		}

		public void unaryOp(JexlLexer.Token token) {
			parser.placeAtCursor(JexlNode.createUnaryExpression(token));
		}

	}

}