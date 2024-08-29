//
//  InBannerCollectionViewCell.swift
//  InfinitedAutoScroll
//
//  Created by D프로젝트노드_오지연 on 8/23/24.
//

import UIKit

class InBannerCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.reset()
    }

    func set(_ model: BannerModel) {
        self.titleLabel.text = model.mainTitle
        self.backgroundColor = model.color
    }
    
    func reset() {
        //
    }

}
