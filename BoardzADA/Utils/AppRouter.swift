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
    case adminGame(BoardGame)
    case signIn
    case gameSearch
    case gameForm(LDGame)
    case newRoot
    case settings
    
    var view: any View {
        switch self {
        case .game(let game): GameView(game: game)
        case .gameList: GameListView()
        case .adminGame(let game): AdminGameView(game: game)
        case .signIn: SignInView()
        case .gameSearch: GameSearchView()
        case .gameForm(let game): GameFormView(selectedGame: game)
        case .newRoot: RouterView<AppRoute>(rootView: .gameList, showBackButton: true)
        case .settings: SettingsView()
            
        }
    }
}
