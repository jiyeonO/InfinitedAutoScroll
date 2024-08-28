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
    private var player: AVQueuePlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerItem: AVPlayerItem?
    
    var tempTitle: String? // Log용
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.reset()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.playerLayer?.frame = self.playerView.bounds
    }
    
    func setupViews() {
        //
    }
    
    func set(_ model: BannerModel) {
        self.titleLabel.text = model.mainTitle
        self.tempTitle = model.mainTitle // Log용
        
        guard let url = model.url else { return }

        let playerItem = AVPlayerItem(url: url)
        playerItem.preferredForwardBufferDuration = 1.0
        self.playerItem = playerItem

        let player = AVQueuePlayer(playerItem: playerItem)
        self.player = player

        // loop
        self.playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
        
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspectFill
        layer.frame = self.playerView.bounds
        layer.backgroundColor = UIColor.lightGray.cgColor // TEMP

        self.playerLayer = layer
        self.playerView.layer.sublayers = [layer]

//        self.player?.play()

        self.player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.new, .initial], context: nil)
        
        self.layoutIfNeeded()
        
        print("===== set \(self.tempTitle ?? "")")
    }
    
    func play() {
        DispatchQueue.main.async {
            self.player?.seek(to: .zero)
            self.player?.play()
//            print("--play \(self.tempTitle)")
        }
    }
    
    func reset() {
        print(">>>>> Reset \(self.tempTitle ?? "") <<<<<< ")
        
        self.thumbnail.isHidden = false
        self.player?.removeObserver(self, forKeyPath: "timeControlStatus")
        self.player = nil
        self.tempTitle = nil
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus" {
            if let statusNumber = change?[.newKey] as? NSNumber {
                let status = AVPlayer.TimeControlStatus(rawValue: statusNumber.intValue)!
                switch status {
                case .playing:
//                    print("Player is playing")
                    self.thumbnail.isHidden = true
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
