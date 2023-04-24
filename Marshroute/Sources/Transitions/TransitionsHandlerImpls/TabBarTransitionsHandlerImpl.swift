import UIKit

public protocol TabBarControllerProtocol: AnyObject {
    var viewControllers: [UIViewController]? { get }
    var selectedIndex: Int { get }
}

extension UITabBarController: TabBarControllerProtocol {}

public protocol TabBarTransitionsHandler: ContainingTransitionsHandler {
    var animatingTransitionsHandlers: [Int: AnimatingTransitionsHandler]? { get set }
    var containingTransitionsHandlers: [Int: ContainingTransitionsHandler]? { get set }
}

final public class TabBarTransitionsHandlerImpl: BaseContainingTransitionsHandler, TabBarTransitionsHandler {
    private weak var tabBarController: (TabBarControllerProtocol & UIViewController)?
    
    public init(
        tabBarController: (TabBarControllerProtocol & UIViewController),
        transitionsCoordinator: TransitionsCoordinator)
    {
        self.tabBarController = tabBarController
        super.init(transitionsCoordinator: transitionsCoordinator)
    }
    
    public var animatingTransitionsHandlers: [Int: AnimatingTransitionsHandler]?
    public var containingTransitionsHandlers: [Int: ContainingTransitionsHandler]?

    // MARK: - TransitionsHandlerContainer
    override public var allTransitionsHandlers: [AnimatingTransitionsHandler]? {
        guard let tabsCount = tabBarController?.viewControllers?.count, tabsCount > 0
            else { return nil }

        return animatingTransitionsHandlers(
            fromTabIndex: 0,
            toTabIndex: tabsCount,
            unboxContainingTransitionsHandler: { (containingTransitionsHandler) -> [AnimatingTransitionsHandler]? in
                return containingTransitionsHandler.allTransitionsHandlers
            }
        )
    }
    
    override public var visibleTransitionsHandlers: [AnimatingTransitionsHandler]? {
        guard (tabBarController?.viewControllers?.count ?? 0) > 0
            else { return nil }
        guard let selectedIndex = tabBarController?.selectedIndex
            else { return nil }
        
        return animatingTransitionsHandlers(
            fromTabIndex: selectedIndex,
            toTabIndex: selectedIndex + 1,
            unboxContainingTransitionsHandler: { (containingTransitionsHandler) -> [AnimatingTransitionsHandler]? in
                // у видимого вложенного содержащего обработчика спрашиваем всех обработчиков, а не видимых
                return containingTransitionsHandler.allTransitionsHandlers
        })
    }
}

// MARK: - helpers
private extension TabBarTransitionsHandlerImpl {
    func animatingTransitionsHandlers(
        fromTabIndex: Int,
        toTabIndex: Int,
        unboxContainingTransitionsHandler: (ContainingTransitionsHandler) -> [AnimatingTransitionsHandler]?)
        -> [AnimatingTransitionsHandler]
    {
        var result = [AnimatingTransitionsHandler]()
        
        for index in fromTabIndex..<toTabIndex {
            if let animatingTransitionsHandler = animatingTransitionsHandlers?[index] {
                result.append(animatingTransitionsHandler)
            }
            
            if let containingTransitionsHandler = containingTransitionsHandlers?[index] {
                if let childAnimatingTransitionHandlers = unboxContainingTransitionsHandler(containingTransitionsHandler) {
                    result.append(contentsOf: childAnimatingTransitionHandlers)
                }
            }
        }
        
        return result
    }
}
