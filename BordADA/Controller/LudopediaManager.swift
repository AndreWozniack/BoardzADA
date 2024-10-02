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

class LudopediaManager {
    let url = "https://ludopedia.com.br/api/v1"
    
    func jogos(search: String) async -> LDGameResponse? {
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
