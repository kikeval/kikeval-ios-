//
//  utilities.swift
//  rappiTunes
//
//  Created by HEART on 1/15/17.
//  Copyright © 2017 kalpani. All rights reserved.
//

import UIKit

var isDir : ObjCBool = false

class utilities: NSObject {
    
    class func getPath(fileName: String) -> String{
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(fileName)
        
        return fileURL.path
        
    }
    
    class func copyFile(fileName: NSString) {
        let dbPath: String = getPath(fileName: fileName as String)
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: dbPath, isDirectory:&isDir) {
            
            if isDir.boolValue {
                // file exists and is a directory
                
                print("ok")
                
            } else {
                // file exists and is not a directory
                print("no")
            }
            
            let documentsURL = Bundle.main.resourceURL
            let fromPath = documentsURL!.appendingPathComponent(fileName as String)
            
            var error : NSError?
            
            do {
                try fileManager.copyItem(atPath: fromPath.path, toPath: dbPath)
                
            } catch let error1 as NSError {
                
                error = error1
                
            }
            
            let alert: UIAlertView = UIAlertView()
            if (error != nil) {
                alert.title = "Alerta"
                alert.message = error?.localizedDescription
            } else {
                alert.title = "Alerta"
                alert.message = "Base de datos copiada con éxito"
            }
            alert.delegate = nil
            alert.addButton(withTitle: "Ok")
            alert.show()
        }
    }
    
    class func invokeAlertMethod(strTitle: NSString, strBody: NSString, delegate: AnyObject?) {
        let alert: UIAlertView = UIAlertView()
        alert.message = strBody as String
        alert.title = strTitle as String
        alert.delegate = delegate
        alert.addButton(withTitle: "Ok")
        alert.show()
    }


}
