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
    @State var isShowing: Bool = false
    
    @EnvironmentObject var router: Router<AppRoute>
    
    var body: some View {
        Text("Lista de Jogos")
        
        List {
            ForEach(vm.gameList) { game in
                Button(game.name) {
                    router.push(to: .game(game.id))
                }
            }
            .onAppear {
                Task {
                    await vm.fetchGames()
                }
            }
            
            Button(action: { self.isShowing.toggle() }) {
                Text("Scan")
            }
        }
        .toolbar {
            Button("Adicionar") {
                router.push(to: .gameCreate)
            }
        }
        .sheet(isPresented: $isShowing) {
            ScannerView(isShowing: $isShowing) { value in
                router.push(to: .game(value))
            }
            .presentationDetents([.medium, .large])
        }
    }
}

#Preview {
    GameListView()
}
