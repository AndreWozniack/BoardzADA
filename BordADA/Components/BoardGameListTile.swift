//
//  BoardGameListTile.swift
//  BordADA
//
//  Created by Felipe Passos on 02/10/24.
//

import SwiftUI

struct BoardGameListTile: View {
    let game: BoardGame
    
    func getColor() -> Color {
        switch(game.status) {
            case .free: .green
            case .occupied: .red
            case .reserved: .red
            case .waiting: .orange
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            AsyncImage(url: URL(string: game.imageUrl)) { result in
                switch result {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    @unknown default:
                        Rectangle()
                            .foregroundStyle(.purple)
                }
            }
            .frame(width: 100, height: 100)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(game.name)
                        .font(.title2)
                        .foregroundStyle(.purple)
                        .bold()
                    
                    Spacer()
                    
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundStyle(.green)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.caption2)
                    
                    Text("\(game.numPlayersMin) - \(game.numPlayersMax) jogadores")
                        .font(.caption2)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(.white)
        .frame(maxWidth: .infinity)
        .clipShape(.rect(cornerRadius: 12))
    }
}

#Preview {
    VStack {
        BoardGameListTile(
            game: BoardGame(
                name: "Coup",
                owner: "André",
                status: .free,
                difficult: .easy,
                numPlayersMax: 2,
                numPlayersMin: 8,
                description: "",
                duration: 10,
                imageUrl: "https://storasge.googleapis.com/ludopedia-capas/35643_t.jpg"
            )
        )
    }
    .padding()
    .background(.red)
}
