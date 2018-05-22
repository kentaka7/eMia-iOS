//
//  FiltersViewController.swift
//  eMia
//

import UIKit

final class FiltersViewController: UIViewController {
    
    var interactor: FilterStoragable!
    
    // MARK: Components
    var genderControllerView: ShowMeSegmentedControl!
    var favoriteControllerView: FavStatusSegmentedControl!
    var municipalityControllerView: MunicipalityControllerView!
    var ageSliderView: AgeSliderView!
    
    // MARK: Outlets
    @IBOutlet weak var genderBackgroundView: UIView!
    @IBOutlet weak var myFavoriteBackgroundView: UIView!
    @IBOutlet weak var municipalityBackgroundView: UIView!
    @IBOutlet weak var agesSliderBackgroundView: UIView!
    
    @IBOutlet weak var ageLabel: UILabel!
    
    @IBOutlet weak var separatorLineView: UIView!
    
    @IBOutlet weak var municipalityLabel: UILabel!
    
    // MARK: Private
    private struct Constants {
        static let cornerRadius: CGFloat = 3.0
        static let borderWidth: CGFloat = 2.0
    }
    
    // MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Appearance.customize(viewController: self)
        
        FilterDependencies.configure(view: self)
        
        configureView()
        interactor.fetchFilterPreferences()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch segueType(for: identifier) {
        case .exitToGallery:
            interactor.saveFilterPreferences()
            return true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueType(for: segue) {
        case .exitToGallery:
            break
        }
    }
    
    @IBAction func backBarButtonPressed(_ sender: Any) {
        performSegue(.exitToGallery, sender: nil)
    }
}

// MARK: - Navigation & SegueRawRepresentable protocol

extension FiltersViewController: SegueRawRepresentable {
    
    enum SegueType: String {
        case exitToGallery
    }
}

//    MARK: - Utilities

extension FiltersViewController  {
    
    private func configureView() {
        configure(self.view)
        configure(separatorLineView)
        configure(genderBackgroundView)
        configure(myFavoriteBackgroundView)
        configure(municipalityBackgroundView)
        configure(municipalityLabel)
        configureAgeSlider()
    }

    fileprivate func configure(_ view: UIView) {
        switch view {
        case self.view:
            view.backgroundColor = UIColor.white.withAlphaComponent(0.75)
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.insertSubview(blurEffectView, at: 0)
            
        case separatorLineView:
            separatorLineView.backgroundColor = GlobalColors.kBrandNavBarColor
        case municipalityLabel:
            municipalityLabel.text = "Municipality".localized
            
        case ageLabel:
            ageLabel.text = "Age".localized

        // MARK: Add Components
        case genderBackgroundView:
            genderBackgroundView.layer.cornerRadius = Constants.cornerRadius
            genderBackgroundView.layer.borderWidth = Constants.borderWidth
            genderBackgroundView.layer.borderColor = UIColor.lightGray.cgColor
            genderControllerView = ShowMeSegmentedControl.getInstance(for: genderBackgroundView)
            
        case myFavoriteBackgroundView:
            myFavoriteBackgroundView.layer.cornerRadius = Constants.cornerRadius
            myFavoriteBackgroundView.layer.borderWidth = Constants.borderWidth
            myFavoriteBackgroundView.layer.borderColor = UIColor.lightGray.cgColor
            favoriteControllerView = FavStatusSegmentedControl.getInstance(for: myFavoriteBackgroundView)
            
        case municipalityBackgroundView:
            municipalityControllerView = MunicipalityControllerView.getInstance(for: municipalityBackgroundView)
            
        default: break
        }
    }
    
    private func configureAgeSlider() {
        ageSliderView = AgeSliderView.getInstance(for: agesSliderBackgroundView, min: 0, max: 100)
    }
}
