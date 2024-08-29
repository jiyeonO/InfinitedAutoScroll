//
//  BannerLayoutHandler.swift
//  PWM
//
//  Created by D프로젝트노드_오지연 on 7/31/24.
//

import UIKit
import Combine

struct BannerLayoutHandler {
    
    private let currentIndexPathSubject: CurrentValueSubject<IndexPath, Never> = .init(Constants.initialIndexPath)
    private let pageSubject: CurrentValueSubject<Int, Never> = .init(Constants.initialPage)
    
    private let collectionView: UICollectionView
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
    }
    
    var currentIndexPathPublisher: AnyPublisher<IndexPath, Never> {
        currentIndexPathSubject
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var pagePublisher: AnyPublisher<Int, Never> {
        pageSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { section, environment -> NSCollectionLayoutSection? in
            // item
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // group
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalHeight(1.0))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            // section
            let layoutSection = NSCollectionLayoutSection(group: group)
            layoutSection.orthogonalScrollingBehavior = .groupPaging
            
            layoutSection.visibleItemsInvalidationHandler = { (visibleItems, offset, env) in
                if let indexPath = visibleItems.last?.indexPath {
                    self.currentIndexPathSubject.send(indexPath)
                }
                
                if let currentPage = Int(exactly: offset.x / self.collectionView.bounds.width) {
                    self.pageSubject.send(currentPage)
                }
            }
            
            DispatchQueue.main.async {
                self.scrollToInitialPosition(in: MainSection.banner.rawValue)
            }
            
            return layoutSection
        }
    }

}

private extension BannerLayoutHandler {
    
//    func scrollToInitialPosition() {
//        let itemsCount = self.collectionView.numberOfItems(inSection: MainSection.banner.rawValue) / Constants.infiniteX
//        self.collectionView.setContentOffset(.init(x: collectionView.frame.width * Double(itemsCount-1), y: 0), animated: false)
//    }
    
    func scrollToInitialPosition(in section: Int) {
        let itemsCount = self.collectionView.numberOfItems(inSection: section) / Constants.infiniteX
        let initialIndexPath = IndexPath(item: itemsCount, section: section)
        self.collectionView.scrollToItem(at: initialIndexPath, at: .centeredHorizontally, animated: false)
    }
    
}

// MARK: - Constants
private extension BannerLayoutHandler {
    
    enum Constants {
        static let initialIndexPath: IndexPath = .init(item: 0, section: MainSection.banner.rawValue)
        static let initialPage: Int = 0
        static let infiniteX: Int = 3
    }
    
}
