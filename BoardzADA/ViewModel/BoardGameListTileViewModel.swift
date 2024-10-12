//
//  BoardGameListTileViewModel.swift
//  BoardzADA
//
//  Created by André Wozniack on 11/10/24.
//

import Foundation
import FirebaseFirestore

class BoardGameListTileViewModel: ObservableObject {
    @Published var player: Player?
    @Published var game: BoardGame
    private var listener: ListenerRegistration?

    init(game: BoardGame) {
        self.game = game
        Task {
            await fetchCurrentPlayer()
        }
        startListeningForChanges()
    }

    deinit {
        listener?.remove()
    }

    private func startListeningForChanges() {
        listener = Firestore.firestore().collection("games").document(game.id.uuidString)
            .addSnapshotListener { [weak self] documentSnapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Erro ao escutar mudanças no jogo: \(error.localizedDescription)")
                    return
                }
                
                guard let document = documentSnapshot, document.exists else {
                    print("Documento do jogo não encontrado.")
                    return
                }
                
                if let updatedGame = try? document.data(as: BoardGame.self) {
                    DispatchQueue.main.async {
                        self.game = updatedGame
                        Task {
                            await self.fetchCurrentPlayer()
                        }
                    }
                }
            }
    }
    
    func fetchCurrentPlayer() async {
        guard let playerRef = game.currentPlayerRef else { return }
        if let player = await UserManager.shared.fetchPlayer(from: playerRef) {
            await MainActor.run {
                self.player = player
            }
        }
    }
}
