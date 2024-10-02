//
//  GameCreateViewModel.swift
//  BordADA
//
//  Created by Felipe Passos on 01/10/24.
//

import SwiftUI

class GameCreateViewModel: ObservableObject {
    @Published var game: BoardGame = BoardGame(
        id: "",
        name: "",
        owner: "",
        status: .free,
        numPlayersMax: 1,
        numPlayersMin: 4,
        description: "",
        difficult: .easy
    )
    
    func create() async {
        print(game)
    }
}
