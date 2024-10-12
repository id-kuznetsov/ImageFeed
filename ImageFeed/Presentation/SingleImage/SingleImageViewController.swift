//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Илья Кузнецов on 04.09.2024.
//

import UIKit

final class SingleImageViewController: UIViewController {
    
    // MARK: - Properties
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    // MARK: - Private properties
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.indicatorStyle = .default
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.delegate = self
        
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .ypBlack
        return imageView
    }()
    
    private lazy var backButton: UIButton = {
        guard let buttonImage = UIImage(systemName: "chevron.backward") else { return UIButton() }
        let button = UIButton.systemButton(
            with: buttonImage,
            target: self,
            action: #selector(didTapBackButton)
        )
        button.tintColor = .ypWhite
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var likeButton: UIButton = {
        guard let buttonImage = UIImage(named: "Сircle") else { return UIButton() }
        let button = UIButton(type: .custom)
        button.setImage(buttonImage, for: .normal)
        button.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        guard let buttonImage = UIImage(named: "Sharing") else { return UIButton() }
        let button = UIButton(type: .custom)
        button.setImage(buttonImage, for: .normal)
        button.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSingleImageView()
        
        guard let image else { return }
        imageView.image = image
        
        imageView.frame.size = image.size

        rescaleAndCenterImageInScrollView(image: image)

    }
    
    // MARK: - actions
    
    @objc
    private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func didTapShareButton() {
        guard let image else { return }
        let shareContent = [image]
        let activityController = UIActivityViewController(
            activityItems: shareContent,
            applicationActivities: nil
        )
        present(activityController, animated: true)
    }
    
    @objc
    private func didTapLikeButton() {
        likeButton.isEnabled = true
        // TODO: Like button logic
    }
    
    // MARK: - private methods
    
    private func setSingleImageView() {
        view.backgroundColor = .ypBlack
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(backButton)
        view.addSubview(likeButton)
        view.addSubview(shareButton)
        
        NSLayoutConstraint.activate(
            backButtonConstraints() +
            likeButtonConstraints() +
            shareButtonConstraints() +
            scrollViewConstraints()
        )
    }
    
    private func backButtonConstraints() -> [NSLayoutConstraint] {
        [backButton.leadingAnchor.constraint(equalTo:view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
         backButton.topAnchor.constraint(equalTo:view.safeAreaLayoutGuide.topAnchor, constant: 8),
         backButton.widthAnchor.constraint(equalToConstant: 44),
         backButton.heightAnchor.constraint(equalToConstant: 44)
        ]
    }
    
    private func likeButtonConstraints() -> [NSLayoutConstraint] {
        [likeButton.leadingAnchor.constraint(equalTo:view.safeAreaLayoutGuide.leadingAnchor, constant: 69),
         likeButton.bottomAnchor.constraint(equalTo:view.safeAreaLayoutGuide.bottomAnchor, constant: -17),
         likeButton.widthAnchor.constraint(equalToConstant: 50),
         likeButton.heightAnchor.constraint(equalToConstant: 50)
        ] }
    
    private func shareButtonConstraints() -> [NSLayoutConstraint] {
        [shareButton.trailingAnchor.constraint(equalTo:view.safeAreaLayoutGuide.trailingAnchor, constant: -69),
         shareButton.bottomAnchor.constraint(equalTo:view.safeAreaLayoutGuide.bottomAnchor, constant: -17),
         shareButton.widthAnchor.constraint(equalToConstant: 50),
         shareButton.heightAnchor.constraint(equalToConstant: 50)
        ]
    }
    
    private func scrollViewConstraints() -> [NSLayoutConstraint] {
        [scrollView.leadingAnchor.constraint(equalTo:view.safeAreaLayoutGuide.leadingAnchor),
         scrollView.trailingAnchor.constraint(equalTo:view.safeAreaLayoutGuide.trailingAnchor),
         scrollView.topAnchor.constraint(equalTo: view.topAnchor),
         scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
    }

    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale =  imageSize.width / visibleRectSize.width
        let vScale =  imageSize.height / visibleRectSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func centerImage() {
        var insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let visibleRectSize = scrollView.bounds.size
        let newContentSize = scrollView.contentSize
        if visibleRectSize.width > newContentSize.width {
            insets.left = visibleRectSize.width / 2
            insets.right = visibleRectSize.width / 2
        }
        if visibleRectSize.height > newContentSize.height {
            insets.top = visibleRectSize.height / 2
            insets.bottom = visibleRectSize.height / 2
        }
        scrollView.contentInset = insets
    }
}

// MARK: - extensions

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
}
