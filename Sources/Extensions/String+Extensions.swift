//
//  String+Extensions.swift
//
//  Created by Shinren Pan on 2024/6/2.
//

import UIKit

extension String {
    enum UserAgent {
        case iOS
        case safari
        case custom(String)
        
        var value: String {
            switch self {
            case .iOS:
                "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4.1 Mobile/15E148 Safari/604.1"
            case .safari:
                "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_3) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.5 Safari/605.1.15"
            case let .custom(string):
                string
            }
        }
    }
    
    enum JavaScript {
        case update
        case detail
        case images
        
        var value: String {
            switch self {
            case .update:
                getJavaScript(fileName: "Update")
            case .detail:
                getJavaScript(fileName: "Detail")
            case .images:
                getJavaScript(fileName: "Images")
            }
        }
    }
    
    var big5: String {
        GBig.traditionalize(self)
    }
    
    var gb: String {
        GBig.simplify(self)
    }
}

// MARK: - Private

private extension String.JavaScript {
    // MARK: Get Something

    func getJavaScript(fileName: String) -> String {
        if let path = Bundle.main.url(forResource: fileName, withExtension: "js"),
           let data = try? Data(contentsOf: path),
           let result = String(data: data, encoding: .utf8)
        {
            return result
        }
        else {
            return ""
        }
    }
}
