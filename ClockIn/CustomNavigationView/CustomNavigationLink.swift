//
//  CustomNavigationLink.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 28/12/2023.
//

import SwiftUI

struct CustomNavigationLink<Label: View, Destination: View>: View {
    let destination: Destination
    let label: Label
    
    init(destination: Destination, @ViewBuilder label: () -> Label) {
        self.destination = destination
        self.label = label()
    }
    
    var body: some View {
        NavigationLink {
            CustomNavigationContainerView {
                destination
            }
            .navigationBarHidden(true)
        } label: {
            label
        }
    }
}

#Preview {
    CustomNavigationLink(destination: Text("Desitination")) {
        Text("Label")
    }
}
