//
// Copyright (c) 2023 Shinren Pan
//

import UIKit
import WebParser

extension Reader.Views {
    final class Cell: UICollectionViewCell {
        lazy var imgView = makeImgView()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            addImgView()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            imgView.cancelLoadImage()
        }
    }
}

// MARK: - Reload Something

extension Reader.Views.Cell {
    func reloadUI(uri: String) {
        if let request = makeRequest(uri: uri) {
            imgView.loadImage(request: request, holder: nil)
        }
        else {
            imgView.image = nil
        }
    }
}

// MARK: - Add Something

private extension Reader.Views.Cell {
    func addImgView() {
        contentView.addSubview(imgView)
        NSLayoutConstraint.activate([
            imgView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imgView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}

// MARK: - Make Something

private extension Reader.Views.Cell {
    func makeImgView() -> UIImageView {
        let result = UIImageView(frame: .zero)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.contentMode = .scaleAspectFit
        return result
    }
    
    func makeRequest(uri: String) -> URLRequest? {
        // 先 decode 再 encode
        // 因為有些網址很奇怪, ex:
        // https://i.hamreus.com/ps3/g/gjszstgtl_xzh/第22.1话/0%20%281%29%20%E6%8B%B7%E8%B4%9D.jpg.webp
        // 話數沒 encode, 但是圖片有 encode
        // 所以都先 decode 變成 https://i.hamreus.com/ps3/g/gjszstgtl_xzh/第22.1话/0 (1) 拷贝.jpg.webp
        // 再 encode 成 https://i.hamreus.com/ps3/g/gjszstgtl_xzh/%E7%AC%AC22.1%E8%AF%9D/0%20(1)%20%E6%8B%B7%E8%B4%9D.jpg.webp
        guard let uri = uri.removingPercentEncoding?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        
        guard let url = URL(string: uri) else {
            return nil
        }
        
        var result = URLRequest(url: url)
        result.allHTTPHeaderFields = [
            "User-Agent": WebParser.UserAgent.safari.desc,
            "Referer": "https://tw.manhuagui.com"
        ]
        
        return result
    }
}
