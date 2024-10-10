//
//  DefaultText.swift
//  BordADA
//
//  Created by André Wozniack on 08/10/24.
//

import SwiftUI

struct DefaultText: View {
    var text: String
    var sfSymbol: String?
    
    var body: some View {
        HStack (spacing: 4){
            if let symbol = sfSymbol {
                Text(.init(systemName: symbol))
                    .font(.system(size: 20))
                    .bold()
                    .foregroundColor(.roxo)
            }
            
            Text(text)
                .font(.system(size: 20))
                .bold()
                .foregroundColor(.roxo)
        }
    }
}

#Preview {
    DefaultText(text: "Texto padrão")
}
