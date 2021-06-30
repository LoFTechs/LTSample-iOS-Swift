//
//  CallActionView.swift
//  LTSample-iOS
//
//  Created by shanezhang on 2021/4/27.
//

import UIKit

class CallActionView: UIView {
    @IBOutlet var btnAction: UIButton!
    @IBOutlet var lblActionName: UILabel!
    @IBOutlet var btnHeightConstraint: NSLayoutConstraint!
    var btnSize: CGFloat = 80 {
        didSet {
            btnHeightConstraint.constant = btnSize
            btnAction.layer.cornerRadius = btnSize * 0.5
            btnAction.layer.masksToBounds = true
        }
    }
    
    var isActive = false {
        didSet {
            setActive = isActive
        }
    }
    
    var setActive: Bool {
        set {
            btnAction.tintColor = newValue ? .black : .white
            btnAction.backgroundColor = newValue ? .white : UIColor(white: 1, alpha: 0.2)
        }
        get {
            return isActive
        }
    }
    
    static func makeView(image: UIImage?, name: String?, btnSize: Int = 80) -> CallActionView {
        let view = Bundle.main.loadNibNamed("CallActionView", owner: nil, options: nil)?.first as! CallActionView
        view.loadView(image: image, name: name, btnSize :btnSize)
        return view
    }
    
    func loadView(image: UIImage?, name: String?, btnSize: Int) {
        
        lblActionName.text = name
        
        btnAction.setImage(image?.withRenderingMode(.alwaysTemplate), for:.normal)
        btnAction.circle()
        btnAction.addTarget(self, action: #selector(touchUpOutside), for: .touchUpOutside)
        btnAction.addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
        btnAction.addTarget(self, action: #selector(touchDown), for: .touchDown)
        
        self.btnSize = CGFloat(btnSize)
        setActive = isActive
    }
    
    @IBAction func touchDown() {
        setActive = true
    }
    
    @IBAction func touchUpInside() {
        isActive = !isActive
    }
    
    @IBAction func touchUpOutside() {
        setActive = isActive
    }
    
}
