//
//  GameViewModel.swift
//  BordADA
//
//  Created by André Wozniack on 08/10/24.
//
import SwiftUI
import FirebaseFirestore

class GameViewModel: ObservableObject {
    @Published var game: BoardGame
    @Published var currentPlayer: Player?
    @Published var waitingPlayers: [Player] = []
    
    init(game: BoardGame) {
        self.game = game
        Task {
            await loadCurrentPlayerAndWaitingList()
        }
    }
    
    @MainActor
    func loadCurrentPlayerAndWaitingList() {
        if game.status == .occupied {
            if let currentPlayerRef = game.currentPlayerRef {
                GamesCollectionManager.shared.fetchPlayer(from: currentPlayerRef) { [weak self] player in
                    guard let self = self else { return }
                    self.currentPlayer = player
                }
            }
            GamesCollectionManager.shared.fetchWaitingPlayers(from: game.waitingPlayerRefs) { [weak self] players in
                guard let self = self else { return }
                self.waitingPlayers = players
            }
        }
    }
    
    func joinGame() async {
        await GamesCollectionManager.shared.addCurrentPlayer(
            to: game.id.uuidString,
            playerID: UserManager.shared.currentUser!.id ?? ""
        )
        await MainActor.run {
            self.game.status = .occupied
        }
    }
    
    func leaveGame() async {
        await GamesCollectionManager.shared.removeCurrentPlayer(from: game.id.uuidString)
        await MainActor.run {
            self.game.status = .free
        }
    }
    
    func joinWaitingList() async {
        await GamesCollectionManager.shared.addPlayerToWaitingList(
            gameId: game.id.uuidString,
            playerID: UserManager.shared.currentUser!.id ?? ""
        )
    }
    
    func updateGame() async {
        // Implementar a lógica para atualizar o jogo, se necessário
    }
}
