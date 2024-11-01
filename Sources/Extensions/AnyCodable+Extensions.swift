//
//  AnyCodable+Extensions.swift
//
//  Created by Shinren Pan on 2024/5/21.
//

import AnyCodable
import UIKit

extension AnyCodable {
    subscript(index: Int) -> AnyCodable {
        anyArray?[safe: index] ?? AnyCodable(NSNull())
    }

    subscript(key: String) -> AnyCodable {
        anyDic?[key] ?? AnyCodable(NSNull())
    }

    // MARK: - Computed Properties

    var string: String? {
        value as? String
    }

    var bool: Bool? {
        value as? Bool
    }

    var int: Int? {
        value as? Int
    }

    var double: Double? {
        value as? Double
    }

    var float: Float? {
        value as? Float
    }

    var anyArray: [AnyCodable]? {
        convertToAnyArray()
    }

    var anyDic: [String: AnyCodable]? {
        convertToAnyDic()
    }

    var dic: [String: Any]? {
        anyDic?.compactMapValues { rawValue in
            rawValue.value
        }
    }

    var number: NSNumber {
        convertToNumber()
    }

    var isNull: Bool {
        value is NSNull
    }

    // MARK: - Private

    private func convertToAnyArray() -> [AnyCodable]? {
        guard let array = value as? [Any?] else {
            return nil
        }

        return array.compactMap {
            if let value = $0 as? AnyCodable {
                return value
            }
            return AnyCodable($0 ?? NSNull())
        }
    }

    private func convertToAnyDic() -> [String: AnyCodable]? {
        guard let dic = value as? [String: Any?] else {
            return nil
        }

        return dic.compactMapValues { value -> AnyCodable in
            if let value = value as? AnyCodable {
                return value
            }
            return AnyCodable(value ?? NSNull())
        }
    }

    private func convertToNumber() -> NSNumber {
        if let int {
            return NSNumber(value: int)
        }

        if let double {
            return NSNumber(value: double)
        }

        if let float {
            return NSNumber(value: float)
        }

        if let bool {
            return NSNumber(value: bool)
        }

        if let string {
            if let int = Int(string) {
                return NSNumber(value: int)
            }

            if let double = Double(string) {
                return NSNumber(value: double)
            }

            if let float = Float(string) {
                return NSNumber(value: float)
            }

            if let bool = Bool(string) {
                return NSNumber(value: bool)
            }
        }

        return NSNumber(value: 0)
    }
}
