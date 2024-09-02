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
            
            player.addObserver(self, forKeyPath: Constants.playerTimeControlKey, options: [.new, .initial], context: nil)
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
            playerView,
            thumbnail,
            titleLabel
        ].forEach {
            self.addSubview($0)
            self.bringSubviewToFront($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: self.topAnchor),
            playerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            playerView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            thumbnail.topAnchor.constraint(equalTo: playerView.topAnchor),
            thumbnail.leadingAnchor.constraint(equalTo: playerView.leadingAnchor),
            thumbnail.trailingAnchor.constraint(equalTo: playerView.trailingAnchor),
            thumbnail.bottomAnchor.constraint(equalTo: playerView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20)
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
        
        self.playerLayer?.frame = self.bounds//self.playerView.bounds
    }
    
    func setupPlayerLayer() {
        let layer = AVPlayerLayer(player: self.player)
        layer.videoGravity = .resizeAspectFill
        layer.frame = self.bounds//playerView.bounds
        layer.backgroundColor = UIColor.lightGray.cgColor
        
        self.playerLayer = layer
        
        self.layoutIfNeeded() // CHECKME: 여기 넣지 않으면 Red 노출 됌.
    }
    
    func set(_ model: BannerModel) {
        self.titleLabel.text = model.mainTitle
        self.tempTitle = model.mainTitle // Log용
        
        self.thumbnail.backgroundColor = .red
        self.thumbnail.isHidden = true//false
        
        guard let url = model.url else { return }
        
        let playerItem = AVPlayerItem(url: url)
        playerItem.preferredForwardBufferDuration = 1.0
        
        self.player = AVQueuePlayer(playerItem: playerItem)
        
//        print("===== set \(self.tempTitle ?? "")")
        
        self.player?.play()//pause()
    }
    
    func pause() {
        self.player?.pause()
        self.player = nil
    }
    
    func play() {
        self.player?.seek(to: .zero)
        self.player?.play()
        print("--play \(self.tempTitle ?? "")")
    }
//
    func reset() {
//        print(">>>>> Reset \(self.tempTitle ?? "") <<<<<< ")
        
        self.player?.removeObserver(self, forKeyPath: Constants.playerTimeControlKey)
        self.player = nil
        self.tempTitle = nil
        self.playerLooper = nil
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == Constants.playerTimeControlKey {
            if let statusNumber = change?[.newKey] as? NSNumber {
                let status = AVPlayer.TimeControlStatus(rawValue: statusNumber.intValue)!
                switch status {
                case .playing:
                    print("Player is playing")
                    self.thumbnail.isHidden = true
                    break
                case .paused:
                    //                    print("Player is paused")
                    break
                case .waitingToPlayAtSpecifiedRate:
                    //                    print("Player is waiting to play at specified rate")
                    break
                @unknown default:
                    //                    print("Player status is unknown")
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


//class BannerCollectionViewCell: UICollectionViewCell {
//
//    @IBOutlet weak var titleLabel: UILabel!
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//    }
//    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        
//        self.reset()
//    }
//
//    func set(_ model: BannerModel) {
//        self.titleLabel.text = model.mainTitle
//        self.backgroundColor = model.color
//    }
//    
//    func reset() {
//        //
//    }
//
//}
