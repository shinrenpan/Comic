//
//  Bundle+Extensions.swift
//
//  Created by Shinren Pan on 2024/5/25.
//

import Foundation

public extension Bundle {
    var version: String {
        (infoDictionary?["CFBundleShortVersionString"] as? String) ?? "unKnown"
    }

    var build: String {
        (infoDictionary?["CFBundleVersion"] as? String) ?? "unKnown"
    }
}
