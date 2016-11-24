//
//  ViewController.swift
//  MemeMe
//
//  Created by Bill Yu on 15/11/2016.
//  Copyright © 2016 Bill Yu. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController,UINavigationControllerDelegate ,UIImagePickerControllerDelegate, UITextFieldDelegate {

    // MARK: Outlet
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var navbar: UINavigationBar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var imagePickerView:UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    // MARK: Instance variables
    var savedMeme : Meme?
    
    // MARK: Target Actions
    @IBAction func pickAnImage(_ sender: UIBarButtonItem) {
        let pickerController = UIImagePickerController()
        
        pickerController.delegate = self
        if sender == cameraButton {
            pickerController.sourceType = .camera
        } else {
            pickerController.sourceType = .photoLibrary
        }
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func cancelEditing(_ sender: Any) {
        initMemeEditor()
    }
    
    @IBAction func shareMeme(_ sender: Any) {
        let memedImage = generatedMemedImage()
        let activityVC = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        present(activityVC, animated: true, completion: nil)
        
        activityVC.completionWithItemsHandler = {(activityType:UIActivityType?, completed:Bool, returnedItems:[Any]?, error: Error?) in
            
            // Return if cancelled
            if (!completed) {
                return
            }
            
            self.save()
            
            self.dismiss(animated: true, completion: nil)
        }
    }

    
    // MARK: UIViewController functions
    override func viewDidLoad() {
        super.viewDidLoad()
        initMemeEditor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: UIImagePickerControllerDelegate Protocol functions
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
        }
        
        updateShareStatus()
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: UITextFieldDelegate Protocol functions
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            setDefaultTextAttr(textField)
        }
        
        updateShareStatus()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
        textField.tag = 0
    }
    
    // MARK: ViewController functions
    
    func initMemeEditor() {
        imagePickerView.image = nil
        setDefaultTextAttr(topText)
        setDefaultTextAttr(bottomText)
        shareButton.isEnabled = false
    }
    
    func updateShareStatus() {
        shareButton.isEnabled = imagePickerView.image != nil && topText.tag == 0 && bottomText.tag == 0
    }
    
    func setDefaultTextAttr(_ textField:UITextField) {
        let memeTextAttributes:[String:Any] = [
            NSStrokeColorAttributeName: UIColor.black,
            NSForegroundColorAttributeName: UIColor.white,
            //NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSFontAttributeName: UIFont(name: "Impact", size: 40)!,
            NSStrokeWidthAttributeName: -5]
        
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.delegate = self
        textField.text = "Enter Text Here"
        textField.tag = 1
    }
    
    func keyboardWillShow(_ notification:Notification) {
        if (bottomText.isEditing) {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func save() {
        let memedImage = generatedMemedImage()
        
        savedMeme = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
    }
    
    func generatedMemedImage() -> UIImage {
        toolbar.isHidden = true
        navbar.isHidden = true
        
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        let memedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        toolbar.isHidden = false
        navbar.isHidden = false

        return memedImage
    }
}

