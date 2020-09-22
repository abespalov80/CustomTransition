//
//  FullSheetDismissTransition.swift
//  CustomTransition
//
//  Created by Alexander Bespalov on 22/09/2020.
//  Copyright © 2020 Alexander Bespalov. All rights reserved.
//

import UIKit

class FullSheetDismissTransition : NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        interruptibleAnimator(using: transitionContext).startAnimation()
    }

    var propertyAnimator: UIViewPropertyAnimator?

    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        let animationDuration = transitionDuration(using: transitionContext)
        if let propertyAnimator = propertyAnimator {
            return propertyAnimator
        }

        let animator = UIViewPropertyAnimator(duration: animationDuration,
                                              curve: .easeInOut)
        animator.addAnimations {
            guard let fromViewController = transitionContext.viewController(forKey: .from) else {
                return
            }
            fromViewController.view.frame.origin.y += fromViewController.view.frame.height
        }

        animator.addCompletion { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            if !transitionContext.transitionWasCancelled {
                self.propertyAnimator = nil
            }
        }
        propertyAnimator = animator
        return animator
    }
}
