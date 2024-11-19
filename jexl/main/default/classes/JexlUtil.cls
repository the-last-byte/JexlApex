public without sharing class JexlUtil {

	public static Boolean isTruthy(Object value) {
		return !isFalsy(value);
	}

	public static Boolean isFalsy(Object value) {
		return value == null || value == 0 || value == false || value == '';
	}

}