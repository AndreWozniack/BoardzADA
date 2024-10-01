//
//  GameCollectionsManager.swift
//  BordADA
//
//  Created by André Wozniack on 01/10/24.
//

import Foundation

class GamesCollectionManager: ObservableObject {
    @Published var games: [BoardGame] = []
    
    // Create (add a new game to the collection)
    func addGame(_ game: BoardGame) {
        games.append(game)
    }

    // Read (get all games or find a specific game by id)
    func getAllGames() -> [BoardGame] {
        return games
    }
    
    func getGameById(_ id: String) -> BoardGame? {
        return games.first { $0.id == id }
    }

    // Update (using the GameManager)
    func updateGame(_ id: String, with changes: (GameManager) -> Void) {
        if let gameIndex = games.firstIndex(where: { $0.id == id }) {
            let gameManager = GameManager(boardGame: games[gameIndex])
            changes(gameManager)
            games[gameIndex] = gameManager.getGame()
        }
    }

    // Delete (remove a game from the collection)
    func removeGame(by id: String) {
        games.removeAll { $0.id == id }
    }

    // Get all available games
    func getAvailableGames() -> [BoardGame] {
        return games.filter { $0.status == .free }
    }
}
