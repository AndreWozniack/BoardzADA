//
//  GameInfoSection.swift
//  BordADA
//
//  Created by André Wozniack on 07/10/24.
//

import SwiftUI

struct GameInfoSection: View {
    let title: String
    let text: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
            Text(text)
            Spacer()
        }
        .padding(.top, 8)
    }
}

#Preview {
    GameInfoSection(title: "Criar Jogo", text: "Sla", systemImage: "checkmark.seal.fill")
}
