//
//  ViewControllerRepresentable.swift
//  NavigationKit
//
//  Created by Tomasz Kubiak on 29/12/2023.
//

import UIKit
import SwiftUI

public struct ViewControllerRepresentable: UIViewControllerRepresentable {
    let vc: UIViewController
    
    public init(vc: UIViewController) {
        self.vc = vc
    }
    
    public func makeUIViewController(context: Context) -> some UIViewController {
        return vc
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
