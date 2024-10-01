//
//  BoardGame.swift
//  BordADA
//
//  Created by André Wozniack on 01/10/24.
//
import Foundation

struct BoardGame: Codable, Identifiable, Equatable, Hashable {
    var id: String
    var name: String
    var owner: String
    var status: GameStatus
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

