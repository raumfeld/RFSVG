//
//  ViewController.swift
//  Example
//
//  Created by Dunja Lalic on 1/25/17.
//  Copyright © 2017 Lautsprecher Teufel GmbH. All rights reserved.
//

import UIKit
import RFSVG

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
                
        var i = 0
        var j = 0
        for index in 1..<1000 {
            let deadlineTime = DispatchTime.now() + Double(Double(index)*0.1)
            
            let imageView = UIImageView.init(frame: CGRect.init(x: i*10, y: j*10, width: 10, height: 10))
            self.view.addSubview(imageView)
            if index % 30 == 0 {
                i = 0
                j += 1
            } else {
                i += 1
            }
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                let image = UIImage.imageFromSVG("unicorn", size: imageView.bounds.size)
                imageView.image = image
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

