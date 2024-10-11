//
//  TittleWithText.swift
//  BordADA
//
//  Created by André Wozniack on 08/10/24.
//

import Foundation
import SwiftUI


struct TittleWithText: View {
    
    var title: String
    var sfSymbolTitle: String?
    var titleSize: CGFloat?
    var text: String?
    var sfSymbol: String?
    var textSize: CGFloat?
    var isMultiline: Bool = false
    var alignment: HorizontalAlignment = .leading
    
    var body: some View {
        VStack(alignment: alignment, spacing: 10) {
            HStack (spacing: 4){
                if let symbol = sfSymbolTitle {
                    Text(.init(systemName: symbol))
                        .font(.system(size: titleSize ?? 20))
                        .fontWeight(.bold)
                        .foregroundColor(.roxo)
                }
                
                Text(title)
                    .font(.system(size: titleSize ?? 20))
                    .fontWeight(.bold)
                    .foregroundColor(.roxo)
            }
            if let text = text {
                HStack (spacing: 4){
                    if let symbol = sfSymbol {
                        Text(.init(systemName: symbol))
                            .font(.system(size: textSize ?? 17))
                            .foregroundColor(.roxo)
                    }
                    
                    if isMultiline {
                        Text(text)
                            .font(.system(size: textSize ?? 17))
                            .foregroundColor(.roxo)
                            .multilineTextAlignment(.leading)
                            
                    } else {
                        Text(text)
                            .font(.system(size: textSize ?? 17))
                            .foregroundColor(.roxo)
                    }
                }
            }
            
        }
    }
}

#Preview {
    TittleWithText(title: "Descrição", sfSymbolTitle: "person.2.fill")
}
