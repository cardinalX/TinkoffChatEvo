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
  
  func saveAndLoadData(from data: [String],
                            fileNames: [String],
                            successWriteCompletion success: @escaping () -> Void,
                            failWriteCompletion failure: @escaping (Error) -> Void,
                            completion: @escaping ([String],[String]) -> Void){
    for (index, data) in data.enumerated(){
      addWriterTask(from: data, fileName: fileNames[index], success: success, failure: failure)
    }
    writersGroup.notify(queue: DispatchQueue.main){
      if self.errors.isEmpty {
        success()
      } else { failure(self.errors[0]) }
    }
    for fileName in fileNames{
      addReaderTask(fileName: fileName, execute: {_ in})
    }
    DispatchQueue.main.async {
      completion(data, fileNames)
    }
    
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
    /*queue.async(flags: .barrier) {
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
    }*/
    
    if (fileName == "description"){
      queue.async(group: writersGroup, flags: .barrier) {
        sleep(1)
        //self.writeFile(data: data, fileName: fileName)
        if FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first != nil {
          do {
            throw MyError.runtimeError("MYERRRPR message")
          } catch let error {
            print("Couldn't write to file <<\(fileName)>> because of error: \(error)")
            self.errors.append(error)/*
            DispatchQueue.main.async {
              failure(error)
            }*/
          }
        }
      }
    }
    else {
      queue.async(group: writersGroup, flags: .barrier) {
        sleep(1)
        //self.writeFile(data: data, fileName: fileName)
        if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
          let fileURL = directory.appendingPathComponent(fileName)
          
          do {
            try data.write(to: fileURL, atomically: false, encoding: .utf8)
            print("Write to file <<\(fileName)>> complete")
            /*DispatchQueue.main.async {
              success()
            }*/
          }
          catch let error {
            print("Couldn't write to file <<\(fileName)>> because of error: \(error)")
            self.errors.append(error)
            /*DispatchQueue.main.async {
              failure(error)
            }*/
          }
        }
      }
    }
    
    /*writersGroup.notify(queue: DispatchQueue.main){
      if self.errors.isEmpty {
        success()
      } else { failure(self.errors[0]) }
    }*/
  }
  
  enum MyError: Error {
      case runtimeError(String)
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
