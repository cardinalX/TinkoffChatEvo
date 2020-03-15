//
//  ViewController.swift
//  TinkoffChatEvo
//
//  Created by max on 14/02/2020.
//  Copyright © 2020 TinkoffLebedev. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
  
  // MARK: UI Outlets
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var cameraButton: UIButton!
  @IBOutlet weak var nameProfileLabel: UILabel!
  @IBOutlet weak var descriptionProfileLabel: UILabel!
  @IBOutlet weak var editButton: UIButton!
  @IBOutlet weak var saveGCDButton: UIButton!
  @IBOutlet weak var saveOperationButton: UIButton!
  @IBOutlet weak var nameProfileTextField: UITextField!
  @IBOutlet weak var descriptionProfileTextView: UITextView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  required public init?(coder: NSCoder) {
    super.init(coder: coder)
    print("editButton in", #function, editButton?.frame as Any) /// Фрейма пока нет, получим nil
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    nameProfileTextField.delegate = self
    descriptionProfileTextView.delegate = self
    addDoneButtonOnKeyboard()
    print(editButton.frame)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    // Application moved from <Dissapeared> to <Appearing>:
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    print(editButton.frame)
    // Геометрия (границы) в viewDidLoad еще не установлены, поэтому там нельзя (криво работает) обрабатывать значения геометрии
    // Application moved from <Appearing> to <Appeared>
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    cameraButton.layer.cornerRadius = cameraButton.frame.size.width / 2
    avatarImageView.layer.cornerRadius = cameraButton.layer.cornerRadius
    editButton.layer.borderWidth = 2.0
    editButton.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    editButton.layer.cornerRadius = 15
    
    descriptionProfileTextView.layer.borderWidth = 1.0
    descriptionProfileTextView.layer.cornerRadius = 8
    descriptionProfileTextView.layer.borderColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
    
    saveGCDButton.layer.borderWidth = 2.0
    saveGCDButton.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    saveGCDButton.layer.cornerRadius = 10
    
    saveOperationButton.layer.borderWidth = 2.0
    saveOperationButton.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    saveOperationButton.layer.cornerRadius = 10
    // попробовать заменить на IBDesignable/IBInspectable
    // Application moved from <Autolayouting> to <Autolayouted>
  }
  
  func addDoneButtonOnKeyboard() {
      let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
      doneToolbar.barStyle = .default

      let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
      let done: UIBarButtonItem = UIBarButtonItem(title: "Done",
                                                  style: .done,
                                                  target: self,
                                                  action: #selector(doneButtonAction))

      let items = [flexSpace, done]
      doneToolbar.items = items
      doneToolbar.sizeToFit()

      descriptionProfileTextView.inputAccessoryView = doneToolbar
  }
  
  private func updateUIUneditable(){
    nameProfileLabel.isHidden = false
    editButton.isHidden = false
    descriptionProfileLabel.isHidden = false
    saveGCDButton.isHidden = true
    saveOperationButton.isHidden = true
    nameProfileTextField.isHidden = true
    descriptionProfileTextView.isHidden = true
  }

  @objc func doneButtonAction() {
      descriptionProfileTextView.resignFirstResponder()
  }
  
  // MARK: IBAction
  
  @IBAction func addImageCameraButton(_ sender: Any) {
    print("Выбери изображение профиля")
    
    let alert = UIAlertController(title: "Добавление фото профиля", message: "Выберете способ добавления", preferredStyle: .actionSheet)
    
    alert.addAction(UIAlertAction(title: "Установить из галлереи", style: UIAlertAction.Style.default) { (action: UIAlertAction) -> Void in
    })
    
    alert.addAction(UIAlertAction(title: "Сделать фото", style: UIAlertAction.Style.default) { (action: UIAlertAction) -> Void in
    })
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (sender: UIAlertAction) -> Void in
    })
    
    self.present(alert, animated: true, completion: nil)
  }
  
  @IBAction func editProfile(_ sender: Any) {
    editButton.isHidden = true
    descriptionProfileLabel.isHidden = true
    saveGCDButton.isHidden = false
    saveOperationButton.isHidden = false
    nameProfileTextField.isHidden = false
    descriptionProfileTextView.isHidden = false
    
  }
  
  @IBAction func done(_ sender: UITextField) {
    //sender.resignFirstResponder()
    self.view.endEditing(true);
  }
  
  @IBAction func gcdSaveInfo(_ sender: Any) {
    let nameProfileDataManager = GCDDataManager(fileName: "name.txt")
    activityIndicator.startAnimating()
    nameProfileDataManager.saveData(from: nameProfileTextField.text ?? "") {
      data in
      self.nameProfileLabel.text = data
    }
    
    let descriptionProfileDataManager = GCDDataManager(fileName: "description.txt")
    descriptionProfileDataManager.saveData(from: descriptionProfileTextView.text ?? "") {
      data in
      self.descriptionProfileLabel.text = data
      self.activityIndicator.stopAnimating()
      self.updateUIUneditable()
    }
    
  }
  
  @IBAction func operationSaveInfo(_ sender: Any) {
    
  }
  
}

// MARK: extensions Text*Delegate
extension ProfileViewController: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard
      let textFieldText = textField.text,
      let rangeOfTextToReplace = Range(range, in: textFieldText)
      else {
            return false
    }
    let substringToReplace = textFieldText[rangeOfTextToReplace]
    let count = textFieldText.count - substringToReplace.count + string.count
    return count <= 30
  }
  
}

extension ProfileViewController: UITextViewDelegate {
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    
      let currentText = textView.text ?? ""
      guard let stringRange = Range(range, in: currentText) else { return false }

      let updatedText = currentText.replacingCharacters(in: stringRange, with: text)

      return updatedText.count <= 1000
  }
}
