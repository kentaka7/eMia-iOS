//
//  PhotoWorker.swift
//  eMia
//
//  Created by Sergey Krotkih on 12/09/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import UIKit

protocol PhotoWorkerProtocol: class {
   init(viewController: UIViewController, presenter: PhotoPresentedProtocol)
   func addPhoto()
}

protocol PhotoPresentedProtocol: class {
   func setImage(_ image: UIImage?)
}

class PhotoWorker: NSObject, PhotoWorkerProtocol, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
   private weak var viewController: UIViewController!
   private weak var output: PhotoPresentedProtocol?
   private let imagePicker = UIImagePickerController()

   required init(viewController: UIViewController, presenter: PhotoPresentedProtocol) {
      self.viewController = viewController
      self.output = presenter
   }
   
   func addPhoto() {
      
      let title = self.viewController?.navigationItem.title
      let alertVC = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
      alertVC.addAction(UIAlertAction(title: "Camera".localized, style: .default, handler: { _ in
         self.openCamera()
      }))
      
      alertVC.addAction(UIAlertAction(title: "Gallary".localized, style: .default, handler: { _ in
         self.openGallary()
      }))
      
      alertVC.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
      
      self.viewController?.present(alertVC, animated: true, completion: nil)
   }
   
   fileprivate func openCamera() {
      if UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
         imagePicker.delegate = self
         imagePicker.allowsEditing = true
         imagePicker.sourceType = .camera
         self.viewController.present(imagePicker, animated: true, completion: nil)
      } else {
         Alert.default.showOk("Warning".localized, message: "Camera isn't presented on your device!".localized)
      }
   }
   
   fileprivate func openGallary() {
      imagePicker.delegate = self
      imagePicker.allowsEditing = true
      imagePicker.sourceType = .photoLibrary
      self.viewController.present(imagePicker, animated: true, completion: nil)
   }
   
   
   func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
      if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
         var photo: UIImage
         if let image =  pickedImage.fitToSize() {
            photo = image
         } else {
            photo = pickedImage
         }
         self.output?.setImage(photo)
      }
      self.viewController.dismiss(animated: true, completion: nil)
   }
   
   func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      self.viewController.dismiss(animated: true, completion: nil)
   }
}
