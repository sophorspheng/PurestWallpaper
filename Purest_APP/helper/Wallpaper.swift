//
//  Wallpaper.swift
//  Note001
//
//  Created by Sophors Pheng on 8/5/24.
//

import Foundation

struct Wallpaper {
    let id: Int
    let name: String
    let imageUrl: String
    var publicId: String
    let image: String
    
}




class WallpaperModel {
    private let urlSession = URLSession.shared
    
    var formDataList: [FormData] = []

    func fetchWallpapers(completion: @escaping (Result<[FormData], Error>) -> Void) {
        let url = URL(string: "https://nodeapi-backend.vercel.app/data")!
        urlSession.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            do {
                let formDataList = try JSONDecoder().decode([FormData].self, from: data)
                self.formDataList = formDataList
                completion(.success(formDataList))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func deleteWallpaper(withId id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://nodeapi-backend.vercel.app/delete/\(id)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        urlSession.dataTask(with: request) { _, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }.resume()
    }
}
