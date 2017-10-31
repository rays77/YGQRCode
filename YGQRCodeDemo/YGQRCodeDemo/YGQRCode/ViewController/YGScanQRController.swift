//
//  YGScanQRController.swift
//  YGQRCodeDemo
//
//  Created by wuyiguang on 2017/10/26.
//  Copyright © 2017年 YG. All rights reserved.
//

import UIKit
import AVFoundation

/// 遮盖层透明度
private let coverColor = UIColor.init(white: 0, alpha: 0.4)

/// 工具栏透明度
private let toolColor = UIColor(white: 0, alpha: 0.8)

/// 扫描动画时长
private let scanAnimationDuration = 3.0

private let qrScreenWidth  = UIScreen.main.bounds.size.width
private let qrScreenHeight = UIScreen.main.bounds.size.height


@objc protocol YGScanQRDelegate: NSObjectProtocol {
    @objc optional func sacnQRComplete(isSuccess: Bool, result: String?)
}


class YGScanQRController: UIViewController {
    
    weak var scanQRDelegate: YGScanQRDelegate?
    
    fileprivate var scanSession:  AVCaptureSession?
    
    /// 开光灯控制
    fileprivate var lightOn = false
    
    /// 菊花
    fileprivate lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activity.frame = CGRect(x: self.scanPane.bounds.size.width/2-15, y: self.scanPane.bounds.size.height/2-15, width: 30, height: 30)
        activity.hidesWhenStopped = true
        return activity
    }()
    
    /// 扫描框
    fileprivate lazy var scanPane: UIImageView = {
        let scan = UIImageView(frame: CGRect(x: 0, y: 0, width: qrScreenWidth-140, height: qrScreenWidth-140))
        scan.image = UIImage(named: "QRCode_ScanBox")
        scan.backgroundColor = UIColor(white: 0, alpha: 0.1)
        scan.center = self.view.center
        return scan
    }()
    
    /// 上遮盖层
    fileprivate lazy var topCover: UIView = {
        let top = UIView(frame: CGRect(x: 0, y: 0, width: qrScreenWidth, height: self.scanPane.frame.minY))
        top.backgroundColor = coverColor
        return top
    }()
    
    /// 左遮盖层
    fileprivate lazy var leftCover: UIView = {
        let left = UIView(frame: CGRect(x: 0, y: self.scanPane.frame.minY, width: self.scanPane.frame.minX, height: self.scanPane.bounds.size.height))
        left.backgroundColor = coverColor
        return left
    }()
    
    /// 右遮盖层
    fileprivate lazy var rightCover: UIView = {
        let right = UIView(frame: CGRect(x: self.scanPane.frame.maxX, y: self.scanPane.frame.minY, width: qrScreenWidth-self.scanPane.frame.maxX, height: self.scanPane.bounds.size.height))
        right.backgroundColor = coverColor
        return right
    }()
    
    /// 下遮盖层
    fileprivate lazy var bottomCover: UIView = {
        let bottom = UIView(frame: CGRect(x: 0, y: self.scanPane.frame.maxY, width: qrScreenWidth, height: self.toolView.frame.minY))
        bottom.backgroundColor = coverColor
        return bottom
    }()
    
    /// 底部工具栏
    fileprivate lazy var toolView: UIView = {
        let tool = UIView(frame: CGRect(x: 0, y: qrScreenHeight-80, width: qrScreenWidth, height: 80))
        tool.backgroundColor = toolColor
        return tool
    }()
    
    /// 选相册
    fileprivate lazy var photoBtn: UIButton = {
        let photo = UIButton(type: .custom)
        photo.frame = CGRect(x: 50, y: 10, width: 45, height: 60)
        photo.setImage(UIImage(named: "qrcode_scan_btn_photo_nor"), for: .normal)
        photo.addTarget(self, action: #selector(photoAction), for: .touchUpInside)
        return photo
    }()
    
    /// 手电筒
    fileprivate lazy var lightBtn: UIButton = {
        let light = UIButton(type: .custom)
        light.frame = CGRect(x: qrScreenWidth-50-45, y: 10, width: 45, height: 60)
        light.setImage(UIImage(named: "qrcode_scan_btn_flash_nor"), for: .normal)
        light.setImage(UIImage(named: "qrcode_scan_btn_scan_off"), for: .selected)
        light.addTarget(self, action: #selector(lightAction(_:)), for: .touchUpInside)
        return light
    }()
    
    /// 扫描线
    lazy var scanLine: UIImageView = {
        let line = UIImageView()
        line.frame = CGRect(x: 0, y: 0, width: self.scanPane.bounds.width, height: 3)
        line.image = UIImage(named: "QRCode_ScanLine")
        return line
    }()
    
    /// 扫描提示文字
    lazy var scanAlertTitle: UILabel = {
        let titleLbl = UILabel()
        titleLbl.frame = CGRect(x: 0, y: 10, width: self.bottomCover.bounds.width, height: 40)
        titleLbl.text = "将取景框对准二维/条形码，即可自动扫描"
        titleLbl.font = UIFont.systemFont(ofSize: 13)
        titleLbl.backgroundColor = UIColor.clear
        titleLbl.textColor = UIColor.white
        titleLbl.textAlignment = .center
        titleLbl.numberOfLines = 0
        return titleLbl
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "二维码/条码"
        setupUI()
        setupScanSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startScan()
    }
    
    /// 开始扫描
    private func startScan() {
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: Dealloc
    deinit {
        if lightOn {
            lightOn = false
            turnTorchOn()
        }
        // 移除通知
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension YGScanQRController {
    func setupUI() {
        self.view.backgroundColor = UIColor .white
        self.view.addSubview(topCover)
        self.view.addSubview(leftCover)
        self.view.addSubview(rightCover)
        self.view.addSubview(bottomCover)
        self.view.addSubview(toolView)
        self.view.addSubview(scanPane)
        scanPane.addSubview(scanLine)
        toolView.addSubview(lightBtn)
        toolView.addSubview(photoBtn)
        bottomCover.addSubview(scanAlertTitle)
        scanPane.addSubview(activityIndicatorView)
    }
}

// MARK: - 创建扫描设备
extension YGScanQRController {
    private func setupScanSession() {
        do {
            //设置捕捉设备
            let device = AVCaptureDevice.default(for: .video)
            //设置设备输入输出
            let input = try AVCaptureDeviceInput(device: device!)
            
            let output = AVCaptureMetadataOutput()
            output.setMetadataObjectsDelegate((self as AVCaptureMetadataOutputObjectsDelegate), queue: DispatchQueue.main)
            
            //设置会话
            let scanSession = AVCaptureSession()
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
            
            // 设置扫描区域
            NotificationCenter.default.addObserver(forName: NSNotification.Name.AVCaptureInputPortFormatDescriptionDidChange, object: nil, queue: nil, using: { [weak self] (noti) in
                if self?.view != nil {
                    scanPreviewLayer.frame = (self?.view.layer.bounds)!
                    output.rectOfInterest = (scanPreviewLayer.metadataOutputRectConverted(fromLayerRect: (self?.scanPane.frame)!))
                }
            })
            
            //保存会话
            self.scanSession = scanSession
            
        } catch {
            // 摄像头不可用
            AlbumTool.confirm(title: "温馨提示", message: "摄像头不可用", controller: self)
            return
        }
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
}

// MARK: - Method
extension YGScanQRController {
    /// 闪光灯
    @objc func lightAction(_ sender: UIButton) {
        lightOn = !lightOn
        sender.isSelected = lightOn
        turnTorchOn()
    }
    
    /// 相册
    @objc func photoAction() {
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
}

// MARK: - AVCaptureMetadataOutputObjects Delegate
// 扫描捕捉完成
extension YGScanQRController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // 停止扫描
        self.activityIndicatorView.startAnimating()
        self.scanLine.layer.removeAllAnimations()
        self.scanSession!.stopRunning()
        
        // 播放声音
        AlbumTool.playAlertSound(sound: "noticeMusic.caf")
        
        // 扫完完成
        if metadataObjects.count > 0 {
            if let resultObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
                self.activityIndicatorView.stopAnimating()
                self.scanQRDelegate?.sacnQRComplete!(isSuccess: true, result: resultObj.stringValue)
                AlbumTool.confirm(title: "扫描结果", message: resultObj.stringValue, controller: self,handler: { (_) in
                    // 继续扫描
                    self.startScan()
                })
            }
        } else {
            self.activityIndicatorView.stopAnimating()
            self.scanQRDelegate?.sacnQRComplete!(isSuccess: false, result: nil)
        }
    }
}
