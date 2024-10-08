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
    @State private var waitingPlayers: [Player] = []
    @State private var showSuccess = false
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
                
                if game.status == .occupied, let currentPlayer = currentPlayer {
                    GameInfoSection(title: "Jogador Atual", text: currentPlayer.name, systemImage: "person.fill")
                    
                    GameQueueView(currentPlayer: currentPlayer, waitingPlayers: waitingPlayers)
                }
                
                if game.status == .occupied && currentPlayer?.id == UserManager.shared.currentUser.id {
                    DefaultButton(action: {
                        Task {
                            await GamesCollectionManager.shared.removeCurrentPlayer(
                                from: game.id.uuidString
                            )
                            router.pop()
                        }
                    }, text: "Sair do jogo", isDestructive: true)

                } else if game.status == .occupied {
                    DefaultButton(
                        action: {
                            if currentPlayer?.id != UserManager.shared.currentUser.id && !waitingPlayers.contains(where: { $0.id == UserManager.shared.currentUser.id }) {
                                Task {
                                    await GamesCollectionManager.shared.addPlayerToWaitingList(
                                        gameId: game.id.uuidString,
                                        playerID: UserManager.shared.currentUser.id ?? ""
                                    )
                                    print("Você foi adicionado à lista de espera")
                                }
                            } else {
                                print("Jogador já está jogando ou na fila!")
                            }
                        },
                        text: "Entrar na fila")
                    
                } else if game.status == .free {
                    DefaultButton(action: {self.isShowing.toggle()}, text: "Entrar no jogo")
                }
            }
            .padding(24)
        }
        .background(Color.uiBackground)
        .task {
            await loadCurrentPlayerAndWaitingList()
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
    
    func loadCurrentPlayerAndWaitingList() async {
        if game.status == .occupied {
            // Carregar o jogador atual através da referência
            GamesCollectionManager.shared.fetchPlayer(from: game.currentPlayerRef!) { player in
                self.currentPlayer = player
            }
            // Carregar os jogadores da fila de espera
            GamesCollectionManager.shared.fetchWaitingPlayers(from: game.waitingPlayerRefs) { players in
                self.waitingPlayers = players
            }
        }
    }
    
    func handleQRCodeScan(_ qrCode: String) async {
        if let scannedGame = GamesCollectionManager.shared.freeGames.first(where: { $0.id.uuidString == qrCode }) {
            print(scannedGame.name)
            await GamesCollectionManager.shared.addCurrentPlayer(
                to: scannedGame.id.uuidString,
                playerID: UserManager.shared.currentUser.id ?? ""
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
            status: .occupied,
            difficult: .easy,
            numPlayersMax: 5,
            numPlayersMin: 3,
            description: "É um jogo mt foda aaaaaaaa",
            duration: 5,
            waitingPlayerRefs: [],
            imageUrl: ""
        )
    )
}

