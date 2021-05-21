//
//  ReminderList.swift
//  ReminderApp
//
//  Created by Oguzhan Bekir on 14.05.2021.
//

import Foundation

struct ListOfReminder {
    var id: UUID?
    var title, color: String?
    var image: String?
    var items: [ItemArray]?
    
    
    init(id: UUID?, title: String?, color: String?, image: String?, items: [ItemArray]?) {
        self.id = id
        self.title = title
        self.color = color
        self.image = image
        self.items = items
    }
}

struct ItemArray {
    var id: UUID?
    var title, notes: String?
    var flag: Bool?
    var priority: Int?
}

public class Item: NSObject, NSCoding {
    
    public var id: UUID?
    public var title, notes: String?
    public var flag: Bool?
    public var priority: Int?
    
    enum Key:String {
        case id = "id"
        case title = "title"
        case notes = "notes"
        case flag = "flag"
        case priority = "priority"
    }
    
    init(id: UUID, title: String?, notes: String?, flag: Bool?, priority: Int?) {

        self.id = id
        self.title = title
        self.notes = notes
        self.flag = flag
        self.priority = priority
    }
    
    public override init() {
        super.init()
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: Key.id.rawValue)
        aCoder.encode(title, forKey: Key.title.rawValue)
        aCoder.encode(notes, forKey: Key.notes.rawValue)
        aCoder.encode(flag, forKey: Key.flag.rawValue)
        aCoder.encode(priority, forKey: Key.priority.rawValue)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
            id = aDecoder.decodeObject(forKey: "id") as? UUID
            title = aDecoder.decodeObject(forKey: "title") as? String
            notes = aDecoder.decodeObject(forKey: "notes") as? String
            flag = aDecoder.decodeObject(forKey: "flag") as? Bool
            priority = aDecoder.decodeObject(forKey: "priority") as? Int
    
            super.init()
        }
}


public class Items: NSObject, NSCoding {
    
    public var items: [Item] = []
    
    enum Key:String {
        case items = "items"
    }
    
    init(items: [Item]) {
        self.items = items
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(items, forKey: Key.items.rawValue)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        let mRanges = aDecoder.decodeObject(forKey: Key.items.rawValue) as! [Item]
        
        self.init(items: mRanges)
    }
}
