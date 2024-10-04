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
                name: "Quest",
                owner: "Felipe",
                status: .free,
                difficult: .easy,
                numPlayersMax: 5,
                numPlayersMin: 3,
                description: "É um jogo mt foda aaaaaaaa",
                duration: 5,
                imageUrl: ""
            ),
            BoardGame(
                name: "Ito",
                owner: "JoyJoy",
                status: .occupied,
                difficult: .easy,
                numPlayersMax: 2,
                numPlayersMin: 10,
                description: "Conta até 100... 99...",
                duration: 5,
                imageUrl: ""
            )
        ]
        
    }
}
