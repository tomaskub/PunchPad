//
//  CustomDatePickerContainer.swift
//  ClockIn
//
//  Created by Tomasz Kubiak on 01/01/2024.
//

import SwiftUI

struct CustomDatePickerContainer<Content: View, Leading: View, Trailing: View>: View {
    @State private var labelSize: CGSize = CGSize()
    private let labelText: String?
    private let cornerRadius: CGFloat
    private var content: () -> Content
    private var leadingIcon: (() -> Leading)?
    private var trailingIcon: (() -> Trailing)?
    
    private init(labelText: String?, cornerRadius: CGFloat,
                 @ViewBuilder content: @escaping () -> Content,
                 leadingIcon: (() -> Leading)?,
                 trailingIcon: (() -> Trailing)?) {
        self.labelText = labelText
        self.cornerRadius = cornerRadius
        self.content = content
        self.leadingIcon = leadingIcon
        self.trailingIcon = trailingIcon
    }
    
    init(labelText: String?, cornerRadius: CGFloat = 10,
         @ViewBuilder content: @escaping () -> Content,
         @ViewBuilder leading: @escaping () -> Leading,
         @ViewBuilder trailing: @escaping () -> Trailing) {
        self.labelText = labelText
        self.cornerRadius = cornerRadius
        self.content = content
        self.leadingIcon = leading
        self.trailingIcon = trailing
    }
    
    init(labelText: String?, cornerRadius: CGFloat = 10,
         @ViewBuilder content: @escaping () -> Content,
         @ViewBuilder leading: @escaping () -> Leading) where Trailing == EmptyView {
        self.init(labelText: labelText,
                  cornerRadius: cornerRadius,
                  content: content,
                  leadingIcon: leading,
                  trailingIcon: nil)
    }
    
    init(labelText: String?, cornerRadius: CGFloat = 10,
         @ViewBuilder content: @escaping () -> Content,
         @ViewBuilder trailing: @escaping () -> Trailing) where Leading == EmptyView {
        self.init(labelText: labelText,
                  cornerRadius: cornerRadius,
                  content: content,
                  leadingIcon: nil,
                  trailingIcon: trailing)
    }
    
    init(labelText: String?, cornerRadius: CGFloat = 10,
         @ViewBuilder content: @escaping () -> Content) where Trailing == EmptyView, Leading == EmptyView {
        self.init(labelText: labelText,
                  cornerRadius: cornerRadius,
                  content: content,
                  leadingIcon: nil,
                  trailingIcon: nil)
    }
    
    var body: some View {
        ZStack {
            GeometryReader { proxy in
                drawBackgroundFrame(in: proxy)
                .stroke(lineWidth: 1)
                .foregroundColor(.theme.secondaryLabel)
                if let labelText {
                    Text(labelText)
                        .font(.system(size: 12))
                        .foregroundColor(.theme.primary)
                        .fixedSize()
                        .padding(.horizontal, 8)
                        .background(
                            GeometryReader { proxy in
                                Color.theme.white
                                    .preference(key: PrefKey.self, value: proxy.size)
                            })
                        .offset(CGSize(width: proxy.size.width/8, height: -labelSize.height/2))
                }
                
            }
            .onPreferenceChange(PrefKey.self, perform: { value in
                labelSize = value
            })
            HStack {
                if let leadingIcon {
                    leadingIcon()
                    Spacer()
                }
                content()
                if let trailingIcon {
                    Spacer()
                    trailingIcon()
                }
            }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
        }
        .padding(.top, labelSize.height/2)
    }
    
    @ViewBuilder
    func drawBackgroundFrame(in proxy: GeometryProxy) -> some Shape {
        Path { path in
            path.move(to: CGPoint(x: 0.125 * proxy.size.width, y: 0))
            path.addLine(to: CGPoint(x: cornerRadius, y: 0))
            path.addArc(center: CGPoint(x: cornerRadius, y: cornerRadius),
                        radius: cornerRadius,
                        startAngle: Angle(degrees: 270),
                        endAngle: Angle.degrees(180),
                        clockwise: true)
            path.addLine(to: CGPoint(x: 0, y: proxy.size.height - cornerRadius))
            path.addArc(center: CGPoint(x: cornerRadius, y: proxy.size.height - cornerRadius),
                        radius: cornerRadius,
                        startAngle: Angle(degrees: 180),
                        endAngle: Angle(degrees: 90),
                        clockwise: true)
            path.addLine(to: CGPoint(x: proxy.size.width - cornerRadius, y: proxy.size.height))
            path.addArc(center: CGPoint(x: proxy.size.width-cornerRadius,
                                        y: proxy.size.height - cornerRadius),
                        radius: cornerRadius,
                        startAngle: Angle(degrees: 90),
                        endAngle: Angle(degrees: 0),
                        clockwise: true)
            path.addLine(to: CGPoint(x: proxy.size.width, y: cornerRadius))
            path.addArc(center: CGPoint(x: proxy.size.width - cornerRadius, y: cornerRadius),
                        radius: cornerRadius,
                        startAngle: Angle(degrees: 0),
                        endAngle: Angle(degrees: 270),
                        clockwise: true)
            path.addLine(to: CGPoint(x: 0.125 * proxy.size.width + labelSize.width, y: 0))
        }
    }
}

private struct PrefKey: PreferenceKey {
    static let defaultValue: CGSize = CGSize()
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

#Preview("Date picker container") {
    CustomDatePickerContainer(labelText: "Label text") {
        DatePicker(selection: .constant(Date())) { EmptyView() }
            .labelsHidden()
    } trailing: {
        Image(systemName: "calendar")
            .font(.title)
            .foregroundColor(.theme.primary)
    }
    .fixedSize()
    .padding(.horizontal)
}
