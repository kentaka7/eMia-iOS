//
//  CollectionViewController.swift
//  eMia
//

import UIKit
import NVActivityIndicatorView
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

protocol GalleryViewProtocol {
   var galleryCollectionView: UICollectionView? { get }
   func startProgress()
   func stopProgress()
}

class GalleryViewController: UIViewController, UICollectionViewDelegateFlowLayout {
   
   var eventHandler: GalleryPresenter!
   var presenter: GalleryPresenter!
   private var refreshControl: UIRefreshControl!
   
   static let kHeaderHeight: CGFloat = 40.0
   static let kCellHeight: CGFloat = 250.0
   
   @IBOutlet weak var collectionView: UICollectionView?
   @IBOutlet weak var newPostButton: UIButton!
   
   @IBOutlet weak var searchBackgroundView: UIView!
   @IBOutlet weak var searchBar: UISearchBar!
   @IBOutlet weak var searchBaxckgroundViewTopConstraint: NSLayoutConstraint!
   
   @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
   
   private let disposeBag = DisposeBag()
   
   private var dataSource: RxCollectionViewSectionedAnimatedDataSource<RxSectionModel>?
   
   private var mSearchText: String = ""

   var data = Variable([RxSectionModel]())
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      navigationItem.title = "\(AppConstants.ApplicationName)"
      
      refreshControl = UIRefreshControl()
      refreshControl?.addTarget(self, action: #selector(simulateRefresh), for: .valueChanged)
      collectionView?.refreshControl = refreshControl
      
      GalleryDependencies.configure(view: self)
      presenter.configure()
      configureSubviews()
      
      configureDataSource()
      
      presenter.fetchData(searchText: "") { [weak self] posts in
         let section = [RxSectionModel(title: "Near dig", data: posts)]
         self?.data.value.append(contentsOf: section)
         DispatchQueue.main.async {
            self?.bindData()
         }
      }
      
   }
   
   @IBAction func exitToGalleryController(_ segue: UIStoryboardSegue) {
   }
   
   private func configureSubviews() {
      configure(searchBar)
      configure(newPostButton)
      configure(collectionView!)
      configure(searchBackgroundView)
      setUp3DPreviewPhoto()
   }
   
   private func configure(_ view: UIView) {
      switch view {
      case newPostButton:
         newPostButton.layer.cornerRadius = newPostButton.frame.width / 2.0
         newPostButton.backgroundColor = GlobalColors.kBrandNavBarColor
      case collectionView!:
         collectionView!.backgroundColor = UIColor.clear
         collectionView!.contentInset = UIEdgeInsets(top: 23, left: 10, bottom: 10, right: 10)
         if let layout = collectionView!.collectionViewLayout as? GalleryLayout {
            layout.delegate = self
         }
      case searchBackgroundView:
         searchBackgroundView.backgroundColor = GlobalColors.kBrandNavBarColor
      case searchBar:
         searchBar.delegate = self
         searchBar.tintColor = GlobalColors.kBrandNavBarColor
         searchBar.backgroundColor = GlobalColors.kBrandNavBarColor
         searchBar.backgroundImage = UIImage()
         searchBar.placeholder = "Search template".localized
      default:
         break
      }
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
      let searchText = searchBar.text ?? ""
      self.presenter.fetchData(searchText: searchText) { _ in
         
      }
   }
   
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      eventHandler.prepare(for: segue, sender: sender)
   }
   
   private func setUp3DPreviewPhoto() {
      if traitCollection.forceTouchCapability == .available {
         registerForPreviewing(with: self, sourceView: collectionView!)
      }
   }
   
   private func setUpHeaderSize() {
      let headerSize = CGSize(width: self.view.frame.width, height: GalleryViewController.kHeaderHeight)
      (collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize = headerSize
   }
   
   private func setUpFooterSize() {
      let footerSize = CGSize(width: self.view.frame.width, height: GalleryViewController.kHeaderHeight)
      (collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize = footerSize
   }
   
   override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      self.view.endEditing(true)
      searchBar.resignFirstResponder()
   }
   
   @objc func simulateRefresh() {
      DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
         self.refreshControl?.endRefreshing()
      }
   }
   
}

// MARK: - View Protocol

extension GalleryViewController: GalleryViewProtocol {
   
   var galleryCollectionView: UICollectionView? {
      return self.collectionView
   }
   
   func startProgress() {
      DispatchQueue.main.async {
         self.activityIndicatorView.startAnimating()
      }
   }
   
   func stopProgress() {
      DispatchQueue.main.async {
         self.activityIndicatorView.stopAnimating()
      }
   }
   
}

// MARK: - UICollectionViewDelegate

extension GalleryViewController: UICollectionViewDelegate {
   
   public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      let post = self.data.value[0].items[indexPath.row]
      eventHandler.edit(post: post)
   }
}

// MARK: - Hide/Show search bar while scrolling up/down

extension GalleryViewController {
   
   public func scrollViewDidScroll(_ scrollView: UIScrollView) {
      hideKeyboard()
      if(scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0)
      {
         searchBaxckgroundViewTopConstraint.constant = 0.0
         UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.view.layoutIfNeeded()
         }, completion: nil)
      }
      else
      {
         searchBaxckgroundViewTopConstraint.constant = -64.0
         UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.view.layoutIfNeeded()
         }, completion: nil)
      }
   }
}

// MARK: - UISearchBarDelegate

extension GalleryViewController: UISearchBarDelegate {
   
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
         presenter.startSearch(text) { _ in
         }
         return true
      } else {
         return false
      }
   }
   
   private func needStopSearch(for text: String) -> Bool {
      if text.isEmpty {
         presenter.stopSearch()
         return true
      } else {
         return false
      }
   }
   
   fileprivate func hideKeyboard() {
      searchBar.resignFirstResponder()
   }
   
}

// MARK: - UIViewControllerPreviewingDelegate

extension GalleryViewController: UIViewControllerPreviewingDelegate {
   
   func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                          commit viewControllerToCommit: UIViewController) {
      
   }
   
   func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
      return eventHandler.previewPhoto(for: location)
   }
}

// MARK: -

extension GalleryViewController {
   
   private func configureDataSource() {
      let dataSource = RxCollectionViewSectionedAnimatedDataSource<RxSectionModel>(configureCell: { _, collectionView, indexPath, dataItem in
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryViewCell", for: indexPath) as! GalleryViewCell
         cell.update(with: dataItem)
         return cell
      }, configureSupplementaryView: {dataSource, collectionView, kind, indexPAth in
         let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPAth) as! GalleryHeaderView
         headerView.title.text = dataSource.sectionModels[indexPAth.section].title
         return headerView
      })
      self.dataSource = dataSource
   }
   
   private func bindData() {
      guard let dataSource = self.dataSource else {
         return
      }
      data.asDriver()
         .drive(self.collectionView!.rx.items(dataSource: dataSource))
         .disposed(by: disposeBag)
   }
}


extension GalleryViewController: GalleryLayoutDelegate {
   
   func collectionView(_ collectionView: UICollectionView, photoSizeAtIndexPath indexPath: IndexPath) -> CGSize {
      let post = self.data.value[0].items[indexPath.row]
      return CGSize(width: post.photoSize.0, height: post.photoSize.1)
   }
   
   func collectionView(_ collectionView: UICollectionView, numberOfItemsinSection: Int) -> Int {
      return data.value[numberOfItemsinSection].data.count
   }
}
