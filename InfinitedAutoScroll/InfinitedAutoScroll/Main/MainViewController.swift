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
    
    private let collectionView = CarouselCollectionView(frame: .zero, collectionViewFlowLayout: UICollectionViewFlowLayout())
    
    private lazy var dataSource = MainDiffableDataSource(collectionView: self.collectionView)
    
    // MARK: - Action
    private var isMovedInfinitedScroll: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.bindViewModel()
        
        self.viewDidLoadPublisher.send()
    }
    
    func setupViews() {
        self.collectionView.register(BannerCollectionViewCell.self, forCellWithReuseIdentifier:"BannerCollectionViewCell")
        self.collectionView.register(.init(nibName: "ProductCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCollectionViewCell")
        
        let size = UIScreen.main.bounds.size
        self.collectionView.flowLayout.itemSize = CGSize(width: size.width, height: size.height)
        
        self.collectionView.carouselDelegate = self
        
        self.view.addSubview(self.collectionView)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
        collectionView.frame = self.view.bounds
    }
    
    func bindViewModel() {
        // Inputs
        let viewDidLoad = self.viewDidLoadPublisher
            .eraseToAnyPublisher()
        
        // Outputs
        let outputs = self.viewModel.bind(.init(
            viewDidLoad: viewDidLoad
        ))
        
        [
            outputs.bannerOriginItemsCount
                .sink(receiveValue: { [weak self] count in
                    self?.collectionView.setupCarousel(itemsCount: count)
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

extension MainViewController: CarouselCollectionViewDelegate {
    
    func afterScroll(index: Int) {
        self.cellForPlay(in: index)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView, index: Int) {
        self.cellForPlay(in: index)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView, index: Int) {
            print("> End : \(index)")
            
            self.cellForPause(in: index-1) // 천천히 이전 화면으로 이동하면 이전 화면, 현재 화면 모두 재생되는 케이스 발생하기에 처리.
            self.cellForPause(in: index+1)
            self.cellForPlay(in: index)  // 단, infinited Index로 변경해주는 경우 따로 처리 필요. (state.needScrolling)
        }
    
}

private extension MainViewController {
    
    func cellForPlay(in index: Int) {
        if let cell = self.collectionView.cellForItem(at: [Constants.bannerSection, index]) as? BannerCollectionViewCell {
            cell.play()
        }
    }
    
    func cellForPause(in index: Int) {
        if let cell = self.collectionView.cellForItem(at: [Constants.bannerSection, index]) as? BannerCollectionViewCell {
            cell.pause()
        }
    }
    
    func scrollToOffset(in index: Int, animated: Bool = false) {
        self.collectionView.setContentOffset(.init(x: Constants.cellWidth * CGFloat(index), y: self.collectionView.contentOffset.y), animated: false)
    }
    
}

private extension MainViewController {
    
    func applySnapshot(items: [MainDataItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, MainItem>()
        
        snapshot.appendSections([0])
        items.forEach { data in
            snapshot.appendItems(data.items, toSection: 0)
        }
        
        self.dataSource.apply(snapshot, animatingDifferences: true) { [weak self] in
            self?.collectionView.setupInitDisplay()
        }
    }
    
}

private extension MainViewController {
    
    enum Constants {
        static let bannerSection: Int = MainSection.banner.rawValue
        static let cellWidth: CGFloat = UIScreen.main.bounds.width
    }
    
}


