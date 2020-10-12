//
//  Provider.swift
//  PhotoHunt
//
//  Created by Ngay Vong on 10/2/20.
//

import Foundation

struct Provider {
    var name: String = String()
    var baseUrl: String = String()
    var parameters: [String: String]?
    var header: [String: String]?
    var isOn: Bool = true
    var filterType: CIFilterType = .normal
    
    mutating func addQueryToParameters(with query: String) {
        switch self.name {
        case Splash.name:
            self.parameters?[Splash.query] = query
        case Pexels.name:
            self.parameters?[Pexels.query] = query
        case PixaBay.name:
            self.parameters?[PixaBay.query] = query
        default:
            break
        }
    }
}
