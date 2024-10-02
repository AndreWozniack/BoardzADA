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
                    router.push(to: .game(game))
                }
            }
            .onAppear {
                Task {
                    await vm.load()
                }
            }
            
            Button(action: { self.isShowing.toggle() }) {
                 Text("Scan")
             }
        }
        .toolbar { EditButton() }
        .sheet(isPresented: $isShowing) {
             ScannerView(isShowing: $isShowing)
                 .presentationDetents([.medium, .large])
         }
    }
}

#Preview {
    GameListView()
}
