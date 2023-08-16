//
// Copyright (c) 2023 Shinren Pan
//

import UIKit

private var dataTasks = [UIImageView: URLSessionDataTask]()

// MARK: - Public Functions

extension UIImageView {
    func cancelLoadImage() {
        guard let dataTask = dataTasks[self] else {
            return
        }
        
        dataTask.cancel()
        dataTasks[self] = nil
    }
    
    func loadImage(uri: String?, holder: UIImage?) {
        guard let uri else { return }
        guard let url = URL(string: uri) else { return }
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        
        loadImage(request: request, holder: holder)
    }
    
    func loadImage(request: URLRequest, holder: UIImage?) {
        cancelLoadImage()
        
        if let image = getCacheImage(uri: request.url?.absoluteString) {
            self.image = image
            return
        }
        
        image = holder
        
        Task {
            if let data = await getImageData(request: request),
               let image = UIImage(data: data) {
                saveImage(data: data, uri: request.url?.absoluteString)
                self.image = image
            }
            
            cancelLoadImage()
        }
    }
}

// MARK: - Private Functions

private extension UIImageView {
    func getFolderName() -> String {
        "com.shinren.Comic.images"
    }
    
    func getCacheImage(uri: String?) -> UIImage? {
        guard let uri = uri else { return nil }
        guard let path = getCachePath(uri: uri) else { return nil }
        guard let data = try? Data(contentsOf: path) else { return nil }
        
        return UIImage(data: data)
    }
    
    func getCachePath(uri: String) -> URL? {
        guard let md5 = uri.toMD5() else {
            return nil
        }
        
        let fileManager = FileManager.default
        
        guard let url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let folderName = getFolderName()
        let folder = url.appendingPathComponent(folderName)
        
        do {
            try fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
            
            return folder.appendingPathComponent(md5)
        }
        catch {
            return nil
        }
    }

    func getImageData(request: URLRequest) async -> Data? {
        await withCheckedContinuation { continuation in
            let task = URLSession.shared.dataTask(with: request) { data, _, _ in
                continuation.resume(returning: data)
            }
            
            dataTasks[self] = task
            task.resume()
        }
    }
    
    func saveImage(data: Data, uri: String?) {
        guard let uri else { return }
        guard let path = getCachePath(uri: uri) else { return }
        try? data.write(to: path, options: .atomic)
    }
}
