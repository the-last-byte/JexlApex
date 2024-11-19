/*
 * Ported from original Javascript by The Last Byte Consulting.
 * Original Jexl Javascript code is Copyright 2020 Tom Shawver
 */
public enum JexlStatus {
	ExpectOperand,
	ExpectBinOp,
	ExpectTransform,
	ExpectObjKey,
	ExpectKeyValSep,
	PostTransform,
	PostArgs,
	Identifier,
	Traverse,
	Filter,
	SubExpression,
	ArgVal,
	ObjVal,
	ArrayVal,
	TernaryMid,
	TernaryEnd,
	Complete
}