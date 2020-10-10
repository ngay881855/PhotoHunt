//
//  SplashApiResponse.swift
//  PhotoHunt
//
//  Created by Ngay Vong on 10/2/20.
//

import Foundation

struct ApiResponse: Decodable {
    var images: [ContentResponse]?
    var photos: [ContentResponse]?
    var hits: [ContentResponse]?
}

struct ContentResponse: Decodable {
    var imageID: Int?
    var url: String?
    var webFormatURL: String?
    var source: SourceDetails?
    
    enum CodingKeys: String, CodingKey {
        case imageID = "id"
        case webFormatURL = "webformatURL"
        case source = "src"
    }
}

struct SourceDetails: Decodable {
    var medium: String?
}
