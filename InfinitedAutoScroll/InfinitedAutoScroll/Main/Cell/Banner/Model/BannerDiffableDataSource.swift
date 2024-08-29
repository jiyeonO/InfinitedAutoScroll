//
//  BannerDiffableDataSource.swift
//  PWM
//
//  Created by D프로젝트노드_오지연 on 8/6/24.
//

import UIKit

final class BannerDiffableDataSource: UICollectionViewDiffableDataSource<Int, BannerModel> {
    
    init(collectionView: UICollectionView) {
        super.init(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InBannerCollectionViewCell", for: indexPath) as! InBannerCollectionViewCell
            cell.set(item)
            return cell
        }
    }
    
}

//extension BannerDiffableDataSource {
//    
//    func itemModelCollectionView(_ collectionView: UICollectionView, in indexPath: IndexPath) -> BannerModel? {
//        self.snapshot().itemIdentifiers(inSection: indexPath.section)[safe: indexPath.item]
//    }
//    
//}
