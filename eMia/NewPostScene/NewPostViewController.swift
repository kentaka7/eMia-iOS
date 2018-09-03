//
//  NewPostViewController.swift
//  eMia
//

import UIKit
import IQKeyboardManagerSwift
import RxSwift
import RxCocoa

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
   private let disposeBag = DisposeBag()
   
   deinit {
      Log()
   }

   override func viewDidLoad() {
      super.viewDidLoad()

      configurator.configure(self)
      presenter.configureView()
      configureView()
      bindButtons()
   }
   
   private func configureView() {
      configure(self.view)
      configure(saveButton)
   }

   private func bindButtons() {
      bindSaveButton()
      bindBackButton()
   }
   
   private func configure(_ view: UIView) {
      switch view {
      case self.view:
         navigationItem.title = presenter.title
      case saveButton:
         saveButton.setAsCircle()
         saveButton.backgroundColor = GlobalColors.kBrandNavBarColor
      default:
         break
      }
   }
   
   private func bindSaveButton() {
      saveButton.rx.tap.bind(onNext: { [weak self] in
         guard let `self` = self else { return }
         self.presenter.doneButtonPressed()
      }).disposed(by: disposeBag)
   }
   
   private func bindBackButton() {
      backBarButtonItem.rx.tap.bind(onNext: { [weak self] in
         guard let `self` = self else { return }
         self.presenter.backButtonPressed()
      }).disposed(by: disposeBag)
   }
}
