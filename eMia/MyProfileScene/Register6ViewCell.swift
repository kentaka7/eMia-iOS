//
//  Register6ViewCell.swift
//  eMia
//

import UIKit
import RxSwift

/**
 MyProfile scene.
 User's photo (as an avatar using) definition
 */

class Register6ViewCell: UITableViewCell, PhotoPresentedProtocol {
   
   @IBOutlet weak var addPhotoButton: UIButton!
   @IBOutlet weak var photoImageView: UIImageView!
   
   weak var viewController: UIViewController!
   
   private var _imageViewController: SFFullscreenImageDetailViewController?
   private var photoWorker: PhotoWorker?
   
   private let disposeBag = DisposeBag()
   
   var photo: UIImage? {
      return photoImageView.image
   }
   
   override func awakeFromNib() {
      configure(addPhotoButton)
      configure(photoImageView)
      bindPhotoImageView()
   }
   
   func setUpPhoto(_ image: UIImage?) {
      changePhoto(to: image)
      if image == nil {
         self.addPhotoButton.setTitle("Add photo".localized, for: .normal)
      } else {
         self.addPhotoButton.setTitle("Change photo".localized, for: .normal)
      }
   }
   
   @IBAction func addPhotoButtonPressed(_ sender: Any) {
      addPhoto()
   }
   
   private func addPhoto() {
      if photoWorker == nil {
         photoWorker = PhotoWorker(viewController: viewController, presenter: self)
      }
      photoWorker!.addPhoto()
   }
   
   private func configure(_ view: UIView) {
      switch view {
      case addPhotoButton:
         addPhotoButton.setTitle("Add photo".localized, for: .normal)
         addPhotoButton.setTitleColor(GlobalColors.kBrandNavBarColor, for: .normal)
         
      case photoImageView:
         photoImageView.isUserInteractionEnabled = true
         
      default:
         break
      }
   }
   
   private func bindPhotoImageView() {
      let tapGesture = UITapGestureRecognizer()
      tapGesture.rx.event.bind(onNext: { [weak self] recognizer in
         self?.didPressOnPhoto()
      }).disposed(by: disposeBag)
      photoImageView.addGestureRecognizer(tapGesture)
   }
   
   private func didPressOnPhoto() {
      _imageViewController = SFFullscreenImageDetailViewController(imageView: photoImageView)
      _imageViewController?.presentInCurrentKeyWindow()
   }
   
   private func changePhoto(to image: UIImage?) {
      if image == nil {
         self.photoImageView.image = nil
      } else if self.photoImageView.image != nil {
         DispatchQueue.main.async {
            UIView.transition(with: self.photoImageView,
                              duration: 0.5,
                              options: .transitionCrossDissolve,
                              animations: {
                                 self.photoImageView.image = image
            },
                              completion: nil)
         }
      } else {
         self.photoImageView.image = image
      }
   }
}

//

extension Register6ViewCell {
   
   func setImage(_ image: UIImage?) {
      self.setUpPhoto(image)
   }
}

