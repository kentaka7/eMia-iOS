//
//  EditPost6ViewCell.swift
//  eMia
//

import UIKit
import RxSwift

class EditPost6ViewCell: UITableViewCell, ForPostConfigurable {

   private var _imageViewController: SFFullscreenImageDetailViewController?
   private let disposeBag = DisposeBag()
   
   @IBOutlet weak var photoImageView: UIImageView!
   
   override func awakeFromNib() {
      configurePhotoImageView()
      bindPhotoImageView()
   }

   func configureView(for post: PostModel) -> CGFloat {
      setUpPhoto(for: post) { image in
         self.photoImageView.image = image
      }
      return -1.0
   }
}

// MARK: - Private methods

extension EditPost6ViewCell {
   
   private func setUpPhoto(for post: PostModel, completion: @escaping (UIImage?) -> Void) {
      post.getPhoto { image in
         completion(image)
      }
   }
   
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
