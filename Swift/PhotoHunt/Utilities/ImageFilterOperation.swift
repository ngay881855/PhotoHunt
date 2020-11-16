//
//  ImageFilterOperation.swift
//  PhotoHunt
//
//  Created by Ngay Vong on 10/8/20.
//

import Foundation
import UIKit

class ImageFilterOperation: Operation {
    var outputImage: UIImage?
    var inputImage: UIImage
    var filterType: CIFilterType
    
    init(inputImage: UIImage, filter: CIFilterType) {
        self.inputImage = inputImage
        self.filterType = filter
    }
    
    private var _isFinished: Bool = false
    override var isFinished: Bool {
        get {
            return self._isFinished
        }
        set {
            if _isFinished != newValue {
                willChangeValue(forKey: "isFinished")
                _isFinished = newValue
                didChangeValue(forKey: "isFinished")
            }
        }
    }
    
    private var _isCanceled: Bool = false
    override var isCancelled: Bool {
        get {
            return self._isCanceled
        }
        set {
            if self._isCanceled != newValue {
                willChangeValue(forKey: "isCancelled")
                self._isCanceled = newValue
                didChangeValue(forKey: "isCancelled")
            }
        }
    }
    
    override func start() {
        if isCancelled {
            print("ImageFilterOperation isCancelled")
            return
        }
        let cIInputImage = CIImage(image: self.inputImage)
        let cIFilter = CIFilter(name: self.filterType.rawValue)
        cIFilter?.setValue(cIInputImage, forKey: kCIInputImageKey)
        
        switch self.filterType {
        case self.filterType:
            break
            
        case .sepiaFilter:
            cIFilter?.setValue(0.5, forKey: kCIInputIntensityKey)
            
        case .bloomFilter:
            cIFilter?.setValue(0.5, forKey: kCIInputIntensityKey)
            cIFilter?.setValue(0.5, forKey: kCIInputRadiusKey)
            
        default:
            break
        }
        
        let cIOutput = cIFilter?.outputImage
        
        guard let ciImage = cIOutput else {
            isCancelled = true
            return
        }
        if let cgImage = ContextManager.sharedManager.context.createCGImage(ciImage, from: ciImage.extent) {
            self.outputImage = UIImage(cgImage: cgImage)
        }
        if isCancelled {
            print("ImageFilterOperation isCancelled")
            return
        }
        isFinished = true
    }
    
    override func cancel() {
        self.isCancelled = true
    }
}
