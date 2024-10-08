//
//  SimpleTileGameView.swift
//  BordADA
//
//  Created by André Wozniack on 07/10/24.
//

import SwiftUI

struct SimpleGameTile: View {
    let imageUrl: String
    let name: String

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            AsyncImage(url: URL(string: imageUrl)) { result in
                switch result {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .empty:
                    Rectangle()
                        .foregroundStyle(.yellow)
                case .failure(_):
                    Rectangle()
                        .foregroundStyle(.gray)
                @unknown default:
                    Rectangle()
                        .foregroundStyle(.purple)
                }
            }
            .frame(width: 100, height: 100)
            .cornerRadius(12)
            
            Text(name)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .lineLimit(2)
                .frame(maxWidth: 120) // Ajuste para limitar a largura do texto
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    VStack {
        SimpleGameTile(
            imageUrl: "https://storage.googleapis.com/ludopedia-capas/35643_t.jpg",
            name: "Quest"
        )
    }
    .padding()
    .background(Color.gray)
}
