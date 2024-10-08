//
//  SearchGameView.swift
//  BordADA
//
//  Created by André Wozniack on 07/10/24.
//

import SwiftUI

struct SearchGameView: View {
    var game: LDGame
    
    var body: some View {
        HStack(alignment: .center, spacing: 12){
            GameImageView(imageUrl: game.thumb ?? "")
                .frame(width: 150, height: 150)
            Spacer()
            Text(game.nm_jogo)
                .font(.title2)
                .bold()
                .foregroundColor(.roxo)
            
            Spacer()
        }
        .background(Color.uiBackground)
        .padding(8)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.clear)
                .stroke(.roxo)
        }
    }
}

#Preview {
    SearchGameView(game: LDGame(
        id_jogo: 1,
        nm_jogo: "Quest",
        nm_original: "Quest",
        thumb: "https://storage.googleapis.com/ludopedia-capas/35643_t.jpg",
        link: "Link de compra",
        tp_jogo: "Tipo"
    ))
}