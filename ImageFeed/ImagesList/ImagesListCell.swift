//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Илья Кузнецов on 30.08.2024.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - IB Outlets
    
    @IBOutlet private var tableImage: UIImageView!
    @IBOutlet private var likeButton: UIButton!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var gradient: UIView!
    
    // MARK: - Private properties
    
    private lazy var currentDate = Date()
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    // MARK: - Methods
    
    func configCell(cell:ImagesListCell, indexPath: IndexPath) {
        guard let image = UIImage(named: "\(indexPath.row)") else { return }
        
        tableImage.image = image
        
        dateLabel.text = dateFormatter.string(from: currentDate)
        
        let isLiked = UIImage.favoritesActive
        let notLiked = UIImage.favoritesNoActive
        
        likeButton.imageView?.image = indexPath.row % 2 == 0 ? isLiked : notLiked
        
        setGradient()
    }
    
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
