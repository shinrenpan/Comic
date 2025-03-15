//
//  Detail.swift
//  DataBase
//
//  Created by Joe Pan on 2025/3/5.
//

import SwiftData

@Model public final class Detail: @unchecked Sendable {
    public var comic: Comic?
    /// 描述
    public var desc: String
    /// 作者
    public var author: String

    init(comic: Comic? = nil, desc: String, author: String) {
        self.comic = comic
        self.desc = desc
        self.author = author
    }
}
