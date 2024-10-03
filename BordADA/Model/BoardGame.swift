//
//  BoardGame.swift
//  BordADA
//
//  Created by André Wozniack on 01/10/24.
//
import Foundation

struct Player: Codable, Identifiable, Equatable, Hashable {
    var id = UUID()
    var name: String
    var email: String
    var currentGameId: String?
    var isPlaying: Bool = false
    var waitingForGameIds: [String] = []
}


struct BoardGame: Codable, Identifiable, Equatable, Hashable {
    var id = UUID().uuidString
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
}

