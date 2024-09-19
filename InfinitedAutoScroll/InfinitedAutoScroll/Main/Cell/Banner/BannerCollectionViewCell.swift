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
        label.textColor = .white
        label.font = .systemFont(ofSize: 30, weight: .bold)
        return label
    }()
    
    private lazy var imageView = UIImageView()
    
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
        self.imageView.image = UIImage(named: model.imageName)
    }
    
    func reset() {
        self.titleLabel.text = nil
    }
    
}

private extension BannerCollectionViewCell {
    
    func setupViews() {
        [
            self.imageView,
            self.titleLabel
        ].forEach {
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            self.imageView.topAnchor.constraint(equalTo: self.topAnchor),
            self.imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
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
