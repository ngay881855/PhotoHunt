//
//  DownloadImageOperation.swift
//  PhotoHunt
//
//  Created by Ngay Vong on 10/7/20.
//

import Foundation
import UIKit

class DownloadImageOperation: Operation {
    var contentImage: UIImage?
    var url: String
    
    private var _isFinished: Bool = false
    override var isFinished: Bool {
        get {
            return self._isFinished
        }
        set {
            if _isFinished != newValue {
                willChangeValue(forKey: "isFinished")
                self._isFinished = newValue
                didChangeValue(forKey: "isFinished")
            }
        }
    }
    
    private var _isCancelled: Bool = false
    override var isCancelled: Bool {
        get {
            return self._isCancelled
        }
        set {
            if self._isCancelled != newValue {
                willChangeValue(forKey: "isCancelled")
                self._isCancelled = newValue
                didChangeValue(forKey: "isCancelled")
            }
        }
    }
    
    init(url: String) {
        self.url = url
    }
    
    override func start() {
        if isCancelled {
            print("DownloadImageOperation isCancelled")
            return
        }
        
        do {
            guard let url = URL(string: url) else { return }
            let data = try Data(contentsOf: url)
            
            if isCancelled {
                print("DownloadImageOperation isCancelled")
                return
            }
            guard let image = UIImage(data: data) else { return }
            self.contentImage = image
            isFinished = true
        } catch {
            print(error)
            self.isCancelled = true
            return
        }
    }
    
    override func cancel() {
        self.isCancelled = true
    }
}
