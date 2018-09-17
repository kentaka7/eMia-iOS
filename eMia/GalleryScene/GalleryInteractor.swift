//
//  GalleryInteractor.swift
//  eMia
//
//  Created by Sergey Krotkih on 27/05/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RealmSwift

struct SectionPostModel {
   var title: String
   var data: [PostModel]
}

// MARK: UIGalleryView data source

extension SectionPostModel: AnimatableSectionModelType {
   typealias Item = PostModel
   typealias Identity = String
   
   var identity: Identity {
      return title
   }
   var items: [Item] {
      return data
   }
   init(original: SectionPostModel, items: [PostModel]) {
      self = original
      data = items
   }
}

class GalleryInteractor: NSObject, AnyObservable {
   
   var presenter: GalleryPresenter!

   var observers: [Any] = []
   
   weak var collectionView: UICollectionView?

   private weak var mSearchBar: UISearchBar!
   private var mSearchText: String?
   
   private let disposeBag = DisposeBag()
   private let postsManager = PostsManager()
   private var token: NotificationToken?

   var data = Variable([SectionPostModel]())

   deinit {
      unregisterObserver()
      token?.invalidate()
   }
   
   func configure() {
      configureDataSource()
      subscribeToSelectGalleryItem()
      configureDataModelListener()
      registerObserver()
   }
   
   func configureSearching(with searchBar: UISearchBar) {
      self.mSearchBar = searchBar
      searchBar.delegate = self
      searchBar.rx.text                                     // observable property
         .throttle(0.5, scheduler: MainScheduler.instance)  // wait 0.5 seconds for changes
         .distinctUntilChanged()                            // check if the new value is the same as the old one
         .skip(1)
         .subscribe { [unowned self] (query) in
            if let text = query.event.element {
               self.mSearchText = text
               self.fetchData()
            }
         }
         .disposed(by: disposeBag)
   }
   
   func registerObserver() {
      let queue = OperationQueue.main
      let center = NotificationCenter.default
      observers.append(
         _ = center.addObserver(forName: Notification.Name(Notifications.UpdatedFilter), object: nil, queue: queue) { [weak self] _ in
            guard let `self` = self else {
               return
            }
            self.fetchData()
            self.scrollOnTop()
         }
      )
   }

   private func configureDataSource() {
      let dataSource = RxCollectionViewSectionedAnimatedDataSource<SectionPostModel>(configureCell: { _, collectionView, indexPath, postModel in
         return self.presenter.prepareGalleryCell(collectionView, indexPath: indexPath, post: postModel)
      }, configureSupplementaryView: {dataSource, collectionView, kind, indexPath in
         let title = dataSource.sectionModels[indexPath.section].title
         return self.presenter.prepareGalleryHeader(collectionView, indexPath: indexPath, kind: kind, text: title)
      })
      self.data.asDriver()
         .drive(self.collectionView!.rx.items(dataSource: dataSource))
         .disposed(by: self.disposeBag)
   }
   
   private func configureDataModelListener() {
      let realm = try? Realm()
      let results = realm?.objects(PostModel.self) // Auto-Updating Results
      token = results?.observe({ change in
         switch change {
         case .initial:
            self.fetchData()
         case .error(let error):
            fatalError("\(error)")
         case .update( _,  _,  _, _):
            // TODO: Update (add, delete) gallery item separately
            self.fetchData()
         }
      })
   }
   
   private func subscribeToSelectGalleryItem() {
      collectionView!.rx.itemSelected.subscribe({ [unowned self] event in
         if let indexPath = event.element {
            if let cell = self.collectionView?.cellForItem(at: indexPath) as? GalleryViewCell {
               cell.flash() {
                  if let post = self.getPost(for: indexPath) {
                     self.presenter.edit(post: post)
                  }
               }
            }
         }
      }).disposed(by: disposeBag)
   }
   
   private func getPost(for indexPath: IndexPath) -> PostModel? {
      if indexPath.row < self.data.value[0].items.count {
         return self.data.value[0].items[indexPath.row]
      } else {
         return nil
      }
   }
   
   private func scrollOnTop() {
      DispatchQueue.main.async {
         guard self.data.value[0].items.count > 0 else {
            return
         }
         let indexPath = IndexPath(row: 0, section: 0)
         self.collectionView?.scrollToItem(at: indexPath, at: .top, animated: false)
      }
   }
}

// MARK: - DataSource

extension GalleryInteractor {

   func fetchData() {
      let localDB = LocalBaseController()
      let posts = localDB.posts.filter({ post -> Bool in
         let searchText = self.mSearchText ?? ""
         return FilterModel.check(post: post, searchTemplate: searchText)
      }).sorted(by: {$0.created > $1.created})
      presenter.galleryItemsCount.onNext(posts.count)
      let section: [SectionPostModel] = [SectionPostModel(title: "\(posts.count)", data: posts)]
      self.data.value = section
   }
}

// MARK: - Gallery Layout

extension GalleryInteractor: GalleryLayoutDelegate {
   
   func collectionView(_ collectionView: UICollectionView, photoSizeAtIndexPath indexPath: IndexPath) -> CGSize {
      if let post = getPost(for: indexPath) {
         return CGSize(width: post.photoSize.0, height: post.photoSize.1)
      } else {
         return CGSize(width: 0, height: 0)
      }
   }
   
   func collectionView(_ collectionView: UICollectionView, numberOfItemsinSection: Int) -> Int {
      if data.value.count > 0 {
         return data.value[numberOfItemsinSection].data.count
      } else {
         return 0
      }
   }
}

// MARK: - Preview Photo

extension GalleryInteractor {
   
   func previewPhoto(for location: CGPoint) -> UIImage? {
      guard let indexPath = collectionView?.indexPathForItem(at: location) else {
         return nil
      }
      guard let image = getPhotoFor(indexPath: indexPath) else {
         return nil
      }
      return image
   }
   
   private func getPhotoFor(indexPath: IndexPath) -> UIImage? {
      guard let cell = collectionView?.cellForItem(at: indexPath) as? GalleryViewCell, let photoImageView = cell.photoImageView  else {
         return nil
      }
      return photoImageView.image
   }
}

// MARK: - UISearchBarDelegate

extension GalleryInteractor: UISearchBarDelegate {
   
   public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
      if search(searchBar.text) {
         hideKeyboard()
      }
   }
   
   public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
      if needStopSearch(for: searchText) {
         hideKeyboard()
      }
   }
   
   private func search(_ text: String?) -> Bool {
      if let text = text, text.isEmpty == false {
         mSearchText = text
         fetchData()
         return true
      } else {
         return false
      }
   }
   
   private func needStopSearch(for text: String) -> Bool {
      if text.isEmpty {
         _ = search("")
         return true
      } else {
         return false
      }
   }
   
   private func hideKeyboard() {
      mSearchBar.resignFirstResponder()
   }
}
