//
//  FormTextField.swift
//  BordADA
//
//  Created by André Wozniack on 07/10/24.
//

import SwiftUI

struct FormTextField: View {
    var title: String
    var sfSymbol: String?
    var inText: String?
    @Binding var text: String
    var isMultiline: Bool = false
    var onSubmitAction: (() -> Void)? = nil
    var onChangeAction: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let sfSymbol = sfSymbol {
                    Image(systemName: sfSymbol)
                        .foregroundColor(Color.roxo)
                }
                Text(title)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.roxo)
            }
            
            if isMultiline {
                TextField(inText ?? "", text: $text)
                    .multilineTextAlignment(.leading)
                    .lineLimit(8)
                    .padding(8)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    .textInputAutocapitalization(.never)
                    .onSubmit {
                        onSubmitAction?()
                        hideKeyboard()
                    }
                    .onChange(of: text) {
                        onChangeAction?()
                    }
                
            } else {
                TextField(inText ?? "", text: $text)
                    .padding(8)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    .textInputAutocapitalization(.never)
                    .onSubmit {
                        onSubmitAction?()
                        hideKeyboard()
                    }
                    .onChange(of: text) {
                        onChangeAction?()
                    }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            hideKeyboard()
        }
    }
}

struct FormNumberField: View {
    var title: String
    var sfSymbol: String?
    var inText: String?
    @Binding var value: Int?
    var onSubmitAction: (() -> Void)? = nil
    var onChangeAction: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let sfSymbol = sfSymbol {
                    Image(systemName: sfSymbol)
                        .foregroundColor(Color.roxo)
                }
                Text(title)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.roxo)
            }
            
            TextField(inText ?? "", value: $value, format: .number)
                .padding(8)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .keyboardType(.numberPad)
                .textInputAutocapitalization(.never)
                .onSubmit {
                    onSubmitAction?()
                    hideKeyboard()
                }
                .onChange(of: value) {
                    onChangeAction?()
                }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            hideKeyboard()
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    FormTextField(
        title: "Jogadores",
        sfSymbol: "person.2.fill",
        text: .constant(""),
        isMultiline: true,
        onSubmitAction: {
            print("Submited")
        },
        onChangeAction: {
            print("Value changed")
        }
    )
}
