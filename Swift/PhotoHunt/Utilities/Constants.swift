//
//  Constants.swift
//  PhotoHunt
//
//  Created by Ngay Vong on 10/3/20.
//

import Foundation

enum Constants {
    static let minCharactersToSearch: Int = 5
    static let timerIntervalToSearch: Double = 2.0
}

enum Splash {
    static let query: String = "query"
    static let name = "Splash"
    static let baseUrl = "http://www.splashbase.co/api/v1/images/search"
    static let parameters = [query: ""]
}

enum Pexels {
    static let query: String = "query"
    static let name = "Pexels"
    static let baseUrl = "https://api.pexels.com/v1/search"
    static let parameters = [query: ""]
    static let headers = ["Authorization": "563492ad6f91700001000001d7f7e19ada2d4640964a4f90731831bf"]
}

enum PixaBay {
    static let query: String = "q"
    static let name = "PixaBay"
    static let baseUrl = "https://pixabay.com/api/"
    static let parameters = [
        "key": "18552487-1f1f788770c0bd9185181a8ff",
        query: "",
        "image_type": "photo"
    ]
}
