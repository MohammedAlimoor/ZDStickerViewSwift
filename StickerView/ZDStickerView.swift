//
// Created by Seonghyun Kim on 5/29/13.
// Copyright (c) 2013 scipi. All rights reserved.
//
//
//  SPGripViewBorderView.swift
//  StickerView
//
//  update by Mohammed alimoor alimoor on 1/8/17.
//


import Foundation
import UIKit
enum ZDSTICKERVIEW_BUTTONS : Int {
    case NULL
    case DEL
    case RESIZE
    case CUSTOM
    case MAX
}

class ZDStickerView: UIView {
    
    var kSPUserResizableViewGlobalInset:CGFloat=5.0
    var kSPUserResizableViewDefaultMinWidth:CGFloat=48.0
    var kSPUserResizableViewInteractiveBorderSize:CGFloat=10.0
    var kZDStickerViewControlSize:CGFloat=36.0

    private var borderView: SPGripViewBorderView?
    private var resizingControl: UIImageView?
    private var deleteControl: UIImageView?
    private var customControl: UIImageView?
    private var preventsLayoutWhileResizing=false
    private var deltaAngle: CGFloat?
    private var prevPoint: CGPoint?
    private var startTransform: CGAffineTransform?
    private var touchStart: CGPoint?
    
    var contentView: UIView!
     
        
        func loadview(contentView: UIView){
            self.contentView=contentView
            self.contentView.removeFromSuperview()

            self.contentView.frame = self.bounds.insetBy(dx: (kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize / 2),dy: (kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize / 2))
            
            
            self.contentView.autoresizingMask=[.flexibleWidth,.flexibleHeight]
          //  self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
            self.addSubview(self.contentView)
            for subview: UIView in self.contentView.subviews {
                
                
                subview.frame =  CGRect(x: 0, y: 0, width: self.contentView.frame.size.width, height: self.contentView.frame.size.height)
                subview.autoresizingMask = [.flexibleWidth,.flexibleHeight]// UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
            }
            self.bringSubview(toFront: self.borderView!)
            self.bringSubview(toFront: self.resizingControl!)
            self.bringSubview(toFront: self.deleteControl!)
            self.bringSubview(toFront: self.customControl!)
        
        
    }
    
    var preventsPositionOutsideSuperview: Bool=false
    var preventsResizing: Bool=false
    var preventsDeleting: Bool=false
    var preventsCustomButton: Bool=false
    var translucencySticker: Bool=false
    var minWidth: CGFloat=1
    var minHeight: CGFloat=1
     var stickerViewDelegate:ZDStickerViewDelegate?
    func hideDelHandle() {
        self.deleteControl?.isHidden = true
    }
    
    func showDelHandle() {
        self.deleteControl?.isHidden = false
    }
    
    func hideEditingHandles() {
        self.resizingControl?.isHidden = true
        self.deleteControl?.isHidden = true
        self.customControl?.isHidden = true
        self.borderView?.isHidden=true
    }
    
    func showEditingHandles() {
        if false == self.preventsCustomButton {
            self.customControl?.isHidden = false
        } else {
            self.customControl?.isHidden = true
        }
        if false == self.preventsDeleting {
            self.deleteControl?.isHidden = false
        } else {
            self.deleteControl?.isHidden = true
        }
        if false == self.preventsResizing {
            self.resizingControl?.isHidden = false
        } else {
            self.resizingControl?.isHidden = true
        }
        self.borderView?.isHidden=false
    }
    
    func showCustomHandle() {
        self.customControl?.isHidden = false
    }
    
    func hideCustomHandle() {
        self.customControl?.isHidden = true
    }
    
    func setButton(type: ZDSTICKERVIEW_BUTTONS, image: UIImage) {
        switch type {
        case .RESIZE :
            self.resizingControl?.image = image
            
        case .DEL:
            self.deleteControl?.image = image
            
        case .CUSTOM:
            self.customControl?.image = image
            
        default:self.customControl?.image = image

            
            
        }
    }
    
