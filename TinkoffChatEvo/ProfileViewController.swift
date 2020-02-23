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
    @IBOutlet weak var nameProfile: UILabel!
    @IBOutlet weak var descriptonProfile: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        print("editButton in", #function, editButton?.frame as Any) /// Фрейма пока нет, получим nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraButton.imageEdgeInsets = UIEdgeInsets(top: 20,left: 20,bottom: 20,right: 20)
        print(editButton.frame)
        editButton.layer.borderWidth = 2.0
        editButton.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        descriptonProfile.text = """
        👨‍💻 Хочу научится прогать под iOS
        🧠 Работать с новым технологиями
        👩‍🚀 Wubba Lubba Dub Dub!
        👨‍💻 Хочу научится прогать под iOS
        🧠 Работать с новым технологиями
        👩‍🚀 Wubba Lubba Dub Dub!
        👨‍💻 Хочу научится прогать под iOS
        🧠 Работать с новым технологиями
        👩‍🚀 Wubba Lubba Dub Dub!
        👨‍💻 Хочу научится прогать под iOS
        🧠 Работать с новым технологиями
        👩‍🚀 Wubba Lubba Dub Dub!
        """
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
        editButton.layer.cornerRadius = 15
        // editButton.clipsToBounds = true
        
        // try to replace with IBDesignable/IBInspectable
        // Application moved from <Autolayouting> to <Autolayouted>
    }
    
    // MARK: IBAction
    
    @IBAction func addImageCameraButton(_ sender: Any) {
        print("Выбери изображение профиля")
        
        let alert = UIAlertController(title: "Добавление фото профиля", message: "Выберете способ добавления", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Установить из галлереи", style: UIAlertAction.Style.default) { (action: UIAlertAction) -> Void in
            
        })
        
        alert.addAction(UIAlertAction(title: "Сделать фото", style: UIAlertAction.Style.default) { (action: UIAlertAction) -> Void in
            
            /*
            let camera = CameraViewController()
            self.setBackground(vc: camera)
            let viewController = storyboard?.instantiateViewController(withIdentifier: "MainMenu") as! UIViewController
            self.present(viewController, animated: true)
             */
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (sender: UIAlertAction) -> Void in
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private let backgroundViewContainer = UIView()
    
    public func setBackground(vc: UIViewController) {

        // Setting background only first time
        if backgroundViewContainer.subviews.count > 0 {
            return
        }

        addChild(vc)
        backgroundViewContainer.addSubview(vc.view)

        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.topAnchor.constraint(equalTo: backgroundViewContainer.topAnchor).isActive = true
        vc.view.bottomAnchor.constraint(equalTo: backgroundViewContainer.bottomAnchor).isActive = true
        vc.view.leadingAnchor.constraint(equalTo: backgroundViewContainer.leadingAnchor).isActive = true
        vc.view.trailingAnchor.constraint(equalTo: backgroundViewContainer.trailingAnchor).isActive = true

        vc.didMove(toParent: self)

    }
        
}

