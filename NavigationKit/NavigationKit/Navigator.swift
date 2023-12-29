//
//  Navigator.swift
//  NavigationKit
//
//  Created by Tomasz Kubiak on 29/12/2023.
//

import Foundation

public class Navigator<Route: Equatable> {
    
    private(set) var routes: [Route] = []
    
    var delegate: NavigatorDelegate<Route>?
    
    public var canGoBack: Bool {
        return routes.count > 1
    }
    
    
    public init(_ initialRoute: Route) {
        routes.append(initialRoute)
    }
    
    public init(_ initialRoutes: [Route]) {
        routes.append(contentsOf: initialRoutes)
    }
    
    public func push(_ route: Route, animated: Bool = true) {
        routes.append(route)
        delegate?.push(route, animated)
    }
    
    public func goBack() {
        guard !routes.isEmpty, routes.count > 1  else {return}
        delegate?.popToCountFromLast(1)
    }
    
    public func goBackToRoot() {
        guard !routes.isEmpty, routes.count > 1,  let first = routes.first else {return}
        delegate?.popToCountFromLast(routes.count - 1)
        routes.removeAll()
        routes.append(first)
    }
    
    public func goBackTo(_ route: Route) {
        guard !routes.isEmpty, let lastIndex = routes.lastIndex(of: route) else {return}
        let count = (lastIndex..<routes.count).count
        routes.removeLast(count)
        delegate?.popToCountFromLast(count)
    }
    
    public func present(_ route: Route, animate: Bool = true, _ completion: (() -> Void)? = nil) {
        delegate?.present(route, false, animate, completion)
    }
    
    
    public func presentFullScreenCover(_ route: Route, animate: Bool = true, _ completion: (() -> Void)?) {
        delegate?.present(route, true, animate, completion)
    }
    
    public func dismiss(animate: Bool = true, _ completion: (() -> Void)?) {
        delegate?.dismiss(animate, completion)
    }
    
    func systemDidNavigatedBack() {
        guard !routes.isEmpty else {return}
        routes.removeLast()
    }
}
