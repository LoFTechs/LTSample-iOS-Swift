//
//  CallRemoteEventView.swift
//  LTSample-iOS
//
//  Created by shanezhang on 2021/6/16.
//

import UIKit


class CallRemoteEventView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var disableCameraView:UIView = {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        coveredByView(blurView, sendToBack: true)
        return blurView
    }()

    private lazy var muteView: UILabel = {
       let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20)
        label.text = "Mute"
        coveredByView(label)
        return label
    }()
    
    var isDisableCamera: Bool = false {
        didSet {
            disableCameraView.isHidden = !isDisableCamera
        }
    }
    
    var isMute: Bool = false {
        didSet {
            muteView.isHidden = !isMute
        }
    }
    
}
