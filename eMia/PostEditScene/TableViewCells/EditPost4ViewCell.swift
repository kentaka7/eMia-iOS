//
//  EditPost4ViewCell.swift
//  eMia
//

import UIKit
import NextGrowingTextView
import NVActivityIndicatorView
import IQKeyboardManagerSwift
import RxSwift

// Comment text enter field

class EditPost4ViewCell: UITableViewCell {
   
   private let kMaxNumberOfLines = 5
   private let kMaxNumberOfSymbols = 256
   
   @IBOutlet weak var commentTextView: NextGrowingTextView!
   
   var commentText = PublishSubject<String>()
   var currentCellHeigt = PublishSubject<CGFloat>()
   
   private var plusSpace: CGFloat!
   
   private let placeholder = "Please enter your comment here (up to 256)".localized
   private var newComment: String?
   var textView: UITextView {
      return commentTextView.textView
   }
   
   var editViewInActiveState: Bool {
      return self.commentTextView.isFirstResponder
   }
   
   deinit {
      Log()
   }
   
   override func awakeFromNib() {
      IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "Send comment".localized
      plusSpace = self.frame.height - commentTextView.frame.height
      configure(commentTextView)
      configure(textView)
   }
   
   private func configure(_ view: UIView) {
      switch view {
      case commentTextView:
         commentTextView.maxNumberOfLines = kMaxNumberOfLines
         commentTextView.delegates.didChangeHeight = {[weak self] height in
            guard let `self` = self else { return }
            self.currentCellHeigt.onNext(height + self.plusSpace)
         }
      case textView:
        textView.delegate = self
         cleanTextView()
      default:
         break
      }
   }
   
   @objc func didPressOnDoneButton() {
      sendComment()
   }
   
   private func sendComment() {
      guard let text = newComment, text.isEmpty == false, text != placeholder else {
         return
      }
      newComment = nil
      cleanTextView()
      commentText.onNext(text)
   }
}

// MARK: - ForPostConfigurable protocol implementstion

extension EditPost4ViewCell: ForPostConfigurable {

   func configureView(for post: PostModel) -> CGFloat {
      return -1.0
   }
}

// MARK: - UITextViewDelegate protocol implementstion

extension EditPost4ViewCell: UITextViewDelegate {
   
   func textViewDidBeginEditing(_ textView: UITextView) {
      let invocation = IQInvocation(self, #selector(didPressOnDoneButton))
      self.textView.keyboardToolbar.doneBarButton.invocation = invocation
      if self.textView.textColor == UIColor.lightGray {
         self.textView.delegate = nil
         self.textView.text = nil
         self.textView.delegate = self
         self.textView.textColor = UIColor.black
         self.newComment = nil
      }
   }
   
   func textViewDidEndEditing(_ textView: UITextView) {
      newComment = self.textView.text
   }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < kMaxNumberOfSymbols
    }
    
   private func cleanTextView() {
      self.textView.text = placeholder
      self.textView.textColor = UIColor.lightGray
   }
}
