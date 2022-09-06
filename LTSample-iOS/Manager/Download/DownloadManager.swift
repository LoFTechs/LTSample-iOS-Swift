//
//  DownloadManager.swift
//  LTSample-iOS
//
//  Created by shanezhang on 2021/4/16.
//

import Foundation

protocol DownloadManagerDelegate: LTProtocol {
    func downloadDidFinished(acitons: [LTStorageAction])
    func downloadDidFailed(acitons: [LTStorageAction])
}

class DownloadManager: DelegatesObject {
    static let shared = DownloadManager()
    
    private var manager: LTStorageManager?
    private var acitons = [LTStorageAction]()
    private var isExecute = false
    
    func setManager(user: LTUser) {
        guard let manager = LTSDK.getStorageManager(withUserID: user.userID!) else {
            return
        }
        self.manager = manager
    }
    
    func execute(actions: [LTStorageAction]) {
        
        let newActions = actions.filter { newAction -> Bool in
            return !self.acitons.contains { action -> Bool in
                return action.actionID == newAction.actionID || action.storePath == newAction.storePath
            }
        }
        
        if newActions.count == 0 {
            return
        }
        
        self.acitons += newActions
        
        batchExecute()
    }
    
    func download(messageRP: LTMessageResponse) {
        if let rp = messageRP as? LTSendMessageResponse, let fileMessage = rp.message as? LTFileMessage {
            let path = FileManager.default.getCachePath().appending(fileMessage.fileName)
            let action = LTStorageAction.createDownloadFileAction(with: fileMessage.fileInfo, storePath: path)
            FileManager.default.removeFile(path: path)
            execute(actions: [action])
            
        }
    }
    
    func batchExecute() {
        guard !isExecute , let manager = self.manager else {
            return
        }
        
        let actions = self.acitons.count > 5 ? Array(self.acitons[0..<5]) : self.acitons
        
        guard actions.count > 0 else {
            return
        }
        
        isExecute = true
        manager.execute(withAcitons: actions) { (response, storageResult) in
            DispatchQueue.main.async {//TODO: 一筆失敗全部都會失敗
                if response.returnCode == .success, let results = storageResult {
                    let array = self.acitons.filter { action -> Bool in
                        return results.contains { return $0.actionID == action.actionID}
                    }
                    
                    for delegate in self.delegateArray {
                        if let downloadManagerDelegate = delegate as? DownloadManagerDelegate {
                            downloadManagerDelegate.downloadDidFinished(acitons: array)
                        }
                    }
                } else {
                    for delegate in self.delegateArray {
                        if let downloadManagerDelegate = delegate as? DownloadManagerDelegate {
                            downloadManagerDelegate.downloadDidFailed(acitons: actions)
                        }
                    }
                }
                
                self.acitons.removeAll { action -> Bool in
                    return actions.contains { return $0 == action}
                }
                
                self.isExecute = false
                self.batchExecute()
            }
        } resultsChanged: { _ in }
    }
}
