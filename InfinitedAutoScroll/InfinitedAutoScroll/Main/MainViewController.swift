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
            self.collectionView.register(BannerCollectionViewCell.self, forCellWithReuseIdentifier:"BannerCollectionViewCell")
            //            self.collectionView.register(.init(nibName: "BannerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BannerCollectionViewCell")
            self.collectionView.register(.init(nibName: "ProductCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCollectionViewCell")
            
            self.collectionView.dataSource = self.dataSource
            self.collectionView.delegate = self
        }
    }
    
    private lazy var dataSource = MainDiffableDataSource(collectionView: self.collectionView)
    
    // MARK: - Action
    private var isMovedInfinitedScroll: Bool = false
    private var originBannerItemsCount: Int = 0
    
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
            viewDidLoad: viewDidLoad
        ))
        
        [
            outputs.bannerOriginItemsCount
                .sink(receiveValue: { [weak self] count in
                    self?.originBannerItemsCount = count
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

extension MainViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("index : \(scrollView.contentOffset.x / Constants.cellWidth)")
        
        let state = getCurrentCarouselState(offsetX: scrollView.contentOffset.x)
        
        if state.needScrolling {
            let index = getInfinitedIndex(state: state)
            
            UIView.animate(withDuration: 0, animations: {
                scrollView.setContentOffset(.init(x: Constants.cellWidth * CGFloat(index), y: scrollView.contentOffset.y), animated: false)
            }) { _ in
                self.cellForPlay(in: index)
            }
        }
    }
    
    // TODO: timer가 다됐을 떄도 scroll 처리 후 아래 같은 처리 필요.
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let state = getCurrentCarouselState(offsetX: scrollView.contentOffset.x)
        let index = getInfinitedIndex(state: state)
        
        DispatchQueue.main.async {
            print("> End : \(index)")
            
            self.cellForPause(in: index-1) // 천천히 이전 화면으로 이동하면 이전 화면, 현재 화면 모두 재생되는 케이스 발생.
            self.cellForPause(in: index+1)
            self.cellForPlay(in: index)  // 단, infinited Index로 변경해주는 경우 따로 처리 필요.
        }
    }
    
}

private extension MainViewController {
    
    enum InfinitedCarouselState {
        
        case underOrigin
        case overOrigin
        case origin
        
        var needScrolling: Bool {
            self == .underOrigin || self == .overOrigin
        }
        
    }
    
    func getInfinitedIndex(state: InfinitedCarouselState) -> Int {
        switch state {
        case .underOrigin:
            return originBannerItemsCount // itemCount
        case .overOrigin:
            return 1
        case .origin:
            return Int(self.collectionView.contentOffset.x / Constants.cellWidth)
        }
    }
    
    func getCurrentCarouselState(offsetX: CGFloat) -> InfinitedCarouselState {
        if offsetX <= 0 { // 첫번째(4)가 보이면 4번째 index의 4로 이동시키기
            return .underOrigin
        } else if offsetX >= Constants.cellWidth * CGFloat(originBannerItemsCount+1) { //마지막 1이 보이면 1번째 index의 1로 이동
            return .overOrigin
        } else {
            return .origin
        }
    }
    
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
    
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: UIScreen.main.bounds.width, height: 488.0)
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
        var snapshot = NSDiffableDataSourceSnapshot<Int, MainItem>()
        //        snapshot.appendSections(MainSection.allCases)
        //
        //        items.forEach { data in
        //            snapshot.appendItems(data.items, toSection: data.section)
        //        }
        
        //        self.dataSource.apply(snapshot, animatingDifferences: true)
        
        snapshot.appendSections([0])
        items.forEach { data in
            snapshot.appendItems(data.items, toSection: 0)
        }
        
        self.dataSource.apply(snapshot, animatingDifferences: true) { [weak self] in
            if let collectionView = self?.collectionView, 
                let index = self?.getInfinitedIndex(state: .overOrigin) {
                
                UIView.animate(withDuration: 0, animations: {
                    collectionView.setContentOffset(.init(x: Constants.cellWidth * CGFloat(index), y: collectionView.contentOffset.y), animated: false)
                }) { _ in
                    self?.cellForPlay(in: index)
                }
                
            }
        }
    }
    
}

private extension MainViewController {
    
    enum Constants {
        static let bannerSection: Int = MainSection.banner.rawValue
        static let cellWidth: CGFloat = UIScreen.main.bounds.width
    }
    
}


