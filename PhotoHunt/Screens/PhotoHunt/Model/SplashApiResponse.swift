//
//  SplashApiResponse.swift
//  PhotoHunt
//
//  Created by Ngay Vong on 10/2/20.
//

import Foundation

struct SplashApiResponse: Decodable {
    var images: [Image]?
}

struct Image: Decodable {
    var imageID: Int?
    var smallImageURL: String?
    var largeImageURL: String?
    var sourceID: Int?
    var copyright: String?
    var site: String?
    
    enum CodingKeys: String, CodingKey {
        case imageID = "id"
        case smallImageURL = "url"
        case largeImageURL = "large_url"
        case sourceID = "source_id"
    }
}
