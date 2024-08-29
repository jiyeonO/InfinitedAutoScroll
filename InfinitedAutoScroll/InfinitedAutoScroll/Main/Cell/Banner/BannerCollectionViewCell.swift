//
//  BannerCollectionViewCell.swift
//  InfinitedAutoScroll
//
//  Created by D프로젝트노드_오지연 on 8/23/24.
//

import UIKit
import Combine

class BannerCollectionViewCell: UICollectionViewCell {

    private var cancellables: [AnyCancellable] = []
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            self.collectionView.register(.init(nibName: "InBannerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "InBannerCollectionViewCell")
            
            self.collectionView.dataSource = self.dataSource
            self.collectionView.delegate = self
            
            self.collectionView.collectionViewLayout = self.collectionViewLayoutHandler.createLayout()
        }
    }
    
    private lazy var dataSource = BannerDiffableDataSource(collectionView: self.collectionView)
    
    private lazy var collectionViewLayoutHandler = BannerLayoutHandler(collectionView: self.collectionView)
    
    // MARK: - Action
    private var isMovedInfinitedScroll: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.reset()
    }

    func set(_ viewModel: BannerCollectionCellViewModel) {
        // Outputs
        let outputs = viewModel.bind(.init(currentIndexPathTrigger: self.collectionViewLayoutHandler.currentIndexPathPublisher,
                                           pageTrigger: self.collectionViewLayoutHandler.pagePublisher))
        
        [
            outputs.currentIndexInfo
                .sink(receiveValue: { [weak self] indexInfo in
                    self?.scrollToInfinitedItem(info: indexInfo)
                }),
            outputs.items
                .sink(receiveValue: { [weak self] items in
                    self?.applySnapshot(items: items)
                }),
            outputs.events
                .sink {
                    _ in
                }
        ].forEach {
            self.cancellables.append($0)
        }
    }
    
    func reset() {
        //
    }

}

extension BannerCollectionViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("willDisplay : \(indexPath.item)")
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("didEndDisplaying : \(indexPath.item)")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrollViewDidScroll: \(scrollView.contentOffset)")
    }

//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        let count = BannerModel.carouselFakes.count // temp
//        
//        print("scrollViewDidEndDecelerating")
//        
//        if scrollView.contentOffset.x == 0 {
//            scrollView.setContentOffset(.init(x: Constants.cellWidth * Double(count-2), y: scrollView.contentOffset.y), animated: false)
//        }
//        if scrollView.contentOffset.x == Double(count-1) * Constants.cellWidth {
//            scrollView.setContentOffset(.init(x: Constants.cellWidth, y: scrollView.contentOffset.y), animated: false)
//        }
//    }
    
}

private extension BannerCollectionViewCell {
    
    func scrollToInfinitedItem(info: BannerIndexInfo) {
        let itemsCount = info.itemsCount
        let index = info.currentIndex
        
        let startLastIndex = itemsCount - 1
        let endSecondIndex = itemsCount * 2 + 1
        let middleLastIndex = itemsCount * 2 - 1
        let middleFirstIndex = itemsCount
        
        switch index {
        case startLastIndex:
            print("## scroll startLastIndex")
            self.collectionView.scrollToItem(at: [Constants.bannerSection, middleLastIndex], at: .centeredHorizontally, animated: false)
        case endSecondIndex:
            print("## scroll endSecondIndex")
            self.collectionView.scrollToItem(at: [Constants.bannerSection, middleFirstIndex], at: .centeredHorizontally, animated: false)
            self.isMovedInfinitedScroll = true
        case middleFirstIndex:
            print("## scroll middleFirstIndex")
            if self.isMovedInfinitedScroll {
                self.isMovedInfinitedScroll = false
                self.scrollToNextPage(in: index + 1) // 스크롤 이동 후 다음 페이지로 넘김.
            }
        default:
            break
        }
    }
    
    func scrollToNextPage(in index: Int) {
        let indexPath = IndexPath(item: index, section: Constants.bannerSection)
        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
}

private extension BannerCollectionViewCell {
    
    func applySnapshot(items: [BannerModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, BannerModel>()
        snapshot.appendSections([0])
        
        snapshot.appendItems(items, toSection: 0)
        
        self.dataSource.apply(snapshot, animatingDifferences: true)
    }
    
}

private extension BannerCollectionViewCell {
    
    enum Constants {
        static let cellWidth = UIScreen.main.bounds.width
        static let bannerSection: Int = MainSection.banner.rawValue
    }
    
}
