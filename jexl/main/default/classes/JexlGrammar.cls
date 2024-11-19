/*
 * Ported from original Javascript by The Last Byte Consulting.
 * Original Jexl Javascript code is Copyright 2020 Tom Shawver
 */
public without sharing class JexlGrammar {

	public enum GrammarType {
		//Defined as standard grammar
		Dot,
		OpenBracket,
		CloseBracket,
		Pipe,
		OpenCurl,
		CloseCurl,
		Colon,
		Comma,
		OpenParen,
		CloseParen,
		Question,
		BinaryOp,
		UnaryOp,
		//Special Types
		Literal,
		Identifier
	}

	private static final Map<String, IGrammar> DefaultElements = new Map<String, IGrammar> {
		'.' => new Grammar(GrammarType.Dot),
		'[' => new Grammar(GrammarType.OpenBracket),
		']' => new Grammar(GrammarType.CloseBracket),
		'|' => new Grammar(GrammarType.Pipe),
		'{' => new Grammar(GrammarType.OpenCurl),
		'}' => new Grammar(GrammarType.CloseCurl),
		':' => new Grammar(GrammarType.Colon),
		',' => new Grammar(GrammarType.Comma),
		'(' => new Grammar(GrammarType.OpenParen),
		')' => new Grammar(GrammarType.CloseParen),
		'?' => new Grammar(GrammarType.Question),
		'+' => new OperatorPlus(30),
		'-' => new OperatorMinus(30),
		'*' => new OperatorMultiply(40),
		'/' => new OperatorDivide(40),
		'//' => new OperatorDivideFlr(40),
		'%' => new OperatorModulus(50),
		'^' => new OperatorExponent(50),
		'==' => new OperatorEquals(20),
		'!=' => new OperatorNotEquals(20),
		'>' => new OperatorGreaterThan(20),
		'>=' => new OperatorGreaterThanEquals(20),
		'<' => new OperatorLessThan(20),
		'<=' => new OperatorLessThanEquals(20),
		'&&' => new OperatorAnd(10),
		'||' => new OperatorOr(10),
		'in' => new OperatorIn(20),
		'!' => new OperatorNot(100)
	};

	public interface IGrammar {
		GrammarType getType();
		Integer getPrecedence();
		Boolean isOnDemand();
	}

	public interface IGrammarEval extends IGrammar {
		Object eval(Object left, Object right);
	}

	public interface IGrammarUnaryEval extends IGrammar {
		Object eval(Object right);
	}

	public interface IGrammarEvalOnDemand extends IGrammar {
		Object evalOnDemand(Object left, Object right);
	}

	public virtual class Grammar implements IGrammar {
		private final GrammarType type { get; set; }
		private final Integer precedence { get; set; }
		private final Boolean onDemand { get; set; }

		private Grammar(GrammarType type, Integer precedence) {
			this.type = type;
			this.precedence = precedence;
			onDemand = false;
		}

		private Grammar(GrammarType type) {
			this.type = type;
			precedence = 0;
			onDemand = false;
		}

		public GrammarType getType() {
			return type;
		}

		public Integer getPrecedence() {
			return precedence;
		}
		public Boolean isOnDemand() {
			return onDemand;
		}
	}

	public class OperatorPlus extends Grammar implements IGrammarEval {

		@TestVisible
		private OperatorPlus(Integer precedence) {
			super(GrammarType.BinaryOp, precedence);
		}

		public Object eval(Object left, Object right) {
			if (areIntegers(left, right)) {
				return (Integer) left + (Integer) right;
			}
			if (areLongs(left, right)) {
				return (Long) left + (Long) right;
			}
			if (areDoubles(left, right)) {
				return (Double) left + (Double) right;
			}
			if (areStrings(left, right) || left instanceof String) {
				return (String) left + String.valueOf(right);
			}
			throw new JexlException('Expected two strings or numbers for addition expression, got: ' + String.valueOf(left) + ', ' + String.valueOf(right));
		}
	}

	public class OperatorMinus extends Grammar implements IGrammarEval {

		@TestVisible
		private OperatorMinus(Integer precedence) {
			super(GrammarType.BinaryOp, precedence);
		}

		public Object eval(Object left, Object right) {
			if (areIntegers(left, right)) {
				return (Integer) left - (Integer) right;
			}
			if (areLongs(left, right)) {
				return (Long) left - (Long) right;
			}
			if (areDoubles(left, right)) {
				return (Double) left - (Double) right;
			}
			throw new JexlException('Expected two numbers for minus expression');
		}
	}

	public class OperatorMultiply extends Grammar implements IGrammarEval {

		@TestVisible
		private OperatorMultiply(Integer precedence) {
			super(GrammarType.BinaryOp, precedence);
		}

		public Object eval(Object left, Object right) {
			if (areIntegers(left, right)) {
				return (Integer) left * (Integer) right;
			}
			if (areLongs(left, right)) {
				return (Long) left * (Long) right;
			}
			if (areDoubles(left, right)) {
				return (Double) left * (Double) right;
			}
			throw new JexlException('Expected two numbers for multiply expression');
		}
	}

	public class OperatorDivide extends Grammar implements IGrammarEval {

		@TestVisible
		private OperatorDivide(Integer precedence) {
			super(GrammarType.BinaryOp, precedence);
		}

		public Object eval(Object left, Object right) {
			if (areIntegers(left, right)) {
				return (Integer) left / (Integer) right;
			}
			if (areLongs(left, right)) {
				return (Long) left / (Long) right;
			}
			if (areDoubles(left, right)) {
				return (Double) left / (Double) right;
			}
			throw new JexlException('Expected two numbers for divide expression');
		}
	}

	public class OperatorDivideFlr extends Grammar implements IGrammarEval {

		@TestVisible
		private OperatorDivideFlr(Integer precedence) {
			super(GrammarType.BinaryOp, precedence);
		}

		public Object eval(Object left, Object right) {
			if (areIntegers(left, right)) {
				return Math.floor((Integer) left / (Integer) right);
			}
			if (areLongs(left, right)) {
				return Math.floor((Long) left / (Long) right);
			}
			if (areDoubles(left, right)) {
				return Math.floor((Double) left / (Double) right);
			}
			throw new JexlException('Expected two numbers for divide expression');
		}
	}

	public class OperatorModulus extends Grammar implements IGrammarEval {

		@TestVisible
		private OperatorModulus(Integer precedence) {
			super(GrammarType.BinaryOp, precedence);
		}

		public Object eval(Object left, Object right) {
			if (areIntegers(left, right)) {
				return Math.mod((Integer) left, (Integer) right);
			}
			if (areLongs(left, right)) {
				return Math.mod((Long) left, (Long) right);
			}
			throw new JexlException('Expected two integers for modulus expression');
		}
	}

	public class OperatorExponent extends Grammar implements IGrammarEval {

		@TestVisible
		private OperatorExponent(Integer precedence) {
			super(GrammarType.BinaryOp, precedence);
		}

		public Object eval(Object left, Object right) {
			if (areDoubles(left, right)) {
				return Math.pow((Double) left, (Double) right);
			}
			throw new JexlException('Expected two numbers for exp expression');
		}
	}

	public class OperatorEquals extends Grammar implements IGrammarEval {

		@TestVisible
		private OperatorEquals(Integer precedence) {
			super(GrammarType.BinaryOp, precedence);
		}

		public Object eval(Object left, Object right) {
			return left == right;
		}
	}

	public class OperatorNotEquals extends Grammar implements IGrammarEval {

		@TestVisible
		private OperatorNotEquals(Integer precedence) {
			super(GrammarType.BinaryOp, precedence);
		}

		public Object eval(Object left, Object right) {
			return left != right;
		}
	}

	public class OperatorGreaterThan extends Grammar implements IGrammarEval {

		@TestVisible
		private OperatorGreaterThan(Integer precedence) {
			super(GrammarType.BinaryOp, precedence);
		}

		public Object eval(Object left, Object right) {
			if (areDoubles(left, right)) {
				return (Double) left > (Double) right;
			}
			if (areStrings(left, right)) {
				return (String) left > (String) right;
			}
			throw new JexlException('Expected two numbers or strings for greater than expression');
		}
	}

	public class OperatorGreaterThanEquals extends Grammar implements IGrammarEval {

		@TestVisible
		private OperatorGreaterThanEquals(Integer precedence) {
			super(GrammarType.BinaryOp, precedence);
		}

		public Object eval(Object left, Object right) {
			if (areDoubles(left, right)) {
				return (Double) left >= (Double) right;
			}
			if (areStrings(left, right)) {
				return (String) left >= (String) right;
			}
			throw new JexlException('Expected two numbers or strings for greater than expression');
		}
	}

	public class OperatorLessThan extends Grammar implements IGrammarEval {

		@TestVisible
		private OperatorLessThan(Integer precedence) {
			super(GrammarType.BinaryOp, precedence);
		}

		public Object eval(Object left, Object right) {
			if (areDoubles(left, right)) {
				return (Double) left < (Double) right;
			}
			if (areStrings(left, right)) {
				return (String) left < (String) right;
			}
			throw new JexlException('Expected two numbers or strings for less than expression');
		}
	}

	public class OperatorLessThanEquals extends Grammar implements IGrammarEval {

		@TestVisible
		private OperatorLessThanEquals(Integer precedence) {
			super(GrammarType.BinaryOp, precedence);
		}

		public Object eval(Object left, Object right) {
			if (areDoubles(left, right)) {
				return (Double) left <= (Double) right;
			}
			if (areStrings(left, right)) {
				return (String) left <= (String) right;
			}
			throw new JexlException('Expected two numbers or strings for less than expression');
		}
	}

	public class OperatorAnd extends Grammar implements IGrammarEval {

		@TestVisible
		private OperatorAnd(Integer precedence) {
			super(GrammarType.BinaryOp, precedence);
		}

		public Object eval(Object left, Object right) {
			return JexlUtil.isTruthy(left) && JexlUtil.isTruthy(right);
		}
	}

	public class OperatorOr extends Grammar implements IGrammarEval {

		@TestVisible
		private OperatorOr(Integer precedence) {
			super(GrammarType.BinaryOp, precedence);
		}

		public Object eval(Object left, Object right) {
			return JexlUtil.isTruthy(left) || JexlUtil.isTruthy(right);
		}
	}

	public class OperatorIn extends Grammar implements IGrammarEval {

		@TestVisible
		private OperatorIn(Integer precedence) {
			super(GrammarType.BinaryOp, precedence);
		}

		public Object eval(Object left, Object right) {
			if (right instanceof List<Object>) {
				return ((List<Object>) right).contains(left);
			}
			if (right instanceof String) {
				return ((String) right).contains(String.valueOf(left));
			}
			throw new JexlException('Expected two strings or an array for "in" expression');
		}
	}

	public class OperatorNot extends Grammar implements IGrammarUnaryEval {

		@TestVisible
		private OperatorNot(Integer precedence) {
			super(GrammarType.UnaryOp, precedence);
		}

		public Object eval(Object right) {
			if (right instanceof Boolean) {
				return right != true;
			}
			return JexlUtil.isFalsy(right);
		}
	}

	private static Boolean areIntegers(Object left, Object right) {
		return (left instanceof Integer && right instanceof Integer);
	}

	private static Boolean areLongs(Object left, Object right) {
		return left instanceof Long && right instanceof Long;
	}

	private static Boolean areDoubles(Object left, Object right) {
		return (
			left instanceof Integer ||
				left instanceof Decimal ||
				left instanceof Double
		) && (
			right instanceof Integer ||
				right instanceof Decimal ||
				right instanceof Double
		);
	}

	private static Boolean areStrings(Object left, Object right) {
		return left instanceof String && right instanceof String;
	}

	public final Map<String, IGrammar> elements;

	public JexlGrammar() {
		elements = DefaultElements;
	}

}