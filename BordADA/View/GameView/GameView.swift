//
//  GameView.swift
//  BordADA
//
//  Created by Felipe Passos on 01/10/24.
//

import RouterKit
import SwiftUI

struct GameView: View {
    var game: BoardGame

    @State private var apiResult: String = ""
    @State private var isShowing: Bool = false
    @State private var currentPlayer: Player?
    @State private var showSuccess = true
    @State private var showError = false

    @EnvironmentObject var router: Router<AppRoute>

    var body: some View {
        VStack {
            GameHeaderView(gameName: game.name)
            
            ScrollView {
                GameImageView(imageUrl: game.imageUrl)
                
                GameInfoSection(title: "Dono", text: game.owner, systemImage: "checkmark.seal.fill")

                GameDescriptionSection(description: game.description)

                GameInfoSection(
                    title: "Jogadores",
                    text: "\(game.numPlayersMin) - \(game.numPlayersMax) jogadores",
                    systemImage: "person.2.fill"
                )
                
                if game.status == .occupied {
                    if let currentPlayer = currentPlayer {
                        GameInfoSection(title: "Jogador Atual", text: currentPlayer.name, systemImage: "person.fill")
                    }
                }
            }
            .padding(24)

            if game.status == .occupied && currentPlayer?.id == UserManager.shared.currentUser?.id {
                DefaultButton(action: {
                    Task {
                        await GamesCollectionManager.shared.removeCurrentPlayer(
                            from: game.id.uuidString,
                            playerId: UserManager.shared.currentUser?.id ?? ""
                        )
                        router.pop()
                    }
                }, text: "Sair do jogo")
            } else if game.status == .free {
                DefaultButton(action: {self.isShowing.toggle()}, text: "Entrar no jogo")
            }
        }
        .background(Color.uiBackground)
        .task {
            await loadCurrentPlayer()
        }
        .sheet(isPresented: $isShowing) {
            ScannerView(isShowing: $isShowing) { value in
                Task {
                    await handleQRCodeScan(value)
                }
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showSuccess) {
            SuccessView(isShowing: $showSuccess)
        }
        .sheet(isPresented: $showError) {
            ErrorView(isShowing: $showError)
        }

    }
    
    func loadCurrentPlayer() async {
        if game.status == .occupied {
            GamesCollectionManager.shared.fetchPlayer(for: game) { player in
                self.currentPlayer = player
            }
        }
    }
    
    func handleQRCodeScan(_ qrCode: String) async {
        if let scannedGame = GamesCollectionManager.shared.freeGames.first(where: { $0.id.uuidString == qrCode }) {
            print(scannedGame.name)
            await GamesCollectionManager.shared.addCurrentPlayer(
                to: scannedGame.id.uuidString,
                playerId: UserManager.shared.currentUser?.id ?? ""
            )
            showSuccess = true
        } else {
            print("Jogo não encontrado.")
            showError = true
        }
    }

}

#Preview {
    GameView(
        game: BoardGame(
            name: "Quest",
            owner: "Felipe",
            status: .free,
            difficult: .easy,
            numPlayersMax: 5,
            numPlayersMin: 3,
            description: "É um jogo mt foda aaaaaaaa",
            duration: 5,
            waitingPlayers: [],
            imageUrl: ""
        )
    )
}

