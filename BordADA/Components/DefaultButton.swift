//
//  DefaultButton.swift
//  BordADA
//
//  Created by André Wozniack on 07/10/24.
//

import SwiftUI

struct DefaultButton: View {
    
    var action: () -> Void = {}
    var text: String = "Default Button"
    var isDestructive: Bool = false
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .foregroundColor(.white)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: 342)
                .background(isDestructive ? Color.vermelho : Color.roxo)
                .cornerRadius(16)
        }

        
    }
}

#Preview {
    DefaultButton()
}
