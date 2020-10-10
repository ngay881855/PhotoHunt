//
//  FetchApisOperation.swift
//  PhotoHunt
//
//  Created by Ngay Vong on 10/7/20.
//

import Foundation

class FetchApisOperation: Operation {
    var section: Section?
    private let urlRequest: URLRequest
    private let provider: Provider
    
    init(urlRequest: URLRequest, provider: Provider) {
        self.urlRequest = urlRequest
        self.provider = provider
    }
    
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
    
    override func start() {
        if isCancelled {
            print("return")
            return
        }
        
        ServiceManager.manager.request(withRequest: urlRequest) { (data, error) in
            guard let data = data as? Data else {
                if let error = error {
                    print(error)
                }
                return
            }
            do {
                let responseObj = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                guard let dictionary = responseObj as? [String: Any] else { return }
                var newSection: [ImageProtocol] = []
                switch self.provider.name {
                case Splash.name:
                    guard let arrayItems = dictionary["images"] as? [[String: Any]], !arrayItems.isEmpty else { return }
                    arrayItems.forEach { dictionary in
                        newSection.append(SplashImageInfo(dict: dictionary))
                    }
                case Pexels.name:
                    guard let arrayItems = dictionary["photos"] as? [[String: Any]], !arrayItems.isEmpty else { return }
                    arrayItems.forEach { dictionary in
                        newSection.append(PexelsImageInfo(dict: dictionary))
                    }
                case PixaBay.name:
                    guard let arrayItems = dictionary["hits"] as? [[String: Any]], !arrayItems.isEmpty else { return }
                    arrayItems.forEach { dictionary in
                        newSection.append(PixabayImageInfo(dict: dictionary))
                    }
                default:
                    break
                }
                if newSection.count > 0 {
                    self.section = Section(provider: self.provider, dataSource: newSection)
                }
                self.isFinished = true
            } catch {
                print(error)
                return
            }
        }
        
        if isCancelled {
            print("return")
            return
        }
    }
}
