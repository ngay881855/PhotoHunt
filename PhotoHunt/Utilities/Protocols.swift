//
//  Protocols.swift
//  PhotoHunt
//
//  Created by Ngay Vong on 10/3/20.
//

import Foundation
import UIKit

protocol PassObject: class {
    func showAlert(_ alert: UIAlertController)
    
    func configChanged()
}

extension PassObject {
    func showAlert(_ alert: UIAlertController) {}
    
    func configChanged() { }
}
