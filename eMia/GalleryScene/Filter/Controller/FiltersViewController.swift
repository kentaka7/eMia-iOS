//
//  FiltersViewController.swift
//  eMia
//

import UIKit

final class FiltersViewController: UIViewController {
    
    var eventHandler: FilterPresenter!
    var presenter: FilterPresenter!
    
    var genderControllerView: GenderControllerView!
    
    //    MARK: Public
    private var municipalityPicker: MunicipalityPicker!
    
    //    MARK: Outlets
    
    // Segmented Control
    @IBOutlet weak var genderBackgroundView: UIView!
    @IBOutlet weak var myFavoriteBackgroundView: UIView!
    @IBOutlet weak var municipalityBackgroundView: UIView!
    
    @IBOutlet weak var selectedAllView: UIView!
    @IBOutlet weak var selectedMyFavoriteView: UIView!
    
    @IBOutlet weak var allLabel: UILabel!
    @IBOutlet weak var myFavoriteLabel: UILabel!
    
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var rangeSlider: MARKRangeSlider!
    @IBOutlet weak var rangeLabel: UILabel!
    
    @IBOutlet weak var separatorLineView: UIView!
    
    @IBOutlet weak var municipalityLabel: UILabel!
    @IBOutlet weak var municipalityPickerView: UIPickerView!
    
    @IBOutlet weak var selectAllMunicipalityView: UIView!
    @IBOutlet weak var selectMunicipalityView: UIView!
    @IBOutlet weak var allMunicipalityLabel: UILabel!
    @IBOutlet weak var selectMunicipalityLabel: UILabel!
    
    //    MARK: Private
    
    fileprivate struct Constants {
        static let cornerRadius: CGFloat = 3.0
        static let borderWidth: CGFloat = 2.0
    }
    
    fileprivate var labelsColor: UIColor!
    
    fileprivate var municipality: String? {
        return municipalityPicker.municipality?.0
    }
    
    fileprivate var selectedMunicipality: (String,String)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Appearance.customize(viewController: self)
        
        FilterDependencies.configure(view: self)
        
        configureView()
        eventHandler.viewDidLoad()
        
