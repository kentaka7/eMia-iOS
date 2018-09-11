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

class EditPost1ViewCell: UITableViewCell {
   
   weak var viewModel: EditPostViewModel!
   
   @IBOutlet weak var avatarBackgroundView: UIView!
   @IBOutlet weak var avatarUserImageView: UIImageView!
   @IBOutlet weak var nameUserLabel: UILabel!
   
   @IBOutlet weak var favoriteButtonBackgroundView: UIView!
   @IBOutlet weak var favoriteButtonImageView: UIImageView!
   
   private let disposeBag = DisposeBag()
   
   private let favoritsManager = FavoritsManager()
   private let postsManager = PostsManager()
   
   override func awakeFromNib() {
      configureView()
   }
   
   private func configureView() {
      configure(avatarBackgroundView)
   }
}

// MARK: - Private methods

extension EditPost1ViewCell {
   
   private func configure(_ view: UIView) {
      switch view {
      case avatarBackgroundView:
         avatarBackgroundView.setAsCircle()
         
      default:
         break
      }
   }
   
   private func bindAddToFavoriteButton() {
      let tapGesture = UITapGestureRecognizer()
      tapGesture.rx.event.bind(onNext: { [weak self] recognizer in
         self?.viewModel.addToFavoriteButtonPressed()
      }).disposed(by: disposeBag)
      favoriteButtonBackgroundView.addGestureRecognizer(tapGesture)
   }
}


extension EditPost1ViewCell {
   
   func setName(_ text: String?) {
      self.nameUserLabel.text = text
   }
   
   func setPhotro(_ image: UIImage?) {
      DispatchQueue.main.async {
         self.avatarUserImageView.image = image
      }
   }

   func setFavorite(_ isItFavorite: Bool) {
      DispatchQueue.main.async {
         self.favoriteButtonImageView.image = UIImage(named: isItFavorite ? "icon-toggle_star" : "icon-toggle_star_outline")
      }
   }

   func setItIsMyPost(_ isItMyPost: Bool) {
      self.favoriteButtonBackgroundView.isHidden = isItMyPost
      if isItMyPost == false {
         bindAddToFavoriteButton()
      }
   }
}
