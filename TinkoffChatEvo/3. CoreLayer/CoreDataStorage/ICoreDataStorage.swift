//
//  ICoreDataStorage.swift
//  TinkoffChatEvo
//
//  Created by Макс Лебедев on 12.04.2020.
//  Copyright © 2020 TinkoffLebedev. All rights reserved.
//

import Foundation
import UIKit

protocol UserManaging {
  func updateUserProfileUI(execute: @escaping (String, String) -> Void)
  func saveUserProfile(name: String?,
                       info: String?,
                       successCompletion success: @escaping () -> Void,
                       failCompletion failure: @escaping (Error) -> Void)
  var userName: String { get }
}

protocol IUserStorage {
  
  func updateUserProfileUI(execute: @escaping (String, String) -> Void)
  func saveUserProfile(name: String?,
                       info: String?,
                       successCompletion success: @escaping () -> Void,
                       failCompletion failure: @escaping (Error) -> Void)
  var userName: String { get }
}

protocol ChannelCaching {
  func saveChannel(channelFB: ChannelFB, successCompletion success: @escaping () -> Void, failCompletion failure: @escaping (Error) -> Void)
  func fetchChannelByIdentifier(identifier: String) -> Channel?
}

protocol MessageCaching {
  func saveMessage(messageFB: MessageFB, messageId: String, parentChannelIdentifier: String, successCompletion success: @escaping () -> Void, failCompletion failure: @escaping (Error) -> Void)
  func fetchMessageByIdentifier(identifier: String) -> Message?
}
