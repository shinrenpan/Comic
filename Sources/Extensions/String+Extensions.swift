//
// Copyright (c) 2023 Shinren Pan
//

import CryptoKit
import UIKit

extension String {
    func toMD5() -> String? {
        guard let data = data(using: .utf8) else { return nil }
        return Insecure.MD5.hash(data: data).map { String(format: "%02hhx", $0) }.joined()
    }
}
