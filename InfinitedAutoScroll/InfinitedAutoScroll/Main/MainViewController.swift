//
//  MainViewController.swift
//  InfinitedAutoScroll
//
//  Created by 오지연 on 8/12/24.
//

import UIKit
import Combine

class MainViewController: UIViewController {

    private let viewModel: MainViewModel = MainViewModel(items: BannerModel.fakes, timer: RepeatTimer())
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - UI
    private lazy var collectionView = CarouselCollectionView(frame: .zero, collectionViewFlowLayout: UICollectionViewFlowLayout())
    private lazy var pageControl = UIPageControl()
    
    private lazy var dataSource = MainDiffableDataSource(collectionView: self.collectionView)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViews()
        self.bindViewModel()
    }

    func bindViewModel() {
        // Outputs
        let outputs = viewModel.bind(.init(currentCarouselIndex: collectionView.currentCarouselIndexPublisher,
                                           endScrollCarouselIndex: collectionView.pageCarouselIndexPublisher))
        
        [
            outputs.originItemsCount
                .sink { [weak self] count in
                    self?.collectionView.setup(originItemsCount: count)
                    self?.pageControl.numberOfPages = count
                },
            outputs.pageIndex
                .sink { [weak self] page in
                    self?.pageControl.currentPage = page
                },
            outputs.nextPage // Done Timer.
                .sink(receiveValue: { [weak self] _ in
                    self?.collectionView.scrollToNextPage()
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
    
    func setupViews() {
        self.collectionView.register(BannerCollectionViewCell.self, forCellWithReuseIdentifier: "BannerCollectionViewCell")
        self.collectionView.setItemSize(CGSize(width: Constants.cellWidth, height: Constants.cellHeight))
        
        [
            self.collectionView,
            self.pageControl
        ].forEach {
            self.view.addSubview($0)
        }
        
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.collectionView.heightAnchor.constraint(equalToConstant: Constants.cellHeight)
        ])
        
        self.pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.pageControl.bottomAnchor.constraint(equalTo: self.collectionView.bottomAnchor, constant: -Constants.pageControlBottomConstraint),
            self.pageControl.leadingAnchor.constraint(equalTo: self.collectionView.leadingAnchor),
            self.pageControl.trailingAnchor.constraint(equalTo: self.collectionView.trailingAnchor),
        ])
    }
    
}

private extension MainViewController {
    
    func applySnapshot(items: [BannerModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, BannerModel>()
        snapshot.appendSections([Constants.bannerSection])
        snapshot.appendItems(items, toSection: Constants.bannerSection)
        
        self.dataSource.apply(snapshot, animatingDifferences: true) { [weak self] in
            self?.collectionView.setupInitDisplay()
        }
    }
    
}

private extension MainViewController {
    
    enum Constants {
        static let bannerSection: Int = 0
        static let pageControlBottomConstraint: CGFloat = 20
        static let cellWidth: CGFloat = UIScreen.main.bounds.width
        static let cellHeight: CGFloat = 600.0
    }
    
}


