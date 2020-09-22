//
//  RootViewController.swift
//  CustomTransition
//
//  Created by Alexander Bespalov on 22/09/2020.
//  Copyright © 2020 Alexander Bespalov. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    var transition: SheetTransitioningDelegate?


    override func viewDidLoad() {
        super.viewDidLoad()
        transition = SheetTransitioningDelegate()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("RootViewController: viewWillAppear")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("RootViewController: viewDidAppear")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("RootViewController: viewWillDisappear")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("RootViewController: viewDidDisappear")
    }

    @IBAction func onButtonClicked(_ sender: Any) {
        let viewController = TopViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.transitioningDelegate = transition
        navigationController.modalPresentationStyle = .custom
        present(navigationController, animated: true, completion: nil)
    }
}

