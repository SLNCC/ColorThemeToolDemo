//
//  ViewController.swift
//  ColorThemeToolDemo
//
//  Created by a on 2021/4/8.
//

import UIKit

let kTooBarHeight: CGFloat = 40
let kPinYinHeight: CGFloat = 26

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cropImageView: UIImageView!
    @IBOutlet weak var colorView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        test()
        let hexColor = SMColorThemeTool.getColorUInt32WithSixHex("#FFFFFF",alpha: 0.7)
        print("6位16进制转化成ColorUInt32：\(hexColor)")
        let color = SMColorThemeTool.getColorWithUInt32(hexColor)
        print("UInt32转成Color：\(color)")
    }
    
    func test() {
        if let path = Bundle.main.path(forResource: "image@2x.png", ofType: nil) {
            imageView.image = UIImage(contentsOfFile: path)
        }
        let size = imageView.frame.size
        
        if let image = imageView.image {
            
            let scaleRect = CGRect(origin: .zero, size: size)
            let partRect = CGRect(x: 0, y: kPinYinHeight+10, width: size.width, height: kTooBarHeight-20)
            
            let color = SMColorThemeTool.mostColor(source: image, scale: scaleRect, part:partRect )
            self.colorView.backgroundColor = color
            
            let image = SMColorThemeTool.cropImage(source: image, scale: scaleRect, part: partRect)
            self.cropImageView.image = image
        }
    }

}

