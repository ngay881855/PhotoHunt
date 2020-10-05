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
}
