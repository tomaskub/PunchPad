//
//  _NavigationControllerWrapper.swift
//  NavigationKit
//
//  Created by Tomasz Kubiak on 29/12/2023.
//

import SwiftUI

struct _NavigationControllerWrapper<Content: View, Route: Equatable>: UIViewControllerRepresentable {
    // Navigator instance managing the navigation routes.
        let navigator: Navigator<Route>

        // Builds the destination view based on the current route.
        @ViewBuilder let destinationBuilder: @MainActor @Sendable (Route) -> Content
        
        // Cleans up the view controller when it is no longer needed.
        static func dismantleUIViewController(_ uiViewController: UINavigationController, coordinator: ()) {
            uiViewController.viewControllers = []
            (uiViewController as! _NavigationController).onPopHandler = nil
        }
        
        // Creates the UINavigationController instance.
        func makeUIViewController(context: Context) -> UINavigationController {
            let navigationController = _NavigationController() {
                navigator.systemDidNavigatedBack()
            }
            navigator.routes.forEach { route in
                navigationController.pushViewController(makeViewController(with: route), animated: true)
            }
            navigator.delegate = getCallbackFor(navigationController)
            return navigationController
        }
        
        // Updates the UINavigationController instance.
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
        
        // Generates callbacks for navigation actions.
        @MainActor
        private func getCallbackFor(_ navigationController: _NavigationController) -> NavigatorDelegate<Route> {
            NavigatorDelegate { route, animate in
                navigationController.pushViewController(makeViewController(with: route), animated: animate)
            } popToCountFromLast: { count in
                let popTo = navigationController.viewControllers[navigationController.viewControllers.count - count - 1]
                navigationController.popToViewController(popTo, animated: true)
            } present: { route, isFullScreen, animate, completion in
                let vc = makeViewController(with: route)
                if isFullScreen {
                    vc.modalPresentationStyle = .fullScreen
                }
                navigationController.present(vc, animated: animate, completion: completion)
            } dismiss: { animated, completion in
                navigationController.dismiss(animated: animated, completion: completion)
            }
        }
        
        // Creates a UIViewController for the given route.
        @MainActor
        private func makeViewController(with route: Route) -> UIViewController {
            let view = NavigationBarWrapper(showBackButton: navigator.canGoBack){
                destinationBuilder(route)
            } onBackTapped: {
                navigator.goBack()
            }
            return UIHostingController(rootView: view)
        }
    }