    func isEditingHandlesHidden() -> Bool {
        return self.borderView!.isHidden
    }
    
    func longPress(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began {
            
                self.stickerViewDelegate?.stickerViewDidLongPressed(sticker: self)
            
        }
        
    }
    
    func singleTap(recognizer: UIPanGestureRecognizer) {
            self.stickerViewDelegate?.stickerViewDidClose(sticker: self)
        
        if false == self.preventsDeleting {
            var close = recognizer.view
            close?.superview?.removeFromSuperview()
        }
    }
    
    func customTap(recognizer: UIPanGestureRecognizer) {
        if false == self.preventsCustomButton {
                self.stickerViewDelegate?.stickerViewDidCustomButtonTap(sticker: self)
            
        }
    }
    
    func resizeTranslate(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began {
            self.enableTransluceny(state: true)
            self.prevPoint = recognizer.location(in: self)
            self.setNeedsDisplay()
        } else if recognizer.state == .changed {
            self.enableTransluceny(state: true)
            if self.bounds.size.width < self.minWidth || self.bounds.size.height < self.minHeight {
                self.bounds = CGRect(x:self.bounds.origin.x,y: self.bounds.origin.y,width: self.minWidth + 1,height: self.minHeight + 1)

                
                self.resizingControl?.frame = CGRect(x:self.bounds.size.width - kZDStickerViewControlSize,y: self.bounds.size.height - kZDStickerViewControlSize,width: kZDStickerViewControlSize,height: kZDStickerViewControlSize)
                
                self.deleteControl?.frame = CGRect(x:0,y: 0,width: kZDStickerViewControlSize,height: kZDStickerViewControlSize)
                self.customControl?.frame = CGRect(x:self.bounds.size.width - kZDStickerViewControlSize,y: 0,width: kZDStickerViewControlSize,height: kZDStickerViewControlSize)
                self.prevPoint = recognizer.location(in: self)
            } else {
                var point = recognizer.location(in: self)
                var wChange:CGFloat = 0.0
                var hChange:CGFloat = 0.0
                wChange = (point.x - (self.prevPoint?.x)!)
                var wRatioChange = (wChange / self.bounds.size.width as! CGFloat)
                hChange = wRatioChange * self.bounds.size.height
                if  abs(wChange) > 50.0  || abs(hChange) > 50.0 {
                    self.prevPoint = recognizer.location(ofTouch: 0, in: self)
                    return
                }
                self.bounds = CGRect(x:self.bounds.origin.x,y: self.bounds.origin.y,width: self.bounds.size.width + (wChange), height:self.bounds.size.height + (hChange))
                self.resizingControl?.frame = CGRect(x:self.bounds.size.width - kZDStickerViewControlSize,y: self.bounds.size.height - kZDStickerViewControlSize,width: kZDStickerViewControlSize,height: kZDStickerViewControlSize)
                self.deleteControl?.frame = CGRect(x:0,y: 0,width: kZDStickerViewControlSize,height: kZDStickerViewControlSize)
                self.customControl?.frame = CGRect(x:self.bounds.size.width - kZDStickerViewControlSize,y: 0, width:kZDStickerViewControlSize, height:kZDStickerViewControlSize)
                self.prevPoint = recognizer.location(ofTouch: 0, in: self)
            }
            var ang = atan2(recognizer.location(in: self.superview).y - self.center.y, recognizer.location(in: self.superview).x - self.center.x)
            var angleDiff = self.deltaAngle! - ang
            if false == self.preventsResizing {
                self.transform = CGAffineTransform(rotationAngle: -angleDiff)
            }
            self.borderView?.frame = self.bounds.insetBy(dx: kSPUserResizableViewGlobalInset, dy: kSPUserResizableViewGlobalInset)
            self.borderView?.setNeedsDisplay()
            self.setNeedsDisplay()
        } else if recognizer.state == .ended {
            self.enableTransluceny(state: false)
            self.prevPoint = recognizer.location(in: self)
            self.setNeedsDisplay()
        }
    }
    
