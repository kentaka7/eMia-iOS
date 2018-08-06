//
//  EditPost4ViewCell.swift
//  eMia
//

import UIKit
import NextGrowingTextView
import NVActivityIndicatorView
import IQKeyboardManagerSwift

// Comment text enter field

class EditPost4ViewCell: UITableViewCell, ForPostConfigurable, UITextViewDelegate {

   @IBOutlet weak var commentTextView: NextGrowingTextView!
   @IBOutlet weak var sendCommentButton: UIButton!
   
   weak var activityIndicator: NVActivityIndicatorView!

   var didChangeHeight: (CGFloat) -> Void = { _ in }
   var didEnterNewComment: () -> Void = { }
   var post: PostModel!
   
   private var plusSpace: CGFloat!
   
   override func awakeFromNib() {
      configure(sendCommentButton)
      configure(commentTextView)
      
      plusSpace = self.frame.height - commentTextView.frame.height
   }

   private func configure(_ view: UIView) {
      switch view {
      case sendCommentButton:
         sendCommentButton.setTitle("Send Comment".localized, for: .normal)
         sendCommentButton.setTitleColor(GlobalColors.kBrandNavBarColor, for: .normal)
      case commentTextView:
         commentTextView.maxNumberOfLines = 10
         commentTextView.delegates.didChangeHeight = { height in
            let currentCellHeigt = height + self.plusSpace
            self.didChangeHeight(currentCellHeigt)
         }
         commentTextView.textView.delegate = self
         
         let invocation = IQInvocation(self, #selector(fff))
         commentTextView.keyboardToolbar.doneBarButton.invocation = invocation
         commentTextView.keyboardToolbar.nextBarButton.invocation = invocation
         commentTextView.keyboardToolbar.previousBarButton.invocation = invocation
         
      default:
         break
      }
   }
   
   func configureView(for post: PostModel) -> CGFloat {
      return -1.0
   }

   @IBAction func sendCommentButtonPressed(_ sender: Any) {
      sendComment()
   }
   
   public func textViewDidEndEditing(_ textView: UITextView) {
      print("12222")
   }

   @objc func fff() {
      print("o909090909")
   }
   
   
}

// MARK: - Save comment

extension EditPost4ViewCell {
   
   fileprivate func sendComment() {
      guard let text = commentTextView.textView.text, text.isEmpty == false else {
         return
      }
      guard let currentUser = gUsersManager.currentUser else {
         return
      }
      activityIndicator.startAnimating()
      let newComment = CommentModel(uid: currentUser.userId, author: currentUser.name, text: text, postid: post.id!)
      newComment.synchronize { success in
         if success {
            self.didEnterNewComment()
            self.commentTextView.textView.text = ""
            _ = self.commentTextView.resignFirstResponder()
         }
         self.activityIndicator.stopAnimating()
      }
   }
}
