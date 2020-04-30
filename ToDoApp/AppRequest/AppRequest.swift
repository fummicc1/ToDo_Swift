//
//  AppRequest.swift
//  AppRequest
//
//  Created by Fumiya Tanaka on 2020/04/30.
//  Copyright © 2020 Fumiya Tanaka. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

public class AppRequest {
    
    public enum Error: Swift.Error {
        case some(Swift.Error)
        case invalidPaths
        case invalidParameters
        case unsuccessfulStatusCode(Int)
        case noData
        case failedToDecode(type: Codable.Type, data: Data)
    }
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        return session
    }()
    
    private let baseURL: String = "http://localhost:8080"
    
    public func get<Entity: Codable>(paths: [String], paramters: [String: String] = [:], headerFields: [String: String] = [:]) -> Single<Entity> {
        Single.create { [weak self] observer-> Disposable in
            guard let self = self else {
                return Disposables.create()
            }
            guard var baseURL = URL(string: self.baseURL) else {
                fatalError()
            }
            paths.forEach { baseURL.appendPathComponent($0) }
            guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
                observer(.error(Error.invalidPaths))
                return Disposables.create()
            }
            components.queryItems = []
            for (name, value) in paramters {
                let queryItem = URLQueryItem(name: name, value: value)
                components.queryItems?.append(queryItem)
            }
            guard let url = components.url else {
                observer(.error(Error.invalidParameters))
                return Disposables.create()
            }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            for (field, value) in headerFields {
                request.addValue(value, forHTTPHeaderField: field)
            }
            self.session.dataTask(with: request, completionHandler: { data, response, error in
                if let error = error {
                    observer(.error(Error.some(error)))
                    return
                }
                if let response = response as? HTTPURLResponse {
                    if !(200..<300).contains(response.statusCode) {
                        observer(.error(Error.unsuccessfulStatusCode(response.statusCode)))
                        return
                    }
                }
                guard let data = data else {
                    observer(.error(Error.noData))
                    return
                }
                guard let entity = try? JSONDecoder().decode(Entity.self, from: data) else {
                    observer(.error(Error.failedToDecode(type: Entity.self, data: data)))
                    return
                }
                observer(.success(entity))
            })
            return Disposables.create()
        }
    }
}
