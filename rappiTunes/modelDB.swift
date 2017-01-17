//
//  modelDB.swift
//  rappiTunes
//
//  Created by HEART on 1/15/17.
//  Copyright © 2017 kalpani. All rights reserved.
//

import UIKit

let sharedInstance = modelDB()

class modelDB: NSObject {
    
    var database: FMDatabase? = nil
    
    class func getInstance() -> modelDB
    {
        if(sharedInstance.database == nil)
        {
            sharedInstance.database = FMDatabase(path: utilities.getPath(fileName: "bd_cache.sqlite"))
        }
        
        return sharedInstance
    }
    
    func getAllArticles() -> NSMutableArray {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM app_cache", withArgumentsIn: nil)
        let arrDataArticulos : NSMutableArray = NSMutableArray()
        
        if (resultSet != nil) {
            while resultSet.next() {
                let cache : data = data()
                
                cache.cache = resultSet.string(forColumn: "cache")
                arrDataArticulos.add(cache)
            }
        }
        
        sharedInstance.database!.close()
        return arrDataArticulos
    }

    

}
