//
//  ConversationsListViewController.swift
//  TinkoffChatEvo
//
//  Created by Макс Лебедев on 28.02.2020.
//  Copyright © 2020 TinkoffLebedev. All rights reserved.
//

import UIKit

class ConversationsListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Tinkoff Chat"
        view.backgroundColor = UIColor(named: "TinkoffColor")
        self.navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barTintColor = UIColor(named: "TinkoffColor")
        //self.navigationController?.navigationBar.
        
        tableView.register(UINib(nibName: String(describing: ConversationCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: ConversationCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        
        sortedData = sortData(filter: data)
        /*print(sortedData[.history]?.count)
        print(sortedData[.online]?.count)*/
        
        /*sortedData2 = sortData2()
        print(type(of: sortedData2))
        print(sortedData2[0])*/
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    // MARK: - DATA
    var data =
        [ConversationCell.ConversationCellModel(name: "Олег Тиньков",
                                                message: "Привет, вот какой-нибудь набросоук текст последнего сообщения в диалоге",
                                                date: Date(),
                                                isOnline: true,
                                                hasUnreadMessages: true),
         ConversationCell.ConversationCellModel(name: "Vladimir Nabokov с очень длинным именем и фамилией",
                                                message: nil,
                                                date: Date().addingTimeInterval(3600*70),
                                                isOnline: true,
                                                hasUnreadMessages: true),
         ConversationCell.ConversationCellModel(name: "Kurilka Gutenberga777",
                                                message: nil,
                                                date: Date().addingTimeInterval(3600*12),
                                                isOnline: true,
                                                hasUnreadMessages: false),
         ConversationCell.ConversationCellModel(name: "Илон Маск",
                                                message: "ПУстой месседж - не нил",
                                                date: Date().addingTimeInterval(-3600*100),
                                                isOnline: true,
                                                hasUnreadMessages: false),
         ConversationCell.ConversationCellModel(name: "Keegan-Michael Key",
                                                message: nil,
                                                date: Date().addingTimeInterval(-3600*2),
                                                isOnline: true,
                                                hasUnreadMessages: true),
         ConversationCell.ConversationCellModel(name: "Mary Elizabeth Winstead",
                                                message: nil,
                                                date: Date().addingTimeInterval(-3600*5),
                                                isOnline: true,
                                                hasUnreadMessages: false),
         ConversationCell.ConversationCellModel(name: "Инфузория туфелька",
                                                message: "Chris Pine, Zachary Quinto, Zoe Saldaßna",
                                                date: Date().addingTimeInterval(-3600*100),
                                                isOnline: true,
                                                hasUnreadMessages: false),
         ConversationCell.ConversationCellModel(name: "Армия клонов",
                                                message: nil,
                                                date: Date().addingTimeInterval(-3600*2),
                                                isOnline: true,
                                                hasUnreadMessages: true),
         ConversationCell.ConversationCellModel(name: "Бот Олег",
                                                message: nil,
                                                date: Date().addingTimeInterval(-3600*5),
                                                isOnline: true,
                                                hasUnreadMessages: false),
         ConversationCell.ConversationCellModel(name: "Дмитрий Клюшкин",
                                                message: "Привет, последнего вот сообщения диалоге какой-нибудь набросоук текст последнего",
                                                date: Date(),
                                                isOnline: true,
                                                hasUnreadMessages: true),
         ConversationCell.ConversationCellModel(name: "Армен Джигарханян",
                                                message: "",
                                                date: Date().addingTimeInterval(3600*70),
                                                isOnline: true,
                                                hasUnreadMessages: true),
         ConversationCell.ConversationCellModel(name: "Дарья Фамилия",
                                                message: "Miracles from Heaven",
                                                date: Date().addingTimeInterval(3600*12),
                                                isOnline: true,
                                                hasUnreadMessages: true),
         // section history
         ConversationCell.ConversationCellModel(name: "Кирилл Животворящий",
                                                message: "Zachary Quinto, Zoe Saldana",
                                                date: Date().addingTimeInterval(-3600*24),
                                                isOnline: false,
                                                hasUnreadMessages: false),
         ConversationCell.ConversationCellModel(name: "Анастасия Бу",
                                                message: "",
                                                date: Date().addingTimeInterval(-3600*10),
                                                isOnline: false,
                                                hasUnreadMessages: false),
         ConversationCell.ConversationCellModel(name: "Бот Дмитрий Валерьева",
                                                message: "Привет, последнего вот сообщения диалоге какой-нибудь набросоук текст последнего",
                                                date: Date().addingTimeInterval(-3600*80),
                                                isOnline: false,
                                                hasUnreadMessages: true),
         ConversationCell.ConversationCellModel(name: "Виктор Гюго",
                                                message: nil,
                                                date: Date().addingTimeInterval(-3600*30),
                                                isOnline: false,
                                                hasUnreadMessages: false),
         ConversationCell.ConversationCellModel(name: "Дмитрий ТеракотовВиновLongNamedUserЛалала",
                                                message: "Zachary Quinto, Zoe Saldana",
                                                date: Date().addingTimeInterval(-3600*24),
                                                isOnline: false,
                                                hasUnreadMessages: false),
         ConversationCell.ConversationCellModel(name: "Chris Pine",
                                                message: nil,
                                                date: Date().addingTimeInterval(-3600*10),
                                                isOnline: false,
                                                hasUnreadMessages: false),
         ConversationCell.ConversationCellModel(name: "8-999-246-xx-xx",
                                                message: "Если есть непрочитанные сообщения — текст последнего сообщения отображается жирным.",
                                                date: Date().addingTimeInterval(-3600),
                                                isOnline: false,
                                                hasUnreadMessages: true),
         ConversationCell.ConversationCellModel(name: "Анастасия Валерьева",
                                                message: nil,
                                                date: Date().addingTimeInterval(-3600*80),
                                                isOnline: false,
                                                hasUnreadMessages: true),
         ConversationCell.ConversationCellModel(name: "Виктор Гюго",
                                                message: nil,
                                                date: Date().addingTimeInterval(-3600*30),
                                                isOnline: false,
                                                hasUnreadMessages: false),
         ConversationCell.ConversationCellModel(name: "Jennifer Garner",
                                                message: "Если есть непрочитанные сообщения — текст последнего сообщения отображается жирным.",
                                                date: Date().addingTimeInterval(-3600),
                                                isOnline: false,
                                                hasUnreadMessages: true),
    ]
    
    // Data variable to track our sorted data
    enum TableSection: Int {
        case online = 0, history, total
    }
    var sortedData = [TableSection: [ConversationCell.ConversationCellModel]]()
    
    func sortData(filter arrayData: [ConversationCell.ConversationCellModel]) -> [TableSection: [ConversationCell.ConversationCellModel]]{
        sortedData[.history] = arrayData.filter({$0.isOnline == false})
        sortedData[.online] = arrayData.filter({$0.isOnline == true})
        return sortedData
    }

}

// MARK: - protocol ConfigurableView
protocol ConfigurableView {
    associatedtype ConfigurationModel
    
    func configure(with model: ConfigurationModel)
}

// MARK: - Extension UITableViewDataSource

extension ConversationsListViewController: UITableViewDataSource{
    
    // MARK: Configurate Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = String(describing: ConversationCell.self)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ConversationCell
            else { return UITableViewCell() }
        
        if  let tableSection = TableSection(rawValue: indexPath.section),
            let dialog = sortedData[tableSection]?[indexPath.row] {
                cell.configure(with: dialog)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        /*if (section == 0) { return "Online" }
        else { return "History" }*/
        switch TableSection(rawValue: section) {
        case .online:
            return "Online"
        default:
            return "History"
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return TableSection.total.rawValue
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tableSection = TableSection(rawValue: section),
           let dataBySection = sortedData[tableSection] {
            return dataBySection.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let conversationViewController = ConversationViewController()
        
        if  let tableSection = TableSection(rawValue: indexPath.section){
            conversationViewController.setTitleController(dialog: sortedData[tableSection]?[indexPath.row].name ?? "Название диалога")
        }
        
        //sortedData[tableSection]?[indexPath.row]
        /*
        let identifier = String(describing: ConversationCell.self)
        let cell = tableView.cellForRow(at: indexPath) as? ConversationCell
        //guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ConversationCell
        if  let tableSection = TableSection(rawValue: indexPath.section),
            let dialog = sortedData[tableSection]?[indexPath.row] {
            
        }*/
        
        navigationController?.pushViewController(conversationViewController, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
}

// MARK: - Extension UITableViewDelegate

extension ConversationsListViewController: UITableViewDelegate{
    
}
