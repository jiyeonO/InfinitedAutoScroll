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
        let currentCarouselIndex: AnyPublisher<Int, Never>
        let endScrollCarouselIndex: AnyPublisher<Int, Never>
    }
    
    struct Outputs {
        let originItemsCount: AnyPublisher<Int, Never>
        let nextPage: AnyPublisher<Void, Never>
        let pageIndex: AnyPublisher<Int, Never>
        let items: AnyPublisher<[BannerModel], Never>
        let events: AnyPublisher<Void, Never>
    }
    
    private let items: [BannerModel]
    private let timer: RepeatTimerProtocol
    
    init(items: [BannerModel], timer: RepeatTimerProtocol) {
        self.items = items
        self.timer = timer
    }
    
}

extension MainViewModel {
    
    func bind(_ inputs: Inputs) -> Outputs {
        let items = self.items
        
        let originItemsSubject: CurrentValueSubject<[BannerModel], Never> = .init(items)
        let originItemsCountSubject: CurrentValueSubject<Int, Never> = .init(items.count)
        
        // Origin Index.
        let pageIndexSubject: PassthroughSubject<Int, Never> = .init()
        
        // Carousel Items.
        let itemsSubject: PassthroughSubject<[BannerModel], Never> = .init()
        
        // Done Timer Action.
        let nextPageTriggerSubject: PassthroughSubject<Void, Never> = .init()
        
        // Events
        let events = Publishers.MergeMany(
            originItemsCountSubject
                .filter { $0 > 1 }
                .handleEvents(receiveOutput: { _ in
                    self.startTimer() // For AutoScroll.
                })
                .map {
                    _ in
                }
                .eraseToAnyPublisher(),
            inputs.currentCarouselIndex // 사용자 스크롤 발생시 Timer 재설정
                .handleEvents(receiveOutput: { page in
                    self.startTimer()
                })
                .map {
                    _ in
                }
                .eraseToAnyPublisher(),
            inputs.endScrollCarouselIndex
                .map { $0 - 1 } // For Page Index
                .handleEvents(receiveOutput: {
                    pageIndexSubject.send($0)
                })
                .map {
                    _ in
                }
                .eraseToAnyPublisher(),
            originItemsSubject
                .map { banners -> [BannerModel] in
                    let canInfinited = banners.count > 1
                    var infinitedItems = banners
                    
                    if canInfinited, let first = items.first, let last = items.last {
                        infinitedItems.insert(last.infinitedModel, at: 0)
                        infinitedItems.append(first.infinitedModel)
                    }
                    
                    return infinitedItems
                }
                .handleEvents(receiveOutput: {
                    itemsSubject.send($0)
                })
                .map {
                    _ in
                }
                .eraseToAnyPublisher(),
            timer.timerPublisher
                .handleEvents(receiveOutput: { _ in
                    nextPageTriggerSubject.send()
                })
                .map {
                    _ in
                }
                .eraseToAnyPublisher()
        )
        
        // Outputs
        return .init(
            originItemsCount: originItemsCountSubject.eraseToAnyPublisher(),
            nextPage: nextPageTriggerSubject.eraseToAnyPublisher(),
            pageIndex: pageIndexSubject.eraseToAnyPublisher(),
            items: itemsSubject.eraseToAnyPublisher(),
            events: events.eraseToAnyPublisher()
        )
    }
    
}

private extension MainViewModel {
    
    func startTimer() {
        self.timer.start()
    }
    
    func stopTimer() {
        self.timer.stop()
    }
    
}
