//
//  _NavigationController.swift
//  NavigationKit
//
//  Created by Tomasz Kubiak on 29/12/2023.
//

import UIKit

class _NavigationController: UINavigationController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    var onPopHandler: (()->Void)?
    
    init(onPopHandler: @escaping () -> Void) {
        self.onPopHandler = onPopHandler
        super.init(nibName: nil, bundle: nil)
        self.delegate = self
        self.isNavigationBarHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        self.interactivePopGestureRecognizer?.delegate = self
        super.viewDidLoad()
    }
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let previousController = navigationController.transitionCoordinator?.viewController(forKey: .from),
              !navigationController.viewControllers.contains(previousController) else {
                  return
              }
        onPopHandler?()
    }
    
    override func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        super.setNavigationBarHidden(true, animated: animated)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.viewControllers.count > 1
    }
}
