//
//  AppRouter.swift
//  BordADA
//
//  Created by Felipe Passos on 01/10/24.
//

import RouterKit
import SwiftUI

enum AppRoute: Routable {
    case game
    case gameList
    
    var view: any View {
        switch self {
            case .game: GameView()
            case .gameList: GameListView()
        }
    }
}
