//
//  CarouselCollectionView.swift
//  InfinitedAutoScroll
//
//  Created by 오지연 on 9/3/24.
//

import UIKit

@objc public protocol CarouselCollectionViewDelegate {
    
    @objc optional func afterScroll(index: Int)
    
    func scrollViewDidScroll(_ scrollView: UIScrollView, index: Int)
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView, index: Int)
}

enum InfinitedCarouselState {
    
    case underOrigin
    case overOrigin
    case origin
    
    var needScrolling: Bool {
        self == .underOrigin || self == .overOrigin
    }
    
}

class CarouselCollectionView: UICollectionView {
    public weak var carouselDelegate: CarouselCollectionViewDelegate?
    
    public let flowLayout: UICollectionViewFlowLayout
    
    private var numberOfItems: Int = 0
    
    public init(frame: CGRect, collectionViewFlowLayout layout: UICollectionViewFlowLayout) {
        flowLayout = layout
        super.init(frame: frame, collectionViewLayout: layout)
        
        self.delegate = self
        self.isPagingEnabled = true
        
        self.flowLayout.scrollDirection = .horizontal
        self.flowLayout.minimumLineSpacing = 0
        self.flowLayout.minimumInteritemSpacing = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCarousel(itemsCount: Int) {
        self.numberOfItems = itemsCount
    }
    
    func setupInitDisplay() {
        let index = self.getInfinitedIndex(state: .overOrigin)
        
        UIView.animate(withDuration: 0, animations: {
            self.scrollToOffset(in: index)
        }) { _ in
            self.carouselDelegate?.afterScroll?(index: index)
        }
    }
    
}

extension CarouselCollectionView: UICollectionViewDelegate {
 
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("index : \(scrollView.contentOffset.x / flowLayout.itemSize.width)")
        
        let state = getCurrentCarouselState(offsetX: scrollView.contentOffset.x)
        
        if state.needScrolling {
            let index = getInfinitedIndex(state: state)
            
            UIView.animate(withDuration: 0, animations: {
                self.scrollToOffset(in: index)
            }) { _ in
                self.carouselDelegate?.scrollViewDidScroll(scrollView, index: index)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let state = getCurrentCarouselState(offsetX: scrollView.contentOffset.x)
        let index = getInfinitedIndex(state: state)
        
        print("> End : \(index)")
        self.carouselDelegate?.scrollViewDidEndDecelerating(scrollView, index: index)
    }
    
}

// TODO: Timer
private extension CarouselCollectionView {
    
    func scrollForTimer() {
        let state = getCurrentCarouselState(offsetX: flowLayout.itemSize.width + self.contentOffset.x)
        let index = getInfinitedIndex(state: state)
        
        UIView.animate(withDuration: 0, animations: {
            self.scrollToOffset(in: index, animated: true)
        }) { _ in
            self.carouselDelegate?.afterScroll?(index: index)
        }
    }
    
}

private extension CarouselCollectionView {
    
    func getInfinitedIndex(state: InfinitedCarouselState) -> Int {
        switch state {
        case .underOrigin:
            return numberOfItems
        case .overOrigin:
            return 1
        case .origin:
            return Int(self.contentOffset.x / flowLayout.itemSize.width)
        }
    }
    
    func getCurrentCarouselState(offsetX: CGFloat) -> InfinitedCarouselState {
        if offsetX <= 0 { // 첫번째(extra)가 보이면 origin last index로 이동시키기
            return .underOrigin
        } else if offsetX >= flowLayout.itemSize.width * CGFloat(numberOfItems+1) { // 마지막(extra)가 보이면 origin first index로 이동하기
            return .overOrigin
        } else {
            return .origin
        }
    }
    
    func scrollToOffset(in index: Int, animated: Bool = false) {
        self.setContentOffset(.init(x: flowLayout.itemSize.width * CGFloat(index), y: self.contentOffset.y), animated: false)
    }
    
}
