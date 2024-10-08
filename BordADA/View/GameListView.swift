//
//  GameListView.swift
//  BordADA
//
//  Created by Felipe Passos on 01/10/24.
//

import RouterKit
import SwiftUI
import FirebaseAuth

struct GameListView: View {
    @StateObject var vm = GamesCollectionManager.shared
    @ObservedObject var userManager = UserManager.shared
    @State var isShowing: Bool = false

    @EnvironmentObject var router: Router<AppRoute>

    var body: some View {
        VStack {
            // Cabeçalho com nome de usuário e botão de QRCode
            HStack {
                Text(userManager.currentUser?.name ?? "Usuário não logado")
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
            .background(.roxo)
            
            ScrollView {
                // Seção de jogos livres
                Text("Jogos Livres")
                    .font(.headline)
                    .padding(.top)
                
                LazyVStack {
                    ForEach(vm.freeGames) { game in
                        Button {
                            router.push(to: .game(game))
                        } label: {
                            BoardGameListTile(game: game)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Text("Jogos Ocupados")
                    .font(.headline)
                    .padding(.top)
                
                LazyVStack {
                    ForEach(vm.occupiedGames) { occupiedGame in
                        Button {
                            router.push(to: .game(occupiedGame.game))
                        } label: {
                            BoardGameListTile(game: occupiedGame.game)
                        }
                        
                    }
                }
            }
            .padding(.top, 16)
            .padding(.horizontal, 24)
            .refreshable {
                Task {
                    await vm.fetchGamesWithPlayers()
                }
            }
        }
        .background(Color.uiBackground)
        .onAppear {
            Task {
                await vm.fetchGamesWithPlayers()
            }
        }
        .sheet(isPresented: $isShowing) {
            ScannerView(isShowing: $isShowing) { value in
                Task {
                    guard let game = vm.freeGames.first(where: { $0.id.uuidString == value}) else {
                        print("Jogo não encontrado")
                        return
                    }
                    await GamesCollectionManager.shared.addCurrentPlayer(
                        to: game.id.uuidString,
                        playerId: userManager.currentUser?.id ?? ""
                    )
                    router.push(to: .game(game))
                }
            }
            .presentationDetents([.medium, .large])
        }
        .navigationBarBackButtonHidden()
        
        DefaultButton(action: {self.isShowing.toggle()}, text: "Scan")
        DefaultButton(action: {router.push(to: .gameSearch)}, text: "Criar Jogo")
    }
}

#Preview {
    GameListView()
}
