//
//  ViewController.swift
//  ImageFeed
//
//  Created by Илья Кузнецов on 29.08.2024.
//

import UIKit

class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    
    private lazy var currentDate = Date()
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
}

// MARK: - extensions

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let image = UIImage(named: "\(indexPath.row)") else { return }
        
        cell.tableImage.image = image
        
        cell.dateLabel.text = dateFormatter.string(from: currentDate)
        
        if indexPath.row % 2 == 0 {
            cell.likeButton.imageView?.image = UIImage.favoritesActive
        } else {
            cell.likeButton.imageView?.image = UIImage.favoritesNoActive
        }
        
        cell.setGradient()
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        )
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: "\(indexPath.row)") else { return 0 }
        
        let insets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageWidth = image.size.width - insets.left - insets.right
        let imageCellWidth = tableView.bounds.width
        let scaleFactor = imageCellWidth / imageWidth
        let imageCellHeight = image.size.height * scaleFactor + insets.left + insets.right
        
        return imageCellHeight
    }
}
