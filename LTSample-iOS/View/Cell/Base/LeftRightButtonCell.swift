//
//  LeftRightButtonCell.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/5/5.
//

import UIKit

protocol LeftRightButtonCellDelegate: AnyObject {
    func LeftRightButtonCellDidClickLeftButton(_ cell: LeftRightButtonCell)
    func LeftRightButtonCellDidClickRightButton(_ cell: LeftRightButtonCell)
}

class LeftRightButtonCell: UITableViewCell {
    
    weak var delegate: LeftRightButtonCellDelegate?
    
    private let leftButton: UIButton = {
        let view = UIButton(type: .system)
        view.setTitleColor(.systemBlue, for: .normal)
        view.titleLabel?.font = .systemFont(ofSize: 17)
        view.isHidden = true
        return view
    }()
    
    var leftTitle: String {
        set {
            leftButton.setTitle(newValue, for: .normal)
            leftButton.isHidden = (newValue.count == 0)
        }
        
        get {
            return leftButton.titleLabel?.text ?? ""
        }
    }
    
    private let rightButton: UIButton = {
        let view = UIButton(type: .system)
        view.setTitleColor(.systemBlue, for: .normal)
        view.titleLabel?.font = .systemFont(ofSize: 17)
        view.isHidden = true
        return view
    }()
    
    var rightTitle: String {
        set {
            rightButton.setTitle(newValue, for: .normal)
            rightButton.isHidden = (newValue.count == 0)
        }
        
        get {
            return rightButton.titleLabel?.text ?? ""
        }
    }

    
    static private let selectedBGView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
        
        leftButton.addTarget(self, action: #selector(clickLeft), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(clickRight), for: .touchUpInside)
        contentView.addSubview(leftButton)
        contentView.addSubview(rightButton)
        selectedBackgroundView = type(of: self).selectedBGView
        separatorInset = .zero
    }
    
    func layout() {
        leftButton.sizeToFit()
        leftButton.center = CGPoint(x: leftButton.bounds.width * 0.5 + 16, y: center.y)
        
        
        rightButton.sizeToFit()
        rightButton.center = CGPoint(x: bounds.width - rightButton.bounds.width * 0.5 - 16, y: center.y)
    }
    
    @IBAction private func clickLeft() {
        delegate?.LeftRightButtonCellDidClickLeftButton(self)
    }
    
    @IBAction private func clickRight() {
        delegate?.LeftRightButtonCellDidClickRightButton(self)
    }
}
