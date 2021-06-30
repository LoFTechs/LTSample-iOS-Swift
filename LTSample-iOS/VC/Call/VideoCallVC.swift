//
//  VideoCallVC.swift
//  LTSample-iOS
//
//  Created by shanezhang on 2021/5/30.
//

import UIKit

class VideoCallVC: UIViewController {
    static let shared: VideoCallVC = {
        let vc = VideoCallVC(nibName: "VideoCallVC", bundle: nil)
        return vc
    }()
    
    lazy var window: UIWindow = {
        let w = UIWindow.init(frame: UIScreen.main.bounds)
        w.windowLevel = .alert - 1
        view.backgroundColor = .clear
        return w
    }()
    
    lazy var panGestureAnimeController: PanGestureAnimeController = {
        return PanGestureAnimeController(moveView: subVideoView,
                                         baseView: mainVideoView,
                                         borderArea: CGRect(x: 5, y: 100, width: UIScreen.main.bounds.width - 5, height: UIScreen.main.bounds.height - 150),
                                         speed: 10)
    }()

    @IBOutlet var mainVideoView: UIView!
    @IBOutlet var subVideoView: UIView! {
        didSet {
            subVideoView.frame = CGRect(x: 5, y: 100, width: 100, height: 133)
            subVideoView.layer.cornerRadius = 10
            subVideoView.addGestureRecognizer(panGestureAnimeController.panGesture)
            subVideoView.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(changeMainAction)))
        }
    }
    
    lazy var eventView: CallRemoteEventView = {
        return CallRemoteEventView(frame: view.frame)
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
    
    @IBOutlet var disableCameraLayoutView: UIView! {
        didSet {
            disableCameraView = CallActionView.makeView(image: UIImage(systemName: "video.slash.fill"),name: "",btnSize: 50)
            disableCameraLayoutView.coveredByView(disableCameraView)
        }
    }
    
    @IBOutlet var switchCameraLayoutView: UIView! {
        didSet {
            switchCameraView = CallActionView.makeView(image: UIImage(named: "SwitchCameraButtonSmall_Normal"),name: "",btnSize: 50)
            switchCameraLayoutView.coveredByView(switchCameraView)
        }
    }

    @IBOutlet var muteLayoutView: UIView! {
        didSet {
            muteView = CallActionView.makeView(image: UIImage(named: "PhoneMuteButton_Normal"),name: "",btnSize: 50)
            muteLayoutView.coveredByView(muteView)
        }
    }
    
    @IBOutlet var btnHangup: UIButton! {
        didSet {
            btnHangup.addTarget(self, action: #selector(hangupAction), for: .touchUpInside)
        }
    }
    
    private var disableCameraView: CallActionView! {
        didSet {
            disableCameraView.btnAction.addTarget(self, action: #selector(disableCameraAction), for: .touchUpInside)
        }
    }
    
    private var switchCameraView: CallActionView! {
        didSet {
            switchCameraView.btnAction.addTarget(self, action: #selector(switchCameraAction), for: .touchUpInside)
        }
    }
    
    private var muteView: CallActionView! {
        didSet {
            muteView.btnAction.addTarget(self, action: #selector(muteAction), for: .touchUpInside)
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
    
    var showRemoteInMainView = false {
        didSet {
            guard let call = ltCall else { return }
            
            if showRemoteInMainView {
                call.setRemoteVideoView(mainVideoView)
                call.setLocalVideoView(subVideoView)
            } else {
                call.setLocalVideoView(mainVideoView)
                call.setRemoteVideoView(subVideoView)
            }
            setRemoteCameraEvent()
        }
    }
    
    var isRemoteMute = false {
        didSet {
            setRemoteCameraEvent()
        }
    }
    
    var isRemoteCameraDisable = false {
        didSet {
            setRemoteCameraEvent()
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        window.frame.size = size
    }
    
    //MARK: - Action

    @IBAction func disableCameraAction() {
        guard let call = ltCall else { return }
        
        call.disableCamera(disableCameraView.isActive)
    }
    
    @IBAction func switchCameraAction() {
        guard let call = ltCall else { return }

        call.switch(switchCameraView.isActive ? LTCameraType.back: LTCameraType.front)
    }

    @IBAction func muteAction() {
        guard let call = ltCall else { return }
        
        call.setCallMuted(muteView.isActive)
    }
    
    @IBAction func changeMainAction() {
        guard ltCall != nil else { return }
        showRemoteInMainView = !showRemoteInMainView
    }
    
    @IBAction func showAction(recognizer: UITapGestureRecognizer) {
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
    
    func setRemoteCameraEvent() {

        eventView.removeFromSuperview()
        eventView.isDisableCamera = isRemoteCameraDisable
        eventView.isMute = isRemoteMute
        
        if showRemoteInMainView {
            mainVideoView.coveredByView(eventView)
        } else {
            subVideoView.coveredByView(eventView)
        }
    }
}

   //MARK: - CallManagerDelegate

extension VideoCallVC: CallManagerDelegate {
    func startOutgointCall(_ call: LTCall?, callName: String) {
        guard let newCall = call else { return }
        
        if ltCall == nil {
            ltCall = newCall
            name = callName
            message = "Calling \(callName)"
            isShow = true
            avatar = ProfileManager.shared.getUserAvatar(newCall.options.userID)
            newCall.setLocalVideoView(mainVideoView)
        }
    }

    func receiveIncomingCall(_ call: LTCall?, callName: String) {
        guard let newCall = call else { return }
        
        if ltCall == nil {
            ltCall = newCall
            name = callName
            avatar = ProfileManager.shared.getUserAvatar(newCall.options.userID)
        }
    }

    func getCall() -> LTCall? {
        return ltCall
    }
}

//MARK: - CallManagerDelegate

extension VideoCallVC: LTCallDelegate {

    func ltCallStateRegistered(_ call: LTCall) {
        print("ltCallStateRegistered")
        guard call == ltCall else { return }
        message = "Ringing \(name ?? "")..."
    }
    
    func ltCallStateConnected(_ call: LTCall) {
        print("ltCallStateConnected")
        guard call == ltCall else { return }
        
        if (!isShow) {
            isShow = true
        }
        
        message = "Ringing \(name ?? "")..."
        showRemoteInMainView = true
    }
    
    func ltCallStateWarning(_ call: LTCall, statusCode: LTCallStatusCode) {
        print("ltCallStateWarning:\(statusCode)")
        if statusCode == LTCallStatusCode.noRecordPermission {
            CallManager.shared.checkMicrophonePrivacy {
                if $0 {
                    call.hangUp()
                }
            }
        } else if statusCode == LTCallStatusCode.noCameraPermission {
            CallManager.shared.checkCameraPrivacy {
                if $0 {
                    call.hangUp()
                }
            }
        }
    }
    
    func ltCallStateTerminated(_ call: LTCall?, statusCode: LTCallStatusCode) {
        print("ltCallStateTerminated:\(statusCode)")
        if statusCode == LTCallStatusCode.noRecordPermission {
            CallManager.shared.checkMicrophonePrivacy {_ in
                self.ltCallStateTerminated(call, statusCode: LTCallStatusCode.hangUp)
            }
        } else if statusCode == LTCallStatusCode.noCameraPermission {
            CallManager.shared.checkCameraPrivacy {_ in
                self.ltCallStateTerminated(call, statusCode: LTCallStatusCode.hangUp)
            }
        } else if call == ltCall {
            isShow = false
            showRemoteInMainView = false
            switchCameraView?.isActive = false
            disableCameraView?.isActive = false
            muteView?.isActive = false
            isRemoteMute = false
            isRemoteCameraDisable = false
            ltCall = nil
        }
    }
    
    func ltCallConnectDuration(_ call: LTCall, duration: Int) {
        guard call == ltCall else { return }
        
        message = String(format: "%02i:%02i", duration / 60 ,duration % 60)
    }
    
    func ltCallMediaStateChanged(_ call: LTCall, mediaType: LTMediaType) {
        guard call == ltCall else { return }
        
        switch mediaType {
        case .audioRoute:
            break
        case .callMuted:
            muteView?.isActive = call.isCallMuted()
            break
        case .cameraEnable:
            disableCameraView?.isActive = call.isCameraDisabled()
            break
        case .cameraSwitched:
            switchCameraView?.isActive = (call.getCurrentCameraType() == LTCameraType.back)
            break
        default: break
        }
    }
    
    func ltCallEvent(_ call: LTCall, callEvent: LTCallEvent) {
        guard call == ltCall else { return }

        switch callEvent.callEventType {
        case .mute:
            guard let value:Bool = callEvent.event["action"] as? Bool else { return }
            isRemoteMute = value
            break
        case .cameraDisable:
            guard let value:Bool = callEvent.event["action"] as? Bool else { return }
            isRemoteCameraDisable = value
            break
        default: break
        }
    }
}
