//
//  EditPostViewController.swift
//  eMia
//

import UIKit
import RxSwift
import RxCocoa
import NVActivityIndicatorView

class EditPostViewController: UIViewController, EditPostViewProtocol {

   weak var post: PostModel!
   
   var presenter: EditPostPresenterProtocol!
   var editor: EditPostEditorProtocol!
   
   @IBOutlet weak var tableView: UITableView!
   @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
   @IBOutlet weak var bottomTableViewConstraint: NSLayoutConstraint!
   @IBOutlet weak var backBarButtonItem: UIBarButtonItem!
   
   private let configurator = EditPostDependencies()
   private let disposeBag = DisposeBag()

   // MARK: View lifecycle
   override func viewDidLoad() {
      super.viewDidLoad()

      configurator.configure(self)
      presenter.configure()
      configureView()
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      editor.configure()
      presenter.updateView()
   }
   
   func setUpTitle(text: String) {
      navigationItem.title = text
   }
   
   private func configureView() {
      Appearance.customize(viewController: self)
      bindBackButton()
   }
   
   private func bindBackButton() {
      backBarButtonItem.rx.tap.bind(onNext: { [weak self] in
         guard let `self` = self else { return }
         self.presenter.closeCurrentViewController()
      }).disposed(by: disposeBag)
   }
}
