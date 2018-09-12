//
//  EditPost5ViewCell.swift
//  eMia
//

import UIKit

// Comment table item

class EditPost5ViewCell: UITableViewCell, ForPostConfigurable {

   @IBOutlet weak var avatarBackgroundView: UIView!
   @IBOutlet weak var avatarImageView: UIImageView!
   @IBOutlet weak var titleLabel: UILabel!
   @IBOutlet weak var bodyLabel: UILabel!
   @IBOutlet weak var createdLabel: UILabel!
   
   override func awakeFromNib() {
      avatarBackgroundView.setAsCircle()
   }

   func configureView(for post: PostModel) -> CGFloat {
      return -1.0
   }

   override func prepareForReuse() {
      self.avatarImageView.image = nil
   }
   
   func configureView(for comment: CommentModel) {
      setUpAvatar(for: comment) { image in
         self.avatarImageView.image = image
      }
      titleLabel.text = userName(for: comment)
      bodyLabel.text = bodyText(for: comment)
      createdLabel.text = created(for: comment)
   }
   
}

// MARK: - Private methods

extension EditPost5ViewCell {
   
   private func setUpAvatar(for comment: CommentModel, completion: @escaping (UIImage?) -> Void) {
      gPhotosManager.downloadAvatar(for: comment.uid) { image in
         completion(image)
      }
   }

   private func userName(for comment: CommentModel) -> String? {
      if let user = gUsersManager.getUserWith(id: comment.uid) {
         return user.name
      } else {
         return nil
      }
   }
   
   private func bodyText(for comment: CommentModel) -> String? {
      return comment.text
   }
   
   private func created(for comment: CommentModel) -> String? {
      return "Created".localized + " " + comment.relativeTimeToCreated()
   }
}
