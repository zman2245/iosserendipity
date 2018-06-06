//
//  LeaveMemoryController.swift
//  Serendipity
//
//  Created by Zachary Foster on 6/6/18.
//  Copyright © 2018 Big Z Industries, LLC. All rights reserved.
//

import UIKit

class LeaveMemoryController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var hotspotIdField: UITextField!
    @IBOutlet weak var messageView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var testResponseImageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    let imageService: ImageService = ImageService()
    let dataService: DataService = DataService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        imageView.backgroundColor = UIColor.lightGray
        
        dataService.fetchImage(url: "images/memories/28") { (success, data) in
            if (success && data != nil) {
                self.testResponseImageView.image = UIImage(data: data!)
            }
        }
    }
    
    // MARK: - Actions
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        // Your action
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        // TODO: image data
        guard let hotspotId = Int(hotspotIdField.text!) else {
            return
        }
        guard let message = messageView.text else {
            return
        }
        
        dataService.saveNewMemory(hotspot: hotspotId, message: message, image: imageView.image)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
