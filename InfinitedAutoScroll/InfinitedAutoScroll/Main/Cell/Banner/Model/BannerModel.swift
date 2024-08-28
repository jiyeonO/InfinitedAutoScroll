//
//  BannerModel.swift
//  InfinitedAutoScroll
//
//  Created by 오지연 on 8/12/24.
//

import Foundation
import UIKit

struct BannerModel {
    
    var id: UUID = UUID()
    
    let imageName: String
    let mainTitle: String
    let subTitle: String
    let url: URL?
    let color: UIColor
    
    init(imageName: String, mainTitle: String, subTitle: String, url: String, color: UIColor) {
        self.imageName = imageName
        self.mainTitle = mainTitle
        self.subTitle = subTitle
        self.url = URL(string: url)
        self.color = color
    }
    
}

extension BannerModel {
    
    var infinitedModel: Self {
        var infinitedModel = self
        infinitedModel.id = UUID()
        return infinitedModel
    }
    
}

extension BannerModel {
    
    static var fakes: [Self] = [
        .init(imageName: "art1", mainTitle: "아트 One", subTitle: "첫번째 아트 소개", url: "https://dywhtlvtiow1a.cloudfront.net/outputs/jeju_cbr.m3u8", color: .purple),
        .init(imageName: "art2", mainTitle: "아트 Two", subTitle: "두번째 아트 소개", url: "https://dywhtlvtiow1a.cloudfront.net/outputs/refik+anadol_cbr.m3u8", color: .green)
//        .init(imageName: "art3", mainTitle: "아트 Three", subTitle: "세번째 아트 소개", url: "https://dywhtlvtiow1a.cloudfront.net/outputs/jeju_cbr.m3u8", color: .yellow),
//        .init(imageName: "art4", mainTitle: "아트 Four", subTitle: "네번째 아트 소개", url: "https://dywhtlvtiow1a.cloudfront.net/outputs/refik+anadol_cbr.m3u8", color: .blue),
//        .init(imageName: "art5", mainTitle: "아트 Five", subTitle: "다섯번째 아트 소개", url: "https://dywhtlvtiow1a.cloudfront.net/outputs/jeju_cbr.m3u8", color: .brown)
    ]
    
}

extension BannerModel: Hashable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}
