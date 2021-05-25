//
//  LTListEmptyView.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/4/26.
//

import UIKit

struct LTListEmptyViewAction {
    var title: String
    var handler: ()->Void
}

class LTListEmptyView: UIView {
    @IBOutlet weak private var lblTitle: UILabel!
    @IBOutlet weak private var lblSubTitle: UILabel!
    @IBOutlet weak private var listView: UITableView!
    @IBOutlet weak private var layoutListHeight: NSLayoutConstraint!
    
    var title: String {
        set {
            lblTitle.text = newValue
        }
        get {
            guard let title = lblTitle.text else {
                return ""
            }
            return title
        }
    }
    
    var attributedTitle: NSAttributedString {
        set {
            lblTitle.attributedText = newValue
        }
        get {
            guard let title = lblTitle.attributedText else {
                return NSAttributedString()
            }
            return title
        }
    }
    
    var subTitle: String {
        set {
            lblSubTitle.text = newValue
        }
        get {
            guard let title = lblSubTitle.text else {
                return ""
            }
            return title
        }
    }
    
    private var actions: [LTListEmptyViewAction] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblTitle.font = .systemFont(ofSize: 20, weight: .medium)
        listView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    }
    
    func addAction(_ action: LTListEmptyViewAction) {
        actions.append(action)
        if let _ = superview, window != nil {
            listView.reloadData()
        }
    }

}

extension LTListEmptyView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 1
        }
        return 48
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row - 1 < actions.count else {
            return
        }
        let action = actions[indexPath.row - 1]
        action.handler()
    }
}

extension LTListEmptyView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if actions.count > 0 {
            layoutListHeight.constant = CGFloat(actions.count * 48) + 1
            return actions.count + 1
        }
        layoutListHeight.constant = 0
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row - 1 < actions.count else {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.numberOfLines = 1
        cell.textLabel?.font = .systemFont(ofSize: 18)
        cell.textLabel?.textColor = .systemBlue
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        
        if indexPath.row == 0 {
            cell.textLabel?.text = ""
            return cell
        }
        let action = actions[indexPath.row - 1]
        cell.textLabel?.text = action.title
        return cell
    }
}
