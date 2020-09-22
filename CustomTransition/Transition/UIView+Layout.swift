//
//  UIView+Layout.swift
//  CustomTransition
//
//  Created by Alexander Bespalov on 22/09/2020.
//  Copyright © 2020 Alexander Bespalov. All rights reserved.
//

import UIKit

extension UIView {
    /// Adds active constraints to all 4 sides of a view to embed it into the provided view
    ///
    /// - Parameters:
    ///   - view: View to constrain against
    ///   - insets: Applied as constants to the created constraints, to allow for a
    ///   margin to be applied.
    func layoutAll(to view: UIView, insets: UIEdgeInsets) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.right),
            topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom)
        ])
    }

    func layoutAll(to view: UIView, margin: CGFloat = 0.0) {
        layoutAll(to: view, insets: UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin))
    }

}
