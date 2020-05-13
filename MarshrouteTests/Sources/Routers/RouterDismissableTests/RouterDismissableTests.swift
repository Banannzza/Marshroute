import XCTest
@testable import Marshroute

final class RouterDismissableTests: XCTestCase
{
    var transitionId: TransitionId!
    var transitionIdGenerator: TransitionIdGenerator!
    var transitionsCoordinator: TransitionsCoordinatorImpl!
    
    var presentingTransitionsHandlerSpy: AnimatingTransitionsHandlerSpy!
    
    override func setUp() {
        super.setUp()
        
        transitionIdGenerator = TransitionIdGeneratorImpl()
        transitionId = transitionIdGenerator.generateNewTransitionId()
        
        transitionsCoordinator = TransitionsCoordinatorImpl(
            stackClientProvider: TransitionContextsStackClientProviderImpl(),
            peekAndPopTransitionsCoordinator: PeekAndPopUtilityImpl()
        )
        
        presentingTransitionsHandlerSpy = AnimatingTransitionsHandlerSpy(
            transitionsCoordinator: transitionsCoordinator
        )
    }
    
    // MARK: - BaseRouter
    
    func testThatNotRootRouterCallsItsPresentingTransitionsHandlerOn_DismissCurrentModule() {
        // Given
        let router = BaseRouter( // Base Router
            routerSeed: RouterSeed(
                transitionsHandlerBox: .init(
                    animatingTransitionsHandler: AnimatingTransitionsHandlerSpy(
                        transitionsCoordinator: transitionsCoordinator
                    )
                ),
                transitionId: transitionId,
                presentingTransitionsHandler: presentingTransitionsHandlerSpy, // Not Root Router
                transitionsHandlersProvider: transitionsCoordinator,
                transitionIdGenerator: transitionIdGenerator,
                controllersProvider: RouterControllersProviderImpl(),
                routerTransitionDelegate: nil
            )
        )
        
        // When
        router.dismissCurrentModule()
        
        // Then
        XCTAssert(router.presentingTransitionsHandler === presentingTransitionsHandlerSpy)
        
        XCTAssert(presentingTransitionsHandlerSpy.undoTransitionWithCalled)
        XCTAssertEqual(presentingTransitionsHandlerSpy.undoTransitionWithTransitionIdParameter, transitionId)
    }
    
    func testThatRootRouterDoesNotCallItsPresentingTransitionsHandlerOn_DismissCurrentModule() {
        // Given
        let router = BaseRouter( // Base Router
            routerSeed: RouterSeed(
                transitionsHandlerBox: .init(
                    animatingTransitionsHandler: AnimatingTransitionsHandlerSpy(
                        transitionsCoordinator: transitionsCoordinator
                    )
                ),
                transitionId: transitionId,
                presentingTransitionsHandler: nil, // Root Router
                transitionsHandlersProvider: transitionsCoordinator,
                transitionIdGenerator: transitionIdGenerator,
                controllersProvider: RouterControllersProviderImpl(),
                routerTransitionDelegate: nil
            )
        )
        
        // When
        router.dismissCurrentModule()
        
        // Then
        XCTAssertNil(router.presentingTransitionsHandler)
        
        XCTAssertFalse(presentingTransitionsHandlerSpy.undoTransitionWithCalled)
    }
    
    // MARK: - BaseMasterDetailRouter
    
    func testThatNotRootMasterDetailRouterCallsItsPresentingTransitionsHandlerOn_DismissCurrentModule() {
        // Given
        let masterDetailRouter = BaseMasterDetailRouter( // MasterDetail Router
            routerSeed: MasterDetailRouterSeed(
                masterTransitionsHandlerBox: .init(
                    animatingTransitionsHandler: AnimatingTransitionsHandlerSpy(
                        transitionsCoordinator: transitionsCoordinator
                    )
                ),
                detailTransitionsHandlerBox: .init(
                    animatingTransitionsHandler: AnimatingTransitionsHandlerSpy(
                        transitionsCoordinator: transitionsCoordinator
                    )
                ),
                transitionId: transitionId,
                presentingTransitionsHandler: presentingTransitionsHandlerSpy, // Not Root Router
                transitionsHandlersProvider: transitionsCoordinator,
                transitionIdGenerator: transitionIdGenerator,
                controllersProvider: RouterControllersProviderImpl(),
                routerTransitionDelegate: nil
            )
        )
        
        // When
        masterDetailRouter.dismissCurrentModule()
        
        // Then
        XCTAssert(masterDetailRouter.presentingTransitionsHandler === presentingTransitionsHandlerSpy)
        
        XCTAssert(presentingTransitionsHandlerSpy.undoTransitionWithCalled)
        XCTAssertEqual(presentingTransitionsHandlerSpy.undoTransitionWithTransitionIdParameter, transitionId)
    }
    
    func testThatRootMasterDetailRouterDoesNotCallItsPresentingTransitionsHandlerOn_DismissCurrentModule() {
        // Given
        let masterDetailRouter = BaseMasterDetailRouter( // MasterDetail Router
            routerSeed: MasterDetailRouterSeed(
                masterTransitionsHandlerBox: .init(
                    animatingTransitionsHandler: AnimatingTransitionsHandlerSpy(
                        transitionsCoordinator: transitionsCoordinator
                    )
                ),
                detailTransitionsHandlerBox: .init(
                    animatingTransitionsHandler: AnimatingTransitionsHandlerSpy(
                        transitionsCoordinator: transitionsCoordinator
                    )
                ),
                transitionId: transitionId,
                presentingTransitionsHandler: nil, // Root Router
                transitionsHandlersProvider: transitionsCoordinator,
                transitionIdGenerator: transitionIdGenerator,
                controllersProvider: RouterControllersProviderImpl(),
                routerTransitionDelegate: nil
            )
        )
        
        // When
        masterDetailRouter.dismissCurrentModule()
        
        // Then
        XCTAssertNil(masterDetailRouter.presentingTransitionsHandler)
        
        XCTAssertFalse(presentingTransitionsHandlerSpy.undoTransitionWithCalled)
    }
}
