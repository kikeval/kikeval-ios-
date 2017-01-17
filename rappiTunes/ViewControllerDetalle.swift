//
//  ViewControllerDetalle.swift
//  rappiTunes
//
//  Created by HEART on 1/16/17.
//  Copyright © 2017 kalpani. All rights reserved.
//

import UIKit
import SystemConfiguration

class ViewControllerDetalle: UIViewController {

    
    @IBOutlet weak var imageDetail: UIImageView!
    @IBOutlet weak var catLb: UILabel!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var dateLb: UILabel!
    @IBOutlet weak var descripTxtV: UITextView!
    
    var nombre = String()
    var date = String()
    var cat = String()
    var descript = String()
    var img = String()
    
    var connectWifi = Bool()
    
    @IBAction func backAction(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.connectWifi = connectedToNetwork()
        
        self.nameLb.text = self.nombre
        self.catLb.text = self.cat
        self.dateLb.text = self.date
        self.descripTxtV.text = self.descript

        self.connectWifi = connectedToNetwork()
        
        let imgUrl = NSURL(string: img)
        
        if connectWifi == true {
            let dataImage = NSData(contentsOf: (imgUrl as? URL)!)
            self.imageDetail.image = UIImage(data: dataImage as! Data)
            
            self.imageDetail.layer.cornerRadius = self.imageDetail.bounds.size.width / 2.0
            self.imageDetail.clipsToBounds = true
            
        }else{
            ImageLoader.sharedLoader.imageForUrl(urlString: img, completionHandler:{(image: UIImage?, url: String) in
                
                self.imageDetail.image = image
                self.imageDetail.layer.cornerRadius = self.imageDetail.bounds.size.width / 2.0
                self.imageDetail.clipsToBounds = true
            })
        }
    }
    
    func connectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
}
