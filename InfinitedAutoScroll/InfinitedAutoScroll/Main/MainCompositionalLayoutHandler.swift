//
//  MainCompositionalLayoutHandler.swift
//  InfinitedAutoScroll
//
//  Created by 오지연 on 8/12/24.
//

import UIKit
import Combine

struct MainCompositionalLayoutHandler {
    
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
                
                let layoutSection = NSCollectionLayoutSection(group: group)
                layoutSection.orthogonalScrollingBehavior = .groupPaging
                
                layoutSection.visibleItemsInvalidationHandler = { (visibleItems, offset, env) in
                    if let indexPath = visibleItems.last?.indexPath, indexPath.section == Constants.bannerSection {
                        self.currentIndexPathSubject.send(indexPath)
//                        print("> indexPath: \(indexPath.item)")
                    }
                    
                    if let currentPage = Int(exactly: offset.x / self.collectionView.bounds.width) {
                        self.pageSubject.send(currentPage)
                    }
                }
                
                DispatchQueue.main.async {
                    self.scrollToInitialPosition(in: Constants.bannerSection)
                }
                
                return layoutSection
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

private extension MainCompositionalLayoutHandler {
    
    func scrollToInitialPosition(in section: Int) {
        let itemsCount = self.collectionView.numberOfItems(inSection: Constants.bannerSection) / Constants.infiniteX
        let initialIndexPath = IndexPath(item: itemsCount, section: Constants.bannerSection)
        self.collectionView.scrollToItem(at: initialIndexPath, at: .centeredHorizontally, animated: false)
    }
    
}


// MARK: - Constants
private extension MainCompositionalLayoutHandler {
    
    enum Constants {
        static let bannerSection: Int = MainSection.banner.rawValue
        static let initialIndexPath: IndexPath = .init(item: 0, section: MainSection.banner.rawValue)
        static let initialPage: Int = 0
        static let infiniteX: Int = 3
        static let bannerHeightDimension: CGFloat = 488.0
    }
    
}
