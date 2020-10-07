//
//  SplashApiResponse.swift
//  PhotoHunt
//
//  Created by Ngay Vong on 10/2/20.
//

import Foundation

struct Section {
    var provider: Provider
    var dataSource: [ImageProtocol] = []
}

protocol ImageProtocol: Decodable {
    var imageUrl: String? { get }
    
    init(dict: [String: Any])
}

struct SplashImageInfo: ImageProtocol {
    var imageUrl: String?
    
    init(dict: [String: Any]) {
        imageUrl = dict["url"] as? String
    }
}

struct PexelsImageInfo: ImageProtocol {
    var imageUrl: String?
    
    init(dict: [String: Any]) {
        self.imageUrl = dict["medium"] as? String
    }
}

struct PixabayImageInfo: ImageProtocol {
    var imageUrl: String?
    
    init(dict: [String: Any]) {
        self.imageUrl = dict["webformatURL"] as? String
    }
}
