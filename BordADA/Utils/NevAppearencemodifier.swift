//
//  NevAppearencemodifier.swift
//  BordADA
//
//  Created by André Wozniack on 08/10/24.
//
import SwiftUI

struct NevAppearencemodifier: ViewModifier {
    init(background: UIColor, foreground: UIColor, tint: UIColor?, hidesShadow: Bool) {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = background
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: foreground]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: foreground]
        if hidesShadow {
            navigationBarAppearance.shadowColor = .clear
        }
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        if let tintColor = tint {
            UIView.appearance().tintColor = tintColor
        }
    }
    
    func body(content: Content) -> some View {
        content
    }
}

extension View {
    func navigationAppearence(
        background: UIColor,
        foreground: UIColor,
        tint: UIColor?,
        hidesShadow: Bool
    ) -> some View {
        self.modifier(NevAppearencemodifier(background: background, foreground: foreground, tint: tint, hidesShadow: hidesShadow))
    }
    
    func defaultNavigationAppearence() -> some View {
        navigationAppearence(
            background: .roxo,
            foreground: .uiBackground,
            tint: .uiBackground,
            hidesShadow: false
        )
    }
}

