//
//  NewPost3ViewCell.swift
//  eMia
//

import UIKit
import RxSwift

class NewPost3ViewCell: UITableViewCell, PhotoPresentedProtocol {

   @IBOutlet weak var addPhotoButton: UIButton!
   @IBOutlet weak var photoImageView: UIImageView!
   
   weak var viewController: UIViewController?
   
   private var _imageViewController: SFFullscreenImageDetailViewController?
   private var photoWorker: PhotoWorker?

   private let disposeBag = DisposeBag()
   
   override func awakeFromNib() {
      configure(addPhotoButton)
      configure(photoImageView)
      bindPhotoImage()
   }

   var photoImage: UIImage? {
      return photoImageView.image
   }

   private func configure(_ view: UIView) {
      switch view {
      case addPhotoButton:
         configureAddPhotoButton()
      case photoImageView:
         configurePhotoImage()
      default:
         break
      }
   }
   
   @IBAction func addButtonPressed(_ sender: Any) {
      addPhoto()
   }

   private func configureAddPhotoButton() {
      addPhotoButton.setTitleColor(GlobalColors.kBrandNavBarColor, for: .normal)
      addPhotoButton.setTitle("Add Photo".localized, for: .normal)
   }
   
   private func configurePhotoImage() {
      photoImageView.isUserInteractionEnabled = true
   }
   
   private func bindPhotoImage() {
      let tapGesture = UITapGestureRecognizer()
      tapGesture.rx.event.bind(onNext: { [weak self] recognizer in
         self?.didPressOnPhoto()
      }).disposed(by: disposeBag)
      photoImageView.addGestureRecognizer(tapGesture)
   }
   
   private func didPressOnPhoto() {
      if photoImage == nil {
         return
      }
      _imageViewController = SFFullscreenImageDetailViewController(imageView: photoImageView)
      _imageViewController?.presentInCurrentKeyWindow()
   }

   private func addPhoto() {
      guard let viewController = self.viewController else {
         return
      }
      if photoWorker == nil {
         photoWorker = PhotoWorker(viewController: viewController, presenter: self)
      }
      photoWorker!.addPhoto()
   }

   func setUpPhoto(_ image: UIImage?) {
      changePhoto(to: image)
      if image == nil {
         self.addPhotoButton.setTitle("Add photo".localized, for: .normal)
      } else {
         self.addPhotoButton.setTitle("Change photo".localized, for: .normal)
      }
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

extension NewPost3ViewCell {
   
   func setImage(_ image: UIImage?) {
      self.setUpPhoto(image)
   }
}
