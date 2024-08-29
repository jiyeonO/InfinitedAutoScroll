//
//  MainViewModel.swift
//  InfinitedAutoScroll
//
//  Created by 오지연 on 8/12/24.
//

import Foundation
import Combine

struct MainViewModel {
    
    struct Inputs {
        let viewDidLoad: AnyPublisher<Void, Never>
    }
    
    struct Outputs {
        let items: AnyPublisher<[MainDataItem], Never>
        let events: AnyPublisher<Void, Never>
    }
    
    init() {
        //
    }
    
}

extension MainViewModel {
    
    func bind(_ inputs: Inputs) -> Outputs {
        
        // Fake Data
        var products: [MainItem] {
            ProductModel.fakes.map { model -> MainItem in
               .product(model)
            }
        }
        
        let bannersSubject: CurrentValueSubject<[BannerModel], Never> = .init(BannerModel.fakes)
        let productsSubject: CurrentValueSubject<[MainItem], Never> = .init(products)
        
        // Sections
        let bannerDataSubject: PassthroughSubject<[MainDataItem], Never> = .init()
        let productDataSubject: PassthroughSubject<[MainDataItem], Never> = .init()

        let allItems = Publishers.CombineLatest(bannerDataSubject, productDataSubject)
            .map { $0 + $1 }
        
        // Events
        let events = Publishers.MergeMany(
            bannersSubject
                .map { banners -> [MainDataItem] in
                    let canInfinited = banners.count > 1

                    let infinitedFrontItems = banners.map { $0.infinitedModel }
                    let infinitedBackItems = banners.map { $0.infinitedModel }
                    let allItems = canInfinited ? infinitedFrontItems + banners + infinitedBackItems : banners

                    return [.init(section: .banner, items: [.banner(.init(items: allItems))])]
                }
                .handleEvents(receiveOutput: {
                    bannerDataSubject.send($0)
                })
                .map { // TODO: mapToVoid
                    _ in
                }
                .eraseToAnyPublisher(),
            productsSubject
                .map { model -> [MainDataItem] in
                    [.init(section: .product, items: products)]
                }
                .handleEvents(receiveOutput: {
                    productDataSubject.send($0)
                })
                .map { // TODO: mapToVoid
                    _ in
                }
                .eraseToAnyPublisher()
        )
        
        // Outputs
        return .init(
            items: allItems.eraseToAnyPublisher(),
            events: events.eraseToAnyPublisher()
        )
    }
    
}
