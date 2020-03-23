//
//  GCDDataManager.swift
//  TinkoffChatEvo
//
//  Created by Макс Лебедев on 14.03.2020.
//  Copyright © 2020 TinkoffLebedev. All rights reserved.
//

import Foundation

class GCDDataManager {

  let qualityOfService: DispatchQoS
  let label: String
  let queue: DispatchQueue
  var errors: [Error] = []
  let writersGroup = DispatchGroup()
  
  init (label: String = "common", qualityOfService: DispatchQoS = .userInitiated) {
    self.label = label
    self.qualityOfService = qualityOfService
    queue = DispatchQueue(label: "com.TinkoffChatApp.\(label)", qos: qualityOfService, attributes: .concurrent)
  }
  
  func saveAndLoadData(from data: String,
                       fileName: String,
                       successWriteCompletion success: @escaping () -> Void,
                       failWriteCompletion failure: @escaping (Error) -> Void,
                       readCompletion completion: @escaping (String) -> Void){
    addWriterTask(from: data, fileName: fileName, success: success, failure: failure)
    addReaderTask(fileName: fileName, execute: completion)
  }

  func addReaderTask(fileName: String, execute completion: @escaping (String) -> Void) {
    queue.async {
      guard let data = self.readFile(fileName: fileName) else { return }
      
      DispatchQueue.main.async {
        completion(data)
      }
    }
  }
  
  func addWriterTask(from data: String,
                     fileName: String,
                     success: @escaping () -> Void,
                     failure: @escaping (Error) -> Void) {
    queue.async(flags: .barrier) {
      if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        let fileURL = directory.appendingPathComponent(fileName)
        
        do {
          try data.write(to: fileURL, atomically: false, encoding: .utf8)
        }
        catch let error {
          self.errors.append(error)
          print("Couldn't write to file \(fileName) because of error: \(error)")
        }
      }
    }
    
    
    writersGroup.notify(queue: DispatchQueue.main){
      if self.errors.isEmpty {
        success()
      } else { failure(self.errors[0]) }
    }
  }
  
  // MARK: FileManagement
  
  private func readFile(fileName: String) -> String?{
    
    if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
      let fileURL = directory.appendingPathComponent(fileName)
      if !FileManager().fileExists(atPath: fileURL.path) {
        print("File not exists")
        return ""
      }
      
      do {
        let contentsOfFile = try String(contentsOf: fileURL, encoding: .utf8)
        print("Content of the file <<\(fileName)>> is: \(contentsOfFile)")
        return contentsOfFile
      }
      catch let error {
        print("There is an file reading error: \(error)")
      }
    }
    return nil
  }
}
