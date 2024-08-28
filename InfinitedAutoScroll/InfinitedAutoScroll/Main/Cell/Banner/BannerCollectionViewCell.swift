//
//  BannerCollectionViewCell.swift
//  InfinitedAutoScroll
//
//  Created by 오지연 on 8/23/24.
//

import UIKit
import AVFoundation

class BannerCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var thumbnail: UIImageView!
    
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
    
    var tempTitle: String? // Log용
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
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
        
        self.layoutIfNeeded() // CHECKME: 여기 넣지 않으면 Red 노출 됌.
    }
    
    func set(_ model: BannerModel) {
        self.titleLabel.text = model.mainTitle
        self.tempTitle = model.mainTitle // Log용
        
        guard let url = model.url else { return }
        
        self.thumbnail.isHidden = true//false
//        self.thumbnailImageView.kf.setImage(with: thumbnailUrl, placeholder: Constants.defaultImage)
        
        let playerItem = AVPlayerItem(url: url)
        playerItem.preferredForwardBufferDuration = 1.0
        
        self.player = AVQueuePlayer(playerItem: playerItem)
        
        print("===== set \(self.tempTitle ?? "")")
        
//        self.player?.seek(to: .zero)
//        self.player?.play()
        self.player?.pause()
    }
    
    func play() {
        self.player?.seek(to: .zero)
        self.player?.play()
        print("--play \(self.tempTitle ?? "")")
    }
    
    func reset() {
        print(">>>>> Reset \(self.tempTitle ?? "") <<<<<< ")
        
        self.player?.removeObserver(self, forKeyPath: Constants.playerTimeControlKey)
        self.player = nil
        self.tempTitle = nil
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == Constants.playerTimeControlKey {
            if let statusNumber = change?[.newKey] as? NSNumber {
                let status = AVPlayer.TimeControlStatus(rawValue: statusNumber.intValue)!
                switch status {
                case .playing:
//                    print("Player is playing")
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
