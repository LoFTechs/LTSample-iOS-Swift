//
//  CollectionViewTVCell.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/5/3.
//

import UIKit

class CollectionViewTVCell: UITableViewCell {
    
    var flowLayout: UICollectionViewFlowLayout? {
        get {
            guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
                return nil
            }
            return layout
        }
    }
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.isScrollEnabled = false
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
    
    private func commonInit() {
        contentView.coveredByView(collectionView)
    }
}
