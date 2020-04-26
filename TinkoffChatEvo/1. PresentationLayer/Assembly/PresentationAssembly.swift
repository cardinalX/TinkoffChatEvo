//
//  PresentationAssembly.swift
//  TinkoffChatEvo
//
//  Created by Макс Лебедев on 12.04.2020.
//  Copyright © 2020 TinkoffLebedev. All rights reserved.
//

import Foundation
import UIKit
protocol IPresentationAssembly {
  /// Создает экран со списком диалогов
  func channelListViewController() -> ChannelListViewController
  
  /// Создает экран канала с сообщениями
  func channelViewController() -> ChannelViewController
  
  /// Создает экран канала с сообщениями
  func profileViewController() -> ProfileViewController
}
/*
class PresentationAssembly: IPresentationAssembly {
  
  private let serviceAssembly: IServicesAssembly
  
  init(serviceAssembly: IServicesAssembly) {
    self.serviceAssembly = serviceAssembly
  }
  
  // MARK: - DemoViewController
  /*
  func profileViewController() -> ProfileViewController {
    let model = profileModel()
    let demoVC = DemoViewController(model: model, presentationAssembly: self)
    model.delegate = demoVC
    return demoVC
  }
  
  private func profileModel() -> IProfileModel {
    return ProfileModel(cardsService: serviceAssembly.cardsService,
                        tracksService: serviceAssembly.tracksService)
  }
  
  // MARK: - PinguinViewController
  
  func pinguinViewController() -> PinguinViewController {
    return PinguinViewController()
  }
  
  // MARK: - AnotherViewController
  //.....
 */
}

*/
