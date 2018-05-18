//
//  GalleryPresenter.swift
//  eMia
//

import UIKit

class GalleryPresenter: NSObject {

   var router: GalleryRouter!
   var interactor: GalleryInteractor!
   var view: GalleryViewProtocol!
   
   func configure() {
      //interactor.configure()
   }
   
   func startProgress() {
      view.startProgress()
   }

   func stopProgress() {
      view.stopProgress()
   }
   
   func fetchData(searchText: String = "", _ completed: @escaping ([PostModel]) -> Void) {
      interactor.fetchData(searchText: searchText, completed)
   }
   
   func filterPosts(_ posts: [PostModel], searchText: String = "") -> [PostModel]  {
      return interactor.filterPosts(posts, searchText: searchText)
   }
   
   func startSearch(_ text: String, _ completed: @escaping ([PostModel]) -> Void) {
      fetchData(searchText: text, completed)
   }

   func stopSearch() {
      fetchData(searchText: "") { _ in
      }
   }
   
   func edit(post: PostModel) {
      self.router.performEditPost(post)
   }

   func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      router.prepare(for: segue, sender: sender)
   }
   
   func previewPhoto(for location: CGPoint) -> UIViewController? {
      if let image = interactor.previewPhoto(for: location), let postViewController = router.postPreviewViewController {
         postViewController.image = image
         return postViewController
      } else {
         return nil
      }
   }
   
}
