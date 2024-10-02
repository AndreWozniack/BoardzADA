//
//  GameListView.swift
//  BordADA
//
//  Created by Felipe Passos on 01/10/24.
//

import SwiftUI
import RouterKit

struct GameListView: View {
    @ObservedObject var vm = GameCreateViewModel()
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

            
            Button(action: { self.isShowing.toggle() }) {
                 Text("Scan")
             }
            Button {
                router.push(to: .gameCreate)
            } label: {
                Text("Criar Jogo")
            }

        }
        .onAppear {
            Task {
                await vm.fetchGames()
                print(vm.gameList)
            }
        }
        .toolbar { EditButton() }
        .sheet(isPresented: $isShowing) {
             ScannerView(isShowing: $isShowing)
                 .presentationDetents([.medium, .large])
         }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    GameListView()
}
