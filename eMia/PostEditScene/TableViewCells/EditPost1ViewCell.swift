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
      configure(avatarBackgroundView)
      configure(favoriteButtonBackgroundView)
   }

   deinit {
      token?.invalidate()
   }
   
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
      switch view {
      case avatarBackgroundView:
         avatarBackgroundView.setAsCircle()

      case avatarUserImageView:
         if let userId = post?.uid {
            gPhotosManager.downloadAvatar(for: userId) { image in
               DispatchQueue.main.async {
                  self.avatarUserImageView.image = image
               }
            }
         }
      
      case favoriteButtonBackgroundView:
         if let post = self.post {
            let isItMyPost = postsManager.isItMyPost(post)
            self.favoriteButtonBackgroundView.isHidden = isItMyPost
            if isItMyPost == false {
               let tapGesture = UITapGestureRecognizer(target: self, action: #selector(favoriteButtonPressed(_:)))
               favoriteButtonBackgroundView.addGestureRecognizer(tapGesture)
            }
         }

      case favoriteButtonImageView:
         if let post = self.post {
            let isItMyFavoritePost = favoritsManager.isItMyFavoritePost(post)
            DispatchQueue.main.async {
               self.favoriteButtonImageView.image = UIImage(named: isItMyFavoritePost ? "icon-toggle_star" : "icon-toggle_star_outline")
            }
         }
      
      case nameUserLabel:
         if let userId = post?.uid {
            if let user = gUsersManager.getUserWith(id: userId) {
               self.nameUserLabel.text = user.name
            } else {
               self.nameUserLabel.text = nil
            }
         }
         
      default:
         break
      }
      
   }
   
   func configureView(for post: PostModel) -> CGFloat {
      self.post = post
      startDataBaseListening()
      configure(nameUserLabel)
      configure(favoriteButtonBackgroundView)
      configure(avatarUserImageView)
      return -1.0
   }
   
   @objc func favoriteButtonPressed(_ gesture: UITapGestureRecognizer) {
      guard let post = self.post else {
         return
      }
      favoritsManager.addToFavorite(post: post)
   }
}
