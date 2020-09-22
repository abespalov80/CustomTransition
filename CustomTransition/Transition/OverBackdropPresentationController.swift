//
//  OverBackdropPresentationController.swift
//  CustomTransition
//
//  Created by Alexander Bespalov on 22/09/2020.
//  Copyright © 2020 Alexander Bespalov. All rights reserved.
//

import Foundation
import UIKit

/// Custom presentation style which adds custom backdropView
final class OverBackdropPresentationController : UIPresentationController {
    private let backdropView = UIView()
    private var snapshotView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let view = snapshotView {
                containerView?.insertSubview(view, at: 0)
            }
        }
    }

    override init(presentedViewController: UIViewController, presenting: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presenting)
    }

    override var shouldRemovePresentersView: Bool {
        true
    }

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        guard let containerView = self.containerView else {
            return
        }
        snapshotView = presentingViewController.view.snapshotView(afterScreenUpdates: true)

        backdropView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .darkGray : .gray
        backdropView.alpha = 0.0

        let tapToDismissGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDismissTap(tapGesture:)))
        backdropView.addGestureRecognizer(tapToDismissGestureRecognizer)
        containerView.addSubview(backdropView)
        backdropView.translatesAutoresizingMaskIntoConstraints = false
        backdropView.layoutAll(to: containerView)
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.backdropView.alpha = 1
        })
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
    }

    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.backdropView.alpha = 0
        })
    }


    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            self.backdropView.removeFromSuperview()
            self.snapshotView?.removeFromSuperview()
        }
        super.dismissalTransitionDidEnd(completed)
    }


    @objc func handleDismissTap(tapGesture: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle else {
            return
        }

        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            snapshotView = presentingViewController.view.snapshotView(afterScreenUpdates: true)
            backdropView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .darkGray : .gray
        }
    }
}
