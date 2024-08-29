//
//  BannerCollectionCellViewModel.swift
//  InfinitedAutoScroll
//
//  Created by D프로젝트노드_오지연 on 8/29/24.
//

import Foundation
import Combine

typealias BannerIndexInfo = (currentIndex: Int, itemsCount: Int)

struct BannerCollectionCellViewModel {
    
    struct Inputs {
        let currentIndexPathTrigger: AnyPublisher<IndexPath, Never>
        let pageTrigger: AnyPublisher<Int, Never>
    }
    
    struct Outputs {
        let currentIndexInfo: AnyPublisher<BannerIndexInfo, Never>
        let replicatedPage: AnyPublisher<Int, Never>
        let items: AnyPublisher<[BannerModel], Never>
        let events: AnyPublisher<Void, Never>
    }
    
    private let items: [BannerModel]
    
    init(items: [BannerModel]) {
        self.items = items
    }
    
}

extension BannerCollectionCellViewModel {
    
    func bind(_ inputs: Inputs) -> Outputs {
        let items = self.items
        
        let itemsSubject: CurrentValueSubject<[BannerModel], Never> = .init(items)
        let replicatedPageSubject: PassthroughSubject<Int, Never> = .init()
        let itemsCountSubject: CurrentValueSubject<Int, Never> = .init(items.count / Constants.dataMultiplier )
        
        let currentIndexInfoSubject: PassthroughSubject<BannerIndexInfo, Never> = .init()
        
        let events = Publishers.MergeMany(
            inputs.currentIndexPathTrigger
                .withLatestFrom(itemsCountSubject) { ($0, $1) }
                .handleEvents(receiveOutput: { indexPath, itemsCount in
                    print("indexPath: \(indexPath)")
                    if itemsCount > 1 {
                        currentIndexInfoSubject.send((indexPath.item, itemsCount))
                    }
                })
                .map {
                    _ in
                }
                .eraseToAnyPublisher(),
            inputs.pageTrigger
                .withLatestFrom(itemsCountSubject) { ($0, $1) }
                .map { page, itemsCount in
                    page % itemsCount
                }
                .removeDuplicates()
                .handleEvents(receiveOutput: { page in
                    replicatedPageSubject.send(page)
                })
                .map {
                    _ in
                }
                .eraseToAnyPublisher()
        )
        
        return .init(currentIndexInfo: currentIndexInfoSubject.eraseToAnyPublisher(),
                     replicatedPage: replicatedPageSubject.eraseToAnyPublisher(),
                     items: itemsSubject.eraseToAnyPublisher(),
                     events: events.eraseToAnyPublisher())
    }
    
}

extension BannerCollectionCellViewModel: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(items)
    }

    static func == (lhs: BannerCollectionCellViewModel, rhs: BannerCollectionCellViewModel) -> Bool {
        return lhs.items == rhs.items
    }
    
}

private extension BannerCollectionCellViewModel {
    
    enum Constants {
        static let dataMultiplier: Int = 3
    }
    
}
