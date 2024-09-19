//
//  CarouselCollectionView.swift
//  InfinitedAutoScroll
//
//  Created by 오지연 on 9/3/24.
//

import UIKit
import Combine

/**
 Infinited Carousel
  - origin : 원본 데이터                                                                   ex) [0, 1, 2, 3]
  - extra : 무한 스크롤을 위해 원본 앞뒤로 복사본을 추가한 데이터      ex) [3, 0, 1, 2, 3, 0]
  - carousel Index : 무한 스크롤을 위해 계산 처리한 Index
 
  - requires: func setup(originItemsCount: Int)
  - requires: func setItemSize(_ size: CGSize)
  - requires: func setupInitDisplay()
 */

class CarouselCollectionView: UICollectionView {
    
    var currentCarouselIndexPublisher: AnyPublisher<Int, Never> {
        currentCarouselIndexSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var pageCarouselIndexPublisher: AnyPublisher<Int, Never> {
        pageCarouselIndexSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private var originItemsCount: Int = 0
    
    private let currentCarouselIndexSubject: PassthroughSubject<Int, Never> = .init() // 스크롤 변경될 때 계속 호출
    private let pageCarouselIndexSubject: PassthroughSubject<Int, Never> = .init() // 페이지 변경될 때 한번씩 호출 (origin 영역 내)
    
    private let flowLayout: UICollectionViewFlowLayout
    
    init(frame: CGRect, collectionViewFlowLayout flowLayout: UICollectionViewFlowLayout) {
        self.flowLayout = flowLayout
        super.init(frame: frame, collectionViewLayout: flowLayout)
        
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        self.delegate = self
        self.isPagingEnabled = true
        self.showsHorizontalScrollIndicator = false
        
        self.flowLayout.scrollDirection = .horizontal
        self.flowLayout.minimumLineSpacing = 0
        self.flowLayout.minimumInteritemSpacing = 0
    }
    
}

extension CarouselCollectionView {
    
    func setup(originItemsCount: Int) {
        self.originItemsCount = originItemsCount
    }
    
    func setItemSize(_ size: CGSize) {
        self.flowLayout.itemSize = size
    }
    
    func setupInitDisplay() {
        UIView.animate(withDuration: 0, animations: {
            self.scrollToOffset(in: Constants.originStartIndex)
        }) { _ in
            self.pageCarouselIndexSubject.send(Constants.originStartIndex)
        }
    }
    
}

// MARK: - Timer
extension CarouselCollectionView {
    
    func scrollToNextPage() {
        let nextOffsetX = self.contentOffset.x + flowLayout.itemSize.width
        let state = getCurrentState(offsetX: nextOffsetX)
        
        // 다음 페이지 index
        let index = Int(nextOffsetX / flowLayout.itemSize.width)
        
        /* 
         [Timer] 다음 페이지로 이동
         - 화면 이동에 대한 animation 처리 위함
         - extra 영역이라도 무조건 이동
         - extra 영역일 경우 scrollViewDidScroll에서 이동 처리.
         */
        self.scrollToOffset(in: index, animated: true) {
            if state.isOrigin {
                self.pageCarouselIndexSubject.send(index)
            }
        }
    }

}

// MARK: - UICollectionViewDelegate
extension CarouselCollectionView: UICollectionViewDelegate {
 
    // Carousel Index로 화면 이동 처리
    // - Timer, 사용자 Scroll Event 모두 처리
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / flowLayout.itemSize.width)
        
        let state = getCurrentState(offsetX: scrollView.contentOffset.x)
        
        if state.needScrolling {
            let carouselIndex = getCarouselIndex(state: state)
            
            self.scrollToOffset(in: carouselIndex) {
                self.pageCarouselIndexSubject.send(carouselIndex)
            }
        } else {
            self.currentCarouselIndexSubject.send(index)
        }
    }
    
    // 사용자 Scroll Event
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / flowLayout.itemSize.width)

        let state = getCurrentState(offsetX: scrollView.contentOffset.x)
        
        if state.isOrigin {
            self.pageCarouselIndexSubject.send(index)
        }
    }
    
}

private extension CarouselCollectionView {
    
    func getCarouselIndex(state: InfinitedCarouselState) -> Int {
        switch state {
        case .underOrigin:
            return originItemsCount
        case .overOrigin:
            return 1
        case .origin:
            return Int(self.contentOffset.x / flowLayout.itemSize.width)
        }
    }
    
    func getCurrentState(offsetX: CGFloat) -> InfinitedCarouselState {
        if offsetX <= 0 {
            return .underOrigin
        } else if offsetX >= flowLayout.itemSize.width * CGFloat(originItemsCount+1) {
            return .overOrigin
        } else {
            return .origin
        }
    }
    
    func scrollToOffset(in index: Int, animated: Bool = false, completion: (() -> ())? = nil) {
        guard let duration = value(forKey: Constants.contentOffsetDuration) as? Double else { return }
        
        self.setContentOffset(.init(x: flowLayout.itemSize.width * CGFloat(index), y: self.contentOffset.y), animated: animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            completion?()
        }
    }
    
}

private extension CarouselCollectionView {
    
    enum Constants {
        static let originStartIndex = 1
        static let contentOffsetDuration = "contentOffsetAnimationDuration"
    }
    
}
