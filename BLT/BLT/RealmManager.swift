//
//  RealmManager.swift
//  BLT
//
//  Created by LorentzenN on 4/13/20.
//  Copyright © 2020 BLT App. All rights reserved.
//

import Foundation
import RealmSwift

var realmManager: RealmManager = RealmManager()

class RealmManager {
    
    let realm: Realm
    
    init() {
        var config = Realm.Configuration()
        
        // Use the default directory, but replace the filename with the username
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("BLT.realm")
        
        // Set this as the configuration used for the default Realm
        Realm.Configuration.defaultConfiguration = config
        realm = try! Realm()
        print("Realm Connection Established")
    }
    
    
}
