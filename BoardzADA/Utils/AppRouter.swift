//
//  AppRouter.swift
//  BordADA
//
//  Created by Felipe Passos on 01/10/24.
//

import RouterKit
import SwiftUI

enum AppRoute: Routable {
    case game(BoardGame)
    case gameList
    case signIn
    case gameSearch
    case gameForm(LDGame)
    
    var view: any View {
        switch self {
            case .game(let game): GameView(game: game)
            case .gameList: GameListView()
            case .signIn: SignInView()
            case .gameSearch: GameSearchView()
            case .gameForm(let game): GameFormView(selectedGame: game)
            
        }
    }
}