//
//  ChatVC.swift
//  LTSample-iOS
//
//  Created by 游勝滄 on 2021/5/5.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Kingfisher
import MapKit

class ChatVC: MessagesViewController {
    
    var chatNavigation: ChatNavigationController {
        get {
            guard let navi = navigationController as? ChatNavigationController else {
                print("Please setup ChatNavigationController.")
                return ChatNavigationController()
            }
            
            return navi
        }
    }
    
    var isSingle: Bool {
        get {
            if chatNavigation.channel?.chType == .single {
                return true
            }
            return false
        }
    }
    
    let outgoingAvatarOverlap: CGFloat = 17.5
    
    let titleView: AvatarTwoLineTitleView = {
        let view = AvatarTwoLineTitleView()
        view.subTitleColor = .systemGray
        return view
    }()
    
    lazy var messageList: [LTMessageResponse] = []
    lazy var sortedMessage: [(TimeInterval, [LTMessageResponse])] = []
    
    private var callItem: UIBarButtonItem?
    
    private(set) lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
        return control
    }()

    // MARK: - Private properties

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        IMManager.shared.currentChannel = chatNavigation.channel
        
        messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: CustomMessagesFlowLayout())
        messagesCollectionView.backgroundColor = .clear
        messagesCollectionView.register(CustomCell.self)
        messagesCollectionView.register(ChatHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        
        super.viewDidLoad()
        
        configureMessageCollectionView()
        configureMessageInputBar()
        setupTitleView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkCanCall()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DownloadManager.shared.addDelegate(self)
        IMManager.shared.addDelegate(self)
        
        messageList.removeAll()
        markRead()
        loadFirstMessages()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        DownloadManager.shared.removeDelegate(self)
        IMManager.shared.removeDelegate(self)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setupTitleView() {
        navigationItem.titleView = titleView
        titleView.title = chatNavigation.subject ?? "Chat"
        if isSingle {
            titleView.subTitle = "last seen recently"
        } else {
            titleView.subTitle = "\(chatNavigation.channel?.memberCount ?? 0) particpants"
        }
        
        titleView.avatar = chatNavigation.avatar
        titleView.imgViewAvatar.contentMode = chatNavigation.avatarContentMode
        titleView.delegate = self

    }
    
    private func checkCanCall() {
        guard let channel = chatNavigation.channel, channel.chType == .single else {
            callItem = navigationItem.rightBarButtonItem
            navigationItem.rightBarButtonItem = nil
            return
        }
        
        guard let _ = navigationItem.rightBarButtonItem else {
            navigationItem.rightBarButtonItem = callItem
            return
        }
    }
    
    @IBAction private func clickCall() {
        if let chID = chatNavigation.channel?.chID {
            let userID = FriendManager.getUserID(chID: chID)
            CallManager.shared.startCall(userID: userID, name: (chatNavigation.subject)!)
        }
    }
    
    private func markRead() {
        guard let channel = chatNavigation.channel else {
            return
        }
        
        var markTS = channel.lastMsgTime
        if channel.unreadCount == 0 {
            guard messageList.count > 0, messageList.last!.sendTime > chatNavigation.readTime else {
                return
            }
            markTS = messageList.last!.sendTime
        } else if messageList.count > 0, messageList.last!.sendTime > markTS {
            markTS = messageList.last!.sendTime
        }
        
        IMManager.shared.markRead(chID: channel.chID, markTS: markTS) {
            if $0 {
                self.chatNavigation.readTime = markTS
            }
        }
    }
    
    func loadFirstMessages() {
        if let chID = chatNavigation.channel?.chID {
            let markTS = Int64(NSDate.now.timeIntervalSince1970 * 1000)
            IMManager.shared.queryMessages(chID: chID, markTS: markTS)
        }
    }
    
    @objc func loadMoreMessages() {
        if let chID = chatNavigation.channel?.chID {
            var markTS = Int64(NSDate.now.timeIntervalSince1970 * 1000)
            if messageList.count > 0 {
                markTS = messageList.first!.sendTime
            }
            
            IMManager.shared.queryMessages(chID: chID, markTS: markTS)
        }
    }
    
    func configureMessageCollectionView() {
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        
        scrollsToLastItemOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false

        showMessageTimestampOnSwipeLeft = true // default false
        
        messagesCollectionView.refreshControl = refreshControl
        
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.sectionInset = UIEdgeInsets(top: 1, left: 8, bottom: 1, right: 8)
        
        // Hide the outgoing avatar and adjust the label alignment to line up with the messages
        layout?.setMessageOutgoingAvatarSize(.zero)
        layout?.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))
        layout?.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))

        // Set outgoing avatar to overlap with the message bubble
        layout?.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 18, bottom: outgoingAvatarOverlap, right: 0)))
        layout?.setMessageIncomingAvatarSize(CGSize(width: 30, height: 30))
        layout?.setMessageIncomingMessagePadding(UIEdgeInsets(top: -outgoingAvatarOverlap, left: -18, bottom: outgoingAvatarOverlap, right: 18))
        
        layout?.setMessageIncomingAccessoryViewSize(CGSize(width: 30, height: 30))
        layout?.setMessageIncomingAccessoryViewPadding(HorizontalEdgeInsets(left: 8, right: 0))
        layout?.setMessageIncomingAccessoryViewPosition(.messageBottom)
        layout?.setMessageOutgoingAccessoryViewSize(CGSize(width: 30, height: 30))
        layout?.setMessageOutgoingAccessoryViewPadding(HorizontalEdgeInsets(left: 0, right: 8))

        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
    func configureMessageInputBar() {
        messageInputBar = CameraInputBarAccessoryView()
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = .primaryColor
        messageInputBar.sendButton.setTitleColor(.primaryColor, for: .normal)
        messageInputBar.sendButton.setTitleColor(
            UIColor.primaryColor.withAlphaComponent(0.3),
            for: .highlighted)
        
        
        messageInputBar.isTranslucent = true
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.inputTextView.tintColor = .primaryColor
        messageInputBar.inputTextView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.placeholderTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 36)
        messageInputBar.inputTextView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        messageInputBar.inputTextView.layer.borderWidth = 1.0
        messageInputBar.inputTextView.layer.cornerRadius = 16.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        configureInputBarItems()
    }
    
    private func configureInputBarItems() {
        messageInputBar.setRightStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.sendButton.imageView?.backgroundColor = UIColor(white: 0.85, alpha: 1)
        messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: false)
        messageInputBar.sendButton.image = UIImage(named: "ic_up")
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.imageView?.layer.cornerRadius = 16
        let charCountButton = InputBarButtonItem()
            .configure {
                $0.title = "0/140"
                $0.contentHorizontalAlignment = .right
                $0.setTitleColor(UIColor(white: 0.6, alpha: 1), for: .normal)
                $0.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .bold)
                $0.setSize(CGSize(width: 50, height: 25), animated: false)
            }.onTextViewDidChange { (item, textView) in
                item.title = "\(textView.text.count)/140"
                let isOverLimit = textView.text.count > 140
                item.inputBarAccessoryView?.shouldManageSendButtonEnabledState = !isOverLimit // Disable automated management when over limit
                if isOverLimit {
                    item.inputBarAccessoryView?.sendButton.isEnabled = false
                }
                let color = isOverLimit ? .red : UIColor(white: 0.6, alpha: 1)
                item.setTitleColor(color, for: .normal)
        }
        let bottomItems = [.flexibleSpace, charCountButton]
        
        configureInputBarPadding()
        
        messageInputBar.setStackViewItems(bottomItems, forStack: .bottom, animated: false)

        // This just adds some more flare
        messageInputBar.sendButton
            .onEnabled { item in
                UIView.animate(withDuration: 0.3, animations: {
                    item.imageView?.backgroundColor = .primaryColor
                })
            }.onDisabled { item in
                UIView.animate(withDuration: 0.3, animations: {
                    item.imageView?.backgroundColor = UIColor(white: 0.85, alpha: 1)
                })
        }
    }
    
    /// The input bar will autosize based on the contained text, but we can add padding to adjust the height or width if neccesary
    /// See the InputBar diagram here to visualize how each of these would take effect:
    /// https://raw.githubusercontent.com/MessageKit/MessageKit/master/Assets/InputBarAccessoryViewLayout.png
    private func configureInputBarPadding() {
    
        // Entire InputBar padding
        messageInputBar.padding.bottom = 8
        
        // or MiddleContentView padding
        messageInputBar.middleContentViewPadding.right = -38
        
    }
    
    // MARK: - Helpers
    
    func isLastSectionVisible() -> Bool {
        
        guard !messageList.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    func isTimeLabelVisible(at indexPath: IndexPath) -> Bool {
        return indexPath.section % 3 == 0 && !isPreviousMessageSameSender(at: indexPath)
    }
    
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.row - 1 >= 0 else { return false }
        let message = sortedMessage[indexPath.section].1[indexPath.row]
        guard message.msgType.rawValue < 9, message.recallStatus == nil else {
            return false
        }
        let preMessage = sortedMessage[indexPath.section].1[indexPath.row - 1]
        guard preMessage.msgType.rawValue < 9, preMessage.recallStatus == nil else {
            return false
        }
        return message.senderID == preMessage.senderID
    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.row + 1 < sortedMessage[indexPath.section].1.count else { return false }
        let message = sortedMessage[indexPath.section].1[indexPath.row]
        guard message.msgType.rawValue < 9, message.recallStatus == nil else {
            return false
        }
        let nextMessage = sortedMessage[indexPath.section].1[indexPath.row + 1]
        guard nextMessage.msgType.rawValue < 9, nextMessage.recallStatus == nil else {
            return false
        }
        return message.senderID == nextMessage.senderID
    }
    
    func setTypingIndicatorViewHidden(_ isHidden: Bool, performUpdates updates: (() -> Void)? = nil) {
        setTypingIndicatorViewHidden(isHidden, animated: true, whilePerforming: updates) { [weak self] success in
            if success, self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
    }
    
    private func makeButton(named: String) -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(10)
                $0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
                $0.setSize(CGSize(width: 25, height: 25), animated: false)
                $0.tintColor = UIColor(white: 0.8, alpha: 1)
            }.onSelected {
                $0.tintColor = .primaryColor
            }.onDeselected {
                $0.tintColor = UIColor(white: 0.8, alpha: 1)
            }.onTouchUpInside {
                print("Item Tapped")
                let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let action = UIAlertAction(title: "Cancel", style: .cancel)
                actionSheet.addAction(action)
                if let popoverPresentationController = actionSheet.popoverPresentationController {
                    popoverPresentationController.sourceView = $0
                    popoverPresentationController.sourceRect = $0.frame
                }
                self.navigationController?.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError("Ouch. nil data source for messages")
        }

        // Very important to check this when overriding `cellForItemAt`
        // Super method will handle returning the typing indicator cell
        guard !isSectionReservedForTypingIndicator(indexPath.section) else {
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }

        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        if case .custom = message.kind {
            let cell = messagesCollectionView.dequeueReusableCell(CustomCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        }
        return super.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        cell.contentView.backgroundColor = .clear
        cell.backgroundColor = .clear
    }
    
    open override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    open override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let message = messageList[indexPath.section]
        var children = [UIAction]()
        
        if message.msgType == .text {
            let copy = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { _ in
                UIPasteboard.general.string = message.msgContent
            }
            children.append(copy)
        }
        
        let recall = UIAction(title: "Recall", image: UIImage(systemName: "arrow.uturn.down")) { _ in

            IMManager.shared.recallMessage(message.msgID)
        }
        children.append(recall)

        let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash.fill"), attributes: [.destructive]) { _ in
            IMManager.shared.deleteMessage(message.msgID)
        }
        children.append(delete)

        let menu = UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
            UIMenu(title: "", children: children)
        }
        return menu
    }
    
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration)
    }
    
    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration)
    }
    
    private func makeTargetedPreview(for configuration: UIContextMenuConfiguration) -> UITargetedPreview? {

        guard let indexPath = configuration.identifier as? NSIndexPath else { return nil }
        guard let cell = messagesCollectionView.cellForItem(at: indexPath as IndexPath) as? MessageContentCell else { return nil }
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        parameters.visiblePath = UIBezierPath(roundedRect: cell.messageContainerView.bounds, cornerRadius: 16)
        return UITargetedPreview(view: cell.messageContainerView, parameters: parameters)
    }
    
}

