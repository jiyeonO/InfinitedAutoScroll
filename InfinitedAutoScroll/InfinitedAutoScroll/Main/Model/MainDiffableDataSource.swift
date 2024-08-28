//
//  MainDiffableDataSource.swift
//  InfinitedAutoScroll
//
//  Created by 오지연 on 8/12/24.
//

import UIKit

final class MainDiffableDataSource: UICollectionViewDiffableDataSource<MainSection, MainItem> {
    
    init(collectionView: UICollectionView) {
        super.init(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .banner(let model):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCollectionViewCell", for: indexPath) as! BannerCollectionViewCell
                cell.set(model)
                return cell
            case .product(let model):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath) as! ProductCollectionViewCell
                cell.set(model)
                return cell
            }
        }
    }
    
}
