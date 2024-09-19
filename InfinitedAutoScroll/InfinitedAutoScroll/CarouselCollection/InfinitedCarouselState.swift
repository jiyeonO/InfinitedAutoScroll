//
//  InfinitedCarouselState.swift
//  PWM
//
//  Created by 오지연 on 9/5/24.
//

import Foundation

enum InfinitedCarouselState {
    
    case underOrigin
    case overOrigin
    case origin
    
}

extension InfinitedCarouselState {
    
    var needScrolling: Bool {
        self == .underOrigin || self == .overOrigin
    }
    
    var isOrigin: Bool {
        self == .origin
    }
    
}
