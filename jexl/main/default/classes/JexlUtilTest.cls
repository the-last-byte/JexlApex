@IsTest
private without sharing class JexlUtilTest {

	@IsTest
	static void isTruthy_Test() {

		Test.startTest();

		Assert.areEqual(false, JexlUtil.isTruthy(null));
		Assert.areEqual(false, JexlUtil.isTruthy(0));
		Assert.areEqual(false, JexlUtil.isTruthy(''));
		Assert.areEqual(false, JexlUtil.isTruthy(false));

		Assert.areEqual(true, JexlUtil.isTruthy(new User()));
		Assert.areEqual(true, JexlUtil.isTruthy(99));
		Assert.areEqual(true, JexlUtil.isTruthy(' '));
		Assert.areEqual(true, JexlUtil.isTruthy(true));

		Test.stopTest();

	}

	@IsTest
	static void isFalsy_Test() {

		Test.startTest();

		Assert.areEqual(true, JexlUtil.isFalsy(null));
		Assert.areEqual(true, JexlUtil.isFalsy(0));
		Assert.areEqual(true, JexlUtil.isFalsy(''));
		Assert.areEqual(true, JexlUtil.isFalsy(false));

		Assert.areEqual(false, JexlUtil.isFalsy(new User()));
		Assert.areEqual(false, JexlUtil.isFalsy(99));
		Assert.areEqual(false, JexlUtil.isFalsy(' '));
		Assert.areEqual(false, JexlUtil.isFalsy(true));

		Test.stopTest();

	}

}