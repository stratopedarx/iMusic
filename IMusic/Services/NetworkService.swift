//
//  NetworkService.swift
//  IMusic
//
//  Created by Sergey Lobanov on 28.10.2021.
//

import UIKit
import Alamofire

class NetworkService {
    // добавить возвращаемое значение мы не можем, так как на запрос в интернет уходит какое-то время.
    // в Alamofire асинхронно отрабатывает запрос. Хороший способ - это комплишен хэндлер.
    // комплишен хендлер - позволяет вернуть функцию в качестве параметра.
    // Он нам позволит обращаться к объектам из интрнета только тогда, когда мы их получим.
    // если мы хотим что бы комплишен мог передавать данные извне, то надо добавить слово escaping
    func fetchTracks(searchText: String, completion: @escaping (SearchResponse?) -> Void) {
        let url = "https://itunes.apple.com/search"
        let parametrs = ["term": searchText,
                         "limit": "20",
                         "media": "music"]
        
        AF.request(url,
                   method: .get,
                   parameters: parametrs,
                   encoding: URLEncoding.default,
                   headers: nil).response { response in
            if let error = response.error {
                print("error received requesting data \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = response.data else { return }
            
            let decoder = JSONDecoder()
            do {
                let objects = try decoder.decode(SearchResponse.self, from: data)
                completion(objects)
            } catch let jsonError {
                print("Failed to decode JSON", jsonError)
                completion(nil)
            }
        }
    }
}
