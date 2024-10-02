//
//  GameListView.swift
//  BordADA
//
//  Created by Felipe Passos on 01/10/24.
//

import SwiftUI
import RouterKit

struct GameListView: View {
    @ObservedObject var vm = GameListViewModel()
    
    @EnvironmentObject var router: Router<AppRoute>
    
    var body: some View {
        List {
            ForEach(vm.gameList) { game in
                Button(game.name) {
                    router.push(to: .game(game))
                }
            }
        }
        .onAppear {
            Task {
                await vm.load()
            }
        }
    }
}

#Preview {
    GameListView()
}
