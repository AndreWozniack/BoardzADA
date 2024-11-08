//
//  LudopediaManager.swift
//  BordADA
//
//  Created by Felipe Passos on 01/10/24.
//

import Alamofire
import Foundation

struct LDGame: Codable, Identifiable, Equatable, Hashable {
    var id: Int { id_jogo }
    let id_jogo: Int
    let nm_jogo: String
    let nm_original: String?
    let thumb: String?
    let link: String?

}

struct LDGameResponse: Codable {
    let jogos: [LDGame]
    let total: Int
}

class LudopediaManager {
    
    let url = "https://ludopedia.com.br/api/v1"
    
    let appId: String = {
        return "dbd21ab8f20a64de"
    }()
    
    let appKey: String = {
        return "f4d37c06a607a4f0fa501453d291cd64"
    }()
    
    let accessToken: String = {
        return "803a4569d210a5d3e15016c8d831cf1f"
    }()


    func jogos() async -> LDGameResponse? {
        
        let urlComponents = URLComponents(string: "\(url)/jogos")


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
            let (data, _) = try await URLSession.shared.data(for: request)
            do {
                
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response Data: \(jsonString)")
                }
                
                let result = try JSONDecoder().decode(LDGameResponse.self, from: data)
                return result
            } catch {
                print("Erro ao decodificar a resposta: \(error.localizedDescription)")
                return nil
            }
        } catch {
            print("Erro na requisição: \(error.localizedDescription)")
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
               let (data, _) = try await URLSession.shared.data(for: request)
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
