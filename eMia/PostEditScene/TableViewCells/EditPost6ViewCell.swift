//
//  EditPost6ViewCell.swift
//  eMia
//

import UIKit
import RxSwift

class EditPost6ViewCell: UITableViewCell {

   private var _imageViewController: SFFullscreenImageDetailViewController?
   private let disposeBag = DisposeBag()
   
   @IBOutlet weak var photoImageView: UIImageView!
   
   override func awakeFromNib() {
      configurePhotoImageView()
      bindPhotoImageView()
   }

}

// MARK: - Private methods

extension EditPost6ViewCell {
   
   private func configurePhotoImageView() {
      photoImageView.isUserInteractionEnabled = true
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
}

extension EditPost6ViewCell {
   
   func setImage(_ image: UIImage?) {
      self.photoImageView.image = image
   }
}

