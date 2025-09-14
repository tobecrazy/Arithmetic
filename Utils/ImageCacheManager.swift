//
//  ImageCacheManager.swift
//  Arithmetic
//
//  Created by Qwen Code on 9/14/25.
//

import Foundation
import UIKit
import SwiftUI

class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private lazy var cacheDirectory: URL? = {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let cacheDirectory = documentsDirectory.appendingPathComponent("ImageCache", isDirectory: true)
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        return cacheDirectory
    }()
    
    private init() {
        // Set cache limits
        cache.countLimit = 100 // Max 100 images in memory
        cache.totalCostLimit = 50 * 1024 * 1024 // Max 50MB memory
    }
    
    /// Get cached image from memory or disk
    func getImage(forKey key: String) -> UIImage? {
        // Check memory cache first
        if let image = cache.object(forKey: key as NSString) {
            return image
        }
        
        // Check disk cache
        if let imagePath = getImagePath(forKey: key),
           let data = try? Data(contentsOf: imagePath),
           let image = UIImage(data: data) {
            // Store in memory cache for next time
            cache.setObject(image, forKey: key as NSString)
            return image
        }
        
        return nil
    }
    
    /// Save image to both memory and disk cache
    func saveImage(_ image: UIImage, forKey key: String) {
        // Save to memory cache
        cache.setObject(image, forKey: key as NSString)
        
        // Save to disk cache
        if let imagePath = getImagePath(forKey: key),
           let data = image.pngData() ?? image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: imagePath)
        }
    }
    
    /// Download image from URL and cache it
    func downloadAndCacheImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let cacheKey = url.absoluteString
        
        // Check if already cached
        if let cachedImage = getImage(forKey: cacheKey) {
            DispatchQueue.main.async {
                completion(cachedImage)
            }
            return
        }
        
        // Download if not cached
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let image = UIImage(data: data),
                  error == nil else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // Cache the image
            self.saveImage(image, forKey: cacheKey)
            
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
    
    /// Get file path for cached image
    private func getImagePath(forKey key: String) -> URL? {
        guard let cacheDirectory = cacheDirectory else { return nil }
        let fileName = key.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? key
        return cacheDirectory.appendingPathComponent(fileName, isDirectory: false).appendingPathExtension("png")
    }
    
    /// Clear all cached images
    func clearCache() {
        cache.removeAllObjects()
        
        guard let cacheDirectory = cacheDirectory else { return }
        try? fileManager.removeItem(at: cacheDirectory)
    }
}