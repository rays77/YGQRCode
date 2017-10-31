//
//  ViewController.swift
//  YGQRCodeDemo
//
//  Created by wuyiguang on 2017/10/26.
//  Copyright © 2017年 YG. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func scanAction(_ sender: UIButton) {
//        let scanVC = YGScanCodeController()
        let scanVC = YGScanQRController()
        self.navigationController?.pushViewController(scanVC, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

