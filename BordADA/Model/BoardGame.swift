//
//  BoardGame.swift
//  BordADA
//
//  Created by André Wozniack on 01/10/24.
//
import Foundation
import FirebaseFirestore

struct Player: Codable, Identifiable, Equatable, Hashable {
    @DocumentID var id: String?
    var name: String
    var email: String
    var currentGameId: String?
    var isPlaying: Bool = false
}


struct BoardGame: Codable, Identifiable, Equatable, Hashable {
    var id = UUID()
    var name: String
    var owner: String
    var status: GameStatus
    var difficult: GameDifficult
    var numPlayersMax: Int
    var numPlayersMin: Int
    var description: String
    var duration: Int
    var currentPlayer: Player?
    var waitingPlayers: [Player] = []
    var imageUrl: String
    
    init(
        name: String,
        owner: String,
        status: GameStatus,
        difficult: GameDifficult,
        numPlayersMax: Int,
        numPlayersMin: Int,
        description: String,
        duration: Int,
        currentPlayer: Player? = nil,
        waitingPlayers: [Player],
        imageUrl: String
    ) {
        self.name = name
        self.owner = owner
        self.status = status
        self.difficult = difficult
        self.numPlayersMax = numPlayersMax
        self.numPlayersMin = numPlayersMin
        self.description = description
        self.duration = duration
        self.currentPlayer = currentPlayer
        self.waitingPlayers = waitingPlayers
        self.imageUrl = imageUrl
    }
}

enum GameStatus: String, Codable, CaseIterable, Hashable {
    case free
    case occupied
    case reserved
    case waiting
}

enum GameDifficult: String, Codable, CaseIterable, Hashable {
    case easy
    case medium
    case hard
    
    var text: String {
        switch self {
        case .easy:
            return "Fácil"
        case .medium:
            return "Medio"
        case .hard:
            return "Dificil"
        }
    }
}

