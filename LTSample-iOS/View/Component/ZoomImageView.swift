//
//  ZoomImageView.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/5/12.
//

import UIKit

class ZoomImageView: UIScrollView {
    
    private var isZoomed = false
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .clear
        return view
    }()
    
    var image: UIImage? {
        set {
            imageView.image = newValue
        }
        
        get {
            return imageView.image
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        isUserInteractionEnabled = true
        clipsToBounds = true
        delegate = self
        contentMode = .center
        maximumZoomScale = 10
        minimumZoomScale = 1
        decelerationRate = .normal
        backgroundColor = .clear

        imageView.frame = bounds
        addSubview(imageView)
    }
    
    private func layout() {
        contentSize = CGSize(width: frame.width * zoomScale, height: frame.height * zoomScale)
        imageView.frame.size = contentSize
    }
    
    
    //MARK: Touch Event
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = event?.allTouches?.first else {
            return
        }
        
        if touch.tapCount == 1 {
            //TODO: Delegate Method
        } else if touch.tapCount == 2 {
            if isZoomed {
                isZoomed = false
                setZoomScale(minimumZoomScale, animated: true)
            } else {
                isZoomed = true
                let zoomScale: CGFloat = 2
                let touchCenter = touch.location(in: self)
                let zoomRectSize = CGSize(width: frame.width / zoomScale, height: frame.height / zoomScale)
                var zoomRect = CGRect(x: touchCenter.x - zoomRectSize.width * 0.5, y: touchCenter.y - zoomRectSize.height * 0.5, width: zoomRectSize.width, height: zoomRectSize.height)
                
                zoomRect.origin.x = min(frame.width - zoomRectSize.width, zoomRect.origin.x)
                zoomRect.origin.x = max(0, zoomRect.origin.x)
                zoomRect.origin.y = min(frame.height - zoomRectSize.height, zoomRect.origin.y)
                zoomRect.origin.y = max(0, zoomRect.origin.y)
                
                zoom(to: zoomRect, animated: true)
            }
        }
    }
}

extension ZoomImageView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        isZoomed = (zoomScale != minimumZoomScale)
    }
}
