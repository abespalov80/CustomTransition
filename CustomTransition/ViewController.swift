//
//  ViewController.swift
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

    override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ParentViewController: viewWillAppear")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("ParentViewController: viewDidAppear")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("ParentViewController: viewWillDisappear")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("ParentViewController: viewDidDisappear")
    }

    @IBAction func onButtonClicked(_ sender: Any) {
        let viewController = TopViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.transitioningDelegate = transition
        navigationController.modalPresentationStyle = .custom
//        navigationController.modalPresentationStyle = .fullScreen
//        navigationController.isModalInPresentation = true
//        navigationController.definesPresentationContext = true
        present(navigationController, animated: true, completion: nil)
        print(navigationController.presentationController?.shouldRemovePresentersView ?? false)
    }

}

