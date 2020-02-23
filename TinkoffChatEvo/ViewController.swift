//
//  ViewController.swift
//  TinkoffChatEvo
//
//  Created by max on 14/02/2020.
//  Copyright © 2020 TinkoffLebedev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
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
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Application moved from <Dissapeared> to <Appearing>:
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(editButton.frame)
        //Геометрия (границы) в viewDidLoad еще не установлены, поэтому там нельзя (криво работает) обрабатывать значения геометрии
        // Application moved from <Appearing> to <Appeared>
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
       // Application moved from <Autolayouted> to <Autolayouting>
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        cameraButton.layer.cornerRadius = cameraButton.frame.size.width / 2
        avatarImageView.layer.cornerRadius = cameraButton.layer.cornerRadius
        editButton.layer.cornerRadius = 15
        // editButton.clipsToBounds = true
        // попробовать IBDesignable/IBInspectable
        // Application moved from <Autolayouting> to <Autolayouted>
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Application moved from <Appeared> to <Disappearing>
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Application moved from <Disappearing> to <Disappeared>
    }
    
    // MARK: IBAction
    
    @IBAction func addImageCameraButton(_ sender: Any) {
        print("Выбери изображение профиля")
    }
    
}

