//
//  GameViewModel.swift
//  BordADA
//
//  Created by André Wozniack on 08/10/24.
//

import Foundation
import FirebaseFirestore

class GameViewModel: ObservableObject {
    @Published var game: BoardGame
    @Published var currentPlayer: Player?
    @Published var waitingPlayers: [Player] = []
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?

    init(game: BoardGame) {
        self.game = game
        self.startListeningForChanges()
        loadCurrentPlayerAndWaitingList()
    }

    deinit {
        listener?.remove()
    }

    func startListeningForChanges() {
        listener = db.collection("games").document(game.id.uuidString)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Erro ao escutar mudanças no jogo: \(error.localizedDescription)")
                    return
                }

                guard let snapshot = snapshot, snapshot.exists else {
                    print("Documento do jogo não encontrado.")
                    return
                }

                if let updatedGame = try? snapshot.data(as: BoardGame.self) {
                    DispatchQueue.main.async {
                        self.game = updatedGame
                        self.loadCurrentPlayerAndWaitingList()
                    }
                }
            }
    }

    func loadCurrentPlayerAndWaitingList() {
        if let playerRef = game.currentPlayerRef {
            playerRef.getDocument { [weak self] document, error in
                guard let document = document, let player = try? document.data(as: Player.self) else { return }
                DispatchQueue.main.async {
                    self?.currentPlayer = player
                }
            }
        }

        if !game.waitingPlayerRefs.isEmpty {
            let group = DispatchGroup()
            var players: [Player] = []

            for playerRef in game.waitingPlayerRefs {
                group.enter()
                playerRef.getDocument { document, error in
                    if let document = document, let player = try? document.data(as: Player.self) {
                        players.append(player)
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
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
    
    func leaveWaitingList() async {
        await GamesCollectionManager.shared.removePlayerFromWaitingList(
            gameId: game.id.uuidString,
            playerID: UserManager.shared.currentUser!.id ?? ""
        )
    }
    
    func updateGame() async {
        Task {
           await GamesCollectionManager.shared.addGame(game)
        }
    }
}
