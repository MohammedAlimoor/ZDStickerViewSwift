//
//  ViewController.swift
//  StickerView
//
//  Created by alimoor on 1/8/17.
//  Copyright © 2017 alimoor. All rights reserved.
//

import UIKit

class ViewController: UIViewController ,ZDStickerViewDelegate{
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var imageView1 = UIImageView(image: UIImage(named: "sampleImage1.jpg"))
        var imageView2 = UIImageView(image: UIImage(named: "sampleImage2.png"))
        imageView2.backgroundColor = UIColor.clear
        var gripFrame1 = CGRect(x:50, y:50,width: 140,height: 140)
        var contentView = UIView(frame: gripFrame1)
        contentView.backgroundColor = UIColor.black
        contentView.addSubview(imageView1)
        contentView.addSubview(imageView2)
        var userResizableView1 = ZDStickerView(frame: gripFrame1)
        userResizableView1.tag = 0
        userResizableView1.stickerViewDelegate = self
        userResizableView1.loadview(contentView: contentView)
        userResizableView1.preventsPositionOutsideSuperview = true
        userResizableView1.translucencySticker = true
        userResizableView1.showEditingHandles()
        self.view.addSubview(userResizableView1)

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func stickerViewDidBeginEditing(sticker: ZDStickerView){}
        func stickerViewDidEndEditing(sticker: ZDStickerView){}
        func stickerViewDidCancelEditing(sticker: ZDStickerView){}
        func stickerViewDidClose(sticker: ZDStickerView){}
        func stickerViewDidLongPressed(sticker: ZDStickerView){}
        func stickerViewDidCustomButtonTap(sticker: ZDStickerView){
          //  [((UITextView*)sticker.contentView) becomeFirstResponder];

    }


}

