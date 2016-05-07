//
//  Main.swift
//  Game of 15
//
//  Created by Adam Deming on 7/14/15.
//  Copyright (c) 2015 Adam Deming. All rights reserved.
//

import UIKit

public var boardSize: Int?

class Main: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var harvardView: UIImageView!
       
    @IBOutlet weak var harvardLabel: UILabel!
    @IBOutlet weak var fifteenGame: UIImageView!
    
    @IBOutlet weak var imageView: UIImageView!
    var newMedia: Bool?
    
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