extension ChatVC: MessagesDataSource {
    func currentSender() -> SenderType {
        return UserInfo.currentUser
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return sortedMessage.count
    }
    
    func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
        return sortedMessage[section].1.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return sortedMessage[indexPath.section].1[indexPath.row]
    }

    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return nil
    }

    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: "Read", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
    }

    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }

    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return nil
    }

}

extension ChatVC: MessageCellDelegate {
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        if let c = cell as? MediaMessageCell, let image = c.imageView.image {
            let vc = PhotoBrowseVC(image: image)
            let navi = UINavigationController.init(rootViewController: vc)
            navi.modalPresentationStyle = .fullScreen
            present(navi, animated: true, completion: nil)
        }
    }
}


extension ChatVC: CameraInputBarAccessoryViewDelegate {

    @objc
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        processInputBar(messageInputBar)
    }

    func processInputBar(_ inputBar: InputBarAccessoryView) {
        // Here we can parse for which substrings were autocompleted
        let text = inputBar.inputTextView.text!
        let attributedText = inputBar.inputTextView.attributedText!
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { (_, range, _) in

            let substring = attributedText.attributedSubstring(from: range)
            let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
            print("Autocompleted: `", substring, "` with context: ", context ?? [])
        }

        inputBar.inputTextView.text = String()
        inputBar.invalidatePlugins()
        // Send button activity animation
        inputBar.sendButton.startAnimating()
        inputBar.inputTextView.placeholder = "Sending..."
        // Resign first responder for iPad split view
        inputBar.inputTextView.resignFirstResponder()
        
        IMManager.shared.sendTextMessage(text) { success in
            inputBar.sendButton.stopAnimating()
            inputBar.inputTextView.placeholder = "Aa"
            if success {
                DispatchQueue.main.async {
                    self.messagesCollectionView.scrollToBottom(true)
                }
            } else {
                AppUtility.alert("Send text message failed.")
            }
        }
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith attachments: [AttachmentManager.Attachment]) {
        guard attachments.count > 0 else {
            return
        }
        
        var isAllSuccess = true
        let group = DispatchGroup()
        for item in attachments {
            if case .image(let image) = item {
                group.enter()
                IMManager.shared.sendImageMessage(image) {
                    if $0 {
                        DispatchQueue.main.async {
                            self.messagesCollectionView.scrollToBottom(true)
                        }
                    } else {
                        isAllSuccess = false
                    }
                    group.leave()
                }
            }
        }
        group.notify(queue: DispatchQueue.main) {
            if !isAllSuccess {
                AppUtility.alert("Some image messages send failed.")
            }
        }
        inputBar.invalidatePlugins()
    }
}

