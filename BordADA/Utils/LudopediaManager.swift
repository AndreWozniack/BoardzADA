//
//  LudopediaManager.swift
//  BordADA
//
//  Created by Felipe Passos on 01/10/24.
//

import Alamofire

struct LDGame: Codable {
    let id_jogo: Int
    let nm_jogo: String
    let nm_original: String
    let thumb: String
    let link: String
    let tp_jogo: String
}

struct LDGameResponse: Codable {
    let jogos: [LDGame]
    let total: Int
}

//APP_ID: dbd21ab8f20a64de
//APP_KEY: f4d37c06a607a4f0fa501453d291cd64
//ACESS_TOKEN (Usuário): 803a4569d210a5d3e15016c8d831cf1f
class LudopediaManager {
    let url = "https://ludopedia.com.br/api/v1"
    
    func jogos() async -> LDGameResponse? {
        let result = await AF.request(
            "\(url)/jogos",
            method: .get,
            encoding: JSONEncoding.default
        )
        .serializingDecodable(LDGameResponse.self)
        .result
        
        
        switch(result) {
            case .success(let value): return value
            case .failure(_): return nil
        }
    }
    
    func jogo(id: Int) async -> LDGame? {
        let result = await AF.request(
            "\(url)/jogos/\(id)",
            method: .get,
            encoding: JSONEncoding.default
        )
        .serializingDecodable(LDGame.self)
        .result
        
        switch(result) {
            case .success(let value): return value
            case .failure(_): return nil
        }
    }
}
