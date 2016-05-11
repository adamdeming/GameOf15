//
//  Main.swift
//  Game of 15
//
//  Created by Adam Deming, Asher Dale, Connor Lynn
//  Copyright (c) 2015 Adam Deming. All rights reserved.
//

import UIKit

public var boardSize: Int?

class Main: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func classic(sender: AnyObject) {
        boardSize = 16
    }
    @IBAction func hard(sender: AnyObject) {
        boardSize = 25
    }
    @IBAction func Insane(sender: AnyObject) {
        boardSize = 36
    }

}
