import UIKit

class Company{
    var name: String
    var manager: ProductManager?
    var ceo: CEOCompany?
    var developer1: Developer?
    var developer2: Developer?
    
    init(ceo: CEOCompany?, manager: ProductManager?, developer1: Developer?, developer2: Developer, name: String){
        self.ceo = ceo
        self.manager = manager
        self.developer1 = developer1
        self.developer2 = developer2
        self.name = name
    }
    
    deinit {
        print("Company deinit")
    }
}

// по диаграмме этого класса нет, но и не сказано, что должно быть 1в1
class Employee{
    let name: String
    init(name: String) {
        self.name = name
    }
}

class CEOCompany: Employee {
    weak var manager: ProductManager?
    
    // решил оставить еще такой вариант, чтобы узнать, какой из вариантов более практичный, поскольку в чате ничего не уточнили
    // мне printManager2 кажется менее гибким, но более предсказуемым
    var printManager2: () -> Void { return{
            print("\(type(of: self.manager)) - \(self.manager?.name ?? "nil manager")\n")
        }
    }
    
    lazy var printManager = { [weak self] in
        print("\(type(of: self?.manager)) - \(self?.manager?.name ?? "nil manager")\n")
    }
    
    lazy var sayManagerPrintDevelopers = { [weak self] in
        self?.manager?.printAllDevelopers()
    }
    
    lazy var sayManagerPrintAllCompany = { [weak self] in
        self?.manager?.printAllEmployeesCompany()
    }
    
    deinit {
        print("CEOCompany deinit")
    }
    
    // это можно не читать, дублирует функциональность замыкания выше, но сделал на случай, если имелось ввиду, что надо все делать из этого класса. Хотя мне кажется это как-то избыточно
    var sayManagerPrintAllCompany3: () -> Void { return {
            self.manager?.doSomething = {
                print("\(type(of: self.manager?.ceo)) - \(self.manager?.ceo?.name ?? "nil ceo")")
                print("\(type(of: self.manager)) - \(self.manager?.name ?? "nil manager")")
                self.manager?.printAllDevelopers()
            }
            self.manager?.doSomething()
        }
    }
}

class ProductManager: Employee {
    var ceo: CEOCompany?
    var developer1: Developer?
    var developer2: Developer?
    
    var printAllDevelopers: () -> Void { return
        {
            print("\(type(of: self.developer1)) - \(self.developer1?.name ?? "nil dev1")")
            print("\(type(of: self.developer2)) - \(self.developer2?.name ?? "nil dev2")\n")
        }
    }
    
    var printAllEmployeesCompany: () -> Void { return
        {
            print("\(type(of: self.ceo)) - \(self.ceo?.name ?? "nil ceo")")
            print("\(type(of: self)) - \(self.name)")
            self.printAllDevelopers()
        }
    }

    func messageToDeveloper(from sender: Developer, message: String){
        if (sender === developer1) {
            print("\(self.developer2?.name ?? "nil developer2"), \(message)")
        }
        else {
            print("\(self.developer1?.name ?? "nil developer1"), \(message)")
        }
    }
    
    func messageToCEO(from sender: Developer, message: String){
        print("\(self.ceo?.name ?? "nil ceo"), \(message). From: \(sender.name)")
    }
    
    func messageToMe(from sender: Developer, message: String){
        print("\(self.name), \(message). From: \(sender.name)")
    }
    
    var doSomething: () -> Void = {}
    var deviverSomething: (Developer, String) -> Void = {_,_ in }
    
    deinit {
        print("ProductManager deinit")
    }
}

//Разработчики могут
//• Общаться между собой и искать пути, как найти другого разработчика, чтобы иметь возможность с ним пообщаться, например: “Ты ”, “Я отправил тебе pull-request”.
//• Спрашивать продукт-менеджера: “Продукт-менеджер, дай ТЗ”, “Продукт-менеджер, дай мне новую задачу"
//• Общаться с CEO: “CEO, я хочу зарплату больше"

class Developer:Employee {
    weak var manager: ProductManager?

    init(name: String, manager: ProductManager?){
        super.init(name: name)
        self.manager = manager
    }
        
    //тоже всё можно было реализовать на замыканиях, но в задании не было таких указаний, поэтому применял более читаемые функции
    func messageToCEO(message: String){
        self.manager?.messageToCEO(from: self, message: message)
    }
    
    func messageToManager(message: String){
        self.manager?.messageToMe(from: self, message: message)
    }
    
    func messageToOtherDeveloper(message: String){
        self.manager?.messageToDeveloper(from: self, message: message)
    }
    
    deinit {
        print("Developer deinit")
    }
    
    
    
    
    // а это сделал, на случай, если все-таки нужно было все делать на замыканиях,
    // дальше можно пропустить, если этого можно было и не делать
    func sayToDeveloperViaDeliver(message: String){
            self.manager?.deviverSomething = { (sender: Developer, message: String) in
                if (sender === self.manager?.developer1) {
                    print("\(self.manager?.developer2?.name ?? "nil developer2"), \(message)")
                }
                else {
                    print("\(self.manager?.developer1?.name ?? "nil developer1"), \(message)")
                }
            }
            self.manager?.deviverSomething(self, message)
    }
    
    lazy var sayManagerToDeveloperClosure = { [weak self] (message: String) in
        self!.manager?.messageToDeveloper(from: self!, message: message)
    }
}

func example(){
    let ceoHendricks = CEOCompany(name: "Richard Hendricks")
    let managerJianYang = ProductManager(name: "Jian Yang")
    let developerGilfoyle = Developer(name:"Gilfoyle", manager: managerJianYang)
    let developerDinesh = Developer(name: "Dinesh", manager: managerJianYang)

    ceoHendricks.manager = managerJianYang

    managerJianYang.developer1 = developerGilfoyle
    managerJianYang.developer2 = developerDinesh
    managerJianYang.ceo = ceoHendricks

    ceoHendricks.printManager()
    ceoHendricks.sayManagerPrintDevelopers()
    ceoHendricks.sayManagerPrintAllCompany()
    
    developerDinesh.messageToOtherDeveloper(message: "Я отправил тебе pull-request.")
    developerGilfoyle.messageToOtherDeveloper(message: "Обязательно посмотрю когда закончу все ненужные дела \n")
    developerDinesh.messageToCEO(message: "У Гилфойла зарплата больше, хочу такую же")
    developerGilfoyle.messageToCEO(message: "Сделай зарплату Динэшу меньше, я заплачу")
    developerDinesh.messageToManager(message: "Дай ТЗ")
    developerGilfoyle.messageToManager(message: "Давай мне новые задачи")
    
    let piedCompany = Company(ceo: ceoHendricks, manager: managerJianYang, developer1: developerGilfoyle, developer2: developerDinesh, name: "Pied Paper")
    print("\n\(piedCompany.name)\n")
    
    // для достоверности, что такие реализации тоже работают
    ceoHendricks.sayManagerPrintAllCompany3()
    developerGilfoyle.sayManagerToDeveloperClosure("Пример через замыкания вызывающего функцию менеджера из разработчика")
    developerDinesh.sayToDeveloperViaDeliver(message: "Пример через переопределение замыкания из разработчика")
}

example()
