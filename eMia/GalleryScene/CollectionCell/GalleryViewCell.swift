//
//  GalleryViewCell.swift
//  eMia
//

import UIKit
import RxSwift

class GalleryViewCell: UICollectionViewCell {
   
   private let widthPhotoDefault: CGFloat = 200.0
   private let heightPhotoDefault: CGFloat = 100.0
   
   private weak var post: PostModel?
   private let disposeBag = DisposeBag()
   
   @IBOutlet weak var borderView: UIView!
   
   @IBOutlet weak var photoImageView: UIImageView!
   @IBOutlet weak var titleLabel: UILabel!
   @IBOutlet weak var bodyLabel: UILabel!
   @IBOutlet weak var favoriteImageView: UIImageView!
   @IBOutlet weak var photoHeightConstraint: NSLayoutConstraint!

   @IBOutlet weak var avatarBackgroundView: UIView!
   @IBOutlet weak var avatarUserImageView: UIImageView!
   @IBOutlet weak var createdLabel: UILabel!
   
   @IBOutlet weak var border1: UIView!
   @IBOutlet weak var border2: UIView!
   @IBOutlet weak var border3: UIView!
   @IBOutlet weak var border4: UIView!
   
   override func awakeFromNib() {
      configureView()
      bindToFavoritesModel()
   }
   
   private func configureView() {
      avatarBackgroundView.layer.cornerRadius = avatarBackgroundView.frame.height / 2.0
      avatarBackgroundView.layer.borderColor = UIColor(rgbValue: 0xffffff).cgColor
      avatarBackgroundView.layer.borderWidth = 1.0
      
      titleLabel.textColor = GlobalColors.kBrandNavBarColor
      bodyLabel.textColor = GlobalColors.kBrandNavBarColor
      
      borderView.layer.borderColor = UIColor.lightGray.cgColor
      borderView.layer.borderWidth = 1
      borderView.layer.cornerRadius = 8
      
      let borderColor = UIColor.clear
      border1.backgroundColor = borderColor
      border2.backgroundColor = borderColor
      border3.backgroundColor = borderColor
      border4.backgroundColor = borderColor
   }

   func update(with post: PostModel) {
      self.post = post
      
      self.post?.getPhoto { [weak self] image in
         guard let `self` = self else {
            return
         }
         if let post = self.post {
            self.photoImageView.image = image
            if post.photoSize == (0.0, 0.0), let size = image?.size {
               post.photoSize = (size.width, size.height)
               post.synchronize { _ in}
            }
         }
      }

      if let userId = self.post?.uid {
         gPhotosManager.downloadAvatar(for: userId) { image in
            DispatchQueue.main.async {
               self.avatarUserImageView.image = image
            }
         }
      }
      
      setUpFavorite(post)

      titleLabel.text = post.title
      bodyLabel.text = post.body
      
      createdLabel.text = "Created".localized + " " + post.relativeTimeToCreated()
      
      var defaultWidth = post.photoSize.0
      var defaultHeight = post.photoSize.1
      if post.photoSize == (0.0, 0.0) {
         defaultWidth = widthPhotoDefault
         defaultHeight = heightPhotoDefault
      }
      photoHeightConstraint.constant = self.frame.width / defaultWidth * defaultHeight
   }
   
   private func setUpFavorite(_ post: PostModel) {
      let isItMyFavoritePost = FavoritsManager.isItMyFavoritePost(post)
      favoriteImageView.image = isItMyFavoritePost ? UIImage(named: "icon-toggle_star") : nil
   }
   
   private func bindToFavoritesModel() {
      FavoriteModel.rxFavorities.subscribe(onNext: { [weak self] (favorities) in
         guard let `self` = self else {
            return
         }
         if let post = self.post {
            self.setUpFavorite(post)
         }
      }).disposed(by: disposeBag)
   }
}
