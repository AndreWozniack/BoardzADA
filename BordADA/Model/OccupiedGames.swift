//
//  GamesWithPlayer.swift
//  BordADA
//
//  Created by André Wozniack on 07/10/24.
//

import Foundation

struct OccupiedGames: Codable, Identifiable{
    var id: String {
        return game.id.uuidString
    }
    var player: Player
    var game: BoardGame
    
    init(player: Player, game: BoardGame) {
        self.player = player
        self.game = game
    }
}
