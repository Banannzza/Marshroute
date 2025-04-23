public protocol MarshrouteAssertionPlugin: AnyObject {
    func assert(
        _ condition: @autoclosure () -> Bool,
        _ message: @autoclosure () -> String,
        fileId: StaticString,
        line: UInt)
    
    func assertionFailure(
        _ message: @autoclosure () -> String,
        fileId: StaticString,
        line: UInt)
}

public final class DefaultMarshrouteAssertionPlugin: MarshrouteAssertionPlugin {
    public init() {}
    
    public func assert(
        _ condition: @autoclosure () -> Bool,
        _ message: @autoclosure () -> String,
        fileId: StaticString,
        line: UInt)
    {
        if !condition() {
            Swift.print("\(message()), fileId: \(fileId), line: \(line)")
        }
    }
    
    public func assertionFailure(
        _ message: @autoclosure () -> String,
        fileId: StaticString,
        line: UInt)
    {
        Swift.print("\(message()), fileId: \(fileId), line: \(line)")
    }
}
