public final class MarshrouteAssertionManager {
    public private(set) static var instance: MarshrouteAssertionPlugin = DefaultMarshrouteAssertionPlugin()
    
    public static func setUpAssertionPlugin(_ plugin: MarshrouteAssertionPlugin) {
        instance = plugin
    }
    
    static func assert(
        _ condition: @autoclosure () -> Bool,
        _ message: @autoclosure () -> String,
        fileId: StaticString,
        line: UInt)
    {
        instance.assert(condition(), message(), fileId: fileId, line: line)
    }
    
    static func assertionFailure(
        _ message: @autoclosure () -> String,
        fileId: StaticString,
        line: UInt)
    {
        instance.assertionFailure(message(), fileId: fileId, line: line)
    }
}
