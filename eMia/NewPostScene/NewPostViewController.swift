//
//  NewPostViewController.swift
//  eMia
//

import UIKit
import IQKeyboardManagerSwift

class NewPostViewController: UIViewController, NewPostViewProtocol {
   
   var presenter: NewPostPresenterProtocol!
   var viewController: UIViewController? {
      return self
   }
   
   @IBOutlet weak var saveButton: UIButton!
   @IBOutlet weak var backBarButtonItem: UIBarButtonItem!
   @IBOutlet weak var tableView: UITableView!
   @IBOutlet weak var fakeTextField: UITextField!
   
   private let configurator = NewPostDependencies()
   
   deinit {
      Log()
   }

   override func viewDidLoad() {
      super.viewDidLoad()

      configurator.configure(self)
      presenter.configureView()
      configureView()
   }
   
   private func configureView() {
      configure(self.view)
      configure(tableView)
      configure(saveButton)
   }
   
   private func configure(_ view: UIView) {
      switch view {
      case self.view:
         navigationItem.title = presenter.title
      case self.tableView:
         break
      case saveButton:
         saveButton.setAsCircle()
         saveButton.backgroundColor = GlobalColors.kBrandNavBarColor
      default:
         break
      }
   }
}