    func setupDefaultAttributes() {
        self.borderView = SPGripViewBorderView(frame: self.bounds.insetBy(dx: kSPUserResizableViewGlobalInset, dy: kSPUserResizableViewGlobalInset))
        self.borderView?.isHidden=true
        self.addSubview(self.borderView!)
        if kSPUserResizableViewDefaultMinWidth > self.bounds.size.width * 0.5 {
            self.minWidth = kSPUserResizableViewDefaultMinWidth
            self.minHeight = self.bounds.size.height * (kSPUserResizableViewDefaultMinWidth / self.bounds.size.width)
        } else {
            self.minWidth = self.bounds.size.width * 0.5
            self.minHeight = self.bounds.size.height * 0.5
        }
        self.preventsPositionOutsideSuperview = true
        self.preventsLayoutWhileResizing = true
        self.preventsResizing = false
        self.preventsDeleting = false
        self.preventsCustomButton = true
        self.translucencySticker = true
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(recognizer:)))
        self.addGestureRecognizer(longpress)
        self.deleteControl = UIImageView(frame: CGRect(x:0,y: 0,width: kZDStickerViewControlSize, height:kZDStickerViewControlSize))
        self.deleteControl?.backgroundColor = UIColor.clear
        self.deleteControl?.image = UIImage(named: "ZDStickerView.bundle/ZDBtn3.png")
        self.deleteControl?.isUserInteractionEnabled = true
        let singleTap = UITapGestureRecognizer(target: self, action:#selector(singleTap(recognizer:)))
        self.deleteControl?.addGestureRecognizer(singleTap)
        self.addSubview(self.deleteControl!)
        self.resizingControl = UIImageView(frame: CGRect(x:self.frame.size.width - kZDStickerViewControlSize,y: self.frame.size.height - kZDStickerViewControlSize,width: kZDStickerViewControlSize,height: kZDStickerViewControlSize))
        self.resizingControl?.backgroundColor = UIColor.clear
        self.resizingControl?.isUserInteractionEnabled = true
        self.resizingControl?.image = UIImage(named: "ZDStickerView.bundle/ZDBtn2.png.png")
        let panResizeGesture = UIPanGestureRecognizer(target: self, action: #selector(resizeTranslate(recognizer:)))
        self.resizingControl?.addGestureRecognizer(panResizeGesture)
        self.addSubview(self.resizingControl!)
        self.customControl = UIImageView(frame: CGRect(x:self.frame.size.width - kZDStickerViewControlSize,y: 0,width: kZDStickerViewControlSize,height: kZDStickerViewControlSize))
        self.customControl?.backgroundColor = UIColor.clear
        self.customControl?.isUserInteractionEnabled = true
        self.customControl?.image = nil
        let customTapGesture = UITapGestureRecognizer(target: self, action:#selector(customTap(recognizer:)))
        self.customControl?.addGestureRecognizer(customTapGesture)
        self.addSubview(self.customControl!)
        self.deltaAngle = atan2(self.frame.origin.y + self.frame.size.height - self.center.y, self.frame.origin.x + self.frame.size.width - self.center.x)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupDefaultAttributes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupDefaultAttributes()
    }
   
    
  
    
    func setFrame(newFrame: CGRect) {
        super.frame=newFrame
        self.contentView.frame = self.bounds.insetBy(dx: kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize / 2, dy: kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize / 2)
        self.contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        for subview: UIView in self.contentView.subviews {
            subview.frame(forAlignmentRect: CGRect(x:0,y: 0,width: self.contentView.frame.size.width,height: self.contentView.frame.size.height))
            
            subview.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        }
        self.borderView?.frame = self.bounds.insetBy(dx: kSPUserResizableViewGlobalInset, dy: kSPUserResizableViewGlobalInset)
        self.resizingControl?.frame = CGRect(x:self.bounds.size.width - kZDStickerViewControlSize,y: self.bounds.size.height - kZDStickerViewControlSize,width: kZDStickerViewControlSize,height: kZDStickerViewControlSize)
        self.deleteControl?.frame = CGRect(x:0,y: 0,width: kZDStickerViewControlSize,height: kZDStickerViewControlSize)
        self.customControl?.frame = CGRect(x:self.bounds.size.width - kZDStickerViewControlSize,y: 0,width: kZDStickerViewControlSize,height: kZDStickerViewControlSize)
        self.borderView?.setNeedsDisplay()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isEditingHandlesHidden() {
            return
        }
        self.enableTransluceny(state: true)
        let touch = touches.first
        self.touchStart = touch?.location(in: self.superview)
        self.stickerViewDelegate?.stickerViewDidBeginEditing(sticker: self)
    }
    
//    func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
//        if self.isEditingHandlesHidden() {
//            return
//        }
//        self.enableTransluceny(state: true)
//        var touch = touches.anyObject() as! UITouch
//        self.touchStart = touch.location(in: self.superview)
//            self.stickerViewDelegate?.stickerViewDidBeginEditing(sticker: self)
//        
//    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.enableTransluceny(state: false)
        self.stickerViewDelegate?.stickerViewDidEndEditing(sticker: self)
    }
    
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.enableTransluceny(state: false)
        self.stickerViewDelegate?.stickerViewDidCancelEditing(sticker: self)
    }
