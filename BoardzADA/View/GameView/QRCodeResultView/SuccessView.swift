//
//  SucessesView.swift
//  BordADA
//
//  Created by André Wozniack on 08/10/24.
//

import Foundation
import SwiftUI

struct SuccessView: View {
    @Binding var isShowing: Bool
    
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 24){
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.uiBackground)
                    .font(.init(.system(size: 100)))
                    .fontWeight(.bold)
                
                Text("Começou a jogar!")
                    .foregroundColor(.uiBackground)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: 185)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Button(action: {
                    isShowing.toggle()
                }) {
                    Text("Vambora")
                        .foregroundColor(.roxo)
                        .fontWeight(.bold)
                        .padding()
                        .background(Color.uiBackground)
                        .cornerRadius(16)
                }
                Spacer()
            }
            Spacer()
        }

        .ignoresSafeArea()
        .background(Color.roxo)
    }
}
#Preview {
    SuccessView(isShowing: .constant(true))
}

