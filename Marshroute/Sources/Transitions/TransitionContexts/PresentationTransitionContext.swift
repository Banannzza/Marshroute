import UIKit

/// Описание перехода `вперед` на следующий модуль (смотри init'ы для более полного описания)
public struct PresentationTransitionContext {
    /// идентификатор перехода
    /// для точной отмены нужного перехода и возвращения на предыдущий экран через
    /// ```swift
    /// undoTransitionWith(transitionId:)
    public let transitionId: TransitionId
    
    /// контроллер, на который нужно перейти
    public let targetViewController: UIViewController
    
    /// обработчик переходов для модуля, на который нужно перейти
    /// (может отличаться от обработчика переходов, ответственного за выполнение текущего перехода)
    public private(set) var targetTransitionsHandlerBox: PresentationTransitionTargetTransitionsHandlerBox
    
    /// параметры перехода, на которые нужно держать сильную ссылку (например, обработчик переходов SplitViewController'а)
    public let storableParameters: TransitionStorableParameters?

    /// параметры запуска анимации прямого перехода
    public var presentationAnimationLaunchingContextBox: PresentationAnimationLaunchingContextBox
}

// MARK: - Init
public extension PresentationTransitionContext {
    // MARK: - Push
    
    /// Контекст описывает последовательный переход внутри UINavigationController'а
    /// если UINavigationController'а не является самым верхним, то переход будет прокинут
    /// в самый верхний UINavigationController
    init(
        pushingViewController targetViewController: UIViewController,
        animator: NavigationTransitionsAnimator,
        transitionId: TransitionId)
    {
        self.transitionId = transitionId
        self.targetViewController = targetViewController
        self.targetTransitionsHandlerBox = .pendingAnimating
       
        self.storableParameters = nil
        
        let animationLaunchingContext = PushAnimationLaunchingContext(
            targetViewController: targetViewController,
            animator: animator
        )
        
        self.presentationAnimationLaunchingContextBox = .push(
            launchingContext: animationLaunchingContext
        )
    }
    
    // MARK: - Modal
    
    /// Контекст описывает переход на простой модальный контроллер
    init(
        presentingModalViewController targetViewController: UIViewController,
        targetTransitionsHandler: AnimatingTransitionsHandler,
        animator: ModalTransitionsAnimator,
        transitionId: TransitionId)
    {
        marshrouteAssert(
            !(targetViewController is UISplitViewController) && !(targetViewController is UITabBarController),
            "use presentingModalMasterDetailViewController:targetTransitionsHandler:animator:transitionId:"
        )
        
        marshrouteAssert(
            !(targetViewController is UINavigationController),
            "use presentingModalNavigationController:targetTransitionsHandler:animator:transitionId:"
        )
        
        self.transitionId = transitionId
        self.targetViewController = targetViewController
        self.targetTransitionsHandlerBox = .init(animatingTransitionsHandler: targetTransitionsHandler)
        
        self.storableParameters = NavigationTransitionStorableParameters(
            presentedTransitionsHandler: targetTransitionsHandler
        )
        
        let animationLaunchingContext = ModalPresentationAnimationLaunchingContext(
            targetViewController: targetViewController,
            animator: animator
        )
        
        self.presentationAnimationLaunchingContextBox = .modal(
            launchingContext: animationLaunchingContext
        )
    }
    
    /// Контекст описывает переход на модальный контроллер, который нельзя! положить в UINavigationController:
    /// UISplitViewController
    init(
        presentingModalMasterDetailViewController targetViewController: SplitViewControllerProtocol & UIViewController,
        targetTransitionsHandler splitViewTransitionsHandler: SplitViewTransitionsHandler,
        animator: ModalMasterDetailTransitionsAnimator,
        transitionId: TransitionId)
    {
        self.transitionId = transitionId
        self.targetViewController = targetViewController
        self.targetTransitionsHandlerBox = .init(containingTransitionsHandler: splitViewTransitionsHandler)
        
        self.storableParameters = NavigationTransitionStorableParameters(
            presentedTransitionsHandler: splitViewTransitionsHandler
        )
        
        let animationLaunchingContext = ModalMasterDetailPresentationAnimationLaunchingContext(
            targetViewController: targetViewController,
            animator: animator
        )
        
        self.presentationAnimationLaunchingContextBox = .modalMasterDetail(
            launchingContext: animationLaunchingContext
        )
    }
    
