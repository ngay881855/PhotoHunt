//
//  ProviderManager.swift
//  PhotoHunt
//
//  Created by Ngay Vong on 10/12/20.
//

import Foundation

class ProviderManager {
    static let sharedManager = ProviderManager()
    
    private init() {
        loadProviderData()
    }
    
    private var _providerList: [Provider] = []
    
    var providerList: [Provider] {
        get {
            return self._providerList
        }
        set {
            self._providerList = newValue
        }
    }
    
    private func loadProviderData() {
        var provider = Provider(name: Splash.name, baseUrl: Splash.baseUrl, parameters: Splash.parameters, isOn: true)
        self._providerList.append(provider)
        provider = Provider(name: Pexels.name, baseUrl: Pexels.baseUrl, parameters: Pexels.parameters, header: Pexels.headers, isOn: true)
        self._providerList.append(provider)
        provider = Provider(name: PixaBay.name, baseUrl: PixaBay.baseUrl, parameters: PixaBay.parameters, isOn: true)
        self._providerList.append(provider)
    }
}
