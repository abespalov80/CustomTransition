//
//  SheetTransitioningDelegate.swift
//  CustomTransition
//
//  Created by Alexander Bespalov on 22/09/2020.
//  Copyright © 2020 Alexander Bespalov. All rights reserved.
//

import Foundation
import UIKit

final class SheetTransitioningDelegate : NSObject, UIViewControllerTransitioningDelegate {
    private var dismissInteractiveTransition: PanDownToDismissInteractiveTransition?

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FullSheetPresentTransition()
    }


    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FullSheetDismissTransition()
    }


    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        dismissInteractiveTransition = PanDownToDismissInteractiveTransition(viewController: presented,
                                                                             panGestureView: presented.view,
                                                                             dismissAction: nil,
                                                                             dismissCompletion: nil)

        return OverBackdropPresentationController(presentedViewController: presented, presenting: presenting)
    }


    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let dismissInteractiveTransition = dismissInteractiveTransition,
            dismissInteractiveTransition.interactionInProgress else {
                return nil
        }
        return dismissInteractiveTransition
    }
}
