//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Илья Кузнецов on 30.08.2024.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet var tableImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet private var gradient: UIView!
    
    func setGradient() {
        gradient.layer.masksToBounds = true
        gradient.layer.cornerRadius = 16
        gradient.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.ypBlack0.cgColor,
            UIColor.ypBlack20.cgColor
        ]
        gradientLayer.frame = gradient.bounds
        gradient.layer.addSublayer(gradientLayer)
    }
    
}
