//
//  ImageLoader.swift
//  TakeHome
//
//  Created by Sebastian Cain on 3/1/26.
//

import UIKit

class ImageLoader {
    static let shared = ImageLoader()
    private let cache = NSCache<NSString, UIImage>()
    
    private let watermarkProviderUrl = URL(string: "https://us-central1-copilot-take-home.cloudfunctions.net/watermark")!
    
    func load(url: URL) async throws -> UIImage {
        if let image = cache.object(forKey: url.absoluteString as NSString) {
            return image
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        var watermarkRequest = URLRequest(url: watermarkProviderUrl)
        watermarkRequest.httpMethod = "POST"
        watermarkRequest.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        watermarkRequest.setValue("\(data.count)", forHTTPHeaderField: "Content-Length")
        watermarkRequest.httpBody = data

        let (watermarkedData, _) = try await URLSession.shared.data(for: watermarkRequest)
        
        guard let image = UIImage(data: watermarkedData) else {
            throw NSError(domain: "ImageLoader", code: 0, userInfo: nil)
        }
        
        cache.setObject(image, forKey: url.absoluteString as NSString)
        return image
    }
}
