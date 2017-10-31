//
//  RecognizeQRCodeViewController.swift
//  YGQRCodeDemo
//
//  Created by wuyiguang on 2017/10/26.
//  Copyright © 2017年 YG. All rights reserved.
//

import UIKit

class RecognizeQRCodeViewController: UIViewController
{
    
    //MARK: -
    //MARK: Global Variables
    
    var sourceImage : UIImage?
    
    @IBOutlet private weak var sourceImageView: UIImageView!
    
    @IBOutlet private weak var activityIndicatoryView: UIActivityIndicatorView!
    
    //MARK: -
    //MARK: Lazy Components
    
    
    //MARK: -
    //MARK: Public Methods
    
    
    //MARK: -
    //MARK: Data Initialize
    
    
    //MARK: -
    //MARK: Life Cycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setupImage()
        
        setupGes()
        
    }
    
    
    //MARK: -
    //MARK: Interface Components
    
    private func setupGes()
    {
        
        sourceImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chooseImage)))
        
    }
    
    private func setupImage()
    {
        
        sourceImageView.image = sourceImage
        recognizeQRCode()
        
    }
    
    //MARK: -
    //MARK: Target Action
    
    @objc private func chooseImage()
    {
        
        AlbumTool.shareTool.choosePicture(self, editor: false) { [weak self] (image) in
            self?.sourceImage = image
            self?.setupImage()
        }
        
    }
    
    //MARK: -
    //MARK: Data Request
    
    
    //MARK: -
    //MARK: Private Methods
    
    private func recognizeQRCode()
    {
        
        activityIndicatoryView.startAnimating()
        
        DispatchQueue.global().async {
            let recognizeResult = self.sourceImage?.recognizeQRCode()
            let result = recognizeResult?.characters.count > 0 ? recognizeResult : "无法识别"
            DispatchQueue.main.async {
                AlbumTool.confirm(title: "扫描结果", message: result, controller: self)
                self.activityIndicatoryView.stopAnimating()
            }
        }
        
        
        
    }
    
    //MARK: -
    //MARK: Dealloc
    
    
}


//MARK: -
//MARK: <#statement#> Delegate



