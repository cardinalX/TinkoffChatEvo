//
//  GCDDataManager.swift
//  TinkoffChatEvo
//
//  Created by Макс Лебедев on 14.03.2020.
//  Copyright © 2020 TinkoffLebedev. All rights reserved.
//

import Foundation

class GCDDataManager {

  let queue: DispatchQueue
  var errors: [Error] = []
  let writersGroup = DispatchGroup()
  let readersGroup = DispatchGroup()
  
  init (label: String = "common", qualityOfService: DispatchQoS = .userInitiated) {
    queue = DispatchQueue(label: "com.TinkoffChatApp.\(label)", qos: qualityOfService, attributes: .concurrent)
  }
  
  //Для записи и обновления массивов данных
  func saveAndLoadDataArr(from data: [String],
                          fileNames: [String],
                          successWriteCompletion success: @escaping () -> Void,
                          failWriteCompletion failure: @escaping (Error) -> Void,
                          updateUICompletion: @escaping ([String],[String]) -> Void) {
    for (index, data) in data.enumerated(){
      addWriterTask(from: data, fileName: fileNames[index], success: success, failure: failure)
    }
    writersGroup.notify(queue: DispatchQueue.main){
      if (self.errors.isEmpty) {
        success()
      } else { failure(self.errors[0]) }
    }
    for fileName in fileNames{
      addReaderTask(fileName: fileName, execute: {_ in})
    }
    readersGroup.notify(queue: DispatchQueue.main){
      if (self.errors.isEmpty) {
          updateUICompletion(data, fileNames)
      }
    }
  }
  
  ///Для одиночных добавления задач записи и чтения
  func saveAndLoadData(from data: String,
                       fileName: String,
                       completion: @escaping (String) -> Void) {
    addWriterTask(from: data, fileName: fileName, success: {}, failure: {_ in })
    addReaderTask(fileName: fileName, execute: completion)
  }
  
  ///Синхронизирует процессы записи и по завершении выполняет соотвествующий успеху или неудачи closure
  func writersGroupCompletion(successWriteCompletion success: @escaping () -> Void,
                       failWriteCompletion failure: @escaping (Error) -> Void) {
    writersGroup.notify(queue: DispatchQueue.main){
      if self.errors.isEmpty {
        success()
      } else { failure(self.errors[0]) }
    }
  }
  
  func addReaderTask(fileName: String, execute completion: @escaping (String) -> Void) {
    queue.async(group: readersGroup) {
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
    queue.async(group: writersGroup, flags: [.barrier, .enforceQoS]) {
      if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        let fileURL = directory.appendingPathComponent(fileName)

        do {
          try data.write(to: fileURL, atomically: false, encoding: .utf8)
          print("Write to file <<\(fileName)>> complete")
        }
        catch let error {
          self.errors.append(error)
          print("Couldn't write to file \(fileName) because of error: \(error)")
        }
      }
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
