//
//  View+Ext.swift
//

import SwiftUI

struct HideKeyboardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                content.hideKeyboard()
            }
    }
}

public extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners) )
    }
    
    func borderRadius(_ radius: CGFloat, lineWidth: CGFloat = 1, color: Color = .black) -> some View {
        overlay {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .stroke(style: StrokeStyle(lineWidth: lineWidth))
                    .foregroundStyle(color)
            }
    }
    
    func hideKeyboard() {
        UIApplication.shared.dismissKeyboard()
    }
}

extension View {
    
    @ViewBuilder
    func ifAvailable(minVersion: OperatingSystemVersion, apply: (Self) -> some View) -> some View {
        let current = ProcessInfo.processInfo.operatingSystemVersion
        if current >= minVersion {
            apply(self)
        } else {
            self
        }
    }

}

extension OperatingSystemVersion {
    init(_ major: Int, _ minor: Int = 0, _ patch: Int = 0) {
        self.init(majorVersion: major, minorVersion: minor, patchVersion: patch)
    }
}

extension OperatingSystemVersion: @retroactive Equatable {}
extension OperatingSystemVersion: @retroactive Comparable {
    public static func == (lhs: OperatingSystemVersion, rhs: OperatingSystemVersion) -> Bool {
        return lhs.majorVersion == rhs.majorVersion && lhs.minorVersion == rhs.minorVersion && lhs.patchVersion == rhs.patchVersion
    }
    
    public static func < (lhs: OperatingSystemVersion, rhs: OperatingSystemVersion) -> Bool {
        if lhs.majorVersion != rhs.majorVersion {
            return lhs.majorVersion < rhs.majorVersion
        }
        if lhs.minorVersion != rhs.minorVersion {
            return lhs.minorVersion < rhs.minorVersion
        }
        return lhs.patchVersion < rhs.patchVersion
    }
}
