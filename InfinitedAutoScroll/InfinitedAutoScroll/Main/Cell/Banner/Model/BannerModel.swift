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
        .init(imageName: "art1", mainTitle: "아트 One", subTitle: "첫번째 아트 소개", url: "https://cdn.pixabay.com/video/2019/02/05/21175-315405446_small.mp4", color: .purple),
        .init(imageName: "art2", mainTitle: "아트 Two", subTitle: "두번째 아트 소개", url: "https://cdn.pixabay.com/video/2021/04/12/70796-538877060_small.mp4", color: .green),
        .init(imageName: "art3", mainTitle: "아트 Three", subTitle: "세번째 아트 소개", url: "https://cdn.pixabay.com/video/2023/11/28/191159-889246512_small.mp4", color: .red),
        .init(imageName: "art4", mainTitle: "아트 Four", subTitle: "네번째 아트 소개", url: "https://cdn.pixabay.com/video/2024/07/27/223461_small.mp4", color: .blue)
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
