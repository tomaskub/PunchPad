//
//  ModifiedContent+Extension.swift
//  PunchPad
//
//  Created by Tomasz Kubiak on 20/01/2025.
//

import SwiftUICore
import SwiftUI

extension ModifiedContent where Modifier == AccessibilityAttachmentModifier {
    nonisolated public func accessibilityIdentifier<T: RawRepresentable>(
        _ identifier: T
    ) -> ModifiedContent<Content, Modifier> where T.RawValue == String {
        accessibilityIdentifier(identifier.rawValue)
    }
}
