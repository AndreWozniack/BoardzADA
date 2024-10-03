//
//  AppRouter.swift
//  BordADA
//
//  Created by Felipe Passos on 01/10/24.
//

import RouterKit
import SwiftUI

enum AppRoute: Routable {
    case game(String)
    case gameList
    case signIn
    case gameCreate
    case status(String)
    
    var view: any View {
        switch self {
            case .game(let id): GameView(id: id)
            case .gameList: GameListView()
            case .signIn: SignInView()
            case .gameCreate: GameCreateView()
            case .status(let id): StatusView(id: id)
        }
    }
}
