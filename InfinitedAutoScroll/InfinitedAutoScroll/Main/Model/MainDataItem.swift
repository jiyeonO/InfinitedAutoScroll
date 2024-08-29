//
//  MainDataItem.swift
//  InfinitedAutoScroll
//
//  Created by 오지연 on 8/12/24.
//

import Foundation

enum MainSection: Int, CaseIterable {
    
    case banner
    case product
    
}

enum MainItem {
    
    case banner(BannerCollectionCellViewModel)
    case product(ProductModel)
    
}

struct MainDataItem {
    
    let section: MainSection
    let items: [MainItem]
    
}

extension MainItem: Hashable { }

extension MainDataItem: Hashable { }
