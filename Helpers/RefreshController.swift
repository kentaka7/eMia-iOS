//
//  RefreshController.swift
//  eMia
//

import UIKit

public protocol RefreshControllerDelegate {
   func refreshData(_ completion: @escaping () -> Void)
}

open class RefreshController: NSObject {
   
   var view: UIView!
   var refreshControl: UIRefreshControl!
   var delegate: RefreshControllerDelegate

   public init(view: UIView, delegate: RefreshControllerDelegate) {
      self.delegate = delegate
      super.init()
      self.view = view
      self.setUpRefreshControl()
   }
   
   fileprivate func setUpRefreshControl() {
      self.refreshControl = UIRefreshControl()
      self.refreshControl.tintColor = GlobalColors.kBrandNavBarColor
      self.refreshControl.addTarget(self, action: #selector(RefreshController.refreshData(_:)), for: UIControlEvents.valueChanged)
      self.view.addSubview(refreshControl)
   }
   
   @objc func refreshData(_ sender: AnyObject) {
      self.delegate.refreshData(){
         DispatchQueue.main.async(execute: {
            self.refreshControl.endRefreshing()
         })
      }
   }
}
