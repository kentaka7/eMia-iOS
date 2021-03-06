//
//  Appearance.swift
//  eMia
//

import UIKit

final class Appearance {
   private init() {
   }
   
   // MARK: - Class functions
   
   static func customize() {
      
      // Color file template should be added into the project.
      UIApplication.shared.keyWindow?.tintColor  = UIColor.tint
      
      Appearance.customizeNavigationBar()
      Appearance.customizeSwithController()
      Appearance.customizeSegmentedControl()
   }
   
   static func customizeNavigationBar() {
      let navBar = UINavigationBar.appearance()
      navBar.tintColor = UIColor.Navigation.tintColor
      
      // Navigation bar title
      let attr: [NSAttributedString.Key: Any] = [
         .foregroundColor: UIColor.white,
         .font: UIFont.Title.navigationBar
      ]
      navBar.titleTextAttributes = attr
      
      // Background color
      navBar.isTranslucent = false
      
      navBar.setBackgroundImage(GlobalColors.kBrandNavBarImage, for: .default)
      navBar.shadowImage = UIImage(Icon.blank)
      
      // Navigation bar item
      let navBarButton = UIBarButtonItem.appearance()
      let barButtonAttr = [ NSAttributedString.Key.font: UIFont.Title.barButton]
      navBarButton.setTitleTextAttributes(barButtonAttr, for: .normal)
      
   }
   
   static func customize(viewController: UIViewController) {
      if viewController.parent is UINavigationController {
         // Hides text in back barbutton item
         viewController.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
      }
   }
   
}

// MARK: - UISwitch

extension Appearance {
   static func customizeSwithController() {
      let appearance = UISwitch.appearance()
      appearance.tintColor = GlobalColors.kBrandNavBarColor
      appearance.onTintColor = GlobalColors.kBrandNavBarColor
   }
}

// MARK: - Segmented control

extension Appearance {
   static func customizeSegmentedControl() {
      let appearance = UISegmentedControl.appearance()
      appearance.tintColor = GlobalColors.kBrandNavBarColor
      let attr = [
         NSAttributedString.Key.font: FontFamily.Avenir.book.font(size: 14),
         NSAttributedString.Key.foregroundColor: UIColor.black
      ]
      appearance.setTitleTextAttributes(attr, for: .normal)
   }
}
