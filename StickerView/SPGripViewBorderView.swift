//
// ZDStickerView.m
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
class SPGripViewBorderView: UIView {
    var kSPUserResizableViewGlobalInset:CGFloat=5.0
    var kSPUserResizableViewDefaultMinWidth:CGFloat=48.0
    var kSPUserResizableViewDefaultMinHeight:CGFloat=48.0
    var kSPUserResizableViewInteractiveBorderSize:CGFloat=10.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
            self.backgroundColor = UIColor.clear
        
       // return self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  func drawRect(rect: CGRect) {
        var context = UIGraphicsGetCurrentContext()
        context!.saveGState()
        context!.setLineWidth(1.0)
        context!.setStrokeColor(UIColor.gray.cgColor)
        context!.addRect(self.bounds.insetBy(dx: kSPUserResizableViewInteractiveBorderSize / 2, dy: kSPUserResizableViewInteractiveBorderSize / 2))
        context!.strokePath()
        context!.restoreGState()
    }
}