extension ChatVC: IMManagerDelegate {
    var className: AnyClass {
        get {
            return type(of: self)
        }
    }
    
    func onQueryMessages(_ messages: [LTMessageResponse]) {
        refreshControl.endRefreshing()
        guard messages.count > 0 else {
            return
        }
        
        let needScrollToBottom = messageList.count == 0
        var filter = messages.filter { message in
            if message.chID != chatNavigation.channel?.chID {
                return false
            }
            
            if message.msgType == .deleteMsg || message.msgType == .deleteChannelMsg || message.msgType == .recall || message.msgType == .setChannelPreference {
                return false
            }
            
            if let _ = messageList.first(where: {
                $0.msgID == message.msgID
            }) {
                return false
            }
            
            return true
        }
        
        guard filter.count > 0 else {
            return
        }
        
        filter.sort(by: { return $0.sendTime < $1.sendTime})
        messageList.insert(contentsOf: filter, at: 0)
        sortMessages()
        if needScrollToBottom {
            messagesCollectionView.layoutIfNeeded()
            messagesCollectionView.scrollToBottom(false)
        }
    }
    
    func onIncomingMessage(_ message: LTMessageResponse?) {
        guard let msg = message, msg.chID == chatNavigation.channel?.chID else {
            return
        }
        messageList.append(msg)
        markRead()
        sortMessages()
    }
    
