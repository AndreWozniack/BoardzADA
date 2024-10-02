//
//  ContentView.swift
//  BordADA
//
//  Created by André Wozniack on 01/10/24.
//

import SwiftUI
import RouterKit

struct ContentView: View {
    var body: some View {
        RouterView<AppRoute>(rootView: .gameList)
    }
}

#Preview {
    ContentView()
}