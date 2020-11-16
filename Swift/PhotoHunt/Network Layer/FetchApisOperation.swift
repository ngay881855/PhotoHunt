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
            if self._isFinished != newValue {
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
    
    override func start() {
        if isCancelled {
            print("FetchApisOperation isCancelled")
            return
        }
        
        ServiceManager.manager.request(withRequest: urlRequest) { data, error in
            guard let data = data as? Data else {
                if let error = error {
                    print(error)
                }
                self.isCancelled = true
                return
            }
            
            if self.isCancelled {
                print("FetchApisOperation isCancelled")
                return
            }
            
            self.section = self.convertDataToSection(data: data, provider: self.provider)
            self.isFinished = true
        }
        
        if isCancelled {
            print("FetchApisOperation isCancelled")
            return
        }
    }
    
    private func convertDataToSection(data: Data, provider: Provider) -> Section? {
        do {
            let responseObj = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            guard let dictionary = responseObj as? [String: Any] else { return nil }
            var newSection: [ImageProtocol] = []
            switch self.provider.name {
            case Splash.name:
                guard let arrayItems = dictionary["images"] as? [[String: Any]], !arrayItems.isEmpty else { return nil }
                arrayItems.forEach { dictionary in
                    newSection.append(SplashImageInfo(dict: dictionary))
                }
                
            case Pexels.name:
                guard let arrayItems = dictionary["photos"] as? [[String: Any]], !arrayItems.isEmpty else { return nil }
                arrayItems.forEach { dictionary in
                    newSection.append(PexelsImageInfo(dict: dictionary))
                }
                
            case PixaBay.name:
                guard let arrayItems = dictionary["hits"] as? [[String: Any]], !arrayItems.isEmpty else { return nil }
                arrayItems.forEach { dictionary in
                    newSection.append(PixabayImageInfo(dict: dictionary))
                }
                
            default:
                break
            }
            if !newSection.isEmpty {
                return Section(provider: self.provider, dataSource: newSection)
            } else {
                return nil
            }
        } catch {
            print(error)
            return nil
        }
    }
}
