//
//  DefaultText.swift
//  BordADA
//
//  Created by André Wozniack on 08/10/24.
//

import SwiftUI

struct DefaultText: View {
    var text: String
    
    var body: some View {
        Text(text)
            .font(.title2)
            .bold()
            .foregroundColor(.roxo)
    }
}

#Preview {
    DefaultText(text: "Texto padrão")
}
