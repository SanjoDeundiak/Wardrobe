//
//  SharedFB.swift
//  Hello
//
//  Created by Oleksandr Deundiak on 5/27/17.
//
//

import Foundation
import TurnstileWeb

class SharedFB {
    private static var sharedInstance: SharedFB!
    
    static var fb: Facebook { return self.sharedInstance.fb }
    
    private let fb: Facebook
    private init(fb: Facebook) {
        self.fb = fb
    }
    
    class func initialize(fb: Facebook) {
        self.sharedInstance = SharedFB(fb: fb)
    }
}
