//
//  ViewController.swift
//  ImageFeed
//
//  Created by Илья Кузнецов on 29.08.2024.
//

import UIKit

final class ImagesListViewController: UIViewController {
    // MARK: - IB Outlets
    @IBOutlet private var tableView: UITableView!
    // MARK: - Properties
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }

            let image = UIImage(named: photosName[indexPath.row])
            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
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
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
        }
    }
