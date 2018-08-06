//
//  EditPostViewController.swift
//  eMia
//

import UIKit
import IQKeyboardManagerSwift
import NVActivityIndicatorView
import RxSwift
import RxCocoa

class EditPostViewController: UIViewController {

   var presenter: EditPostPresenting!
   var post: PostModel!
   var keyboardController: KeyboardController!
   private let disposeBag = DisposeBag()
   
   @IBOutlet weak var tableView: UITableView!
   @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
   @IBOutlet weak var fakeTextField: UITextField!
   
   // MARK: View lifecycle
   override func viewDidLoad() {
      super.viewDidLoad()

      EditPostDependencies.configure(view: self, post: post, tableView: tableView, activityIndicator: activityIndicator, fakeTextField: fakeTextField)
      
      navigationItem.title = presenter.title

      Appearance.customize(viewController: self)
      
      configureView()
      presenter.configure()
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      keyboardController.configure(with: self.view)
      presenter.updateView()
   }
   
   // MARK: Actions
   @IBAction func backButtonPressed(_ sender: Any) {
      close()
   }
   
   // MARK: Private nethods
   private func configureView() {
      
      IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "Send Comment".localized
      
      configure(tableView)
   }
   
   private func configure(_ view: UIView) {
      switch view {
      case tableView:
         tableView.rowHeight = UITableViewAutomaticDimension
         tableView.estimatedRowHeight = 140
         tableView.delegate = self
         tableView.dataSource = self
      default:
         break
      }
   }
   
   private func close() {
      navigationController?.popViewController(animated: true)
   }
}

extension EditPostViewController: UITableViewDataSource, UITableViewDelegate {
   
   public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return presenter.numberOfRows
   }
   
   public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return presenter.heightCell(for: indexPath)
   }
   
   public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      return presenter.cell(for: indexPath)
   }
}