    func onNeedQueryMessage() {
        messageList.removeAll()
        loadFirstMessages()
    }
    
    private func sortMessages() {
        sortedMessage = Dictionary(grouping: messageList, by: {
            (TimeInterval($0.sendTime) * 0.001).zeroTimeInDay()
        }).sorted(by: {
            $0.key < $1.key
        }).compactMap{
            ($0, $1)
        }
        messagesCollectionView.reloadData()
    }
}

extension ChatVC: MessagesLayoutDelegate {

    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isTimeLabelVisible(at: indexPath) {
            return 18
        }
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isFromCurrentSender(message: message) {
            return !isPreviousMessageSameSender(at: indexPath) ? 20 : 0
        } else {
            return !isPreviousMessageSameSender(at: indexPath) ? (20 + outgoingAvatarOverlap) : 0
        }
    }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return (!isNextMessageSameSender(at: indexPath) && isFromCurrentSender(message: message)) ? 16 : 0
    }
    
    func messageHeaderView(for indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageReusableView {
        let header = messagesCollectionView.dequeueReusableHeaderView(ChatHeaderView.self, for: indexPath)
        let time = sortedMessage[indexPath.section].0.timeFormat()
        header.title = time
        return header
    }
    
    func headerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 28)
    }

}


// MARK: - MessagesDisplayDelegate

