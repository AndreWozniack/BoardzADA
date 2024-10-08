//
//  GameDescriptionSection.swift
//  BordADA
//
//  Created by André Wozniack on 07/10/24.
//

import SwiftUI

struct GameDescriptionSection: View {
    let description: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Descrição")
                    .font(.caption)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            Text(description)
        }
        .padding(.top, 8)
    }
}

#Preview {
    GameDescriptionSection(description: "Descrição maneira")
}
