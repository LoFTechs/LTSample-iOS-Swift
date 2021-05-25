//
//  LoginVC.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/4/16.
//

import UIKit

class LoginVC : LTVC {
    @IBOutlet weak private var tfAccountID: UITextField!
    @IBOutlet weak private var tfPassword: UITextField!
    @IBOutlet weak private var btRegister: UIButton!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observe(name: UITextField.textDidChangeNotification, object: tfAccountID, queue: OperationQueue.main) {_ in
            self.navigationItem.rightBarButtonItem?.isEnabled = self.checkInput()
        }
        
        observe(name: UITextField.textDidChangeNotification, object: tfPassword, queue: OperationQueue.main) {_ in
            self.navigationItem.rightBarButtonItem?.isEnabled = self.checkInput()
        }
        
        if !tfAccountID.isFirstResponder && !tfPassword.isFirstResponder {
            tfAccountID.becomeFirstResponder()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeAllObserve()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var shouldAutorotate: Bool {
        return false
    }
    
    @IBAction func clickLogin() {
        loading("Login ...", true)
        SDKManager.shared.login(tfAccountID.text!, password: tfPassword.text!) {returnCode in
            DispatchQueue.main.async {
                self.endLoading()
                self.returnAction(returnCode)
            }
        }
    }
    
    override func loading(_ string: String, _ wait: Bool) {
        super.loading(string, wait)
        btRegister.isEnabled = false
    }
    
    override func endLoading() {
        super.endLoading()
        btRegister.isEnabled = true
    }
    
    private func checkInput() -> Bool {
        if tfAccountID.text?.count == 0 {
            return false
        }
        
        if tfPassword.text?.count == 0 {
            return false
        }
        
        return true
    }

    private func returnAction(_ returnCode: ReturnCode) {
        if returnCode == .success {
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            appdelegate.changeMainVC()

        } else if returnCode == .failed {
            AppUtility.alert("Failed.")
        } else if returnCode == .wrongPassword {
            AppUtility.alert("Wrong password.")
        } else if returnCode == .accountNotExist {
            AppUtility.alert("Account not exist.")
        } else if returnCode == .accountAlreadyExists {
            AppUtility.alert("Account alreay exists.")
        } else if returnCode == .requiresPassword {
            AppUtility.alert("Requires password.")
        }
    }
}

extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfAccountID {
            tfPassword.becomeFirstResponder()
        } else {
            if tfAccountID.text?.count == 0 {
                AppUtility.alert("Please enter account.")
            } else {
                clickLogin()
            }
        }
        return true
    }
}
