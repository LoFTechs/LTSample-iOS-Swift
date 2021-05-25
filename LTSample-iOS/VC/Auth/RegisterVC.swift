//
//  RegisterVC.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/4/22.
//

import UIKit

class RegisterVC : LTVC {
    @IBOutlet weak private var tfAccountID: UITextField!
    @IBOutlet weak private var tfPassword: UITextField!
    @IBOutlet weak private var tfPasswordAgain: UITextField!
    @IBOutlet weak private var lblHint: UILabel!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observe(name: UITextField.textDidChangeNotification, object: tfAccountID, queue: OperationQueue.main) {_ in
            self.navigationItem.rightBarButtonItem?.isEnabled = self.checkInput()
        }
        
        observe(name: UITextField.textDidChangeNotification, object: tfPassword, queue: OperationQueue.main) {_ in
            self.navigationItem.rightBarButtonItem?.isEnabled = self.checkInput()
        }
        
        observe(name: UITextField.textDidChangeNotification, object: tfPasswordAgain, queue: OperationQueue.main) {_ in
            self.navigationItem.rightBarButtonItem?.isEnabled = self.checkInput()
        }
        
        if !tfAccountID.isFirstResponder && !tfPassword.isFirstResponder && !tfPasswordAgain.isFirstResponder {
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
    
    @IBAction func clickRegister() {
        loading("Registering ...", true)
        SDKManager.shared.register(tfAccountID.text!, password: tfPassword.text!) {returnCode in
            DispatchQueue.main.async {
                self.endLoading()
                self.returnAction(returnCode)
            }
        }
    }
    
    private func checkInput() -> Bool {
        if tfAccountID.text?.count == 0 {
            lblHint.text = "Please enter your accountID."
            return false
        }
        
        return checkPassword()
    }
    
    private func checkPassword() -> Bool {
        if tfPassword.text?.count == 0 {
            lblHint.text = "Please enter your password."
            return false
        }
        
        if tfPassword.text == tfPasswordAgain.text {
            lblHint.text = ""
            return true
        }
        
        lblHint.text = "Enter the wrong password again."
        return false
        
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

extension RegisterVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfAccountID {
            tfPassword.becomeFirstResponder()
        } else if textField == tfPassword {
            tfPasswordAgain.becomeFirstResponder()
        } else {
            if checkInput() {
                clickRegister()
            }
        }
        return true
    }
}
