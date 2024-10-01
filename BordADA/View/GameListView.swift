//
//  GameListView.swift
//  BordADA
//
//  Created by Felipe Passos on 01/10/24.
//

import SwiftUI
import RouterKit

struct GameListView: View {
    @ObservedObject var vm = GameListViewModel()
    
    @EnvironmentObject var router: Router<AppRoute>
    
    var body: some View {
        VStack {
            
            
            List {
                Text("1* BoarADA")
                
                ForEach(vm.gameList) { game in
                    GameListTile(game: game)
                }
            }
            .onAppear {
                Task {
                    await vm.load()
                }
            }
        }
    }
}

struct GameListTile: View {
    let game: BoardGame
    
    func getColor() -> Color {
        switch(game.status) {
            case .free: .green
            case .occupied: .red
            case .reserved: .red
            case .waiting: .yellow
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(game.name)
                    .font(.headline)
                
                Circle()
                    .foregroundStyle(.red)
                    .frame(height: 10)
            }
            
            Text(game.description)
                .font(.subheadline)
        }
    }
}

#Preview {
    GameListView()
}
