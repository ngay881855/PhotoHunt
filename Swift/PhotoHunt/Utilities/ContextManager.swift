//
//  ContextManager.swift
//  PhotoHunt
//
//  Created by Ngay Vong on 10/11/20.
//

import Foundation
import UIKit

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