//    func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
//        self.enableTransluceny(state: false)
//            self.stickerViewDelegate?.stickerViewDidCancelEditing(sticker: self)
//    
//    }
    
    func translateUsingTouchLocation(touchPoint: CGPoint) {
        
        var newCenter = CGPoint(x:self.center.x + touchPoint.x - (self.touchStart?.x)!,y: self.center.y + touchPoint.y - (self.touchStart?.y)!)
        if self.preventsPositionOutsideSuperview {
            var midPointX = self.bounds.midX
            if newCenter.x > (self.superview?.bounds.size.width)! - midPointX {
                newCenter.x = (self.superview?.bounds.size.width)! - midPointX
            }
            if newCenter.x < midPointX {
                newCenter.x = midPointX
            }
            var midPointY = self.bounds.midY
            if newCenter.y > (self.superview?.bounds.size.height)! - midPointY {
                newCenter.y = (self.superview?.bounds.size.height)! - midPointY
            }
            if newCenter.y < midPointY {
                newCenter.y = midPointY
            }
        }
        self.center = newCenter
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
       // print("sssss")
        
                if self.isEditingHandlesHidden() {
                    return
                }
                self.enableTransluceny(state: true)
                var touchLocation = touches.first?.location(in: self)
                if (self.resizingControl?.frame.contains(touchLocation!))! {
                    return
                }
                let touch = touches.first?.location(in: self.superview)
                self.translateUsingTouchLocation(touchPoint: touch!)
                self.touchStart = touch
        
        
        
    }
//   override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
//        if self.isEditingHandlesHidden() {
//            return
//        }
//        self.enableTransluceny(state: true)
//        var touchLocation = (touches.anyObject()as! UITouch).location(in: self)
//        if (self.resizingControl?.frame.contains(touchLocation))! {
//            return
//        }
//        let touch = (touches.anyObject()as! UITouch ).location(in: self.superview)
//        self.translateUsingTouchLocation(touchPoint: touch)
//        self.touchStart = touch
//    }
    
    func enableTransluceny(state: Bool) {
        if self.translucencySticker == true {
            if state == true {
                self.alpha = 0.65
            } else {
                self.alpha = 1.0
            }
        }
    }
}

protocol ZDStickerViewDelegate {
     func stickerViewDidBeginEditing(sticker: ZDStickerView)
     func stickerViewDidEndEditing(sticker: ZDStickerView)
     func stickerViewDidCancelEditing(sticker: ZDStickerView)
     func stickerViewDidClose(sticker: ZDStickerView)
     func stickerViewDidLongPressed(sticker: ZDStickerView)
     func stickerViewDidCustomButtonTap(sticker: ZDStickerView)
}
