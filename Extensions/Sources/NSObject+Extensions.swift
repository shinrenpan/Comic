//
//  NSObject+Extensions.swift
//
//  Created by Shinren Pan on 2024/5/21.
//

import UIKit

public extension NSObjectProtocol {
    @discardableResult func setup<Value>(_ keypath: ReferenceWritableKeyPath<Self, Value>, value: Value) -> Self {
        self[keyPath: keypath] = value
        return self
    }

    @discardableResult func setup<Value>(_ keypath: ReferenceWritableKeyPath<Self, Value>, condition: () -> Value) -> Self {
        self[keyPath: keypath] = condition()
        return self
    }
}
