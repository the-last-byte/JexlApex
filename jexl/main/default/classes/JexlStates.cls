/*
 * Ported from original Javascript by The Last Byte Consulting.
 * Original Jexl Javascript code is Copyright 2020 Tom Shawver
 */
public without sharing class JexlStates {

	public static final Map<JexlStatus, State> StatusToState = new Map<JexlStatus, State> {
		JexlStatus.ExpectOperand => new State(new Map<JexlGrammar.GrammarType, TokenType> {
			JexlGrammar.GrammarType.Literal => new TokenType(JexlStatus.ExpectBinOp),
			JexlGrammar.GrammarType.Identifier => new TokenType(JexlStatus.Identifier),
			JexlGrammar.GrammarType.UnaryOp => new TokenType(),
			JexlGrammar.GrammarType.OpenParen => new TokenType(JexlStatus.SubExpression),
			JexlGrammar.GrammarType.OpenCurl => new TokenType(JexlStatus.ExpectObjKey, JexlNamedMethod.ObjectStart),
			JexlGrammar.GrammarType.Dot => new TokenType(JexlStatus.Traverse),
			JexlGrammar.GrammarType.OpenBracket => new TokenType(JexlStatus.ArrayVal, JexlNamedMethod.ArrayStart)
		}),
		JexlStatus.ExpectBinOp => new State(
			new Map<JexlGrammar.GrammarType, TokenType> {
				JexlGrammar.GrammarType.BinaryOp => new TokenType(JexlStatus.ExpectOperand),
				JexlGrammar.GrammarType.Pipe => new TokenType(JexlStatus.ExpectTransform),
				JexlGrammar.GrammarType.Dot => new TokenType(JexlStatus.Traverse),
				JexlGrammar.GrammarType.Question => new TokenType(JexlStatus.TernaryMid, JexlNamedMethod.TernaryStart)
			},
			true
		),
		JexlStatus.ExpectTransform => new State(new Map<JexlGrammar.GrammarType, TokenType> {
			JexlGrammar.GrammarType.Identifier => new TokenType(JexlStatus.PostTransform, JexlNamedMethod.Transform)
		}),
		JexlStatus.ExpectObjKey => new State(new Map<JexlGrammar.GrammarType, TokenType> {
			JexlGrammar.GrammarType.Identifier => new TokenType(JexlStatus.ExpectKeyValSep, JexlNamedMethod.ObjectKey),
			JexlGrammar.GrammarType.CloseCurl => new TokenType(JexlStatus.ExpectBinOp)
		}),
		JexlStatus.ExpectKeyValSep => new State(new Map<JexlGrammar.GrammarType, TokenType> {
			JexlGrammar.GrammarType.Colon => new TokenType(JexlStatus.ObjVal)
		}),
		JexlStatus.PostTransform => new State(
			new Map<JexlGrammar.GrammarType, TokenType> {
				JexlGrammar.GrammarType.OpenParen => new TokenType(JexlStatus.ArgVal),
				JexlGrammar.GrammarType.BinaryOp => new TokenType(JexlStatus.ExpectOperand),
				JexlGrammar.GrammarType.Dot => new TokenType(JexlStatus.Traverse),
				JexlGrammar.GrammarType.OpenBracket => new TokenType(JexlStatus.Filter),
				JexlGrammar.GrammarType.Pipe => new TokenType(JexlStatus.ExpectTransform)
			},
			true
		),
		JexlStatus.PostArgs => new State(
			new Map<JexlGrammar.GrammarType, TokenType> {
				JexlGrammar.GrammarType.BinaryOp => new TokenType(JexlStatus.ExpectOperand),
				JexlGrammar.GrammarType.Dot => new TokenType(JexlStatus.Traverse),
				JexlGrammar.GrammarType.OpenBracket => new TokenType(JexlStatus.Filter),
				JexlGrammar.GrammarType.Pipe => new TokenType(JexlStatus.ExpectTransform)
			},
			true
		),
		JexlStatus.Identifier => new State(
			new Map<JexlGrammar.GrammarType, TokenType> {
				JexlGrammar.GrammarType.BinaryOp => new TokenType(JexlStatus.ExpectOperand),
				JexlGrammar.GrammarType.Dot => new TokenType(JexlStatus.Traverse),
				JexlGrammar.GrammarType.OpenBracket => new TokenType(JexlStatus.Filter),
				JexlGrammar.GrammarType.OpenParen => new TokenType(JexlStatus.ArgVal, JexlNamedMethod.FunctionCall),
				JexlGrammar.GrammarType.Pipe => new TokenType(JexlStatus.ExpectTransform),
				JexlGrammar.GrammarType.Question => new TokenType(JexlStatus.TernaryMid, JexlNamedMethod.TernaryStart)
			},
			true
		),
		JexlStatus.Traverse => new State(new Map<JexlGrammar.GrammarType, TokenType> {
			JexlGrammar.GrammarType.Identifier => new TokenType(JexlStatus.Identifier)
		}),
		JexlStatus.Filter => new State(
			new Map<JexlGrammar.GrammarType, TokenType> {
				JexlGrammar.GrammarType.CloseBracket => new TokenType(JexlStatus.Identifier)
			},
			JexlNamedMethod.Filter
		),
		JexlStatus.SubExpression => new State(
			new Map<JexlGrammar.GrammarType, TokenType> {
				JexlGrammar.GrammarType.CloseParen => new TokenType(JexlStatus.ExpectBinOp)
			},
			JexlNamedMethod.SubExpression
		),
		JexlStatus.ArgVal => new State(
			new Map<JexlGrammar.GrammarType, TokenType> {
				JexlGrammar.GrammarType.Comma => new TokenType(JexlStatus.ArgVal),
				JexlGrammar.GrammarType.CloseParen => new TokenType(JexlStatus.PostArgs)
			},
			JexlNamedMethod.ArgVal
		),
		JexlStatus.ObjVal => new State(
			new Map<JexlGrammar.GrammarType, TokenType> {
				JexlGrammar.GrammarType.Comma => new TokenType(JexlStatus.ExpectObjKey),
				JexlGrammar.GrammarType.CloseCurl => new TokenType(JexlStatus.ExpectBinOp)
			},
			JexlNamedMethod.ObjectValue
		),
		JexlStatus.ArrayVal => new State(
			new Map<JexlGrammar.GrammarType, TokenType> {
				JexlGrammar.GrammarType.Comma => new TokenType(JexlStatus.ArrayVal),
				JexlGrammar.GrammarType.CloseBracket => new TokenType(JexlStatus.ExpectBinOp)
			},
			JexlNamedMethod.ArrayVal
		),
		JexlStatus.TernaryMid => new State(
			new Map<JexlGrammar.GrammarType, TokenType> {
				JexlGrammar.GrammarType.Colon => new TokenType(JexlStatus.TernaryEnd)
			},
			JexlNamedMethod.TernaryMid
		),
		JexlStatus.TernaryEnd => new State(
			JexlNamedMethod.TernaryEnd,
			true
		)
	};

	public class State {

		public final Map<JexlGrammar.GrammarType, TokenType> tokenTypes { get; set; }
		public final Map<JexlGrammar.GrammarType, TokenType> endStatuses { get; set; }
		public final Boolean completable { get; set; }
		public final JexlNamedMethod subHandlerName { get; set; }

		private State(Map<JexlGrammar.GrammarType, TokenType> tokenTypes) {
			this.tokenTypes = tokenTypes;
			completable = false;
		}

		private State(Map<JexlGrammar.GrammarType, TokenType> tokenTypes, Boolean completable) {
			this.tokenTypes = tokenTypes;
			this.completable = completable;
		}

		private State(Map<JexlGrammar.GrammarType, TokenType> endStatuses, JexlNamedMethod subHandlerName) {
			this.endStatuses = endStatuses;
			this.subHandlerName = subHandlerName;
			completable = false;
		}

		private State(JexlNamedMethod subHandlerName, Boolean completable) {
			this.subHandlerName = subHandlerName;
			this.completable = completable;
		}

	}

	public class TokenType {

		public final JexlStatus toStatus { get; set; }
		public final JexlNamedMethod handler { get; set; }

		private TokenType() {
		}
		private TokenType(JexlStatus toStatus) {
			this.toStatus = toStatus;
		}
		private TokenType(JexlStatus toStatus, JexlNamedMethod handler) {
			this.toStatus = toStatus;
			this.handler = handler;
		}
	}

}