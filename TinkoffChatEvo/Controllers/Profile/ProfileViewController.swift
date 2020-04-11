//
//  ViewController.swift
//  TinkoffChatEvo
//
//  Created by max on 14/02/2020.
//  Copyright © 2020 TinkoffLebedev. All rights reserved.
//

import UIKit
import CoreData

class ProfileViewController: UIViewController {
  
  // MARK: UI Outlets
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var cameraButton: UIButton!
  @IBOutlet weak var nameProfileLabel: UILabel!
  @IBOutlet weak var descriptionProfileLabel: UILabel!
  @IBOutlet weak var editButton: UIButton!
  @IBOutlet weak var saveButton: UIButton!
  @IBOutlet weak var nameProfileTextField: UITextField!
  @IBOutlet weak var descriptionProfileTextView: UITextView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  required public init?(coder: NSCoder) {
    super.init(coder: coder)
    print("editButton in", #function, editButton?.frame as Any) /// Фрейма пока нет, получим nil
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadProfileData()
    nameProfileTextField.delegate = self
    descriptionProfileTextView.delegate = self
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardWillShow),
                                           name: UIResponder.keyboardWillShowNotification,
                                           object: self.view.window)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardWillHide),
                                           name: UIResponder.keyboardWillHideNotification,
                                           object: self.view.window)
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
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self.view.window)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self.view.window)
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
    
    saveButton.layer.borderWidth = 2.0
    saveButton.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    saveButton.layer.cornerRadius = 10
    
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
                                                action: #selector(keyboardWillHide))
    
    doneToolbar.items = [flexSpace, done]
    doneToolbar.sizeToFit()
    
    descriptionProfileTextView.inputAccessoryView = doneToolbar
  }
  
  @objc func keyboardWillHide() {
    if self.view.frame.origin.y != 0 {
      self.view.frame.origin.y = 0
    }
    descriptionProfileTextView.resignFirstResponder()
  }
  
  @objc func keyboardWillShow(notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
      if self.view.frame.origin.y == 0 {
        self.view.frame.origin.y -= keyboardSize.height
      }
    }
  }
  
  var retryAlert: (Error) -> Void { return{ error in
    self.activityIndicator.stopAnimating()
    let alert = UIAlertController(title: "Ошибка при сохранении данных: \(error)", message: "Выберите действие", preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "Ок", style: .default) { (action: UIAlertAction) -> Void in })
    alert.addAction(UIAlertAction(title: "Повторить", style: .default) { (action: UIAlertAction) -> Void in self.saveButtonPressed(self)})
    self.present(alert, animated: true, completion: nil)
    }
  }
  
  var successAlert: () -> Void {
    return {
      DispatchQueue.main.async{
        self.activityIndicator.stopAnimating()
        let alert = UIAlertController(title: "Успех",
                                      message: "Данные успешно сохранены",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default) { (action: UIAlertAction) -> Void in })
        self.present(alert, animated: true, completion: nil)
      }
      self.loadProfileData()
    }
  }
  
  func loadProfileData(){
    StorageManager.instance.updateUserProfileUI { name, info in
      DispatchQueue.main.async {
        self.nameProfileLabel.text = name
        self.descriptionProfileLabel.text = info
      }
    }
  }
  
  func switchUIToUneditableMode(){
    nameProfileLabel.isHidden = false
    editButton.isHidden = false
    descriptionProfileLabel.isHidden = false
    saveButton.isHidden = true
    nameProfileTextField.isHidden = true
    descriptionProfileTextView.isHidden = true
  }
  
  // MARK: IBAction
  
  @IBAction func addImageCameraButtonPressed(_ sender: Any) {
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
  
  @IBAction func editProfileButtonPressed(_ sender: Any) {
    nameProfileTextField.text = nameProfileLabel.text
    descriptionProfileTextView.text = descriptionProfileLabel.text
    editButton.isHidden = true
    descriptionProfileLabel.isHidden = true
    saveButton.isHidden = false
    nameProfileTextField.isHidden = false
    descriptionProfileTextView.isHidden = false
  }
  
  @IBAction func doneButtonOnKeyboardPressed(_ sender: UITextField) {
    //sender.resignFirstResponder()
    self.view.endEditing(true)
  }
  
  // MARK: saveButtons
  
  @IBAction func saveButtonPressed(_ sender: Any) {
    descriptionProfileTextView.resignFirstResponder()
    nameProfileTextField.resignFirstResponder()

    if (nameProfileTextField.text != nameProfileLabel.text) {
      if let name = nameProfileTextField.text {
        print("\(name) = nameProfileTextField.text")
        StorageManager.instance.saveUserProfile(name: name, info: nil, successCompletion: successAlert, failCompletion: retryAlert)
      }
    }
    if (descriptionProfileTextView.text != descriptionProfileLabel.text) {
      if let descriptionProfile = descriptionProfileTextView.text {
        print("\(descriptionProfile) = descriptionProfile.text")
        StorageManager.instance.saveUserProfile(name: nil, info: descriptionProfile, successCompletion: successAlert, failCompletion: retryAlert)
      }
    }
    self.switchUIToUneditableMode()
  }
}

// MARK: extension TextFieldDelegate

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
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    if (textField == nameProfileTextField){
      if (textField.text != nameProfileLabel.text) {
        saveButton.isEnabled = true
      } else {
        saveButton.isEnabled = false
      }
    }
  }
  
  
}

// MARK: extension TextViewDelegate

extension ProfileViewController: UITextViewDelegate {
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    
    let currentText = textView.text ?? ""
    guard let stringRange = Range(range, in: currentText) else { return false }
    
    let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
    
    return updatedText.count <= 1000
  }
  
  func textViewDidChange(_ textView: UITextView) {
    if (textView == descriptionProfileTextView) {
      if (textView.text != descriptionProfileLabel.text) {
        saveButton.isEnabled = true
      } else {
        saveButton.isEnabled = false
      }
    }
  }
}
