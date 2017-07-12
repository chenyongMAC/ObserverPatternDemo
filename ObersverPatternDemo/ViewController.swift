//
//  ViewController.swift
//  ObersverPatternDemo
//
//  Created by ucmed on 2017/7/12.
//  Copyright © 2017年 ucmed. All rights reserved.
//

import UIKit

class McyCustomNotification: NSObject {
    let name: String
    let object: AnyObject?
    let userInfo: [String : AnyObject]?
    
    init(name: String, object: AnyObject?, userInfo: [String : AnyObject]?) {
        self.name = name
        self.object = object
        self.userInfo = userInfo
    }
}

class McyObserver: NSObject {
    let observer: AnyObject
    let selector: Selector
    
    init(observer: AnyObject, selector: Selector) {
        self.observer = observer
        self.selector = selector
    }
}

typealias ObserverArray = Array<McyObserver>
class McySubject: NSObject {
    var notification: McyCustomNotification?
    var observers: ObserverArray
    
    init(notification: McyCustomNotification!, observers: ObserverArray) {
        self.notification = notification
        self.observers = observers
    }
    
    //add observer
    func addCustomObserver(observerObj: McyObserver) {
        for pObserverObj in self.observers {
            if pObserverObj.observer === observerObj.observer {
                return
            }
        }
        self.observers.append(observerObj)
    }
    
    //remove observer
    func removeCustomObserver(observer: AnyObject) {
        for i in 0 ..< observers.count {
            if observers[i].observer === observer {
                observers.remove(at: i)
                break
            }
        }
    }
    
    //send notification
    func postNotification() {
        for i in 0 ..< observers.count {
            let myObserver: McyObserver = self.observers[i]
            _ = myObserver.observer.perform(myObserver.selector, with: self.notification)
        }
    }
}

typealias SubjectDictionary = Dictionary<String, McySubject>
class McyCustomNotificationCenter: NSObject {
    private static let singleton = McyCustomNotificationCenter()
    private var center: SubjectDictionary = SubjectDictionary()
    
    static func defaultCenter() -> McyCustomNotificationCenter {
        return singleton
    }
    //私有化构造方法，防止外部实例化
    override private init() {
        super.init()
    }
    
    func postNotification(notification: McyCustomNotification) {
        let subject = self.getSubjectWithNotification(notification: notification)
        subject.postNotification()
    }
    
    func getSubjectWithNotification(notification: McyCustomNotification) -> McySubject {
        guard let subject: McySubject = center[notification.name] else {
            center[notification.name] = McySubject(notification: notification, observers: ObserverArray())
            return self.getSubjectWithNotification(notification: notification)
        }
        if subject.notification == nil {
            subject.notification = notification
        }
        
        return subject
    }
    
    func addObserver(observer: AnyObject, aSelector: Selector, aName: String) {
        let myObserver = McyObserver(observer: observer, selector: aSelector)
        var subject: McySubject? = center[aName]
        if subject == nil {
            subject = McySubject(notification: nil, observers: ObserverArray())
            center[aName] = subject
        }
        
        subject!.addCustomObserver(observerObj: myObserver)
    }
    
    func removeObserver(observer: AnyObject, name: String) {
        guard let subject: McySubject = center[name] else {
            return
        }
        subject.removeCustomObserver(observer: observer)
    }
}

class Boss: NSObject {
    func sendMessage(message: String) {
        guard message.characters.count > 0 else {
            return
        }
        let userInfo = ["message" : message]
        let notification = McyCustomNotification.init(name: "Boss", object: self, userInfo: userInfo as [String : AnyObject])
        McyCustomNotificationCenter.defaultCenter().postNotification(notification: notification)
    }
}

class Coder: NSObject {
    func observeBoss() {
        McyCustomNotificationCenter.defaultCenter().addObserver(observer: self, aSelector:#selector(self.acceptNotification(notification:)), aName: "Boss")
    }
    
    func acceptNotification(notification: McyCustomNotification) {
        var info: Dictionary = notification.userInfo!
        print("the work: \(String(describing: info["message"]))")
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let boss = Boss()
        let coder = Coder()
        let coder1 = Coder()
        
        coder.observeBoss()
        coder1.observeBoss()
        
        boss.sendMessage(message: "涨工资吧")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

