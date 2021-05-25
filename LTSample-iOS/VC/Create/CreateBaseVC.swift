//
//  CreateBaseVC.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/5/4.
//

import UIKit

class CreateBaseVC: LTListVC {
    var navigation: CreateNavigationController {
        get {
            guard let navi = navigationController as? CreateNavigationController else {
                print("Please setup CreateNavigationController.")
                return CreateNavigationController()
            }
            
            return navi
        }
    }
    
    var isSearching: Bool {
        get {
            return search.searchBar.isFirstResponder && (search.searchBar.text ?? "").count > 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listView.tableFooterView = UIView()
    }
}
