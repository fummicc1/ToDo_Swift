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
import AppEntity

public protocol ToDoRequest {
    func createToDo(_ todo: ToDo) throws -> Single<AppEntity.ToDo>
    func getAllToDo() throws -> Single<[ToDo]>
}

public class AppRequest {
    
    struct URLRequestBuilder {
        let paths: [String]
        let parameters: [String: String]
        let headers: [String: String]
        let method: String
        let body: Data?
    }
    
    public enum Error: Swift.Error {
        case some(Swift.Error)
        case invalidPaths
        case invalidParameters
        case unsuccessfulStatusCode(Int)
        case noResponseData
        case failedToEncode(entity: Codable)
        case failedToDecode(type: Codable.Type, data: Data)
    }
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        return session
    }()
    
    private let baseURL: String = "http://localhost:8080"
    
    public init() { }
    
    private func get<Entity: Codable>(paths: [String], paramters: [String: String] = [:], headers: [String: String] = [:]) -> Single<Entity> {
        Single.create { [weak self] observer-> Disposable in
            guard let self = self else {
                return Disposables.create()
            }
            do {
                let request = try self.buildURLRequest(URLRequestBuilder(paths: paths, parameters: paramters, headers: headers, method: "GET", body: nil))
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
                        observer(.error(Error.noResponseData))
                        return
                    }
                    guard let entity = try? JSONDecoder().decode(Entity.self, from: data) else {
                        observer(.error(Error.failedToDecode(type: Entity.self, data: data)))
                        return
                    }
                    observer(.success(entity))
                })
            } catch let error as AppRequest.Error {
                observer(.error(error))
            } catch {
                observer(.error(Error.some(error)))
            }
            return Disposables.create()
        }
    }
    
    private func create<Entity: Codable>(paths: [String], body: Data, headers: [String: String] = [:]) -> Single<Entity> {
        Single.create { [weak self] observer -> Disposable in
            guard let self = self else {
                return Disposables.create()
            }
            do {
                let request = try self.buildURLRequest(URLRequestBuilder(paths: paths, parameters: [:], headers: headers, method: "POST", body: body))
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
                        observer(.error(Error.noResponseData))
                        return
                    }
                    guard let entity = try? JSONDecoder().decode(Entity.self, from: data) else {
                        observer(.error(Error.failedToDecode(type: Entity.self, data: data)))
                        return
                    }
                    observer(.success(entity))
                })
            } catch let error as AppRequest.Error {
                observer(.error(error))
            } catch {
                observer(.error(Error.some(error)))
            }
            return Disposables.create()
        }
    }
    
    private func buildURLRequest(_ buiilder: URLRequestBuilder) throws -> URLRequest {
        guard var baseURL = URL(string: self.baseURL) else {
            fatalError()
        }
        buiilder.paths.forEach { baseURL.appendPathComponent($0) }
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            throw Error.invalidPaths
        }
        components.queryItems = []
        for (name, value) in buiilder.parameters {
            let queryItem = URLQueryItem(name: name, value: value)
            components.queryItems?.append(queryItem)
        }
        guard let url = components.url else {
            throw Error.invalidParameters
        }
        var request = URLRequest(url: url)
        request.httpMethod = buiilder.method
        request.httpBody = buiilder.body
        for (field, value) in buiilder.headers {
            request.addValue(value, forHTTPHeaderField: field)
        }
        return request
    }
}

extension AppRequest: ToDoRequest {
    public func createToDo(_ todo: ToDo) throws -> Single<AppEntity.ToDo> {
        guard let data = try? JSONEncoder().encode(todo) else {
            throw Error.failedToEncode(entity: todo)
        }
        return create(paths: ["/todo"], body: data)
    }
    
    public func getAllToDo() throws -> Single<[ToDo]> {
        get(paths: ["/todo"])
    }
}
