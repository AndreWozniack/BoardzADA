//
//  GameView.swift
//  BordADA
//
//  Created by Felipe Passos on 01/10/24.
//

import SwiftUI

struct GameView: View {
    var boardGame: BoardGame
    
    var body: some View {
        VStack {
            Text(boardGame.owner)
            Text(boardGame.description)
            
        }
        .navigationTitle(boardGame.name)
    }
}

#Preview {
    GameView(boardGame: BoardGame(
        id: "1234",
        name: "Quest",
        owner: "Felipe",
        status: .free,
        numPlayersMax: 5,
        numPlayersMin: 3,
        description: "É um jogo mt foda aaaaaaaa"
    ))
}
