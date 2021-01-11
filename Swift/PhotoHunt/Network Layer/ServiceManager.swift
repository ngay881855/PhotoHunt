//
//  ServiceManager.swift
//  PhotoHunt
//
//  Created by Ngay Vong on 10/4/20.
//

import Foundation

@objc class ServiceManager: NSObject {
    static let manager = ServiceManager()
    
    @objc func request(withRequest urlRequest: URLRequest, completed: @escaping (Any?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse, (response.statusCode == 200) else {
                completed(nil, error)
                return
            }
            
            completed(data, nil)
            return
        }
        task.resume() // calls the service
    }
}
