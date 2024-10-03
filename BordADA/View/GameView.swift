//
//  GameView.swift
//  BordADA
//
//  Created by Felipe Passos on 01/10/24.
//

import SwiftUI

struct GameView: View {
    var game: BoardGame
    
    var body: some View {
        VStack {
            Text(game.owner)
            
            Text(game.description)
        }
        .navigationTitle(game.name)
        .task {
            let result = await LudopediaManager().jogos()
            
            print(result)
        }
    }
}

#Preview {
    GameView(game: BoardGame(
        name: "Quest",
        owner: "Felipe",
        status: .free,
        difficult: .easy,
        numPlayersMax: 5,
        numPlayersMin: 3,
        description: "É um jogo mt foda aaaaaaaa",
        duration: 10
    ))
}
