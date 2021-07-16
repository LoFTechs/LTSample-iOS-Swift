//
//  CallVC.swift
//  LTSample-iOS
//
//  Created by shanezhang on 2021/4/27.
//

import UIKit

class CallVC: UIViewController {
    static let shared: CallVC = {
        let vc = CallVC(nibName: "CallVC", bundle: nil)
        CallManager.shared.delegate = vc
        return vc
    }()
    
    lazy var window: UIWindow = {
        let w = UIWindow.init(frame: UIScreen.main.bounds)
        w.windowLevel = .alert + 1
        view.backgroundColor = .clear
        return w
    }()
    
    private lazy var statusBarVC: CallStatusBarVC = {
        return CallStatusBarVC.shared
    }()
    
    @IBOutlet var lblName: UILabel! {
        didSet {
            lblName.text = name
        }
    }
    
    @IBOutlet var lblMessage: UILabel! {
        didSet {
            lblMessage.text = message
        }
    }
    
    @IBOutlet var imgAvatar: UIImageView! {
        didSet {
            imgAvatar.image = avatar ?? UIImage(systemName: "person.crop.circle")
            imgAvatar.circle()
        }
    }
    
    @IBOutlet var speakerLayoutView: UIView! {
        didSet {
            speakerView = CallActionView.makeView(image: UIImage(named: "PhoneSpeakerButton_Normal"),name: "speaker")
            speakerLayoutView.coveredByView(speakerView)
        }
    }

    @IBOutlet var muteLayoutView: UIView! {
        didSet {
            muteView = CallActionView.makeView(image: UIImage(named: "PhoneMuteButton_Normal"),name: "mute")
            muteLayoutView.coveredByView(muteView)
        }
    }
    
    @IBOutlet var btnHangup: UIButton! {
        didSet {
            btnHangup.addTarget(self, action: #selector(hangupAction), for: .touchUpInside)
        }
    }
    
    private var speakerView: CallActionView! {
        didSet {
            speakerView.btnAction.addTarget(self, action: #selector(speakerAction), for: .touchUpInside)
        }
    }
    
    private var muteView: CallActionView! {
        didSet {
            muteView.btnAction.addTarget(self, action: #selector(muteAction), for: .touchUpInside)
        }
    }
    
    private var blurView: UIVisualEffectView? {
        didSet {
            oldValue?.removeFromSuperview()
            guard let new = blurView else {
                return
            }
            
            view.coveredByView(new, sendToBack: true)
        }
    }
    
    var isShow = false {
        didSet {
            window.rootViewController = self
            let view = window
            let ratio: CGFloat = 0.2
            let scale: CGFloat = 1 + ratio
            let largeTransform = CGAffineTransform(translationX: 0, y: -(view.bounds.height * ratio * 0.05)).scaledBy(x: scale, y: scale)
            let normalTransform = CGAffineTransform.identity
            let startTransform = isShow ? largeTransform : normalTransform
            let startAlpha = isShow ? 0 : 1
            let endTransform = isShow ? normalTransform : largeTransform
            let endAlpha = isShow ? 1 : 0
            
            view.isHidden = false
            statusBarVC.isShow = false
            
            if isShow {
                let blurEffect = UIBlurEffect(style: .dark)
                blurView = UIVisualEffectView(effect: blurEffect)
            }
            
            view.transform = startTransform
            view.alpha = CGFloat(startAlpha)
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
                view.transform = endTransform
                view.alpha = CGFloat(endAlpha)
            } completion: { _ in
                view.transform = normalTransform
                view.alpha = 1
                view.isHidden = !self.isShow
            }
        }
    }
    
    var ltCall: LTCall? {
        didSet {
            ltCall?.delegate = self
        }
    }
    
    var name: String? {
        didSet {
            lblName?.text = name
        }
    }
    
    var message: String? {
        didSet {
            lblMessage?.text = message
        }
    }
    
    var avatar: UIImage? {
        didSet {
            imgAvatar?.image = avatar ?? UIImage(systemName: "person.crop.circle")
        }
    }
    
    var audioRoute: LTAudioRoute? {
        didSet {
            if speakerView != nil {
                speakerView.isActive = (audioRoute == LTAudioRoute.speaker)
            }
        }
    }
    
    var isCallMuted: Bool? {
        didSet {
            if muteView != nil {
                muteView.isActive = isCallMuted ?? false
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        window.frame.size = size
    }
    
    //MARK: - Action

    @IBAction func speakerAction() {
        guard let call = ltCall else {
            return
        }
        
        call.setAudioRoute(speakerView.isActive ? LTAudioRoute.speaker : LTAudioRoute.builtin)
    }

    @IBAction func muteAction() {
        guard let call = ltCall else {
            return
        }
        
        call.setCallMuted(muteView.isActive)
    }
    
    @IBAction func hiddenAction() {
        statusBarVC.isShow = true
        statusBarVC.tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(showAction))
        statusBarVC.lblMessage.text = "Touch to return to call."
        window.isHidden = true
    }
    
    @IBAction func showAction(recognizer: UITapGestureRecognizer) {
        statusBarVC.isShow = false
        isShow = true
    }
    
    @IBAction func hangupAction() {
        guard let call = ltCall else {
            isShow = false
            return
        }
        message = "Call ended"
        call.hangUp()
    }
    
}

   //MARK: - CallManagerDelegate

extension CallVC: CallManagerDelegate {
    func startOutgointCall(_ call: LTCall?, callName: String) {
        guard let newCall = call else {
            return
        }
        
        if ltCall == nil {
            ltCall = newCall
            name = callName
            message = "Calling \(callName)"
            avatar = ProfileManager.shared.getUserAvatar(newCall.options.userID)
            isShow = true
        }
    }

    func receiveIncomingCall(_ call: LTCall, callName: String) {
        if ltCall == nil {
            ltCall = call
            name = callName
            avatar = ProfileManager.shared.getUserAvatar(call.options.userID)
        }
    }

    func getCall() -> LTCall? {
        return ltCall
    }
}

//MARK: - CallManagerDelegate

extension CallVC: LTCallDelegate {

    func ltCallStateRegistered(_ call: LTCall) {
        if call == ltCall {
            message = "Ringing \(name ?? "")..."
        }
    }
    
    func ltCallStateConnected(_ call: LTCall) {
        if !statusBarVC.isShow {
            isShow = true
        }
    }
    
    func ltCallStateWarning(_ call: LTCall, statusCode: LTCallStatusCode) {
        if statusCode == LTCallStatusCode.noRecordPermission {
            CallManager.shared.checkMicrophonePrivacy {
                if $0 {
                    call.hangUp()
                }
            }
        }
    }
    
    func ltCallStateTerminated(_ call: LTCall?, statusCode: LTCallStatusCode) {
        if statusCode == LTCallStatusCode.noRecordPermission {
        } else if call == ltCall {
            ltCall = nil
            isShow = false
            
        }
    }
    
    func ltCallConnectDuration(_ call: LTCall, duration: Int) {
        if call == ltCall {
            message = String(format: "%02i:%02i", duration / 60 ,duration % 60)
            if statusBarVC.isShow {
                statusBarVC.lblMessage.text = message
            }
        }
    }
    
    func ltCallMediaStateChanged(_ call: LTCall, mediaType: LTMediaType) {
        if call == ltCall {
            switch mediaType {
            case .audioRoute:
                if speakerView != nil {
                    audioRoute = call.getCurrentAudioRoute()
                }
                break
            case .callMuted:
                isCallMuted = call.isCallMuted()
                break
            default: break
            }
        }
    }
}
