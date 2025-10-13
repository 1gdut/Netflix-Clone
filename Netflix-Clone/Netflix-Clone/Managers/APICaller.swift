//
//  File.swift
//  Netflix-Clone
//
//  Created by xrt on 2025/10/13.
//

import Foundation

struct Constants {
    static let API_KEY = "40e22a49e3d91d6db28d30ae4089ab8a"
    static let baseURL = "https://api.themoviedb.org/3"
}

enum APIError: Error {
    case failedToGetData
}

class APICaller {
    static let shared = APICaller()

    func getTrendingMovies(completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard let url = URL(string: "\(Constants.baseURL)/trending/all/day?api_key=\(Constants.API_KEY)") else {
            return
        }
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            do {
                let results = try JSONDecoder().decode(TrendingMoviesResponse.self, from: data)
                completion(.success(results.results))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}