//
//  ButtonStyle+Extension.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 02/01/2024.
//

import SwiftUI

extension ButtonStyle where Self == CancelButtonStyle {
    static var dismissive: CancelButtonStyle { .init() }
}

extension ButtonStyle where Self == ConfirmButtonStyle {
    static var confirming: ConfirmButtonStyle { .init() }
}


