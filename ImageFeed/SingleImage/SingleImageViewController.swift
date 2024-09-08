//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Илья Кузнецов on 04.09.2024.
//

import UIKit

final class SingleImageViewController: UIViewController {
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let image else { return }
        imageView.image = image
        
        imageView.frame.size = image.size
        rescaleAndCenterImageInScrollView(image: image)
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func centerImage() {
        //TODO: подумать как сделать
        var insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let visibleRectSize = scrollView.bounds.size
        print(visibleRectSize)
        let newContentSize = scrollView.contentSize
        print(newContentSize)
        if visibleRectSize.width > newContentSize.width {
            insets.left = (visibleRectSize.width /*- newContentSize.width*/) / 2
            insets.right = (visibleRectSize.width /*- newContentSize.width*/) / 2
        }
        if visibleRectSize.height > newContentSize.height {
            insets.top = (visibleRectSize.height - newContentSize.height) / 2
            insets.bottom = (visibleRectSize.height - newContentSize.height) / 2
        }
        scrollView.contentInset = insets // добавляется какое-то смещение слева и сверху
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    @IBAction private func didTapShareButton(_ sender: Any) {
        guard let image else { return }
        let shareContent = [image]
        let activityController = UIActivityViewController(
            activityItems: shareContent,
            applicationActivities: nil
        )
        present(activityController, animated: true)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
}
