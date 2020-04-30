//
//  AppEntity.swift
//  AppEntity
//
//  Created by Fumiya Tanaka on 2020/04/30.
//  Copyright © 2020 Fumiya Tanaka. All rights reserved.
//

public struct ToDo: Codable {
    let id: Int?
    public let title: String
    
    public init(id: Int? = nil, title: String) {
        self.id = id
        self.title = title
    }
}
