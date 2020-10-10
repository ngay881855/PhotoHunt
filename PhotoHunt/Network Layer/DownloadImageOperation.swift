//
//  DownloadImageOperation.swift
//  PhotoHunt
//
//  Created by Ngay Vong on 10/7/20.
//

import Foundation
import UIKit

class DownloadImageOperation: Operation {
    
    var cache = NSCache<NSString, UIImage>()
    var contentImage: UIImage?
    var url: String
    
    init(url: String) {
        self.url = url
    }
    
    override func start() {
        if isCancelled {
            print("return")
            return
        }
        
        do {
            let cacheKey = url as NSString
            
            // If an image is already in the cache -> use it, else download it, add it to cache
            if let image = cache.object(forKey: cacheKey) {
                self.contentImage = image
                completionBlock?()
                return
            } else {
                guard let url = URL(string: url) else { return }
                let data = try Data(contentsOf: url)
                
                if isCancelled {
                    print("return")
                    return
                }
                guard let image = UIImage(data: data) else { return }
                cache.setObject(image, forKey: cacheKey)
                self.contentImage = image
                completionBlock?()
            }
        } catch {
            print(error)
            return
        }
    }
}
