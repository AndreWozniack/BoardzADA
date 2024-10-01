//
//  BoardGame.swift
//  BordADA
//
//  Created by André Wozniack on 01/10/24.
//
import Foundation

struct BoardGame: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let owner: String
    let status: GameStatus
    let numPlayersMax: Int
    let numPlayersMin: Int
    let description: String
}

enum GameStatus: String, Codable, CaseIterable {
    case free
    case occupied
    case reserved
    case waiting
}

