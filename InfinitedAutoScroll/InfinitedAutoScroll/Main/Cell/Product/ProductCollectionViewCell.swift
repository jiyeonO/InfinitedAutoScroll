//
//  ProductCollectionViewCell.swift
//  InfinitedAutoScroll
//
//  Created by 오지연 on 8/12/24.
//

import UIKit

class ProductCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func set(_ model: ProductModel) {
        self.titleLabel.text = model.title
    }
    
}
