//
//  BoardGameListTileViewModel.swift
//  BoardzADA
//
//  Created by André Wozniack on 11/10/24.
//
import Foundation

class BoardGameListTileViewModel: ObservableObject {
    @Published var player: Player?
    let game: BoardGame

    init(game: BoardGame) {
        self.game = game
        Task {
            await fetchCurrentPlayer()
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
