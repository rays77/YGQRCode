//
//  RootViewController.swift
//  YGQRCodeDemo
//
//  Created by wuyiguang on 2017/10/26.
//  Copyright © 2017年 YG. All rights reserved.
//

import UIKit

class RootViewController: UIViewController
{
    
    //MARK: -
    //MARK: Global Variables
    private let segueID = "RecognizeQRCodeViewController"
    private var sourceImage : UIImage?
    
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
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        
        guard segue.identifier == segueID else { return }
        guard let destinationViewController =  segue.destination as? RecognizeQRCodeViewController else { return }
        destinationViewController.sourceImage = sourceImage;
        
    }
    
    
    //MARK: -
    //MARK: Interface Components
    
    
    //MARK: -
    //MARK: Target Action
    
    @IBAction private  func recognizeQRCodeClick()
    {
        
        AlbumTool.shareTool.choosePicture(self, editor: true) { [weak self] (image) in
            self!.sourceImage = image
            self!.performSegue(withIdentifier: self!.segueID, sender: self)
        }
        
    }
    
    //MARK: -
    //MARK: Data Request
    
    
    //MARK: -
    //MARK: Private Methods
    
    
    //MARK: -
    //MARK: Dealloc
    
    
}




