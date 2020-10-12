//
//  ContextManager.swift
//  PhotoHunt
//
//  Created by Ngay Vong on 10/11/20.
//
import UIKit
import Foundation

class ContextManager {
    
    static let sharedManager = ContextManager()
    
    private init() { }
    
    private let _context = CIContext()
    
    var context: CIContext {
        {
            return self._context
        }()
    }
}
