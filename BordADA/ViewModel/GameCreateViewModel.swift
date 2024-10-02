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
        difficult: .easy,
        numPlayersMax: 1,
        numPlayersMin: 4,
        description: ""
    )
    
    func create() async {
        print(game)
    }
}