extension ChatVC: MessagesDisplayDelegate {

    // MARK: - Text Messages

    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }

    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .hashtag, .mention:
            if isFromCurrentSender(message: message) {
                return [.foregroundColor: UIColor.white]
            } else {
                return [.foregroundColor: UIColor.primaryColor]
            }
        default: return MessageLabel.defaultAttributes
        }
    }

    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }

    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if case .photo = message.kind {
            return .systemGray
        }
        return isFromCurrentSender(message: message) ? .primaryColor : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }

    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        var corners: UIRectCorner = []
        
        if isFromCurrentSender(message: message) {
            corners.formUnion(.topLeft)
            corners.formUnion(.bottomLeft)
            if !isPreviousMessageSameSender(at: indexPath) {
                corners.formUnion(.topRight)
            }
            if !isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomRight)
            }
        } else {
            corners.formUnion(.topRight)
            corners.formUnion(.bottomRight)
            if !isPreviousMessageSameSender(at: indexPath) {
                corners.formUnion(.topLeft)
            }
            if !isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomLeft)
            }
        }
        
        return .custom { view in
            let radius: CGFloat = 16
            let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            view.layer.mask = mask
        }
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        var (_, imgAvatar) = ProfileManager.shared.getUserProfile(message.sender.senderId)
        if imgAvatar == nil {
            imgAvatar = UIImage(systemName: "person.circle.fill")
        }
        let avatar = Avatar(image: imgAvatar)
        avatarView.set(avatar: avatar)
        avatarView.isHidden = isNextMessageSameSender(at: indexPath)
        avatarView.layer.borderWidth = 2
        avatarView.layer.borderColor = UIColor.primaryColor.cgColor
        avatarView.backgroundColor = .clear
        avatarView.tintColor = .systemGray
    }

    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if case MessageKind.photo(let media) = message.kind, let imageURL = media.url {
            imageView.kf.setImage(with: imageURL)
        } else {
            imageView.kf.cancelDownloadTask()
        }
    }
    
    // MARK: - Location Messages
    
    func annotationViewForLocation(message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
        let pinImage = #imageLiteral(resourceName: "ic_map_marker")
        annotationView.image = pinImage
        annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
        return annotationView
    }
    
    func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
        return { view in
            view.layer.transform = CATransform3DMakeScale(2, 2, 2)
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
                view.layer.transform = CATransform3DIdentity
            }, completion: nil)
        }
    }
    
    func snapshotOptionsForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LocationMessageSnapshotOptions {
        
        return LocationMessageSnapshotOptions(showsBuildings: true, showsPointsOfInterest: true, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    }

    // MARK: - Audio Messages

    func audioTintColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return self.isFromCurrentSender(message: message) ? .white : .primaryColor
    }

    func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
//        audioController.configureAudioCell(cell, message: message) // this is needed especily when the cell is reconfigure while is playing sound
    }
    
}

extension ChatVC: NaviTitleViewDelegate {
    func clickTitleView() {
        performSegue(withIdentifier: "goChatSetting", sender: nil)
    }

}

extension ChatVC: DownloadManagerDelegate {
    func downloadDidFinished(acitons: [LTStorageAction]) {
        messagesCollectionView.reloadData()
    }
    
    func downloadDidFailed(acitons: [LTStorageAction]) {
        
    }

}

extension UIColor {
    static let primaryColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
}


