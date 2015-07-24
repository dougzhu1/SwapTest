//
//  UploadImageViewController.swift
//  Layer-Parse-iOS-Swift-Example
//
//  Created by Manudeep N.s on 7/24/15.
//  Copyright (c) 2015 layer. All rights reserved.
//

import UIKit

class UploadImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    @IBOutlet weak var showItemImage: UIImageView!
    @IBOutlet weak var showItemDescription: UITextView!
    
    let imagePicker = UIImagePickerController()
    let tapRec = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        tapRec.addTarget(self, action: "uploadImage")
        showItemImage.userInteractionEnabled = true
        showItemImage.addGestureRecognizer(tapRec)
        
        self.showItemDescription.delegate = self
        self.showItemDescription.text = "Describe your item"
        self.showItemDescription.textColor = UIColor.lightGrayColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func uploadImage() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .SavedPhotosAlbum
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            showItemImage.image = pickedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func uploadImageToServer() {
        let imageData = UIImagePNGRepresentation(showItemImage.image!)
        let imageFile = PFFile(name: "image.png", data: imageData)
        
        var userPhoto = PFObject(className: "Photos")
        userPhoto["imageCaption"] = showItemDescription.text!
        userPhoto["user"] = PFUser.currentUser()
        userPhoto["imageFile"] = imageFile
        userPhoto.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            
            if success {
                println("Succesfully posted")
            } else {
                println("Did not manage to post")
            }
        }
        
        let alertController = UIAlertController(title: "Success", message: "Succesfully uploaded", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
        self.showItemDescription.resignFirstResponder()
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if showItemDescription.textColor == UIColor.lightGrayColor() {
            showItemDescription.text = nil
            showItemDescription.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if showItemDescription.text.isEmpty {
            showItemDescription.text = "Placeholder"
            showItemDescription.textColor = UIColor.lightGrayColor()
        }
    }
}
