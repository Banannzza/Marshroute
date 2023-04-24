@testable import Marshroute

final class DummyAnimatingTransitionsHandler: BaseAnimatingTransitionsHandler {
    override func performTransition(context: PresentationTransitionContext) {}
    override func undoTransitionsAfter(transitionId: TransitionId) {}
    override func undoTransitionWith(transitionId: TransitionId) {}
    override func undoAllChainedTransitions() {}
    override func undoAllTransitions() {}
    override func resetWithTransition(context: ResettingTransitionContext) {}
    
    override func launchPresentationAnimation(launchingContextBox: inout PresentationAnimationLaunchingContextBox) {}
    override func launchDismissalAnimation(launchingContextBox: DismissalAnimationLaunchingContextBox) {}
    override func launchResettingAnimation(launchingContextBox: inout ResettingAnimationLaunchingContextBox) {}
    
    init() {
        let peekAndPopTransitionsCoordinator = PeekAndPopUtilityImpl()
        
        let coodinator = TransitionsCoordinatorImpl(
            peekAndPopTransitionsCoordinator: peekAndPopTransitionsCoordinator
        )
        
        super.init(transitionsCoordinator: coodinator)
    }
}
