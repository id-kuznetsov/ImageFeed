//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Илья Кузнецов on 29.08.2024.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {

    // MARK: - Public Properties

    var presenter: (any ImagesListPresenterProtocol)?

    // MARK: - Private Properties
    
    private let imagesListService = ImagesListService.shared
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.backgroundColor = .ypBlack
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .none
        return tableView
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        presenter?.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.presenter?.updatePhotos()
        }

        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Methods
    
    func configure(_ presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    
    func updateTableViewAnimated(from oldCount: Int, to newCount: Int) {
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map { i in
                IndexPath(row: i, section: 0)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in }
    }
    
    func blockInteraction(_ state: Bool) {
        if state {
            UIBlockingProgressHUD.show()
        } else {
            UIBlockingProgressHUD.dismiss()
        }
    }
    
    func showError() {
        let alertModel = AlertModel(
            title: "Что-то пошло не так(",
            message: "Не удалось изменить лайк",
            buttonText: "OK",
            completion: {}
        )
        AlertPresenter.showAlert(alertModel, delegate: self)
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

// MARK: - Extensions

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        cell.configCell(cell: cell, indexPath: indexPath)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.numberOfPhotos() ?? 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.loadNextPage(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        )
        
        guard let imageListCell = cell as? ImagesListCell else {
            assertionFailure("Construct cell failed")
            return ImagesListCell()
        }
        
        imageListCell.delegate = self
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = presenter?.getPhoto(for: indexPath.row) else {
            return 200
        }
        
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
        singleImage.delegate = self
        singleImage.indexPath = indexPath
        let photo = presenter?.getPhoto(for: indexPath.row)
        guard let largeImageURL = photo?.largeImageURL else { return }
        let isLiked = photo?.isLiked ?? false
        let photoID = photo?.id ?? ""
        singleImage.setImageFromURL(fullImageURL: largeImageURL, isLiked: isLiked, photoID: photoID)
        singleImage.modalPresentationStyle = .overFullScreen
        present(singleImage, animated: true)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.didTapLike(for: indexPath.row, in: cell)
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

// MARK: AlertPresenterDelegate

extension ImagesListViewController: AlertPresenterDelegate {
    func showAlert(_ alert: UIAlertController) {
        present(alert, animated: true)
    }
}

extension ImagesListViewController: SingleImageViewControllerDelegate {
    func didUpdateLikeStatus(for indexPath: IndexPath, isLiked: Bool) {
        presenter?.updateLike(for: indexPath.row, isLiked: isLiked)
        
        if let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell {
            cell.setIsLiked(isLiked)
        }
    }
}
