//
//  GalleryPresenter.swift
//  eMia
//

import UIKit

class GalleryPresenter: NSObject, GallerySearchable, GalleryPresentable {

   var router: GalleryRouter!
   var interactor: GalleryInteractor!
   var view: GalleryViewProtocol!
   
   var title: String {
      return "\(AppConstants.ApplicationName)"
   }
   
   func configure() {
      interactor.configure()
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
   
   func startSearch(_ text: String, _ completed: @escaping ([PostModel]) -> Void) {
      fetchData(searchText: text, completed)
   }

   func stopSearch() {
      fetchData(searchText: "") { _ in
      }
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
   
   func prepareGalleryCell(_ collectionView: UICollectionView, indexPath: IndexPath, post: PostModel) -> UICollectionViewCell {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryViewCell", for: indexPath) as! GalleryViewCell
      cell.update(with: post)
      return cell
   }

   func prepareGalleryHeader(_ collectionView: UICollectionView, indexPath: IndexPath, kind: String, text: String) -> UICollectionReusableView {
      let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! GalleryHeaderView
      headerView.title.text = text
      return headerView
   }
}

// MARK: -

extension GalleryPresenter {

   func edit(post: PostModel) {
      self.router.performEditPost(post)
   }
}

// MARK: -

extension GalleryPresenter: GalleryLayoutDelegate {
   
   func collectionView(_ collectionView: UICollectionView, photoSizeAtIndexPath indexPath: IndexPath) -> CGSize {
      return interactor.collectionView(collectionView, photoSizeAtIndexPath: indexPath)
   }
   
   func collectionView(_ collectionView: UICollectionView, numberOfItemsinSection section: Int) -> Int {
      return interactor.collectionView(collectionView, numberOfItemsinSection: section)
   }
}


