//
//  FilterUIImage.swift
//  PhotoHunt
//
//  Created by Ngay Vong on 10/12/20.
//

import Foundation
import UIKit

class FilterImage {
    var filterType: CIFilterType
    var image: UIImage
    
    init(filterType: CIFilterType, image: UIImage) {
        self.filterType = filterType
        self.image = image
    }
}
