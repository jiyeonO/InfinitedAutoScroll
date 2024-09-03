//
//  BannerCollectionViewCell.swift
//  InfinitedAutoScroll
//
//  Created by D프로젝트노드_오지연 on 8/23/24.
//

import UIKit
import AVFoundation

final class BannerCollectionViewCell: UICollectionViewCell {
    
    private var titleLabel = UILabel()
    private var playerView = UIView()
    private var thumbnail = UIImageView()
    private var playerLooper: AVPlayerLooper?
    
    private var player: AVQueuePlayer? {
        didSet {
            guard let player = player, let playerItem = player.currentItem else { return }
            self.playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
            
            self.setupPlayerLayer()
            
            player.addObserver(self, forKeyPath: Constants.playerTimeControlKey, options: [.new], context: nil)
        }
    }
    
    private var playerLayer: AVPlayerLayer? {
        didSet {
            guard let layer = playerLayer else { return }
            self.playerView.layer.sublayers = [layer]
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        [
            self.playerView,
            self.thumbnail,
            self.titleLabel
        ].forEach {
            self.addSubview($0)
            self.bringSubviewToFront($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            self.playerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.playerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.playerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.playerView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.thumbnail.topAnchor.constraint(equalTo: self.playerView.topAnchor),
            self.thumbnail.leadingAnchor.constraint(equalTo: self.playerView.leadingAnchor),
            self.thumbnail.trailingAnchor.constraint(equalTo: self.playerView.trailingAnchor),
            self.thumbnail.bottomAnchor.constraint(equalTo: self.playerView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            self.titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var tempTitle: String? // Log용
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.reset()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.playerLayer?.frame = self.playerView.bounds
    }
    
    func setupPlayerLayer() {
        let layer = AVPlayerLayer(player: self.player)
        layer.videoGravity = .resizeAspectFill
        layer.frame = self.playerView.bounds
        layer.backgroundColor = UIColor.lightGray.cgColor
        
        self.playerLayer = layer
    }
    
    func set(_ model: BannerModel) {
        self.titleLabel.text = model.mainTitle
        self.tempTitle = model.mainTitle // Log용
        
        self.thumbnail.backgroundColor = model.color
        
        guard let url = model.url else { return }
        
        let playerItem = AVPlayerItem(url: url)
//        playerItem.preferredForwardBufferDuration = 3.0
//        playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
//        
//        self.player?.automaticallyWaitsToMinimizeStalling = false
        self.player = AVQueuePlayer(playerItem: playerItem)
//        print("===== set \(self.tempTitle ?? "")")
        
        self.player?.pause()
    }
    
    func play() {
        self.player?.seek(to: .zero)
        self.player?.play()
        print("--play \(self.tempTitle ?? "")")
    }

    func reset() {
        print(">>>>> Reset \(self.tempTitle ?? "") <<<<<< ")
        self.player?.removeObserver(self, forKeyPath: Constants.playerTimeControlKey, context: nil)
        
        self.player = nil
        self.tempTitle = nil
        self.playerLooper = nil
        
        self.thumbnail.isHidden = false
    }
    
    func pause() {
        self.player?.pause()
        self.thumbnail.isHidden = false
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == Constants.playerTimeControlKey {
            if let statusNumber = change?[.newKey] as? NSNumber {
                let status = AVPlayer.TimeControlStatus(rawValue: statusNumber.intValue)!
                switch status {
                case .playing:
                    print("Player is playing \(String(describing: tempTitle))")
                    
                    if player?.currentItem?.isPlaybackLikelyToKeepUp ?? false {
                        print("isPlaybackLikelyToKeepUp")
                        self.thumbnail.isHidden = true
                    }
                default:
                    break
                }
            }
        }
    }
   
}

private extension BannerCollectionViewCell {
    
    enum Constants {
        static let playerTimeControlKey: String = "timeControlStatus"
    }
    
}
