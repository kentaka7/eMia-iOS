//
//  CollectionViewController.swift
//  eMia
//

import UIKit
import NVActivityIndicatorView
import RxSwift
import RxCocoa
import RxDataSources

class GalleryViewController: UIViewController, UICollectionViewDelegateFlowLayout {
   static let kHeaderHeight: CGFloat = 0.0
   static let kCellHeight: CGFloat = 250.0
   static let kSearchBarHeight: CGFloat = 64.0

   var presenter: GalleryPresentable!
   weak var layoutDelegate: GalleryLayoutDelegate!
   var searcher: GallerySearching!
   
   private var refreshControl: UIRefreshControl!
   private let disposeBag = DisposeBag()
   
   @IBOutlet weak var collectionView: UICollectionView?
   @IBOutlet weak var newPostButton: UIButton!
   
   @IBOutlet weak var searchBackgroundView: UIView!
   @IBOutlet weak var searchBar: UISearchBar!
   @IBOutlet weak var countItemsLabel: UILabel!
   @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint!
   
   @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
   
   override func viewDidLoad() {
      super.viewDidLoad()

      GalleryDependencies.configure(view: self)

      navigationItem.title = presenter.title
      configureSubviews()
      presenter.configure()
      searcher.configure(searchBar: searchBar)
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
   }
   
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      presenter.prepare(for: segue, sender: sender)
   }
   
   override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      self.view.endEditing(true)
      searchBar.resignFirstResponder()
   }
   
   @objc func simulateRefresh() {
      presenter.reloadData()
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
         self.refreshControl?.endRefreshing()
      }
   }
}

// MARK: - Private methods

extension GalleryViewController {
   
   private func configureSubviews() {
      configure(searchBar)
      configure(newPostButton)
      configure(collectionView!)
      configure(searchBackgroundView)
      configure(countItemsLabel)
      setUpHeaderSize()
      setUp3DPreviewPhoto()
   }
   
   private func configure(_ view: UIView) {
      switch view {
      case newPostButton:
         newPostButton.layer.cornerRadius = newPostButton.frame.width / 2.0
         newPostButton.backgroundColor = GlobalColors.kBrandNavBarColor
      case collectionView!:
         collectionView!.delegate = self
         collectionView!.backgroundColor = UIColor.clear
         collectionView!.contentInset = UIEdgeInsets(top: 23, left: 10, bottom: 10, right: 10)
         if let layout = collectionView!.collectionViewLayout as? GalleryLayout {
            layout.delegate = layoutDelegate
         }
         refreshControl = UIRefreshControl()
         collectionView!.refreshControl = refreshControl
         refreshControl.rx.controlEvent(.valueChanged).subscribe(onNext: { [unowned self] in
            self.simulateRefresh()
         }).disposed(by: disposeBag)
      case searchBackgroundView:
         searchBackgroundView.backgroundColor = GlobalColors.kBrandNavBarColor
      case searchBar:
         searchBar.tintColor = GlobalColors.kBrandNavBarColor
         searchBar.backgroundColor = GlobalColors.kBrandNavBarColor
         searchBar.backgroundImage = UIImage()
      case countItemsLabel:
         presenter.galleryItemsCount.subscribe(onNext: { value in
            self.countItemsLabel.text = "Total".localized + " \(value)"
         }).disposed(by: disposeBag)
      default:
         break
      }
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

// MARK: - Hide/Show search bar while scrolling up/down

extension GalleryViewController {
   
   public func scrollViewDidScroll(_ scrollView: UIScrollView) {
      searchBar.resignFirstResponder()
      if scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0 {
         searchBarTopConstraint.constant = 0.0
         UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.view.layoutIfNeeded()
         }, completion: nil)
      } else {
         searchBarTopConstraint.constant = -1.0 * GalleryViewController.kSearchBarHeight
         UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.view.layoutIfNeeded()
         }, completion: nil)
      }
   }
}

// MARK: - UIViewControllerPreviewingDelegate

extension GalleryViewController: UIViewControllerPreviewingDelegate {
   
   func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                          commit viewControllerToCommit: UIViewController) {
      
   }
   
   func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
      return presenter.previewPhoto(for: location)
   }
}
