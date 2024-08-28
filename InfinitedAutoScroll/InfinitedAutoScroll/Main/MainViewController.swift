//
//  MainViewController.swift
//  InfinitedAutoScroll
//
//  Created by 오지연 on 8/12/24.
//

import UIKit
import Combine

class MainViewController: UIViewController {

    private let viewModel: MainViewModel = MainViewModel()
    
    private var cancellables: [AnyCancellable] = []
    private let viewDidLoadPublisher: PassthroughSubject<Void, Never> = .init()
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            self.collectionView.register(.init(nibName: "BannerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BannerCollectionViewCell")
            self.collectionView.register(.init(nibName: "ProductCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCollectionViewCell")
            
            self.collectionView.dataSource = self.dataSource
            
            self.collectionView.collectionViewLayout = self.collectionViewLayoutHandler.createLayout()
        }
    }
    
    private lazy var dataSource = MainDiffableDataSource(collectionView: self.collectionView)
    
    private lazy var collectionViewLayoutHandler = MainCompositionalLayoutHandler(collectionView: self.collectionView)
    
    // MARK: - Action
    private var isMovedInfinitedScroll: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModel()
        
        self.viewDidLoadPublisher.send()
    }

    func bindViewModel() {
        // Inputs
        let viewDidLoad = self.viewDidLoadPublisher
            .eraseToAnyPublisher()
        
        // Outputs
        let outputs = self.viewModel.bind(.init(
            viewDidLoad: viewDidLoad,
            currentIndexPathTrigger: self.collectionViewLayoutHandler.currentIndexPathPublisher
        ))
        
        [
            outputs.currentIndexInfo
                .sink(receiveValue: { [weak self] indexInfo in
                    self?.scrollToInfinitedItem(info: indexInfo)
                }),
            outputs.items
                .sink { [weak self] items in
                    self?.applySnapshot(items: items)
                },
            outputs.events
                .sink {
                    _ in
                }
        ].forEach {
            self.cancellables.append($0)
        }
    }
    
}

private extension MainViewController {
    
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

private extension MainViewController {
    
    func applySnapshot(items: [MainDataItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<MainSection, MainItem>()
        snapshot.appendSections(MainSection.allCases)
        
        items.forEach { data in
            snapshot.appendItems(data.items, toSection: data.section)
        }
        
        self.dataSource.apply(snapshot, animatingDifferences: true)
    }
    
}

private extension MainViewController {
    
    enum Constants {
        static let bannerSection: Int = MainSection.banner.rawValue
    }
    
}


