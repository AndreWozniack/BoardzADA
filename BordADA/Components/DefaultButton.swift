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
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .foregroundColor(.white)
//                .font(.title2)
                .fontWeight(.bold)
                .padding()
                .frame(width: 342)
                .background(Color.roxo)
                .cornerRadius(16)
        }

        
    }
}

#Preview {
    DefaultButton()
}
