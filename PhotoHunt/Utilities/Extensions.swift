//
//  Extensions.swift
//  PhotoHunt
//
//  Created by Ngay Vong on 10/2/20.
//

import Foundation
import UIKit

extension UIImageView {
    func downloadImage(with url: URL) {
        /*
         global = background thread that is managed by the system
         need to put downloading the image on background thread,
         if we don't do this it will cause lagging when scrolling
         */
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: url)
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    print("downloaded image url")
                    self.image = image
                }
            } catch {
                print(error)
            }
        }
    }
}
