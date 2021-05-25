//
//  LTListVC.swift
//  LTSample-iOS
//
//  Created by shanezhang on 2021/4/23.
//

import UIKit

class LTListVC: LTVC {
    
    @IBOutlet weak var listView: UITableView!
    
    lazy var search:UISearchController = {
        let search = UISearchController()
        search.searchBar.placeholder = "Search"
        search.obscuresBackgroundDuringPresentation = false
        return search
    }()
    
    var emptyView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            guard let view = emptyView else {
                return
            }
            self.view.coveredByView(view)
            emptyViewShow = true
        }
    }

    var searchShow = false {
        didSet {
            navigationItem.searchController = searchShow ? search : nil
        }
    }
    
    var listViewShow = false {
        didSet {
            listView.isHidden = !listViewShow
            if emptyViewShow && listViewShow {
                emptyViewShow = false
            } else if !emptyViewShow && !listViewShow {
                emptyViewShow = true
            }
        }
    }

    var emptyViewShow = false {
        didSet {
            guard let view = emptyView else {
                return
            }
            
            view.isHidden = !emptyViewShow

            if emptyViewShow && listViewShow {
                listViewShow = false
            } else if !emptyViewShow && !listViewShow {
                listViewShow = true
            }
        }
    }
    
    override func viewDidLoad() {
        searchShow = false
        listViewShow = false
        emptyViewShow = false
    }
    
}
