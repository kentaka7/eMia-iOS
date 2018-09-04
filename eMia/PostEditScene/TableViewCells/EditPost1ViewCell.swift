//
//  EditPost1ViewCell.swift
//  eMia
//

import UIKit
import RxSwift
import RealmSwift

protocol ForPostConfigurable {
   func configureView(for post: PostModel) -> CGFloat
}

// User's avatar photo and name

class EditPost1ViewCell: UITableViewCell, ForPostConfigurable {
   
   @IBOutlet weak var avatarBackgroundView: UIView!
   @IBOutlet weak var avatarUserImageView: UIImageView!
   @IBOutlet weak var nameUserLabel: UILabel!
   
   @IBOutlet weak var favoriteButtonBackgroundView: UIView!
   @IBOutlet weak var favoriteButtonImageView: UIImageView!
   
   private let disposeBag = DisposeBag()
   
   private var token: NotificationToken?
   private let favoritsManager = FavoritsManager()
   private let postsManager = PostsManager()
   private var post: PostModel?
   
   override func awakeFromNib() {
   }
   
   deinit {
      token?.invalidate()
   }
   
   func configureView(for post: PostModel) -> CGFloat {
      self.post = post
      startDataBaseListening()
      configure(avatarBackgroundView)
      configure(nameUserLabel)
      configure(favoriteButtonBackgroundView)
      configure(avatarUserImageView)
      return -1.0
   }
}

// MARK: - Private methods

extension EditPost1ViewCell {
   
   private func startDataBaseListening() {
      guard let postid = post?.id else {
         return
      }
      let realm = try? Realm()
      let results = realm?.objects(FavoriteModel.self).filter("postid = '\(postid)'") // Auto-Updating Results
      token = results?.observe({ change in
         switch change {
         case .initial:
            self.configure(self.favoriteButtonImageView)
         case .error(let error):
            fatalError("\(error)")
         case .update( _,  _,  _, _):
            self.configure(self.favoriteButtonImageView)
         }
      })
   }
   
   private func configure(_ view: UIView) {
      guard let post = self.post else {
         return
      }
      switch view {
      case avatarBackgroundView:
         avatarBackgroundView.setAsCircle()
         
      case avatarUserImageView:
         setUpAvatarImage(post)
         
      case favoriteButtonBackgroundView:
         configureAddToFavoriteButton(post)
         
      case favoriteButtonImageView:
         setUpImageOnTheAddToFavoriteButton(post)
         
      case nameUserLabel:
         setUpUserName(post)
         
      default:
         break
      }
   }

   private func setUpUserName(_ post: PostModel) {
      if let user = gUsersManager.getUserWith(id: post.uid) {
         self.nameUserLabel.text = user.name
      } else {
         self.nameUserLabel.text = nil
      }
   }
   
   private func setUpAvatarImage(_ post: PostModel) {
      gPhotosManager.downloadAvatar(for: post.uid) { image in
         DispatchQueue.main.async {
            self.avatarUserImageView.image = image
         }
      }
   }
   
   private func setUpImageOnTheAddToFavoriteButton(_ post: PostModel) {
      let isItMyFavoritePost = favoritsManager.isItMyFavoritePost(post)
      DispatchQueue.main.async {
         self.favoriteButtonImageView.image = UIImage(named: isItMyFavoritePost ? "icon-toggle_star" : "icon-toggle_star_outline")
      }
   }
   
   private func configureAddToFavoriteButton(_ post: PostModel) {
      let isItMyPost = postsManager.isItMyPost(post)
      self.favoriteButtonBackgroundView.isHidden = isItMyPost
      if isItMyPost == false {
         bindAddToFavoriteButton()
      }
   }
   
   private func bindAddToFavoriteButton() {
      let tapGesture = UITapGestureRecognizer()
      tapGesture.rx.event.bind(onNext: { [weak self] recognizer in
         self?.addToFavoriteButtonPressed()
      }).disposed(by: disposeBag)
      favoriteButtonBackgroundView.addGestureRecognizer(tapGesture)
   }
   
   private func addToFavoriteButtonPressed() {
      guard let post = self.post else {
         return
      }
      favoritsManager.addToFavorite(post: post)
   }
}
