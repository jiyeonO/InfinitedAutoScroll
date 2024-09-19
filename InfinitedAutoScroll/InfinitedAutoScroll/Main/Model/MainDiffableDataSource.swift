//
//  MainDiffableDataSource.swift
//  InfinitedAutoScroll
//
//  Created by 오지연 on 8/12/24.
//

import UIKit

final class MainDiffableDataSource: UICollectionViewDiffableDataSource<Int, BannerModel> {
    
    init(collectionView: UICollectionView) {
        super.init(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCollectionViewCell", for: indexPath) as! BannerCollectionViewCell
            cell.set(item)
            return cell
        }
    }
    
}
