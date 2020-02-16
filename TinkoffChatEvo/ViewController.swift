//
//  ViewController.swift
//  TinkoffChatEvo
//
//  Created by max on 14/02/2020.
//  Copyright © 2020 TinkoffLebedev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Log.printMessage(message: "Application moved from <Dissapeared> to <Appearing>: \(#function)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Log.printMessage(message: "Application moved from <Appearing> to <Appeared>: \(#function)")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        Log.printMessage(message: "Application moved from <Autolayouted> to <Autolayouting>: \(#function)")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        Log.printMessage(message: "Application moved from <Autolayouting> to <Autolayouted>: \(#function)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Log.printMessage(message: "Application moved from <Appeared> to <Disappearing>: \(#function)")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Log.printMessage(message: "Application moved from <Disappearing> to <Disappeared>: \(#function)")
    }
}

