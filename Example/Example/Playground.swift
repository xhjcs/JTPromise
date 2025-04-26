//
//  Playground.swift
//  Example
//
//  Created by xinghanjie on 2024/10/4.
//

import Foundation
import JTPromiseKit

@objcMembers
class Playground: NSObject {
    static func play() {
        Promise(resolve: 101)
            .then { value in
                
            }
    }
}
