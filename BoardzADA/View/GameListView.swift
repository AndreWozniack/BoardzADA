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
    @State private var loadedGamesCount = 20

    @EnvironmentObject var router: Router<AppRoute>

    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(vm.gameList.prefix(loadedGamesCount), id: \.id) { game in
                        Button {
                            if userManager.currentUser?.role == .admin {
                                router.push(to: .adminGame(game))
                            }
                            router.push(to: .game(game))
                        } label: {
                            BoardGameListTile(game: game)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical)
                .onAppear {
                    if loadedGamesCount < vm.gameList.count {
                        loadedGamesCount += 10
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .scrollIndicators(.never)
            .padding(.horizontal, 24)
            .refreshable {
                Task {
                    await vm.fetchGames()
                }
            }
            HStack {
                DefaultButton(action: { self.isShowing.toggle() }, text: "Scan")
                    .shadow(radius: 5)
                
                if let player = userManager.currentUser {
                    if player.role == .admin {
                        DefaultButton(action: { router.push(to: .gameSearch) }, text: "Adicionar Jogo")
                            .shadow(radius: 5)
                    }
                }
            }
            
            .padding(.horizontal)
            .padding(.vertical)
        }
        .scrollIndicators(.never)
        .navigationBarBackButtonHidden(true)
        .defaultNavigationAppearence()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    router.push(to: .settings)
                }) {
                    Text(Image(systemName: "gear"))
                        .bold()
                }
            }
        }
        .navigationTitle("BoardzADA")
        .navigationBarTitleDisplayMode(.large)
        .background(Color.uiBackground)
        .sheet(isPresented: $isShowing) {
            ScannerView(isShowing: $isShowing) { value in
                Task {
                    
                    guard let game = vm.freeGames.first(where: { $0.id.uuidString == value}) else {
                        print("Jogo não encontrado")
                        return
                    }
                    
                    router.push(to: .game(game))
                    await GamesCollectionManager.shared.addCurrentPlayer(
                        to: game.id.uuidString,
                        playerID: userManager.currentUser!.id ?? ""
                    )

                }
            }
            .presentationDetents([.medium, .large])
        }
        .onAppear {
            vm.startListening()
        }
        .onDisappear {
            vm.stopListening()
        }
    }
}

#Preview {
    GameListView()
}
