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
            ScrollView {
                VStack(alignment: .leading) {
                    LazyVStack {
                        ForEach(vm.gameList, id: \.id) { game in
                            Button {
                                router.push(to: .game(game))
                            } label: {
                                BoardGameListTile(game: game)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.vertical)
            }
            .padding(.horizontal, 24)
            .refreshable {
                Task {
                    await vm.fetchGames()
                }
            }
            HStack {
                DefaultButton(action: { self.isShowing.toggle() }, text: "Scan")
                    .shadow(radius: 5)
                if let player = UserManager.shared.currentUser {
                    if player.role == .admin {
                        DefaultButton(action: { router.push(to: .gameSearch) }, text: "Criar Jogo")
                            .shadow(radius: 5)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical)
        }
        .defaultNavigationAppearence()
        .navigationTitle("BoardzADA")
        .navigationBarTitleDisplayMode(.large)
        .background(Color.uiBackground)
        .onAppear {
            Task {
                await vm.fetchGames()
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
                        playerID: userManager.currentUser!.id ?? ""
                    )
                    router.push(to: .game(game))
                }
            }
            .presentationDetents([.medium, .large])
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    GameListView()
}
