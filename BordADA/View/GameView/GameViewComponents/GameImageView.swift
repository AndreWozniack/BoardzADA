//
//  GameImageView.swift
//  BordADA
//
//  Created by André Wozniack on 07/10/24.
//

import SwiftUI

struct GameImageView: View {
    let imageUrl: String

    var body: some View {
        AsyncImage(url: URL(string: imageUrl)) { result in
            switch result {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
            case .empty:
                Rectangle()
                    .foregroundStyle(.purple)
            case .failure(_):
                Rectangle()
                    .foregroundStyle(.red)
            @unknown default:
                Rectangle()
                    .foregroundStyle(.purple)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    GameImageView(imageUrl: "https://storage.googleapis.com/ludopedia-capas/35643_t.jpg")
}
