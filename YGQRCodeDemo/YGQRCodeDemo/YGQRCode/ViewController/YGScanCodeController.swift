//
//  YGScanCodeController.swift
//  YGQRCodeDemo
//
//  Created by wuyiguang on 2017/10/26.
//  Copyright © 2017年 YG. All rights reserved.
//

import UIKit
import AVFoundation

/// 扫描动画时长
private let scanAnimationDuration = 3.0

class YGScanCodeController: UIViewController {
    /// 扫描框
    @IBOutlet weak var scanPane: UIImageView!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    /// 开光灯控制
    var lightOn = false
    
    lazy var scanLine : UIImageView = {
        let scanLine = UIImageView()
        scanLine.frame = CGRect(x: 0, y: 0, width: self.scanPane.bounds.width, height: 3)
        scanLine.image = UIImage(named: "QRCode_ScanLine")
        
        return scanLine
    }()
    
    var scanSession :  AVCaptureSession?
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // view.layoutIfNeeded()
        self.title = "二维码/条码"
        scanPane.addSubview(scanLine)
        setupScanSession()
    }
    
    override func viewWillLayoutSubviews() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startScan()
    }
    
    // MARK: Interface Components
    func setupScanSession() {
        do {
            //设置捕捉设备
            let device = AVCaptureDevice.default(for: .video)
            //设置设备输入输出
            let input = try AVCaptureDeviceInput(device: device!)
            
            let output = AVCaptureMetadataOutput()
            output.setMetadataObjectsDelegate((self as AVCaptureMetadataOutputObjectsDelegate), queue: DispatchQueue.main)
            
            //设置会话
            let  scanSession = AVCaptureSession()
            scanSession.canSetSessionPreset(AVCaptureSession.Preset.high)
            
            if scanSession.canAddInput(input) {
                scanSession.addInput(input)
            }
            
            if scanSession.canAddOutput(output) {
                scanSession.addOutput(output)
            }
            
            //设置扫描类型(二维码和条形码)
            output.metadataObjectTypes = [
                AVMetadataObject.ObjectType.qr,
                AVMetadataObject.ObjectType.code39,
                AVMetadataObject.ObjectType.code128,
                AVMetadataObject.ObjectType.code39Mod43,
                AVMetadataObject.ObjectType.ean13,
                AVMetadataObject.ObjectType.ean8,
                AVMetadataObject.ObjectType.code93
            ]
            
            //预览图层
            let scanPreviewLayer = AVCaptureVideoPreviewLayer(session:scanSession)
            scanPreviewLayer.videoGravity = .resizeAspectFill
            scanPreviewLayer.frame = self.view.layer.bounds
            
            view.layer.insertSublayer(scanPreviewLayer, at: 0)
            
            //设置扫描区域
            NotificationCenter.default.addObserver(forName: NSNotification.Name.AVCaptureInputPortFormatDescriptionDidChange, object: nil, queue: nil, using: { (noti) in
                scanPreviewLayer.frame = self.view.layer.bounds
                output.rectOfInterest = (scanPreviewLayer.metadataOutputRectConverted(fromLayerRect: self.scanPane.frame))
            })
            
            //保存会话
            self.scanSession = scanSession
            
        } catch {
            // 摄像头不可用
            AlbumTool.confirm(title: "温馨提示", message: "摄像头不可用", controller: self)
            return
        }
    }
    
    // MARK: Target Action
    /// 闪光灯
    @IBAction func light(_ sender: UIButton) {
        lightOn = !lightOn
        sender.isSelected = lightOn
        turnTorchOn()
    }
    
    /// 相册
    @IBAction func photo() {
        AlbumTool.shareTool.choosePicture(self, editor: true, options: .photoLibrary) {[weak self] (image) in
            
            self!.activityIndicatorView.startAnimating()
            
            DispatchQueue.global().async {
                let recognizeResult = image.recognizeQRCode()
                let result = recognizeResult?.characters.count > 0 ? recognizeResult : "无法识别"
                DispatchQueue.main.async {
                    self!.activityIndicatorView.stopAnimating()
                    AlbumTool.confirm(title: "扫描结果", message: result, controller: self!)
                }
            }
        }
    }
    
    // MARK: Data Request
    
    // MARK: Private Methods
    // 开始扫描
    fileprivate func startScan() {
        scanLine.layer.add(scanAnimation(), forKey: "scan")
        
        guard let scanSession = scanSession else { return }
        
        if !scanSession.isRunning {
            scanSession.startRunning()
        }
    }
    
    /// 扫描动画
    private func scanAnimation() -> CABasicAnimation {
        let startPoint = CGPoint(x: scanLine .center.x  , y: 1)
        let endPoint = CGPoint(x: scanLine.center.x, y: scanPane.bounds.size.height - 2)
        
        let translation = CABasicAnimation(keyPath: "position")
        translation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        translation.fromValue = NSValue(cgPoint: startPoint)
        translation.toValue = NSValue(cgPoint: endPoint)
        translation.duration = scanAnimationDuration
        translation.repeatCount = MAXFLOAT
        translation.autoreverses = true
        
        return translation
    }
    
    /// 闪光灯
    private func turnTorchOn() {
        guard let device = AVCaptureDevice.default(for: .video) else {
            if lightOn {
                AlbumTool.confirm(title: "温馨提示", message: "闪光灯不可用", controller: self)
            }
            return
        }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                if lightOn && device.torchMode == .off {
                    device.torchMode = .on
                }
                
                if !lightOn && device.torchMode == .on {
                    device.torchMode = .off
                }
                
                device.unlockForConfiguration()
            }
            catch{ }
        }
    }
    
    // MARK: Dealloc
    deinit {
        // 移除通知
        NotificationCenter.default.removeObserver(self)
    }
}


// MARK: AVCaptureMetadataOutputObjects Delegate
// 扫描捕捉完成
extension YGScanCodeController: AVCaptureMetadataOutputObjectsDelegate
{
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // 停止扫描
        self.scanLine.layer.removeAllAnimations()
        self.scanSession!.stopRunning()
        
        // 播放声音
        AlbumTool.playAlertSound(sound: "noticeMusic.caf")
        
        // 扫完完成
        if metadataObjects.count > 0 {
            if let resultObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
                AlbumTool.confirm(title: "扫描结果", message: resultObj.stringValue, controller: self,handler: { (_) in
                    // 继续扫描
                    self.startScan()
                })
            }
        }
    }
}
