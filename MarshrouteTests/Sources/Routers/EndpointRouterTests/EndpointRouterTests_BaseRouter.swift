import XCTest
@testable import Marshroute

final class EndpointRouterTests_BaseRouter: XCTestCase
{
    var detailAnimatingTransitionsHandlerSpy: AnimatingTransitionsHandlerSpy!
    var router: EndpointRouter!
    
    override func setUp() {
        super.setUp()
        
        let transitionIdGenerator = TransitionIdGeneratorImpl()
        
        let peekAndPopTransitionsCoordinator = PeekAndPopUtilityImpl()
        
        let transitionsCoordinator = TransitionsCoordinatorImpl(
            stackClientProvider: TransitionContextsStackClientProviderImpl(),
            peekAndPopTransitionsCoordinator: peekAndPopTransitionsCoordinator
        )
        
        detailAnimatingTransitionsHandlerSpy = AnimatingTransitionsHandlerSpy(
            transitionsCoordinator: transitionsCoordinator
        )
        
        router = BaseRouter(
            routerSeed: RouterSeed(
                transitionsHandlerBox: .init(
                    animatingTransitionsHandler: detailAnimatingTransitionsHandlerSpy
                ),
                transitionId: transitionIdGenerator.generateNewTransitionId(),
                presentingTransitionsHandler: nil,
                transitionsHandlersProvider: transitionsCoordinator,
                transitionIdGenerator: transitionIdGenerator,
                controllersProvider: RouterControllersProviderImpl(),
                routerTransitionDelegate: nil
            )
        )
    }
    
    func testThatRouterCallsItsTransitionsHandlerOn_PresentModalEndpointNavigationController_WithCorrectPresentationContext() {
        // Given
        let targetNavigationController = UINavigationController()
        var nextModuleRouterSeed: RouterSeed!
        
        // When
        router.presentModalEndpointNavigationController(targetNavigationController) { (routerSeed) in
            nextModuleRouterSeed = routerSeed
        }
        
        // Then
        XCTAssert(detailAnimatingTransitionsHandlerSpy.performTransitionCalled)
        
        let presentationContext = detailAnimatingTransitionsHandlerSpy.perFormTransitionContextParameter
        XCTAssertEqual(presentationContext?.transitionId, nextModuleRouterSeed.transitionId)
        XCTAssert(presentationContext?.targetViewController === targetNavigationController)
        if case .some(.animating) = presentationContext?.targetTransitionsHandlerBox {} else { XCTFail() }
        XCTAssert(presentationContext?.storableParameters! is NavigationTransitionStorableParameters)
        if case .some(.modalEndpointNavigation(let launchingContext)) = presentationContext?.presentationAnimationLaunchingContextBox {
            XCTAssert(launchingContext.targetNavigationController! == targetNavigationController)
        } else { XCTFail() }
    }
    
    func testThatRouterCallsItsTransitionsHandlerOn_PresentModalEndpointNavigationController_WithCorrectPresentationContext_IfCustomAnimator() {
        // Given
        let targetNavigationController = UINavigationController()
        var nextModuleRouterSeed: RouterSeed!
        let modalEndpointNavigationTransitionsAnimator = ModalEndpointNavigationTransitionsAnimator()
        
        // When
        router.presentModalEndpointNavigationController(
            targetNavigationController,
            animator: modalEndpointNavigationTransitionsAnimator) { (routerSeed) in
                nextModuleRouterSeed = routerSeed
        }
        
        // Then
        XCTAssert(detailAnimatingTransitionsHandlerSpy.performTransitionCalled)
        
        let presentationContext = detailAnimatingTransitionsHandlerSpy.perFormTransitionContextParameter
        XCTAssertEqual(presentationContext?.transitionId, nextModuleRouterSeed.transitionId)
        XCTAssert(presentationContext?.targetViewController === targetNavigationController)
        if case .some(.animating) = presentationContext?.targetTransitionsHandlerBox {} else { XCTFail() }
        XCTAssert(presentationContext?.storableParameters! is NavigationTransitionStorableParameters)
        if case .some(.modalEndpointNavigation(let launchingContext)) = presentationContext?.presentationAnimationLaunchingContextBox {
            XCTAssert(launchingContext.animator === modalEndpointNavigationTransitionsAnimator)
            XCTAssert(launchingContext.targetNavigationController! === targetNavigationController)
        } else { XCTFail() }
    }
}
