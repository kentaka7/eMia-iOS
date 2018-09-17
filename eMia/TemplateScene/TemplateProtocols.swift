//
//  TemplateProtocols.swift
//  eMia
//
//  Created Sergey Krotkih on 04/09/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//
//  Template generated by Juanpe Catalán @JuanpeCMiOS
//

import Foundation

//MARK: Wireframe -
protocol TemplateWireframeProtocol: class {

}
//MARK: Presenter -
protocol TemplatePresenterProtocol: class {

    var interactor: TemplateInteractorInputProtocol? { get set }
}

//MARK: Interactor -
protocol TemplateInteractorOutputProtocol: class {

    /* Interactor -> Presenter */
}

protocol TemplateInteractorInputProtocol: class {

    var presenter: TemplateInteractorOutputProtocol?  { get set }

    /* Presenter -> Interactor */
}

//MARK: View -
protocol TemplateViewProtocol: class {

    var presenter: TemplatePresenterProtocol?  { get set }

    /* Presenter -> ViewController */
}
