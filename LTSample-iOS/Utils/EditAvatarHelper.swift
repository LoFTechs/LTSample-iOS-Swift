//
//  EditAvatarHelper.swift
//  LTSample-iOS
//
//  Created by shanezhang on 2021/5/10.
//

import Foundation

protocol EditAvatarProtocol {
    func deleteHandler()
    func editHandler(isLoadingPicker: Bool)
    func completionHandler(avatar: UIImage?)
}

class EditAvatarHelper: NSObject {
    var presentVC: (UIViewController & EditAvatarProtocol)?
    
    init(vc: UIViewController & EditAvatarProtocol) {
        self.presentVC = vc
    }
    
    func clickEditAvatar(avatar: UIImage?) {
        if let _ = avatar {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: "Delete photo", style: .destructive) {_ in
                self.presentVC?.deleteHandler()
            }
            let editAction = UIAlertAction(title: "Choose photo", style: .default) {_ in
                self.presentVC?.editHandler(isLoadingPicker: true)
                self.editAvatar()
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(deleteAction)
            alert.addAction(editAction)
            alert.addAction(cancelAction)
            presentVC?.present(alert, animated: true, completion: nil)
            return
        } else {
            editAvatar()
        }
    }
    
    private func editAvatar() {
        let pickerVC = UIImagePickerController()
        pickerVC.modalPresentationStyle = .fullScreen
        pickerVC.delegate = self
        presentVC?.present(pickerVC, animated: true, completion:{
            self.presentVC?.editHandler(isLoadingPicker: false)
        })
    }
}

extension EditAvatarHelper: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage
        self.presentVC?.completionHandler(avatar: image)
        picker.dismiss(animated: true, completion: nil)
    }
}
