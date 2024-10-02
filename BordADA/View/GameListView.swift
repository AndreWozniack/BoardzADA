//
//  GameListView.swift
//  BordADA
//
//  Created by Felipe Passos on 01/10/24.
//

import SwiftUI
import RouterKit

struct GameListView: View {
    @ObservedObject var vm = GamesCollectionManager()
    
    @EnvironmentObject var router: Router<AppRoute>
    
    var body: some View {
        Text("Lista de Jogos")
        
        List {
            ForEach(vm.gameList) { game in
                Button(game.name) {
                    router.push(to: .game(game))
                }
            }
        }
        .onAppear {
            Task {
                await vm.fetchGames()
            }
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    GameListView()
}
