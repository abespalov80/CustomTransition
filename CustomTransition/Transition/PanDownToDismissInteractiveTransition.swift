//
//  PanDownToDismissInteractiveTransition.swift
//  CustomTransition
//
//  Created by Alexander Bespalov on 22/09/2020.
//  Copyright © 2020 Alexander Bespalov. All rights reserved.
//

import UIKit

/// Describes an object that animates a transition and exposes the internal animator used to perform the transition.
protocol AnimatedTransitioningAnimatorProviding: AnyObject {
    var animator: UIViewPropertyAnimator? { get }
}

final class PanDownToDismissInteractiveTransition : UIPercentDrivenInteractiveTransition {

    // MARK: Internal variables

    /// If `true`, automatically tracks every scrollView which blocks pan gesture recognizer attached for interactive transtion.
    /// Pulling down beyond the tracked scrollView's content offset will trigger interactive transtion for dismissal.
    /// `true` by default.
    var automaticallyTrackScrollView = true

    /// Whether or not interaction is in progress.
    private(set) var interactionInProgress = false

    /// The animating object owned by the animated transition associated with this interactive transition.
    weak var animatedTransition: AnimatedTransitioningAnimatorProviding?


    // MARK: Private variables

    /// The target view controller for dismissal.
    private weak var viewController: UIViewController?

    /// The height of the container.
    private var containerHeight: CGFloat!

    /// A closure executed when interactive transition begins.
    /// This closure is expected to be a function which triggers system to initiate dismissal.
    /// Usually either `dismiss(animated:completion:)` on `UIViewController`
    /// or `popViewController(animated:)` on `UINavigationController`
    private var dismissAction: (() -> Void)?

    /// closure executed when interactive transition is finished.
    private var dismissCompletion: (() -> Void)?

    /// view to which pan gesture recognizer is attached
    private var panGestureView: UIView

    /// gesture recognizer for interactive transition
    private var panGestureRecognizer: UIPanGestureRecognizer!

    /// scroll views being tracked
    private var trackedScrollViews: [UIScrollView] = []

    /// Whether or not transition should be completed.
    private var shouldCompleteTransition = false

    /// Higher pan velocity than this value will trigger finishing interactive transition.
    private let velocityThreshold: CGFloat = 3000


    // MARK: Internal functions

