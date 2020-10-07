//
//  FetchApisOperation.swift
//  PhotoHunt
//
//  Created by Ngay Vong on 10/7/20.
//

import Foundation

class FetchApisOperation: Operation {
    var contentData: Data?
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    override func start() {
        if isCancelled {
            print("return")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            
            if isCancelled {
                print("return")
                return
            }
            self.contentData = data
            completionBlock?()
        } catch {
            print(error)
            return
        }
    }
}
