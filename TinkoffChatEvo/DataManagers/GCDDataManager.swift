//
//  GCDDataManager.swift
//  TinkoffChatEvo
//
//  Created by Макс Лебедев on 14.03.2020.
//  Copyright © 2020 TinkoffLebedev. All rights reserved.
//

import UIKit

enum dataType {
  case fi
}

class GCDDataManager {
  let fileName: String
  
  init (fileName: String) {
    self.fileName = fileName
  }
  
  func saveData(from data: String, execute work: @escaping @convention(block) (String) -> Void){
    writeData(from: data)
    readData(execute: work)
  }
  
  func readData(execute work: @escaping @convention(block) (String) -> Void) {
    let queue = DispatchQueue.global(qos: .utility)
    queue.async{
      guard let data = self.readFile() else { return }
      DispatchQueue.main.async {
        work(data)
      }
    }
  }
  
  func writeData(from data: String) {
    let queue = DispatchQueue.global(qos: .utility)
    queue.sync{
      self.writeFile(data: data)
    }
  }
  
  /*
  //: ### Загрузка изображения с помощью асинхронной обертки синхронной операции
  func fetchImage3(fileName: String) {
    asyncLoadText(fileName: fileName,
                  runQueue: DispatchQueue.global(),
                  completionQueue: DispatchQueue.main)
    { result, error in
      guard let image = result else {return}
      eiffelImage.image = image
    }
  }*/
  
  // MARK: FileManagement
  
  private func writeFile(data: String) {
    if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
      let fileURL = directory.appendingPathComponent(fileName)
      
      do {
        try data.write(to: fileURL, atomically: false, encoding: .utf8)
      }
      catch let error {
        print("Couldn't write to file \(fileName) because of error: \(error)")
      }
    }
  }
  
  private func readFile() -> String?{
    sleep(2)
    if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
      let fileURL = directory.appendingPathComponent(fileName)
      if !FileManager().fileExists(atPath: fileURL.path) {
        print("File not exists")
        return ""
      }
      
      do {
        let contentsOfFile = try String(contentsOf: fileURL, encoding: .utf8)
        print("Content of the file \(fileName) is: \(contentsOfFile)")
        return contentsOfFile
      }
      catch let error {
        print("There is an file reading error: \(error)")
      }
    }
    return nil
  }
}
