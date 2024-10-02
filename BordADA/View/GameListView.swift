//
//  GameListView.swift
//  BordADA
//
//  Created by Felipe Passos on 01/10/24.
//

import RouterKit
import SwiftUI

struct GameListView: View {
    @ObservedObject var vm = GameCreateViewModel()
    @State var isShowing: Bool = false

    @EnvironmentObject var router: Router<AppRoute>

    var body: some View {
//        Button(action: { self.isShowing.toggle() }) {
//            Text("Scan")
//        }
//        
//        Button {
//            router.push(to: .gameCreate)
//        } label: {
//            Text("Criar Jogo")
//        }

        VStack {
            HStack {
                Text("Felipe")
                    .font(.title)
                    .foregroundStyle(.white)
                    .bold()
                
                Spacer()
                
                Button {
                    isShowing = true
                } label: {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.title)
                        .foregroundStyle(.white)
                }

            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
            .background(.purple)
            
            ScrollView {
                LazyVStack {
                    ForEach([
                        // TODO: Remover o mock
                        // vm.gameList
                        BoardGame(
                            name: "Quest", owner: "Felipe", status: .free,
                            difficult: .easy, numPlayersMax: 10, numPlayersMin: 4,
                            description:
                                "Quest é um jogo mt bom para jogar com amigos, bla bla bla",
                            imageUrl:
                                "https://storage.googleapis.com/ludopedia-capas/35643_t.jpg"
                        )
                    ]) { game in
                        Button {
                            router.push(to: .game(game.id))
                        } label: {
                            BoardGameListTile(game: game)
                        }
                        .buttonStyle(.plain)

                    }
                }
            }
            .padding(.top, 16)
            .padding(.horizontal, 24)
        }
        .background(Color.uiBackground)
        .onAppear {
            Task {
                await vm.fetchGames()
                print(vm.gameList)
            }
        }
        .sheet(isPresented: $isShowing) {
            ScannerView(isShowing: $isShowing) { value in
                router.push(to: .game(value))
            }
            .presentationDetents([.medium, .large])
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    GameListView()
}
