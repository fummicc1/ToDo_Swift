//
//  AppDomain.swift
//  AppDomain
//
//  Created by Fumiya Tanaka on 2020/04/30.
//  Copyright © 2020 Fumiya Tanaka. All rights reserved.
//

import RxSwift
import RxRelay
import AppRequest
import AppEntity

public class AppDomain {
    
    public enum Error: Swift.Error {
        case emptyTitle
    }
    
    let apiRequest: ToDoRequest = AppRequest()
    
    func createToDo(title: String) -> Observable<Void> {
        
        if title.isEmpty {
            return Observable.error(Error.emptyTitle)
        }
        
        let todo = ToDo(title: title)
        do {
            return try self.apiRequest.createToDo(todo).asObservable().map { _ in () }
        } catch {
            return Observable.error(error)
        }
    }
    
    func getToDos() -> Observable<[AppEntity.ToDo]> {
        do {
            return try self.apiRequest.getAllToDo().asObservable()
        } catch {
            return Observable.error(error)
        }
    }
}
