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
    let tp_jogo: String?

}

struct LDGameResponse: Codable {
    let jogos: [LDGame]
    let total: Int
}

class LudopediaManager {
    
    let url = "https://ludopedia.com.br/api/v1"
    
    let appId: String = {
        guard let id = Bundle.main.object(forInfoDictionaryKey: "LUDOPEDIA_APP_ID") as? String else {
            fatalError("LUDOPEDIA_APP_ID não foi configurado no Info.plist")
        }
        return id
    }()
    
    let appKey: String = {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "LUDOPEDIA_APP_KEY") as? String else {
            fatalError("LUDOPEDIA_APP_KEY não foi configurado no Info.plist")
        }
        return key
    }()
    
    let accessToken: String = {
        guard let token = Bundle.main.object(forInfoDictionaryKey: "LUDOPEDIA_ACCESS_TOKEN") as? String else {
            fatalError("LUDOPEDIA_ACCESS_TOKEN não foi configurado no Info.plist")
        }
        return token
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