    /// Контекст описывает переход на модальный контроллер, который положен в UINavigationController
    init(
        presentingModalViewController targetViewController: UIViewController,
        inNavigationController navigationController: UINavigationController,
        targetTransitionsHandler navigationTransitionsHandler: NavigationTransitionsHandler,
        animator: ModalNavigationTransitionsAnimator,
        transitionId: TransitionId)
    {
        marshrouteAssert(
            !(targetViewController is UISplitViewController)
            && !(targetViewController is SplitViewControllerProtocol)
            && !(targetViewController is UITabBarController)
            && !(targetViewController is TabBarControllerProtocol),
            "use presentingModalMasterDetailViewController:targetTransitionsHandler:animator:transitionId:"
        )
        
        self.transitionId = transitionId
        self.targetViewController = targetViewController
        self.targetTransitionsHandlerBox = .init(animatingTransitionsHandler: navigationTransitionsHandler)
        
        self.storableParameters = NavigationTransitionStorableParameters(
            presentedTransitionsHandler: navigationTransitionsHandler
        )
        
        let animationLaunchingContext = ModalNavigationPresentationAnimationLaunchingContext(
            targetNavigationController: navigationController,
            targetViewController: targetViewController,
            animator: animator
        )
        
        self.presentationAnimationLaunchingContextBox = .modalNavigation(
            launchingContext: animationLaunchingContext
        )
    }
    
    /// Контекст описывает переход на конечный модальный UINavigationController
    /// использовать для MFMailComposeViewController, UIImagePickerController
    init(
        presentingModalEndpointNavigationController navigationController: UINavigationController,
        targetTransitionsHandler navigationTransitionsHandler: NavigationTransitionsHandler,
        animator: ModalEndpointNavigationTransitionsAnimator,
        transitionId: TransitionId)
    {        
        self.transitionId = transitionId
        self.targetViewController = navigationController
        self.targetTransitionsHandlerBox = .init(animatingTransitionsHandler: navigationTransitionsHandler)
        
        self.storableParameters = NavigationTransitionStorableParameters(
            presentedTransitionsHandler: navigationTransitionsHandler
        )
        
        let animationLaunchingContext = ModalEndpointNavigationPresentationAnimationLaunchingContext(
            targetNavigationController: navigationController,
            animator: animator
        )
        
        self.presentationAnimationLaunchingContextBox = .modalEndpointNavigation(
            launchingContext: animationLaunchingContext
        )
    }
    
    // MARK: - Popover

    /// Контекст описывает вызов поповера, содержащего простой UIViewController
    init(
        presentingViewController targetViewController: UIViewController,
        inPopoverController popoverController: UIPopoverController,
        fromRect rect: CGRect,
        inView view: UIView,
        targetTransitionsHandler: AnimatingTransitionsHandler,
        animator: PopoverTransitionsAnimator,
        transitionId: TransitionId)
    {
        self.targetViewController = targetViewController
        self.transitionId = transitionId
        self.targetTransitionsHandlerBox = .init(animatingTransitionsHandler: targetTransitionsHandler)
        
        self.storableParameters = PopoverTransitionStorableParameters(
            popoverController: popoverController,
            presentedTransitionsHandler: targetTransitionsHandler
        )
        
        let animationLaunchingContext = PopoverPresentationAnimationLaunchingContext(
            transitionStyle: .popoverFromView(sourceView: view, sourceRect: rect),
            targetViewController: targetViewController,
            popoverController: popoverController,
            animator: animator)
        
        self.presentationAnimationLaunchingContextBox = .popover(
            launchingContext: animationLaunchingContext
        )
    }
    
