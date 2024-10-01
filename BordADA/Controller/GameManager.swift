//
//  BoardGameManager.swift
//  BordADA
//
//  Created by André Wozniack on 01/10/24.
//

import Foundation


class GameManager {
    private var boardGame: BoardGame

    init(boardGame: BoardGame) {
        self.boardGame = boardGame
    }

    func getGame() -> BoardGame {
        return boardGame
    }

    func updateGame(name: String? = nil, owner: String? = nil, status: GameStatus? = nil, numPlayersMax: Int? = nil, numPlayersMin: Int? = nil, description: String? = nil) {
        if let name = name {
            boardGame.name = name
        }
        if let owner = owner {
            boardGame.owner = owner
        }
        if let status = status {
            boardGame.status = status
        }
        if let numPlayersMax = numPlayersMax {
            boardGame.numPlayersMax = numPlayersMax
        }
        if let numPlayersMin = numPlayersMin {
            boardGame.numPlayersMin = numPlayersMin
        }
        if let description = description {
            boardGame.description = description
        }
    }

    func deleteGame() {
        print("\(boardGame.name) deleted.")
    }
}

