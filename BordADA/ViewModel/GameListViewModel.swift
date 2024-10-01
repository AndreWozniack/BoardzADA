//
//  GameListViewModel.swift
//  BordADA
//
//  Created by Felipe Passos on 01/10/24.
//

import SwiftUI

class GameListViewModel: ObservableObject {
    @Published var gameList: [BoardGame] = []
    
    func load() async {
        gameList = [
            BoardGame(
                id: "1234",
                name: "Quest",
                owner: "Felipe",
                status: .free,
                numPlayersMax: 5,
                numPlayersMin: 3,
                description: "É um jogo mt foda aaaaaaaa"
            ),
            BoardGame(
                id: "12345",
                name: "Ito",
                owner: "JoyJoy",
                status: .free,
                numPlayersMax: 2,
                numPlayersMin: 10,
                description: "Conta até 100... 99..."
            )
        ]
    }
}
