//
//  PresentationAssembly.swift
//  TinkoffChatEvo
//
//  Created by Макс Лебедев on 12.04.2020.
//  Copyright © 2020 TinkoffLebedev. All rights reserved.
//

import Foundation
import UIKit
protocol IPresentationAssembly {/*
    /// Создает экран со списком диалогов
    func conversationsListViewController() -> ChannelsListViewController
    
    /// Создает экран где бегают пингвинчики
    func pinguinViewController() -> PinguinViewController
}

class PresentationAssembly: IPresentationAssembly {
    
    private let serviceAssembly: IServicesAssembly
    
    init(serviceAssembly: IServicesAssembly) {
        self.serviceAssembly = serviceAssembly
    }
    
    // MARK: - DemoViewController
    
    func demoViewCotnroller() -> DemoViewController {
        let model = demoModel()
        let demoVC = DemoViewController(model: model, presentationAssembly: self)
        model.delegate = demoVC
        return demoVC
    }
    
    private func demoModel() -> IDemoModel {
        return DemoModel(cardsService: serviceAssembly.cardsService,
                         tracksService: serviceAssembly.tracksService)
    }
    
    // MARK: - PinguinViewController
    
    func pinguinViewController() -> PinguinViewController {
        return PinguinViewController()
    }
    
    // MARK: - AnotherViewController
    //.....*/
}

