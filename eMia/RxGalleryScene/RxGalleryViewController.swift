//
//  RxGalleryViewController.swift
//  eMia
//

import UIKit
import RxSwift
import RxDataSources

struct RxSectionModel {
   let title: String
   var data: [PostModel]
}

extension RxSectionModel : AnimatableSectionModelType {
   typealias Item = PostModel
   typealias Identity = String
   
   var identity: Identity {
      return title
   }
   var items: [Item] {
      return data
   }
   
   init(original: RxSectionModel, items: [PostModel]) {
      self = original
      data = items
   }
}

class RxGalleryViewController: UIViewController {

   @IBOutlet weak var collectionView: UICollectionView!
   
   private let disposeBag = DisposeBag()
   
   private var dataSource: RxCollectionViewSectionedAnimatedDataSource<RxSectionModel>?
   
   private var mSearchText: String = ""
   private var filterManager: FilterManager = FilterManager()
   
   var data = Variable([RxSectionModel]())
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      configure(collectionView!)
      
      confogureDataSource()
      
      fetchData(searchText: "") { [weak self] in
         self?.bindData()
      }
   }

   private func configure(_ view: UIView) {
      switch view {
      case collectionView:
         collectionView?.backgroundColor = UIColor.clear
         collectionView?.contentInset = UIEdgeInsets(top: 23, left: 10, bottom: 10, right: 10)
         if let layout = collectionView?.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
         }
      default:
         break
      }
   }

   private func confogureDataSource() {
      let dataSource = RxCollectionViewSectionedAnimatedDataSource<RxSectionModel>(configureCell: { _, collectionView, indexPath, dataItem in
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryViewCell", for: indexPath) as! GalleryViewCell
         cell.update(with: dataItem)
         return cell
      }, configureSupplementaryView: {dataSource, collectionView, kind, indexPAth in
         let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPAth) as! RxGalleryHeader
         headerView.titleLabel.text = dataSource.sectionModels[indexPAth.section].title
         return headerView
      })
      self.dataSource = dataSource
   }
   
   private func bindData() {
      guard let dataSource = self.dataSource else {
         return
      }
      data.asDriver()
         .drive(collectionView.rx.items(dataSource: dataSource))
         .disposed(by: disposeBag)
   }
   
}

// MARK: -

extension RxGalleryViewController: PinterestLayoutDelegate {

   func collectionView(_ collectionView: UICollectionView, photoSizeAtIndexPath indexPath: IndexPath) -> CGSize {
      let post = self.data.value[0].items[indexPath.row]
      return CGSize(width: post.photoSize.0, height: post.photoSize.1)
   }
   
   func collectionView(_ collectionView: UICollectionView, numberOfItemsinSection: Int) -> Int {
      return data.value[numberOfItemsinSection].data.count
   }
}

extension RxGalleryViewController {
   
   private func fetchData(searchText: String = "", completed: @escaping () -> Void) {
      DispatchQueue.global(qos: .utility).async() {
         let data = PostsManager.getData()
         let filteredData = self.filterPosts(data, searchText: searchText)
         let section = [RxSectionModel(title: "Near dig", data: filteredData)]
         self.data.value.append(contentsOf: section)
         DispatchQueue.main.async {
            completed()
         }
      }
   }

   private func filterPosts(_ posts: [PostModel], searchText: String = "") -> [PostModel] {
      mSearchText = searchText
      return filterManager.filterPosts(posts,searchText: searchText)
   }
}
