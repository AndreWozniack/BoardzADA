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
    var isPlaying: Bool = false
    var role: PlayerRole
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
    var currentPlayerRef: DocumentReference? // Usando referência ao jogador
    var waitingPlayerRefs: [DocumentReference] = [] // Referências para a fila de espera
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
        currentPlayerRef: DocumentReference? = nil, // Referência ao jogador
        waitingPlayerRefs: [DocumentReference] = [], // Lista de referências aos jogadores
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
        self.currentPlayerRef = currentPlayerRef
        self.waitingPlayerRefs = waitingPlayerRefs
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


enum PlayerRole: String, Hashable, Codable, CaseIterable {
    case user
    case admin
    
    var text: String {
        switch self {
        case .user:
            return "Player"
        case .admin:
            return "Adimin"
        }
    }
}
