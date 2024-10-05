//
//  LudopediaManager.swift
//  BordADA
//
//  Created by Felipe Passos on 01/10/24.
//

import Alamofire
import Foundation

struct LDGame: Codable, Identifiable {
    var id: Int { id_jogo }
    let id_jogo: Int
    let nm_jogo: String
    let nm_original: String?
    let thumb: String?
    let link: String?
    let tp_jogo: String?
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
        let appId = "dbd21ab8f20a64de"   // Substitua pelo seu APP_ID
        let appKey = "f4d37c06a607a4f0fa501453d291cd64" // Substitua pelo seu APP_KEY
        let accessToken = "803a4569d210a5d3e15016c8d831cf1f" // Substitua pelo seu ACCESS_TOKEN


    func jogos() async -> LDGameResponse? {
        let parameters: Parameters = [
            "app_id": appId,
            "app_key": appKey
        ]

        let result = await AF.request(
            "\(url)/jogos",
            method: .get,
            parameters: parameters,
            encoding: URLEncoding.default
        )
        .serializingDecodable(LDGameResponse.self)
        .result

        switch(result) {
            case .success(let value): return value
            case .failure(let error):
                print("Erro ao obter jogos: \(error.localizedDescription)")
                return nil
        }
    }

    func jogo(id: Int) async -> LDGame? {
        let parameters: Parameters = [
            "app_id": appId,
            "app_key": appKey
        ]

        let result = await AF.request(
            "\(url)/jogos/\(id)",
            method: .get,
            parameters: parameters,
            encoding: URLEncoding.default
        )
        .serializingDecodable(LDGame.self)
        .result

        switch(result) {
            case .success(let value): return value
            case .failure(let error):
                print("Erro ao obter jogo: \(error.localizedDescription)")
                return nil
        }
    }
    func buscarJogosPorNome(nome: String) async -> [LDGame]? {
           var urlComponents = URLComponents(string: "\(url)/jogos")
           urlComponents?.queryItems = [
               URLQueryItem(name: "search", value: nome),
               URLQueryItem(name: "rows", value: "3")
           ]

           guard let url = urlComponents?.url else {
               print("URL inválida.")
               return nil
           }

           var request = URLRequest(url: url)
           request.httpMethod = "GET"
           request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
           request.addValue(appId, forHTTPHeaderField: "app_id")
           request.addValue(appKey, forHTTPHeaderField: "app_key")

           do {
               let (data, response) = try await URLSession.shared.data(for: request)
               do {
                   let result = try JSONDecoder().decode(LDGameResponse.self, from: data)
                   return result.jogos
               } catch {
                   print("Erro ao decodificar a resposta: \(error.localizedDescription)")
                   return nil
               }
           } catch {
               print("Erro na requisição: \(error.localizedDescription)")
               return nil
           }
       }
   }
