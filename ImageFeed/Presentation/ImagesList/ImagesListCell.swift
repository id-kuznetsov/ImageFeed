//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Илья Кузнецов on 30.08.2024.
//

import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Constants
    
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - Properties
    
    weak var delegate: ImagesListCellDelegate?
    
    // MARK: - Private Properties
    
    private let imagesListService = ImagesListService.shared
    private let isoFormatter = ISO8601DateFormatter()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    private lazy var tableImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 16
        image.layer.masksToBounds = true
        return image
    }()
    
    private lazy var likeButton: UIButton = {
        guard let buttonImage = UIImage(named: "FavoritesNoActive") else { return UIButton() }
        let button = UIButton(type: .custom)
        button.setImage(buttonImage, for: .normal)
        button.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.textColor = .ypWhite
        dateLabel.font = .systemFont(ofSize: 13)
        return dateLabel
    }()
    
    private lazy var gradient: UIView = {
        let gradient = UIView()
        return gradient
    }()
    
    // MARK: - Initializers
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .ypBlack
        backgroundColor = .clear
        selectionStyle = .none
        setCellUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tableImage.kf.cancelDownloadTask()
        tableImage.image = nil
        dateLabel.text = nil
        likeButton.setImage(UIImage.favoritesNoActive, for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.layer.sublayers?.forEach { $0.frame = gradient.bounds }
    }
    
    // MARK: - Actions
    @objc
    private func didTapLikeButton() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    // MARK: - Public Methods
    
    func configCell(cell:ImagesListCell, indexPath: IndexPath) {
        if let thumbImageURL = imagesListService.photos[indexPath.row].thumbImageURL {
            tableImage.kf.indicatorType = .activity
            tableImage.kf.setImage(with: thumbImageURL,
                                   placeholder: UIImage(named: "placeholder")
            ){ [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let value):
                    contentMode = .scaleAspectFill
                    self.tableImage.image = value.image
                case .failure(let error):
                    print("Failed set photo in list with error: \(error.localizedDescription)")
                }
            }
        } else {
            self.tableImage.image = UIImage(named: "placeholder")
        }
        
        if let imageDateString = imagesListService.photos[indexPath.row].createdAt,
           let imageDate = isoFormatter.date(from: imageDateString) {
            dateLabel.text = dateFormatter.string(from: imageDate)
        } else {
            dateLabel.text = ""
        }
  
        setIsLiked(imagesListService.photos[indexPath.row].isLiked)
        setGradient()
    }

    func setIsLiked(_ isLiked: Bool) {
        let isLikedImage = UIImage.favoritesActive
        let notLikedImage = UIImage.favoritesNoActive
        let image = isLiked ? isLikedImage : notLikedImage
        likeButton.setImage(image, for: .normal)
    }
    
    // MARK: - Private Methods
    
    private func setCellUI() {
        guard tableImage.superview == nil else { return }
        contentView.backgroundColor = .ypBlack
        contentView.clipsToBounds = true
        
        [tableImage, likeButton, dateLabel, gradient].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate(
            tableImageConstraint() +
            likeButtonConstraint() +
            dateLabelConstraint() +
            gradientConstraint()
        )
    }
    
    private func setGradient() {
        gradient.layer.masksToBounds = true
        gradient.layer.cornerRadius = 16
        gradient.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.ypBlack0.cgColor,
            UIColor.ypBlack20.cgColor
        ]
        gradientLayer.frame = gradient.bounds
        if self.gradient.layer.sublayers?.count == nil  {
            gradient.layer.addSublayer(gradientLayer)
        }
    }
    
    // MARK: - Constraints
    
    private func tableImageConstraint() -> [NSLayoutConstraint] {[
        tableImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
        tableImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
        tableImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        tableImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
    ]
    }
    
    private func likeButtonConstraint() -> [NSLayoutConstraint] {[
        likeButton.topAnchor.constraint(equalTo: tableImage.topAnchor),
        likeButton.trailingAnchor.constraint(equalTo: tableImage.trailingAnchor),
        likeButton.widthAnchor.constraint(equalToConstant: 44),
        likeButton.heightAnchor.constraint(equalTo: likeButton.widthAnchor)
    ]
    }
    
    private func dateLabelConstraint() -> [NSLayoutConstraint] {[
        dateLabel.leadingAnchor.constraint(equalTo: tableImage.leadingAnchor, constant: 8),
        dateLabel.bottomAnchor.constraint(equalTo: tableImage.bottomAnchor, constant: -8)
    ]
    }
    
    private func gradientConstraint() -> [NSLayoutConstraint] {[
        gradient.leadingAnchor.constraint(equalTo: tableImage.leadingAnchor),
        gradient.trailingAnchor.constraint(equalTo: tableImage.trailingAnchor),
        gradient.bottomAnchor.constraint(equalTo: tableImage.bottomAnchor),
        gradient.heightAnchor.constraint(equalToConstant: 30)
    ]
    }
}
