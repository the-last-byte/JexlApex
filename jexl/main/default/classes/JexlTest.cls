@IsTest
private class JexlTest {

	@IsTest
	static void coverageTest() {

		final Jexl j = new Jexl();

		Test.startTest();

		Assert.areEqual(
			123,
			j.eval('100+23')
		);

		Assert.areEqual(
			'test',
			j.eval(
				'Parent.Name',
				new Account(
					Parent = new Account(
						Name = 'test'
					)
				)
			)
		);

		Assert.areEqual(
			'yup',
			j.eval(
				'hello.world',
				(Map<String, Object>) JSON.deserializeUntyped('{"hello": {"world": "yup"}}')
			)
		);

		Test.stopTest();

	}

}