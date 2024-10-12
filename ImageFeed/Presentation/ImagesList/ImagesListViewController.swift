//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Илья Кузнецов on 29.08.2024.
//

import UIKit

final class ImagesListViewController: UIViewController {
    
    // MARK: - Private properties
    
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.backgroundColor = .ypBlack
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        return tableView
    }()
    
    // MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    // MARK: - Private Methods
    
    private func setTableView() {
        view.backgroundColor = .ypBlack
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate(
            [tableView.topAnchor.constraint(equalTo: view.topAnchor),
             tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
             tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ]
        )
    }
}

// MARK: - extensions

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        cell.configCell(cell: cell, indexPath: indexPath)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        )
        
        guard let imageListCell = cell as? ImagesListCell else {
            return ImagesListCell()
        }
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: "\(indexPath.row)") else { return 0 }
        
        let insets = UIEdgeInsets(
            top: Constants.imageTopConstraint,
            left: Constants.leadingSize,
            bottom: Constants.imageBottomConstraint,
            right: Constants.trailingSize
        )
        let imageWidth = image.size.width - insets.left - insets.right
        let imageCellWidth = tableView.bounds.width
        let scaleFactor = imageCellWidth / imageWidth
        let imageCellHeight = image.size.height * scaleFactor + insets.left + insets.right
        
        return imageCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let singleImage = SingleImageViewController()
        let image = UIImage(named: photosName[indexPath.row])
        singleImage.image = image
        singleImage.modalPresentationStyle = .overFullScreen
        present(singleImage, animated: true)
    }
}

extension ImagesListViewController {
    private enum Constants {
        static let imageTopConstraint: CGFloat = 4
        static let imageBottomConstraint: CGFloat = 4
        static let leadingSize: CGFloat = 16
        static let trailingSize: CGFloat = 16
    }
}
