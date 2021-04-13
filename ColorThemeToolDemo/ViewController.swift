//
//  ViewController.swift
//  ColorThemeToolDemo
//
//  Created by a on 2021/4/8.
//

import UIKit

let kTooBarHeight: CGFloat = 40
let kPinYinHeight: CGFloat = 26
let kscreenWidth = UIScreen.main.bounds.size.width
let kscreenHeight = UIScreen.main.bounds.size.height

class ViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cropImageView: UIImageView!
    @IBOutlet weak var colorView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        test()
        test2()
    }
    
    func setupView() {
        if let path = Bundle.main.path(forResource: "image@2x.png", ofType: nil) {
            imageView.image = UIImage(contentsOfFile: path)
        }
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        imageView.addGestureRecognizer(tapGR)
    }
    @objc private func tapAction() {
        let alertController: UIAlertController = UIAlertController.init(title: "温馨提示", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let action: UIAlertAction = UIAlertAction.init(title: "相机", style: UIAlertAction.Style.default, handler: { (action) in
            self.choicePhotoWithType(type: .camera)
            alertController.dismiss(animated: true, completion: nil)
        })
        let action1: UIAlertAction = UIAlertAction.init(title: "相册", style: UIAlertAction.Style.default, handler: { (action) in
            self.choicePhotoWithType(type: .photoLibrary)
            alertController.dismiss(animated: true, completion: nil)
        })
        let action2: UIAlertAction = UIAlertAction.init(title: "关闭", style: UIAlertAction.Style.default, handler: { (action) in
            alertController.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(action)
        alertController.addAction(action1)
        alertController.addAction(action2)
        present(alertController, animated: true, completion: nil)
    }
    
    func choicePhotoWithType(type: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(type) {
            let picker = UIImagePickerController.init()
            picker.delegate = self//代理
            picker.sourceType = type//来源
            picker.allowsEditing = false

            self.present(picker, animated: true, completion: nil)
        }else {
            let str: String?
            if type == UIImagePickerController.SourceType.camera {
                str = "摄像头不可用"
            }else
            {
                str = "相册不可用"
            }
            let alertController: UIAlertController = UIAlertController.init(title: "温馨提示", message: str, preferredStyle: UIAlertController.Style.alert)
            let action: UIAlertAction = UIAlertAction.init(title: "知道了", style: UIAlertAction.Style.default, handler: { (action) in
                alertController.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(action)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image: UIImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        print("\(image)")
        imageView.image = image
        picker.dismiss(animated: true, completion: nil)
        test()
    }
    
    func test() {
        let partRect = CGRect(x: 0, y: kPinYinHeight, width: kscreenWidth, height: kTooBarHeight)

        /*
        if let image = imageView.image {
            let size = imageView.frame.size
            let scaleRect = CGRect(origin: .zero, size: size)
            
            let color = SMColorThemeTool.mostColor(source: image, scale: scaleRect, part:partRect )
            self.colorView.backgroundColor = color
            
            let image = SMColorThemeTool.cropImage(source: image, scale: scaleRect, part: partRect)
            self.cropImageView.image = image
        }
         */
        
        /*
         let image = SMColorThemeTool.generateImage(source: imageView, part: partRect)
         self.cropImageView.image = image
         let color = SMColorThemeTool.mostColor(source: imageView, part: partRect)
         self.colorView.backgroundColor = color
         */
        
        //ColorThief框架
        let image = SMColorThemeTool.generateImage(source: imageView, part: partRect)
        self.cropImageView.image = image
        let color = SMColorThemeTool.mostColorByColorThief(source: imageView, part: partRect, quality: 1)
        self.colorView.backgroundColor = color
    }
    
    func test2() {
        let hexColor = SMColorNumberTool.getColorUInt32ByHex("#FFFFFF",alpha: 0.7)
        print("6位16进制转化成ColorUInt32：\(hexColor)")
        let color = SMColorNumberTool.getColorUInt32(hexColor)
        print("UInt32转成Color：\(color)")
        
        let hex = SMColorNumberTool.getAHexColor(color: color)
        print("hex===\(String(describing: hex))")
        
        let colorUInt32 = SMColorNumberTool.getColorUInt32ByColor(color: color)
        print("hex===\(String(describing: colorUInt32))")
    }

}

