//
//  RepeatTimer.swift
//
//
//  Created by 오지연 on 8/6/24.
//

import Foundation
import Combine

protocol RepeatTimerProtocol {
    
    var timerPublisher: AnyPublisher<Void, Never> { get }
    
    func start()
    func stop()
    
}

final class RepeatTimer {
    
    private var cancellables: [AnyCancellable] = []
    
    private let timerSubject: PassthroughSubject<Void, Never> = .init()
    
    private let duration: TimeInterval
    
    init(duration: TimeInterval = 3.0) {
        self.duration = duration
    }
    
    deinit {
        print("[DEINIT] \(type(of: self))")
        self.cancellables = []
    }
    
}

extension RepeatTimer: RepeatTimerProtocol {
    
    var timerPublisher: AnyPublisher<Void, Never> {
        timerSubject.eraseToAnyPublisher()
    }
    
    func start() {
        self.stop()
        
        Timer.publish(every: self.duration, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.timerSubject.send()
            }
            .store(in: &cancellables)
    }
    
    func stop() {
        self.cancellables = []
    }
    
}