        setUpMunicipalityValue()
    }
    
    private func configureView() {
        configure(self.view)
        configure(municipalityPickerView)
        configure(separatorLineView)
        configure(genderBackgroundView)
        configure(myFavoriteBackgroundView)
        configure(municipalityBackgroundView)
        configure(rangeSlider)
        configure(rangeLabel)
        configure(municipalityLabel)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch segueType(for: identifier) {
        case .exitToGallery:
            presenter.backButtonPressed()
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
    
    var status: FilterFavorite = .none {
        didSet {
            
            allLabel.text = "All".localized
            myFavoriteLabel.text = "My Favorities".localized
            
            selectedAllView.layer.borderColor = UIColor.clear.cgColor
            selectedMyFavoriteView.layer.borderColor = UIColor.clear.cgColor
            
            allLabel.textColor = labelsColor
            allLabel.font = GlobalFonts.kAvenirBook
            myFavoriteLabel.textColor = labelsColor
            myFavoriteLabel.font = GlobalFonts.kAvenirBook
            
            switch status {
            case .none:
                return
            case .all:
                allLabel.textColor = GlobalColors.kBrandNavBarColor
                allLabel.font = GlobalFonts.kAvenirBold
                selectedAllView.layer.borderColor = GlobalColors.kBrandNavBarColor.cgColor
            case .myFavorite:
                myFavoriteLabel.textColor = GlobalColors.kBrandNavBarColor
                myFavoriteLabel.font = GlobalFonts.kAvenirBold
                selectedMyFavoriteView.layer.borderColor = GlobalColors.kBrandNavBarColor.cgColor
            }
        }
    }
    
    var municipalityId: String? {
        didSet {
            allMunicipalityLabel.text = "All".localized
            selectMunicipalityLabel.text = municipalityPicker.getName(for: municipalityId)
            
            selectAllMunicipalityView.layer.borderColor = UIColor.clear.cgColor
            selectMunicipalityView.layer.borderColor = UIColor.clear.cgColor
            
            allMunicipalityLabel.textColor = labelsColor
            allMunicipalityLabel.font = GlobalFonts.kAvenirBook
            selectMunicipalityLabel.textColor = labelsColor
            selectMunicipalityLabel.font = GlobalFonts.kAvenirBook
            
            if let _ = municipalityId {
                selectMunicipalityLabel.textColor = GlobalColors.kBrandNavBarColor
                selectMunicipalityLabel.font = GlobalFonts.kAvenirBold
                selectMunicipalityView.layer.borderColor = GlobalColors.kBrandNavBarColor.cgColor
            } else {
                allMunicipalityLabel.textColor = GlobalColors.kBrandNavBarColor
                allMunicipalityLabel.font = GlobalFonts.kAvenirBold
                selectAllMunicipalityView.layer.borderColor = GlobalColors.kBrandNavBarColor.cgColor
            }
        }
    }
    
    var minAge: CGFloat = 0.0 {
        didSet {
            rangeSlider.setLeftValue(minAge, rightValue: maxAge)
        }
    }
    
    var maxAge: CGFloat = 0.0 {
        didSet {
            rangeSlider.setLeftValue(minAge, rightValue: maxAge)
        }
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
            
        case municipalityPickerView:
            municipalityPicker = MunicipalityPicker(pickerView: municipalityPickerView)
            
        case genderBackgroundView:
            genderBackgroundView.layer.cornerRadius = Constants.cornerRadius
            genderBackgroundView.layer.borderWidth = Constants.borderWidth
            genderBackgroundView.layer.borderColor = UIColor.lightGray.cgColor
            
            genderControllerView = Bundle.main.loadNibNamed("GenderControllerView", owner: nil, options: nil)![0] as! GenderControllerView
            genderControllerView.frame = genderBackgroundView.bounds
            genderControllerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            genderBackgroundView.addSubview(genderControllerView)
            
        case myFavoriteBackgroundView:
            myFavoriteBackgroundView.layer.cornerRadius = Constants.cornerRadius
            myFavoriteBackgroundView.layer.borderWidth = Constants.borderWidth
            myFavoriteBackgroundView.layer.borderColor = UIColor.lightGray.cgColor
            
            let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(selectedAll(_:)))
            selectedAllView.addGestureRecognizer(tapGesture1)
            selectedAllView.layer.cornerRadius = Constants.cornerRadius
            selectedAllView.layer.borderWidth = Constants.borderWidth
            
            let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(selectedMyFavorite(_:)))
            selectedMyFavoriteView.addGestureRecognizer(tapGesture2)
            selectedMyFavoriteView.layer.cornerRadius = Constants.cornerRadius
            selectedMyFavoriteView.layer.borderWidth = Constants.borderWidth
            
        case municipalityBackgroundView:
            municipalityBackgroundView.layer.cornerRadius = Constants.cornerRadius
            municipalityBackgroundView.layer.borderWidth = Constants.borderWidth
            municipalityBackgroundView.layer.borderColor = UIColor.lightGray.cgColor
            
            let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(selectedAllMunicipalities(_:)))
            selectAllMunicipalityView.addGestureRecognizer(tapGesture1)
            selectAllMunicipalityView.layer.cornerRadius = Constants.cornerRadius
            selectAllMunicipalityView.layer.borderWidth = Constants.borderWidth
            
            let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(selectedMunicipality(_:)))
            selectMunicipalityView.addGestureRecognizer(tapGesture2)
            selectMunicipalityView.layer.cornerRadius = Constants.cornerRadius
            selectMunicipalityView.layer.borderWidth = Constants.borderWidth
            
        case rangeSlider:
            rangeSlider.backgroundColor = UIColor.clear
            rangeSlider.setMinValue(CGFloat(0), maxValue: CGFloat(100))
            rangeSlider.minimumDistance = 4
            rangeSlider.addTarget(self, action: #selector(rangeSliderValueChanged(_:)), for: .valueChanged)
            
        case rangeLabel:
            rangeLabel.text = "\(Int(rangeSlider.leftValue)) - \(Int(rangeSlider.rightValue))"
            
        case municipalityLabel:
            municipalityLabel.text = "Municipality".localized
            
        case ageLabel:
            ageLabel.text = "Age".localized
            
        default: break
        }
    }
}

// MARK: - Gender Filter

extension FiltersViewController  {
    
    @objc func selectedAll(_ gesture: UITapGestureRecognizer) {
        presenter.status = .all
    }
}

// MARK: - My Favorite Filter

extension FiltersViewController  {
    
    @objc func selectedMyFavorite(_ gesture: UITapGestureRecognizer) {
        presenter.status = .myFavorite
    }
}

// MARK: - Municipality Filter

extension FiltersViewController {
    
    fileprivate func setUpMunicipalityValue() {
        municipalityPicker.didSelectMunicipality = { municipality in
            self.selectedMunicipality = municipality
            if let municipality = municipality {
                self.selectMunicipalityLabel.text = municipality.1
                self.presenter.municipalityId = municipality.0
            }
        }
        if let municipalityId = presenter.municipalityId {
            municipalityPicker.select(municipalityId)
        }
    }
    
    @objc func selectedAllMunicipalities(_ gesture: UITapGestureRecognizer) {
        presenter.municipalityId = nil
    }
    
    @objc func selectedMunicipality(_ gesture: UITapGestureRecognizer) {
        var currentMunicipalityId: String?
        if let selectedMunicipality = self.selectedMunicipality {
            currentMunicipalityId = selectedMunicipality.0
        }
        presenter.municipalityId = currentMunicipalityId
    }
}

// MARK: - Age Filter

extension FiltersViewController  {
    
    //    MARK: Range slider
    @IBAction func rangeSliderValueChanged(_ sender: MARKRangeSlider) {
        let minAge = CGFloat(rangeSlider.leftValue)
        let maxAge = CGFloat(rangeSlider.rightValue)
        presenter.minAge = minAge
        presenter.maxAge = maxAge
        configure(rangeLabel)
    }
}

