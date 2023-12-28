//
//  CustomNavigationBarView.swift
//  ClockInTests
//
//  Created by Tomasz Kubiak on 28/12/2023.
//

import SwiftUI

struct CustomNavigationBarView: View {
    @Environment(\.presentationMode) var presentationMode
    let showBackButton: Bool
    let title: String
    let subtitle: String?
    let titleDisplayMode: NavigationBarItem.TitleDisplayMode = .automatic
    
    var body: some View {
        HStack {
            if showBackButton {
                backButon
                Spacer()
            }
            titleSection
            Spacer()
            backButon
            .opacity(0)
        }
        
        .tint(.white)
        .padding()
        .font(.headline)
        .background(
            ZStack {
                BackgroundFactory.buildSolidColor()
                RoundedRectangle(cornerRadius: 24)
                    .foregroundColor(.theme.white)
                    .ignoresSafeArea(edges: .top)
            }
            )
    }
    var backButon: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Image(systemName: "chevron.left")
        })
    }
    
    @ViewBuilder
    var titleSection: some View {
        if titleDisplayMode != NavigationBarItem.TitleDisplayMode.inline{
            VStack(spacing: 4) {
                Text(title)
                    .font(.title)
                    .fontWeight(.semibold)
                if let subtitle {
                    Text(subtitle)
                }
            }
        } else {
            Text(title)
                .fontWeight(.semibold)
        }
        
    }
}

#Preview {
    struct Preview: View {
        var body: some View {
            ZStack {
                BackgroundFactory.buildSolidColor()
                CustomNavigationBarView(showBackButton: true, title: "Custom navigation bar", subtitle: "A preview")
            }
        }
    }
    return Preview()
}
