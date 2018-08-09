//
//  PostsPageViewController.swift
//  eMia
//
//  Created by Сергей Кротких on 08/08/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit

class PostsPageViewController: UIPageViewController {
   
   struct Storyboards {
      static let editPost = "EditPost"
   }
   
   struct Segue {
      static let editPostViewController = "EditPostViewController"
   }
   
   enum Direction {
      case current
      case before
      case after
   }
   
   var interactor: GalleryInteractor!
   var post: PostModel!
   
   override func viewDidLoad() {
      self.dataSource = self
      let controller = createViewController(direction: .current)
      self.setViewControllers([controller], direction: .forward, animated: false, completion: nil)
   }
   
   func createViewController(direction: Direction) -> UIViewController {
      let storyboard = UIStoryboard(name: Storyboards.editPost, bundle: nil)
      if let controller = storyboard.instantiateViewController(withIdentifier: Segue.editPostViewController) as? EditPostViewController {
          controller.post = getPost(direction)
         return controller
      } else {
         return UIViewController()
      }
   }
   
   private func getPost(_ direction: Direction) -> PostModel {
      let array = self.interactor.data.value[0].items
      if array.count == 1 {
         return post
      }

      switch direction {
      case .current:
         break
      case .before:
         var index = -1
         for i in 0...array.count - 1 {
            let item = array[i]
            if post == item {
               index = i - 1
            }
         }
         if index == -1 {
            index = array.count - 1
         }
         post = array[index]
      case .after:
         var index = array.count
         for i in 0...array.count - 1 {
            let item = array[i]
            if post == item {
               index = i + 1
            }
         }
         if index == array.count {
            index = 0
         }
         post = array[index]
      }
      return post
   }
}

extension PostsPageViewController: UIPageViewControllerDataSource {

   func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
      let controller = createViewController(direction: .before)
      return controller
   }
   
   func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
      let controller = createViewController(direction: .after)
      return controller
   }

}
