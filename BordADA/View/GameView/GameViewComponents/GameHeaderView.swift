//
//  GameHeaderVew.swift
//  BordADA
//
//  Created by André Wozniack on 07/10/24.
//

import SwiftUI

struct GameHeaderView: View {
    let gameName: String

    var body: some View {
        HStack {
            Spacer()
            Text(gameName)
                .font(.title)
                .foregroundColor(.white)
                .bold()
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
        .background(Color.roxo)
    }
}

#Preview {
    GameHeaderView(gameName: "Coup")
}
