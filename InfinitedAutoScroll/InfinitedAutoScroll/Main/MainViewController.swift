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
        let outputs = self.viewModel.bind(.init(viewDidLoad: viewDidLoad))
        
        [
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


