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
