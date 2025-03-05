//
//  Episode.swift
//  DataBase
//
//  Created by Joe Pan on 2025/3/5.
//

import SwiftData

@Model public final class Episode: @unchecked Sendable {
    public var comic: Comic?
    /// Id
    public private(set) var id: String
    /// Index
    public private(set) var index: Int
    /// Title
    public private(set) var title: String

    public init(comic: Comic? = nil, id: String, index: Int, title: String) {
        self.comic = comic
        self.id = id
        self.index = index
        self.title = title
    }
}