    /// Контекст описывает вызов поповера, содержащего контроллер, который положен в UINavigationController
    init(
        presentingViewController targetViewController: UIViewController,
        inNavigationController navigationController: UINavigationController,
        inPopoverController popoverController: UIPopoverController,
        fromRect rect: CGRect,
        inView view: UIView,
        targetTransitionsHandler navigationTransitionsHandler: NavigationTransitionsHandler,
        animator: PopoverNavigationTransitionsAnimator,
        transitionId: TransitionId)
    {
        self.targetViewController = targetViewController
        self.transitionId = transitionId
        self.targetTransitionsHandlerBox = .init(animatingTransitionsHandler: navigationTransitionsHandler)
        
        self.storableParameters = PopoverTransitionStorableParameters(
            popoverController: popoverController,
            presentedTransitionsHandler: navigationTransitionsHandler
        )
        
        let animationLaunchingContext = PopoverNavigationPresentationAnimationLaunchingContext(
            transitionStyle: .popoverFromView(sourceView: view, sourceRect: rect),
            targetViewController: targetViewController,
            targetNavigationController: navigationController,
            popoverController: popoverController,
            animator: animator)
        
        self.presentationAnimationLaunchingContextBox = .popoverNavigation(
            launchingContext: animationLaunchingContext
        )
    }
    
    /// Контекст описывает вызов поповера, содержащего простой UIViewController
    init(presentingViewController targetViewController: UIViewController,
        inPopoverController popoverController: UIPopoverController,
        fromBarButtonItem buttonItem: UIBarButtonItem,
        targetTransitionsHandler: AnimatingTransitionsHandler,
        animator: PopoverTransitionsAnimator,
        transitionId: TransitionId)
    {
        self.transitionId = transitionId
        self.targetViewController = targetViewController
        self.targetTransitionsHandlerBox = .init(animatingTransitionsHandler: targetTransitionsHandler)
        
        self.storableParameters = PopoverTransitionStorableParameters(
            popoverController: popoverController,
            presentedTransitionsHandler: targetTransitionsHandler
        )
        
        let animationLaunchingContext = PopoverPresentationAnimationLaunchingContext(
            transitionStyle: .popoverFromBarButtonItem(buttonItem: buttonItem),
            targetViewController: targetViewController,
            popoverController: popoverController,
            animator: animator)
        
        self.presentationAnimationLaunchingContextBox = .popover(
            launchingContext: animationLaunchingContext
        )
    }
    
    /// Контекст описывает вызов поповера, содержащего контроллер, который положен в UINavigationController
    init(
        presentingViewController targetViewController: UIViewController,
        inNavigationController navigationController: UINavigationController,
        inPopoverController popoverController: UIPopoverController,
        fromBarButtonItem buttonItem: UIBarButtonItem,
        targetTransitionsHandler navigationTransitionsHandler: NavigationTransitionsHandler,
        animator: PopoverNavigationTransitionsAnimator,
        transitionId: TransitionId)
    {
        self.transitionId = transitionId
        self.targetViewController = targetViewController
        self.targetTransitionsHandlerBox = .init(animatingTransitionsHandler: navigationTransitionsHandler)

        self.storableParameters = PopoverTransitionStorableParameters(
            popoverController: popoverController,
            presentedTransitionsHandler: navigationTransitionsHandler
        )
        
        let animationLaunchingContext = PopoverNavigationPresentationAnimationLaunchingContext(
            transitionStyle: .popoverFromBarButtonItem(buttonItem: buttonItem),
            targetViewController: targetViewController,
            targetNavigationController: navigationController,
            popoverController: popoverController,
            animator: animator)
        
        self.presentationAnimationLaunchingContextBox = .popoverNavigation(
            launchingContext: animationLaunchingContext
        )
    }
}

// MARK: - Convenience
extension PresentationTransitionContext {
    var needsAnimatingTargetTransitionHandler: Bool {
        let result = self.targetTransitionsHandlerBox.needsAnimatingTargetTransitionHandler
        return result
    }
    
    /// Проставляем непроставленного ранее обработчика переходов
    mutating func setAnimatingTargetTransitionsHandler(_ transitionsHandler: AnimatingTransitionsHandler)
    {
        marshrouteAssert(needsAnimatingTargetTransitionHandler)
        targetTransitionsHandlerBox = .init(animatingTransitionsHandler: transitionsHandler)
    }
}
