//
//  LTFileInfo+extension.swift
//  LTSample-iOS
//
//  Created by shanezhang on 2021/4/19.
//

import Foundation

extension LTFileInfo {
    func getStoragePath() -> String {
        return FileManager.default.getCachePath() + self.fileName
    }
    
    func createDownloadFileAction() -> LTStorageAction {
        return LTStorageAction.createDownloadFileAction(with: self, storePath: self.getStoragePath())
    }
    
    func getFileData() -> Data? {
        return nil
    }
}
