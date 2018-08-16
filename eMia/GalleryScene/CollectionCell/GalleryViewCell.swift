//
//  GalleryViewCell.swift
//  eMia
//

import UIKit
import RxSwift
import RealmSwift

class GalleryViewCell: UICollectionViewCell {
   
   private let widthPhotoDefault: CGFloat = 200.0
   private let heightPhotoDefault: CGFloat = 100.0
   
   private weak var post: PostModel?
   private let disposeBag = DisposeBag()
   var representedAssetIdentifier: String!
   private let favoritsManager = FavoritsManager()
   private var token: NotificationToken?
   
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
   }

   deinit {
      token?.invalidate()
   }

   override func prepareForReuse() {
      super.prepareForReuse()
      photoImageView.image = nil
      favoriteImageView.image = nil
   }
   
   func flash(_ completion: @escaping () -> Void) {
      photoImageView.alpha = 0
      setNeedsDisplay()
      UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: { [weak self] in
         self?.photoImageView.alpha = 1
      }, completion: { _ in
         completion()
      })
   }
   
   private func configureView() {
      avatarBackgroundView.setAsCircle()
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
      
      self.representedAssetIdentifier = post.id!
      self.post?.getPhoto { [weak self] image in
         guard let `self` = self else {
            return
         }
         if let post = self.post {
            if self.representedAssetIdentifier == post.id! {
               self.photoImageView.image = image
               if post.photoSize == (0.0, 0.0), let size = image?.size {
                  post.photoSize = (size.width, size.height)
                  post.synchronize { _ in}
               }
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
      
      bindToFavoritesModel()

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
      let isItMyFavoritePost = favoritsManager.isItMyFavoritePost(post)
      favoriteImageView.image = isItMyFavoritePost ? UIImage(named: "icon-toggle_star") : nil
   }
   
   private func bindToFavoritesModel() {
      guard let post = self.post else {
         return
      }
      let realm = try? Realm()
      let results = realm?.objects(FavoriteModel.self).filter("postid = '\(post.id!)'") // Auto-Updating Results
      token = results?.observe({ change in
         switch change {
         case .initial:
            self.setUpFavorite(post)
         case .error(let error):
            fatalError("\(error)")
         case .update( _,  _,  _, _):
            self.setUpFavorite(post)
         }
      })
   }
}
