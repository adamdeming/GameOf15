//
//  ViewController.swift
//  Harvard IOS Game
//
//  Created by Adam Deming, Asher Dale, Connor Lynn
//  Copyright (c) 2015 AdamDemingDevelopment. All rights reserved.
//

import UIKit

import MobileCoreServices
import Darwin



// Subclass: Allows tile buttons to have position values(x, y)

class GameTile: UIButton {
    
    var x : Int?
    var y : Int?
}



class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    // Declaring variables for using images in-game
    
    @IBOutlet weak var imageView: UIImageView!
    var newMedia: Bool?
    var finalImage: UIImage!
    var beginImage: CIImage!
    let filter = CIFilter(name: "CIVignette")
    var photoUsed = false
    
    // Setting up the timer
    
    var startTime = NSTimeInterval()
    var timer = NSTimer()
    var shuffleButton = UIButton()
    
    
    // Getting screen dimensions
    
    var screenHeight = Int(UIScreen.mainScreen().applicationFrame.size.height) + 20
    var screenWidth = Int(UIScreen.mainScreen().applicationFrame.size.width)
    
    
    // Double array that represents the game board
    
    var gameSize = boardSize!
    var gameBoard = Array(count: 4, repeatedValue:Array(count: 4, repeatedValue:GameTile()))
    var root: Int?
    
    
    
    // Declaring some labels and buttons
    
    var moveCounter = UILabel()
    var bestScoreLabel = UILabel()
    var winLabel = UILabel()
    var resetButton = UIButton()
    
    // Stored properties to be used for different functionalities of the game
    
    var movesTaken = 0
    var bestScore = Int.max
    var isBoardShuffled = false
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        gameSize = boardSize!
        
        // Creates the game board
        
        gameBoard = Array(count: Int(sqrt(Double(gameSize))), repeatedValue:Array(count: Int(sqrt(Double(gameSize))), repeatedValue:GameTile()))
        root = Int(sqrt(Double(gameSize)))
        createButtons()
        
        // Variables to size and position the control buttons and labels
        
        let buttonWidth = widthMultiplier(10/37)
        let buttonHeight = heightMultiplier(1/10)
        let buttonPositionY = heightMultiplier(3/4)
        let buttonPositionY2 = heightMultiplier(3/4) + 75
        
        
        // Makes control buttons and labels
        
        let shuffleRect = CGRectMake(widthMultiplier(1/38), buttonPositionY, buttonWidth, buttonHeight)
        shuffleButton = makeButton(shuffleRect, title: "Shuffle", action: "shuffle:")
        shuffleButton.layer.cornerRadius = shuffleButton.bounds.size.width * 0.25
        
        
        let cameraRect = CGRectMake(widthMultiplier(10/14), buttonPositionY2, buttonWidth,buttonHeight)
        let cameraButton = makeButton(cameraRect, title: "Camera", action: "useCamera:")
        cameraButton.layer.cornerRadius = cameraButton.bounds.size.width * 0.25
        
        let photoRect = CGRectMake(widthMultiplier(1/38), buttonPositionY2, buttonWidth,buttonHeight)
        let photoButton = makeButton(photoRect, title: "Photos", action: "usePhoto:")
        photoButton.layer.cornerRadius = photoButton.bounds.size.width * 0.25
        
        let resetRect = CGRectMake(widthMultiplier(10/14),buttonPositionY,buttonWidth,buttonHeight)
        resetButton = makeButton(resetRect, title: "Reset", action: "reset:")
        resetButton.layer.cornerRadius = resetButton.bounds.size.width * 0.25
        
        
        
        let moveRect = CGRectMake(widthMultiplier(3/8), buttonPositionY,buttonWidth,buttonHeight)
        moveCounter = makeLabel(moveRect, text: "Moves: \(String(movesTaken))", fontSize: 18)
        
        
        
        let bestRect = CGRectMake(widthMultiplier(3/8), buttonPositionY2, buttonWidth,buttonHeight)
        bestScoreLabel = makeLabel(bestRect, text: "Best: ", fontSize: 18)
        
        
        
        let winRect = CGRectMake(0, 0, CGFloat(screenWidth), CGFloat(screenHeight))
        winLabel = makeLabel(winRect, text: "You Won!", fontSize: 75)
        winLabel.hidden = true
        
        
        
        // Saves and keeps track of best score
        
        let bestDefault = NSUserDefaults.standardUserDefaults()
        if (bestDefault.valueForKey("bestScore") != nil) {
            
            bestScore = bestDefault.valueForKey("bestScore") as! NSInteger
            
            bestScoreLabel.text = "Best: " + String(bestScore)
            
        }
        
    }
    
    // Called when a tile is pressed
    
    func move(sender: GameTile!) {
        // Check if board is shuffled
        
        if !isBoardShuffled
            
        {
            return
        }

        // Initializes the positions of the pressed button and black tile
        
        let xPosition = sender.x!
        let yPosition = sender.y!
        var xPositionBlackTile = 0
        var yPositionBlackTile = 0
        
        // Finds position of the black tile
        
        for c in 0 ... Int(sqrt(Double(gameSize)) - 1)
            
        {
            for r in 0 ... Int(sqrt(Double(gameSize)) - 1)
                
            {
                if gameBoard[r][c].titleLabel!.text! == String(gameSize)
                    
                {
                    
                    xPositionBlackTile = r
                    yPositionBlackTile = c
                    
                }
            }
        }
        
        // Variables to check for Manhattan Distance
        
        let differenceBetweenXValues = abs(xPositionBlackTile - xPosition)
        let differenceBetweenYValues = abs(yPositionBlackTile - yPosition)
        
        //Checking for Manhattan Distance
        
        if ((differenceBetweenXValues == 1) || (differenceBetweenYValues == 1)){
            if ((differenceBetweenXValues==0) || (differenceBetweenYValues==0)){
            
                // Swaps the button pressed with the black tile
                
                let blackTile = gameBoard[xPositionBlackTile][yPositionBlackTile]
                let buttonPressed = gameBoard[xPosition][yPosition]
                blackTile.x = xPosition
                blackTile.y = yPosition
                buttonPressed.x = xPositionBlackTile
                buttonPressed.y = yPositionBlackTile
                gameBoard[xPositionBlackTile][yPositionBlackTile] = buttonPressed
                gameBoard[xPositionBlackTile][yPositionBlackTile].backgroundColor = UIColor.whiteColor()
                gameBoard[xPosition][yPosition] = blackTile
                gameBoard[xPosition][yPosition].backgroundColor = UIColor.blackColor()
                
                // Sets the position and frame of the swapped tiles
                
                let originX = CGFloat(xPositionBlackTile) * widthMultiplier(1/sqrt(Double(gameSize)))
                let originY = CGFloat(yPositionBlackTile) * heightMultiplier(3/5/sqrt(Double(gameSize))) + 50
                
                gameBoard[xPositionBlackTile][yPositionBlackTile].frame = CGRectMake(originX, originY,widthMultiplier(1/sqrt(Double(gameSize))),heightMultiplier(3/5/sqrt(Double(gameSize))))
                
                gameBoard[xPosition][yPosition].frame = CGRectMake(CGFloat(xPosition) * widthMultiplier(1/sqrt(Double(gameSize))),CGFloat(yPosition) * heightMultiplier(3/5/sqrt(Double(gameSize))) + 50, widthMultiplier(1/sqrt(Double(gameSize))), heightMultiplier(3/5/sqrt(Double(gameSize))))
                
                self.view.addSubview(gameBoard[xPositionBlackTile][yPositionBlackTile])
                self.view.addSubview(gameBoard[xPosition][yPosition])
                
        
                // Updates move counter
                
                movesTaken++
                moveCounter.text = "Moves: " + String(movesTaken)
                
                // Checks if user has won
                
                if win() {
                    
                    // Renders correct labels and buttons after winning
                    
                    winLabel.hidden = false
                    
                    self.view.addSubview(winLabel)
                    self.view.addSubview(resetButton)
                    self.view.addSubview(moveCounter)
                    self.view.addSubview(bestScoreLabel)
            
                    // Checks if user has a new best score
                    
                    if movesTaken < bestScore {
                        
                        bestScore = movesTaken
                        bestScoreLabel.text = "Best: " + String(bestScore)
                        
                        let bestDefault = NSUserDefaults.standardUserDefaults()
                        bestDefault.setValue(bestScore, forKey: "bestScore")
                        bestDefault.synchronize()
                        
                    }
                }
            }
        }
    }

    // Resets the puzzle to original order and resets some specific variables
    
    func reset(sender:UIButton!)
        
    {
        photoUsed = false
        isBoardShuffled = false
        createButtons()
        
        movesTaken = 0
        moveCounter.text = "Moves: " + String(movesTaken)
        winLabel.hidden = true
        
    }

    
    // Shuffles the board
    
    func shuffle(sender:UIButton!)
        
    {
        
        isBoardShuffled = true
        movesTaken = 0
        moveCounter.text = "Moves: 0"
        
        // Generates the random numbers to assign to each tile
        
        var randomNumArray: [Int] = Array(count: gameSize, repeatedValue: 0)
        var imageArray: [UIImage] = Array(count: (gameSize + 1), repeatedValue: UIImage())
        
        for i in 0 ... (gameSize - 1)
            
        {
            
            randomNumArray[i] = Int(arc4random_uniform(UInt32(gameSize)) + 1)
            
        }
        
        for j in 0 ... (gameSize - 1)
            
        {
            
            for var z = 0; z < j; z++
                
            {
                
                if(randomNumArray[j] == randomNumArray[z])
                    
                {
                    randomNumArray[j] = Int(arc4random_uniform(UInt32(gameSize)) + 1)
                    
                    z = -1
                    
                }
                
            }
            
        }
        
        
        
        // Randomizes board with images
        
        if photoUsed{
            
            for c in 0 ... Int(sqrt(Double(gameSize)) - 1)
                
            {
                
                for r in 0 ... Int(sqrt(Double(gameSize)) - 1)
                    
                {
                    
                    // Crops and sets each image
                    
                    var rec = beginImage.extent
                    
                    let croppedImage = beginImage.imageByCroppingToRect(CGRectMake(CGFloat(r * Int(rec.width)/root!) , CGFloat(abs(c-Int(sqrt(Double(gameSize)) - 1)) * Int(rec.height)/root!), CGFloat(Int(rec.width)/root!),CGFloat(Int(rec.height)/root!)))
                    
                    filter!.setValue(croppedImage, forKey: kCIInputImageKey)
                    var img = UIImage(CIImage: filter!.outputImage!)
                    
                    finalImage = img.imageWithRenderingMode(.AlwaysOriginal)
                    imageArray[randomNumArray[(c*(Int(sqrt(Double(gameSize))))+r)] - 1] = finalImage
                    
                    
                    
                }
                
            }
            
        }

        
        // Displays the newly shuffles board
        
        for i in 0 ... Int(sqrt(Double(gameSize)) - 1) {
            
            for j in 0 ... Int(sqrt(Double(gameSize)) - 1) {
                
                gameBoard[i][j].setTitle("\(randomNumArray[(i*(Int(sqrt(Double(gameSize))))+j)])", forState: UIControlState.Normal)
                gameBoard[i][j].x = i
                gameBoard[i][j].y = j
                
                if gameBoard[i][j].backgroundColor == UIColor.blackColor()
                    
                {
                    gameBoard[i][j].backgroundColor = UIColor.whiteColor()
                    
                }
                
                if randomNumArray[(i*(Int(sqrt(Double(gameSize))))+j)] == gameSize
                    
                {
                    gameBoard[i][j].backgroundColor = UIColor.blackColor()
                    gameBoard[i][j].setImage(nil, forState: .Normal)
                    
                }
                else {
                    
                    gameBoard[i][j].setImage(imageArray[(i*(Int(sqrt(Double(gameSize))))+j)] , forState: .Normal)
                    
                }
                
            }
            
        }
        if !isSolvable()
        {
            shuffle(sender)
        }
        
    }

    // Creates the game board
    
    func createButtons()
        
    {
        
        for c in 0 ... Int(sqrt(Double(gameSize)) - 1)
            
        {
            
            for r in 0 ... Int(sqrt(Double(gameSize)) - 1)
                
            {
            
                // Creates the tile
                // Gametile is bugged from conversion of swift code
                let gameTile = GameTile(type: UIButtonType.System)
                gameTile.x = r
                gameTile.y = c
                
                let originX = CGFloat(r) * widthMultiplier(1/sqrt(Double(gameSize)))
                let originY  = CGFloat(c) * heightMultiplier(3/5/sqrt(Double(gameSize))) + 50
                
                gameTile.frame = CGRectMake(originX ,originY , widthMultiplier(1/sqrt(Double(gameSize))),heightMultiplier(3/5/sqrt(Double(gameSize))))
                gameTile.setTitle(String(c*(Int(sqrt(Double(gameSize))))+r+1), forState: UIControlState.Normal)
                
                
                
                if (c*(Int(sqrt(Double(gameSize))))+r+1) == gameSize {
                    
                    // Sets black tile
                    gameTile.backgroundColor = UIColor.blackColor()
                    
                }
                    
                else {
                    
                    gameTile.backgroundColor = UIColor.whiteColor()
                    
                    if photoUsed{
                        
                        // Creates board with the selected image from camera roll
                        
                        var imageDimensions = beginImage.extent
                        let croppedImage = beginImage.imageByCroppingToRect(CGRectMake(CGFloat(r * Int(imageDimensions.width)/root!) , CGFloat(abs(c-Int(sqrt(Double(gameSize)) - 1)) * Int(imageDimensions.height)/root!), CGFloat(Int(imageDimensions.width)/root!),CGFloat(Int(imageDimensions.height)/root!)))
                        
                        filter!.setValue(croppedImage, forKey: kCIInputImageKey)
                        var preImage = UIImage(CIImage: filter!.outputImage!)
                        finalImage = preImage.imageWithRenderingMode(.AlwaysOriginal)
                        
                        
                        
                        gameTile.setImage(finalImage, forState: .Normal)
                        
                    }
                    
                }
                
                gameTile.setTitleColor(UIColor.blackColor(), forState: .Normal)
                
                gameTile.addTarget(self, action: "move:", forControlEvents: UIControlEvents.TouchUpInside)
                
                self.view.addSubview(gameTile)
                
                
                
                // Sets the tile to the game board double array
                
                gameBoard[r][c] = gameTile
                
            }
            
        }
        
        callForWait()
        
    }

    // Checks if the user has won
    
    func win() -> Bool
        
    {
        
        for i in 0 ... Int(sqrt(Double(gameSize)) - 1)
            
        {
            
            for j in 0 ... Int(sqrt(Double(gameSize)) - 1)
                
            {
                
                if gameBoard[j][i].titleLabel!.text! != String(i*(Int(sqrt(Double(gameSize))))+j+1)
                    
                {
                    
                    return false
                    
                }
                
            }
            
        }
        
        return true
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
        
    }
    
    // Allows user to pick an image from their camera roll once opened
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if mediaType == (kUTTypeImage as String) {
            
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            let gotImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            beginImage = CIImage(image:gotImage)
            photoUsed = true

            // Creates a new game board using the selected image
            
            createButtons()

            if (newMedia == true) {
                
                UIImageWriteToSavedPhotosAlbum(image, self,
                    
                    "image:didFinishSavingWithError:contextInfo:", nil)
                
            } else if mediaType == (kUTTypeMovie as String) {
                
                // Code to support video here
                
            }
            
            
            
        }
        
    }
    // Error checking for saving image from camera roll
    
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo:UnsafePointer<Void>) {
        
        if error != nil {
            
            let alert = UIAlertController(title: "Save Failed",
                
                message: "Failed to save image",
                preferredStyle: UIAlertControllerStyle.Alert)
            
            let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true,
                
                completion: nil)
            
        }
        
    }
    
    // Method to cancel picking image from camera roll
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    
    // Allows user to open their camera roll
    
    func usePhoto(sender: GameTile) {
        
        if UIImagePickerController.isSourceTypeAvailable(
            
            UIImagePickerControllerSourceType.SavedPhotosAlbum) {
                
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                
                imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                imagePicker.mediaTypes = [kUTTypeImage as NSString as String]
                
                imagePicker.allowsEditing = false
                self.presentViewController(imagePicker, animated: true,
                    
                    completion: nil)
                
                newMedia = false
                
        }
        
    }

    func useCamera(sender: AnyObject) {
 
        if UIImagePickerController.isSourceTypeAvailable(
            
            UIImagePickerControllerSourceType.Camera) {
                
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
                imagePicker.mediaTypes = [kUTTypeImage as NSString as String]
                imagePicker.allowsEditing = false
                self.presentViewController(imagePicker, animated: true,
                    
                    completion: nil)
                
                newMedia = true
                
        }
        
    }
    
    // Makes and returns a control button
    
    func makeButton (rect: CGRect, title: String, action: Selector) -> UIButton {
        
        let button = UIButton(type: UIButtonType.System)
        button.frame = rect
        
        button.backgroundColor = UIColor.whiteColor()
        button.setTitle(title, forState: UIControlState.Normal)
        button.setTitleColor(UIColor.blackColor(), forState: .Normal)
        button.addTarget(self, action: action, forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button)
        
        return button
        
    }

    // Makes and returns a label
    
    func makeLabel (rect: CGRect, text: String, fontSize: CGFloat) -> UILabel {
        
        let label = UILabel(frame: rect)
        
        label.backgroundColor = UIColor.blackColor()
        label.textAlignment = NSTextAlignment.Center
        label.text = text
        label.textColor = UIColor.whiteColor()
        self.view.addSubview(label)
        label.font = UIFont( name: label.font.fontName, size: fontSize)
        return label
        
    }
    // Functions to simplify CGFloat multiplications with screen dimensions
    
    func widthMultiplier (multiplier: Double) -> CGFloat {
        
        return CGFloat(Double(screenWidth) * multiplier)
        
    }
    func heightMultiplier (multiplier: Double) -> CGFloat {
        
        return CGFloat(Double(screenHeight) * multiplier)
        
    }
    // Time Shuffle
    
    func callForWait() {
        
        //setting the delay time 3 secs.
        
        let delay = 3.0 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(time, dispatch_get_main_queue()) {
            
            // Method calls steps after delay.
            
            self.stepsAfterDelay()
            
        }
    }
    
    func stepsAfterDelay() {
        
        // Code after delay
        
        shuffle(shuffleButton)
    }
    
    func isSolvable() -> Bool {
        
        var inversions = 0
        var blankLocation = 0
        
        for var i = 0; i < Int(sqrt(Double(gameSize))); i++ {
            
            for var j = i + 1; j < Int(sqrt(Double(gameSize))); j++ {
                
                if ((gameBoard[i][j - 1].backgroundColor == UIColor.blackColor()) || (gameBoard[i][j].backgroundColor == UIColor.blackColor())) {
                    blankLocation = i
                    
                }
                
                inversions++
            }
        }
        
        if (((sqrt(Double(gameSize)) % 2 == 1) && (inversions % 2 == 0)) || ((sqrt(Double(gameSize)) % 2 == 0) && ((inversions % 2 == 0) == (blankLocation % 2 == 1))))
            
        {
            return true
            
        }
        return false
    }
}