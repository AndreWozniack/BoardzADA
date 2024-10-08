//
//  ErrorView.swift
//  BordADA
//
//  Created by André Wozniack on 08/10/24.
//

import Foundation
import SwiftUI

struct ErrorView: View {
    @Binding var isShowing: Bool
    
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 24){
                Spacer()
                Image(systemName: "x.circle.fill")
                    .foregroundColor(.vermelho)
                    .font(.init(.system(size: 100)))
                    .fontWeight(.bold)
                
                Text("QR Code Inválido")
                    .foregroundColor(.uiBackground)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: 185)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Button(action: {
                    isShowing.toggle()
                }) {
                    Text("Sair")
                        .foregroundColor(.vermelho)
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
        .background(Color.vermelho)
    }
}
#Preview {
    ErrorView(isShowing: .constant(true))
}
