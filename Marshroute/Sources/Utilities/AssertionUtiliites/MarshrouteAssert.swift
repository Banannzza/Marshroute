func marshrouteAssert(
    _ condition: @autoclosure () -> Bool,
    _ message: @autoclosure () -> String = "",
    fileId: StaticString = #fileID,
    line: UInt = #line)
{
    MarshrouteAssertionManager.assert(condition(), message(), fileId: fileId, line: line)
}

func marshrouteAssertionFailure(
    _ message: @autoclosure () -> String = "",
    fileId: StaticString = #fileID,
    line: UInt = #line)
{
    MarshrouteAssertionManager.assertionFailure(message(), fileId: fileId, line: line)
}
