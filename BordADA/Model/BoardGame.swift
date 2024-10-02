//
//  BoardGame.swift
//  BordADA
//
//  Created by André Wozniack on 01/10/24.
//
import Foundation

struct BoardGame: Codable, Identifiable, Equatable, Hashable {
    var id: String = UUID().uuidString
    var name: String
    var owner: String
    var status: GameStatus
    var difficult: GameDifficult
    var numPlayersMax: Int
    var numPlayersMin: Int
    var description: String
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