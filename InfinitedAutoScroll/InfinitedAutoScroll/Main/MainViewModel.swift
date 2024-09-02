//
//  MainViewModel.swift
//  InfinitedAutoScroll
//
//  Created by 오지연 on 8/12/24.
//

import Foundation
import Combine

typealias BannerIndexInfo = (currentIndex: Int, itemsCount: Int)

struct MainViewModel {
    
    struct Inputs {
        let viewDidLoad: AnyPublisher<Void, Never>
//        let currentIndexPathTrigger: AnyPublisher<IndexPath, Never>
    }
    
    struct Outputs {
//        let currentIndexInfo: AnyPublisher<BannerIndexInfo, Never>
        let bannerOriginItemsCount: AnyPublisher<Int, Never>
        let items: AnyPublisher<[MainDataItem], Never>
        let events: AnyPublisher<Void, Never>
    }
    
    init() {
        //
    }
    
}

extension MainViewModel {
    
    func bind(_ inputs: Inputs) -> Outputs {
        
//        let currentIndexInfoSubject: PassthroughSubject<BannerIndexInfo, Never> = .init()
        
        // Fake Data
//        var products: [MainItem] {
//            ProductModel.fakes.map { model -> MainItem in
//               .product(model)
//            }
//        }
        
        let bannersSubject: CurrentValueSubject<[BannerModel], Never> = .init(BannerModel.fakes)
//        let productsSubject: CurrentValueSubject<[MainItem], Never> = .init(products)
        
        // Data 처리
        let bannerOriginItemsCountSubject: PassthroughSubject<Int, Never> = .init()
        
        // Sections
        let bannerDataSubject: PassthroughSubject<[MainDataItem], Never> = .init()
//        let productDataSubject: PassthroughSubject<[MainDataItem], Never> = .init()

//        let allItems = Publishers.CombineLatest(bannerDataSubject, productDataSubject)
//            .map { $0 + $1 }
        
        // Events
        let events = Publishers.MergeMany(
//            inputs.currentIndexPathTrigger
//                .withLatestFrom(bannersSubject) { ($0, $1.count) }
//                .handleEvents(receiveOutput: { indexPath, itemsCount in
//                    if itemsCount > 1 {
//                        currentIndexInfoSubject.send((indexPath.item, itemsCount))
//                    }
//                })
//                .map {
//                    _ in
//                }
//                .eraseToAnyPublisher(),
            bannersSubject
                .handleEvents(receiveOutput: {
                    bannerOriginItemsCountSubject.send($0.count)
                })
                .map { // TODO: mapToVoid
                    _ in
                }
                .eraseToAnyPublisher(),
            bannersSubject
                .map { banners -> [MainDataItem] in
                    let canInfinited = banners.count > 1
                    
                    var infinitedItem = banners
                    if canInfinited, let first = banners.first, let last = banners.last {
                        infinitedItem.insert(last.infinitedModel, at: 0)
                        infinitedItem.append(first.infinitedModel)
                    }
                    
//                    let infinitedFrontItems = banners.map { $0.infinitedModel }
//                    let infinitedBackItems = banners.map { $0.infinitedModel }
//                    let allItems = canInfinited ? infinitedFrontItems + banners + infinitedBackItems : banners
                    
                    // temp
                    let banners = infinitedItem.map { model -> MainItem in
                            .banner(model)
                    }
                    
                    return [.init(section: .banner, items: banners)]
                }
                .handleEvents(receiveOutput: {
                    bannerDataSubject.send($0)
                })
                .map { // TODO: mapToVoid
                    _ in
                }
                .eraseToAnyPublisher()
//            productsSubject
//                .map { model -> [MainDataItem] in
//                    [.init(section: .product, items: products)]
//                }
//                .handleEvents(receiveOutput: {
//                    productDataSubject.send($0)
//                })
//                .map { // TODO: mapToVoid
//                    _ in
//                }
//                .eraseToAnyPublisher()
        )
        
        // Outputs
        return .init(
//            currentIndexInfo: currentIndexInfoSubject.eraseToAnyPublisher(),
            bannerOriginItemsCount: bannerOriginItemsCountSubject.eraseToAnyPublisher(),
            items: bannerDataSubject.eraseToAnyPublisher(),
            events: events.eraseToAnyPublisher()
        )
    }
    
}