    /// Designated initializer
    /// - Parameters:
    ///   - viewController: view controller to dismiss
    ///   - panGestureView: view to which the pan gesture recognizer is attached.
    ///   - dismissAction: a closure used to trigger dismissal
    ///   - dismissCompletion: a closure called when interactive transition finishes
    init(viewController: UIViewController,
         panGestureView: UIView,
         dismissAction: (() -> Void)?,
         dismissCompletion: (() -> Void)?) {
        self.viewController = viewController
        self.panGestureView = panGestureView
        self.dismissAction = dismissAction
        self.dismissCompletion = dismissCompletion

        super.init()

        panGestureRecognizer = UIPanGestureRecognizer(target: self,
                                                      action: #selector(handlePanGesture))
        panGestureRecognizer.delegate = self
        self.panGestureView.addGestureRecognizer(panGestureRecognizer)
    }


    /// Tracks provided `scrollView` to handle pulling down scrollView to initiate interactive dissmisal.
    /// This function should  only be used when `automaticallyTrackScrollView` is set to `false`
    /// - Parameter scrollView: scrollView to track.
    func trackScrollView(_ scrollView: UIScrollView) {
        if !trackedScrollViews.contains(scrollView) {
            trackedScrollViews.append(scrollView)
        }
    }


    deinit {
        untrackAllScrollViews()
        panGestureView.removeGestureRecognizer(panGestureRecognizer)
    }


    // MARK: Private functions

    /// Handles panning gesture attached to `panGestureView`
    @objc func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began {
            containerHeight = viewController?.view.frame.height
        }

        let velocity = gestureRecognizer.velocity(in: gestureRecognizer.view?.superview)
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view?.superview)
        handlePanning(velocity: velocity,
                      translation: translation,
                      gestureRecognizerState: gestureRecognizer.state)
    }


    private func startInteractionIfNotStarted() {
        let isAnimatorRunning: Bool = animatedTransition?.animator?.isRunning ?? false
        if !interactionInProgress && !isAnimatorRunning {
            interactionInProgress = true
            if let dismissAction = dismissAction {
                dismissAction()
            } else {
                viewController?.dismiss(animated: true, completion: nil)
            }
        }
    }


    private let progressRequiredForDismissal: CGFloat = 0.30

    private var hasPannedPastRubberbandThreshold: Bool = false

    private var feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

    private func handlePanning(velocity: CGPoint,
                               translation: CGPoint,
                               gestureRecognizerState: UIGestureRecognizer.State) {

        switch gestureRecognizerState {
        case .began:
            startInteractionIfNotStarted()
            feedbackGenerator.prepare()

        case .changed:
            guard interactionInProgress else {
                return
            }

            guard translation.y > 0 else {
                return
            }

            let absoluteProgress = translation.y / containerHeight
            var accumulatedProgress: CGFloat = 0.0

            if absoluteProgress < progressRequiredForDismissal {
                accumulatedProgress = log10(absoluteProgress + 1.0) * 1.7
            } else {
                let rubberbandThreshold = progressRequiredForDismissal
                accumulatedProgress = (log10(absoluteProgress + 1.0) * 1.7) + (absoluteProgress - rubberbandThreshold)
            }

            if absoluteProgress > progressRequiredForDismissal && !hasPannedPastRubberbandThreshold {
                hasPannedPastRubberbandThreshold = true
                feedbackGenerator.impactOccurred()
            }

            shouldCompleteTransition = absoluteProgress > progressRequiredForDismissal
            update(accumulatedProgress)

        case .cancelled:
            guard interactionInProgress else {
                return
            }

            cancelPanning()

        case .ended:
            guard interactionInProgress else {
                return
            }

            hasPannedPastRubberbandThreshold = false
            interactionInProgress = false
            if shouldCompleteTransition || velocity.y > velocityThreshold {
                let remainingDistance = abs(containerHeight - translation.y)
                let relativeVelocity = abs(velocity.y) / remainingDistance
                finishPanning(initialVelocity: CGVector(dx: relativeVelocity, dy: relativeVelocity))
            } else {
                cancelPanning()
            }
        default:
            break
        }
    }


    /// Untrack all tracked scroll views
    private func untrackAllScrollViews() {
        for scrollView in trackedScrollViews {
            scrollView.panGestureRecognizer.removeTarget(self, action: nil)
        }
        trackedScrollViews.removeAll()
    }


    private func enableTrackedScrollViews() {
        trackedScrollViews.forEach {
            $0.isScrollEnabled = true
        }
    }


    private func cancelPanning() {
        interactionInProgress = false
        enableTrackedScrollViews()
        timingCurve = UISpringTimingParameters(damping: 1.0, response: 1.0)
        cancel()
    }


    private func finishPanning(initialVelocity: CGVector) {
        interactionInProgress = false
        enableTrackedScrollViews()
        timingCurve = UISpringTimingParameters(damping: 1.0, response: 0.4, initialVelocity: initialVelocity)
        finish()
        dismissCompletion?()
    }
}


// MARK: UIGestureRecognizerDelegate

extension PanDownToDismissInteractiveTransition : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        guard let scrollViewPanGestureRecognizer = otherGestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }

        guard let scrollView = scrollViewPanGestureRecognizer.view as? UIScrollView else {
            return false
        }

        /// Enforce that this is a vertical scrolling scroll view, not horizontal
        guard scrollView.contentSize.height > scrollView.bounds.height || scrollView.alwaysBounceVertical else {
            return false
        }

        if automaticallyTrackScrollView && gestureRecognizer == panGestureRecognizer {
            trackScrollView(scrollView)
        }

        let scrollViewVelocity = scrollViewPanGestureRecognizer.velocity(in: scrollView)
        let viewIsDismissing = interactionInProgress

        let isPullingDownFromTopSheetPosition = scrollViewVelocity.y > 0
            && scrollView.contentOffset.y <= 0
            && !interactionInProgress

        if viewIsDismissing || isPullingDownFromTopSheetPosition {
            // disable the scroll view's pan via the gesture (not the scrollView itself) to avoid weird contentOffset behavior
            otherGestureRecognizer.isEnabled = false
        } else {
            scrollView.isScrollEnabled = true
        }

        return false
    }
}


public extension UISpringTimingParameters {

    convenience init(damping: CGFloat, response: CGFloat, initialVelocity: CGVector = .zero) {
        let stiffness = pow(2 * .pi / response, 2)
        let damp = 4 * .pi * damping / response
        self.init(mass: 1, stiffness: stiffness, damping: damp, initialVelocity: initialVelocity)
    }

}
