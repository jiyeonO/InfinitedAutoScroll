//
//  BannerCollectionViewCell.swift
//  InfinitedAutoScroll
//
//  Created by D프로젝트노드_오지연 on 8/23/24.
//

import UIKit

final class BannerCollectionViewCell: UICollectionViewCell {
    
    private lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        self.titleLabel.text = nil
    }
    
}

private extension BannerCollectionViewCell {
    
    func setupViews() {
        [
            self.titleLabel
        ].forEach {
            self.addSubview($0)
        }
        
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -Constants.InsetConstraint),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.InsetConstraint)
        ])
    }
    
}

private extension BannerCollectionViewCell {
    
    enum Constants {
        static let InsetConstraint: CGFloat = 20
    }
    
}
