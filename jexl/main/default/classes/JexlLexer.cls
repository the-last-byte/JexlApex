/*
 * Ported from original Javascript by The Last Byte Consulting.
 * Original Jexl Javascript code is Copyright 2020 Tom Shawver
 */
public with sharing class JexlLexer {

	private static final String Regex_IdentifierCheck = '^[a-zA-Zа-яА-Я_\\u00C0-\\u00D6\\u00D8-\\u00F6\\u00F8-\\u00FF$][a-zA-Zа-яА-Я0-9_\\u00C0-\\u00D6\\u00D8-\\u00F6\\u00F8-\\u00FF$]*$';
	private static final String Regex_EscapeStringItems = '[.*+?^${}()|\\[\\]\\\\]';
	private static final String Regex_EscapeEscape = '\\\\\\\\';
	private static final String Regex_Numeric = '^-?(?:(?:[0-9]*\\.[0-9]+)|[0-9]+)$';

	private static final List<String> Regex_PreOperationElements = new List<String> {
		//Strings
		'\'(?:(?:\\\\\\\\\')|[^\'])*\'',
		'"(?:(?:\\\\\\\\")|[^"])*"',
		//Whitespace
		'\\\\s+',
		//Boolean
		'\\\\btrue\\\\b',
		'\\\\bfalse\\\\b'
	};

	private static final List<String> Regex_PostOperationElements = new List<String> {
		//Identifiers
		'[a-zA-Zа-яА-Я_\\u00C0-\\u00D6\\u00D8-\\u00F6\\u00F8-\\u00FF\\\\$][a-zA-Z0-9а-яА-Я_\\u00C0-\\u00D6\\u00D8-\\u00F6\\u00F8-\\u00FF\\\\$]*',
		//Numerics (w/o negative symbol)
		'(?:(?:[0-9]*\\\\.[0-9]+)|[0-9]+)'
	};

	private static final Set<JexlGrammar.GrammarType> NegativeValueMayFollow = new Set<JexlGrammar.GrammarType> {
		JexlGrammar.GrammarType.BinaryOp,
		JexlGrammar.GrammarType.UnaryOp,
		JexlGrammar.GrammarType.OpenParen,
		JexlGrammar.GrammarType.OpenBracket,
		JexlGrammar.GrammarType.Question,
		JexlGrammar.GrammarType.Colon
	};

	private static final Pattern Pattern_IdentifierCheck {
		get {
			if (Pattern_IdentifierCheck == null) {
				Pattern_IdentifierCheck = Pattern.compile(Regex_IdentifierCheck);
			}
			return Pattern_IdentifierCheck;
		}
		set;
	}

	private static final Pattern Pattern_EscapeStringItems {
		get {
			if (Pattern_EscapeStringItems == null) {
				Pattern_EscapeStringItems = Pattern.compile(Regex_EscapeStringItems);
			}
			return Pattern_EscapeStringItems;
		}
		set;
	}

	private static final Pattern Pattern_EscapeEscape {
		get {
			if (Pattern_EscapeEscape == null) {
				Pattern_EscapeEscape = Pattern.compile(Regex_EscapeEscape);
			}
			return Pattern_EscapeEscape;
		}
		set;
	}

	private static final Pattern Pattern_Numeric {
		get {
			if (Pattern_Numeric == null) {
				Pattern_Numeric = Pattern.compile(Regex_Numeric);
			}
			return Pattern_Numeric;
		}
		set;
	}

	private final JexlGrammar grammar { get; set; }

	private final Pattern splitRegexPattern {
		get {
			if (splitRegexPattern == null) {
				splitRegexPattern = buildSplitRegex(grammar);
			}
			return splitRegexPattern;
		}
		set;
	}

	public JexlLexer(JexlGrammar grammar) {
		this.grammar = grammar;
	}

	@TestVisible
	private static Boolean hasIdentifierMatch(String expression) {
		return Pattern_IdentifierCheck.matcher(expression).matches();
	}

	public List<String> getElements(String expression) {
		final List<String> elements = new List<String>();
		final Matcher matcher = splitRegexPattern.matcher(expression);
		Integer lastEndIndex;
		while (matcher.find()) {
			final Integer groupCount = matcher.groupCount() + 1; // 0 is the full match
			for (Integer i = 1; i < groupCount; i++) {
				final String match = matcher.group(i);
				//Ignore any empty matches
				if (match.length() != 0) {
					//Collect any whitespace from the previous match
					if (lastEndIndex != null && lastEndIndex != matcher.start()) {
						elements.add(expression.substring(lastEndIndex, matcher.start()));
					}
					lastEndIndex = matcher.end();
					elements.add(match);
				}
			}
		}
		return elements;
	}

	public List<Token> getTokens(List<String> elements) {
		final List<Token> tokens = new List<Token>();
		Boolean negate = false;
		for (Integer i = 0; i < elements.size(); i++) {
			String element = elements[i];
			//Append whitespace to the previous element
			if (element != '' && String.isBlank(element)) {
				if (!tokens.isEmpty()) {
					tokens[tokens.size() - 1].raw += element;
				}
			}
			//Handle negatives
			else if (element == '-' && isNegative(tokens)) {
				negate = true;
			}
			//Handle everything else
			else {
				if (negate) {
					element = '-' + element;
					elements[i] = element;
					negate = false;
				}
				tokens.add(new Token(grammar, element));
			}
		}
		//Handle a trailing negative
		if (negate) {
			tokens.add(new Token(grammar, '-'));
		}
		return tokens;
	}

	public List<Token> tokenize(String expression) {
		return getTokens(getElements(expression));
	}

	private static Pattern buildSplitRegex(JexlGrammar grammar) {
		//Extract grammar element strings
		final List<String> elements = new List<String>(grammar.elements.keySet());
		//Sort from shortest to longest names
		elements.sort(new SortByStringLengthHandler());
		//Escape the elements for Regex
		for (Integer i = 0; i < elements.size(); i++) {
			elements[i] = escapeRegexStringLiteral(elements[i]);
		}
		return Pattern.compile(
			'(' +
				String.join(
					new List<String> {
						String.join(Regex_PreOperationElements, '|'),
						String.join(elements, '|'),
						String.join(Regex_PostOperationElements, '|')
					},
					'|'
				) +
				')'
		);
	}

	@TestVisible
	private static String escapeRegexStringLiteral(String s) {
		//In this replacement, `$0` matches the whole capture group, equivalent to `$&` in Javascript
		s = Pattern_EscapeStringItems.matcher(s).replaceAll('\\\\$0');
		if (hasIdentifierMatch(s)) {
			return '\\b' + s + '\\b';
		}
		return s;
	}

	@TestVisible
	private static String unquoteString(String s) {
		final String quoteValue = s.left(0);
		return Pattern_EscapeEscape.matcher(
			s.substring(1, s.length() - 1)
				.replaceAll('\\\\' + quoteValue, quoteValue)
		).replaceAll('\\');
	}

	private static Boolean isNegative(List<Token> tokens) {
		if (tokens.isEmpty()) {
			return true;
		}
		return NegativeValueMayFollow.contains(
			tokens[tokens.size() - 1].type
		);
	}

	@TestVisible
	private class SortByStringLengthHandler implements Comparator<String> {

		public Integer compare(String param1, String param2) {
			if (param1.length() == param2.length()) {
				return param1.compareTo(param2);
			}
			return param1.length() < param2.length()
				? 1
				: -1;
		}

	}

	public class Token {

		public final JexlGrammar.GrammarType type { get; set; }
		public final Object value { get; set; }
		public String raw { get; set; }

		@TestVisible
		private Token(JexlGrammar grammar, String element) {
			raw = element;
			if (element.startsWith('"') || element.startsWith('\'')) {
				value = unquoteString(element);
				type = JexlGrammar.GrammarType.Literal;
			} else if (Pattern_Numeric.matcher(element).matches()) {
				value = JSON.deserializeUntyped(element);
				type = JexlGrammar.GrammarType.Literal;
			} else if (element == 'true' || element == 'false') {
				value = element == 'true';
				type = JexlGrammar.GrammarType.Literal;
			} else {
				value = element;
				final JexlGrammar.GrammarType matchingType = grammar.elements.get(element)?.getType();
				if (matchingType != null) {
					type = matchingType;
				} else if (Pattern_IdentifierCheck.matcher(element).matches()) {
					type = JexlGrammar.GrammarType.Identifier;
				} else {
					//Keep the IDE happy
					type = null;
					throw new JexlException('Invalid expression token: ' + element);
				}
			}
		}
	}

}