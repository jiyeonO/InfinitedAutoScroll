//
//  MainCompositionalLayoutHandler.swift
//  InfinitedAutoScroll
//
//  Created by 오지연 on 8/12/24.
//

import UIKit
import Combine

struct MainCompositionalLayoutHandler {
    
    private let collectionView: UICollectionView
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
    }
    
    func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { section, environment -> NSCollectionLayoutSection? in
            switch section {
            case MainSection.banner.rawValue:
                // item
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .absolute(Constants.bannerHeightDimension))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                // group
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .absolute(Constants.bannerHeightDimension))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                return NSCollectionLayoutSection(group: group)
            case MainSection.product.rawValue:
                // item
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(0.5))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                // group
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .fractionalHeight(0.5))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                return NSCollectionLayoutSection(group: group)
            default:
                return nil
            }
        }
    }
    
}

// MARK: - Constants
private extension MainCompositionalLayoutHandler {
    
    enum Constants {
        static let bannerHeightDimension: CGFloat = 488.0
    }
    
}
