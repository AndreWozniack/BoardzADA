//
//  ContentView.swift
//  BordADA
//
//  Created by André Wozniack on 01/10/24.
//

import AVFoundation
import CarBode
import SwiftUI
import RouterKit

struct ContentView: View {
    var body: some View {
        if UserManager.shared.currentUser == nil {
            RouterView<AppRoute>(rootView: .signIn, showBackButton: false)
                .preferredColorScheme(.light)
        } else {
            RouterView<AppRoute>(rootView: .gameList, showBackButton: true)
                .preferredColorScheme(.light)
                
        }
    }
}

#Preview {
	ContentView()
}
