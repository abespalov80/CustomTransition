//
//  FullSheetPresentTransition.swift
//  CustomTransition
//
//  Created by Alexander Bespalov on 22/09/2020.
//  Copyright © 2020 Alexander Bespalov. All rights reserved.
//

import UIKit

class FullSheetPresentTransition : NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        /// [Apple Bug: UIViewControllerContextTransitioning.view(forKey:) returns nil when the view is being presented non-modally](http://www.openradar.me/radar?id=4999313432248320)
        guard let toViewController = transitionContext.viewController(forKey: .to) else {
            return
        }

        transitionContext.containerView.addSubview(toViewController.view)
        toViewController.view.frame.origin.y = toViewController.view.frame.height
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0.0,
                       options: .curveEaseOut,
                       animations: {
                        toViewController.view.frame.origin.y = 0
        },
                       completion: { _ in
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }

}
