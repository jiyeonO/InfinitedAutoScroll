//
//  ProductModel.swift
//  InfinitedAutoScroll
//
//  Created by 오지연 on 8/12/24.
//

import Foundation

struct ProductModel {
    
    let id = UUID()
    let title: String
    
    init(title: String) {
        self.title = title
    }
    
}

extension ProductModel {
    
    static var fakes: [Self] = [
        .init(title: "상품1"),
        .init(title: "상품2"),
        .init(title: "상품3"),
        .init(title: "상품4"),
        .init(title: "상품5")
    ]
    
}

extension ProductModel: Hashable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}
