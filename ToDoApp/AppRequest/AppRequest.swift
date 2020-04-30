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
        case unsuccessfulStatusCode(Int)
        case noData
        case failedToDecode(type: Codable.Type, data: Data)
    }
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        return session
    }()
    
    private func get<Entity: Codable>(request: URLRequest) -> Single<Entity> {
        Single.create { [weak self] observer-> Disposable in
            self?.session.dataTask(with: request, completionHandler: { data, response, error in
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
