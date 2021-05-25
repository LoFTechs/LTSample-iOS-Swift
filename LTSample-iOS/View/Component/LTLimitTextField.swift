//
//  LTLimitTextField.swift
//  LTSample-iOS
//
//  Created by 游勝滄 on 2021/5/3.
//

import UIKit

class LTLimitTextField: UITextField {
    private var __maxLengths = [UITextField: Int]()
    @IBInspectable var maxLength: Int {
        get {
            guard let l = __maxLengths[self] else {
                return Int.max // (global default-limit. or just, Int.max)
            }
            return l
        }
        set {
            __maxLengths[self] = newValue
            addTarget(self, action: #selector(checkLength), for: .editingChanged)
        }
    }
    
    @IBAction func checkLength(textField: UITextField) {
        if let _ = textField.markedTextRange {
            return
        }
        
        
        guard let text = textField.text, text.count > maxLength else {
            updateLimitHint()
            return
        }
        
        textField.text = String(Array(text).prefix(upTo: maxLength))
    }
    
    
    private let lblLimitHint: UILabel = {
        let view = UILabel()
        view.textColor = .systemGray3
        view.font = .systemFont(ofSize: 16)
        view.adjustsFontSizeToFitWidth = false
        return view
    }()
    
    private let limitHintView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    func commonInit() {
        lblLimitHint.font = font
        limitHintView.addSubview(lblLimitHint)
        lblLimitHint.frame.origin.x = 8
        rightView = limitHintView
        layout()
    }
    
    func layout() {
        lblLimitHint.sizeToFit()
        limitHintView.frame.size = CGSize(width: lblLimitHint.frame.width + 8, height: bounds.height)
        lblLimitHint.frame.size = CGSize(width: lblLimitHint.frame.width, height: bounds.height)
    }
    
    func updateLimitHint() {
        guard let count = text?.count, count > 0 else {
            rightViewMode = .never
            return
        }
        rightViewMode = .always
        let hint = max(0, maxLength - count)
        lblLimitHint.text = "\(hint)"
        layout()
    }
    
    override var text: String? {
        didSet {
            updateLimitHint()
        }
    }
    
    override var font: UIFont? {
        didSet {
            lblLimitHint.font = font
            updateLimitHint()
        }
    }
    
}
