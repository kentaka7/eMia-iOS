//
//  SettingsViewController.swift
//  eMia
//
//  Created by Sergey Krotkih on 12/20/17.
//  Copyright © 2017 Coded I/S. All rights reserved.
//

import UIKit

/**
 * SettingsViewController class is an example of the MVVM pattern
 * We use presenter as a view model as well
 */

class SettingsViewController: UIViewController {

   @IBOutlet weak var tableView: UITableView!
   
   var presenter: TableViewPresentable!
   var router: SettingsRouter!
   
   override func viewDidLoad() {
      super.viewDidLoad()
      SettingsDependencies.configure(view: self, tableView: tableView)
   }
   
   private func configureTableView() {
      tableView.delegate = self
      tableView.dataSource = self
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      tableView.reloadData()
   }
   
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      router.prepare(for: segue, sender: sender)
   }
   
   @IBAction func backButtonPressed(_ sender: Any) {
      navigationController?.popViewController(animated: true)
   }
}

// MARK: - Table View delegate protocol

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
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
