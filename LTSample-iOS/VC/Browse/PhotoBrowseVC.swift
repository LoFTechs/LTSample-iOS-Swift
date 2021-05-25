//
//  PhotoBrowseVC.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/5/12.
//

import UIKit

class PhotoBrowseVC: UIViewController {
    private let imageView: ZoomImageView = {
        let view = ZoomImageView()
        return view
    }()
    
    init(image: UIImage?) {
        imageView.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.coveredByView(imageView)
        
        if let _ = navigationController {
            title = "Browse Picture"
            navigationController?.navigationBar.isTranslucent = false
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "multiply"), style: .done, target: self, action: #selector(clickClose))
        }
    }
    
    @IBAction private func clickClose() {
        dismiss(animated: true, completion: nil)
    }
}
