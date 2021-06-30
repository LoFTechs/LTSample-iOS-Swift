//
//  PanGestureAnimeController.swift
//  LTSample-iOS
//
//  Created by shanezhang on 2021/5/30.
//

import Foundation

class PanGestureAnimeController {

    var moveView: UIView
    var baseView: UIView
    var borderArea: CGRect
    var speed: CGFloat = 2
    var leftMove:Bool = { return true }()
    var topMove:Bool = { return true }()
    var offsetPoint:CGPoint = { return CGPoint.zero }()
    var oldPanPoint:CGPoint = { return CGPoint.zero }()

    lazy var panGesture: UIPanGestureRecognizer = {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panAction))
        return panGesture
    }()
    
    init(moveView: UIView, baseView: UIView,borderArea: CGRect, speed: CGFloat) {
        self.moveView = moveView
        self.baseView = baseView
        self.borderArea = borderArea
        self.speed = speed
    }
    
    @objc func panAction(recognizer:UIPanGestureRecognizer) {
        let point = recognizer.location(in: baseView)

        if recognizer.state == .began {
            offsetPoint = CGPoint(x: point.x - moveView.center.x, y: point.y - moveView.center.y)
        } else if recognizer.state == .changed {
            
            moveView.center = CGPoint(x: point.x - offsetPoint.x , y: point.y - offsetPoint.y)
            
            leftMove = (moveView.center.x < baseView.frame.width / 2)
            getSpeedOffset(offset: &leftMove, newOffset: point.x, oldOffset: oldPanPoint.x, speed: speed)
            topMove = (moveView.center.y < baseView.frame.height / 2)
            getSpeedOffset(offset: &topMove, newOffset: point.y, oldOffset: oldPanPoint.y, speed: speed)
            
            oldPanPoint = point

        } else if recognizer.state == .ended {
            let animX = leftMove ? moveView.frame.width / 2 + borderArea.origin.x
                : borderArea.width - moveView.frame.width / 2
            let animY = topMove ? moveView.frame.height / 2 + borderArea.origin.y : borderArea.height - moveView.frame.height / 2
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut) {[self] in
                moveView.center = CGPoint(x: animX , y: animY)
            }
        }
    }
    
    func getSpeedOffset( offset:inout Bool, newOffset: CGFloat, oldOffset: CGFloat, speed: CGFloat) {
        if  newOffset - oldOffset > speed {
            offset = false
        } else if  oldOffset - newOffset > speed {
            offset = true
        }
    }
}
