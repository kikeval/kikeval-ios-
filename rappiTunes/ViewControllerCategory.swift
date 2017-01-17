//
//  ViewControllerCategory.swift
//  rappiTunes
//
//  Created by HEART on 1/16/17.
//  Copyright © 2017 kalpani. All rights reserved.
//

import UIKit
import SystemConfiguration


class ViewControllerCategory: UIViewController {

    @IBAction func backAction(_ sender: Any) {
        self.viewAnimate.transform = CGAffineTransform(scaleX:0.1,y: 0.1)
        
        UIView.animate(withDuration: 1, animations: {
            
            self.viewAnimate.layer.cornerRadius = self.viewAnimate.bounds.size.width / 2.0
            self.viewAnimate.clipsToBounds = true
            
            self.viewAnimate.transform = CGAffineTransform(scaleX:700,y: 700)
            self.viewAnimate.alpha = 1;
        })
        
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            
            self.segueClick3()
            
        })
    }
    
    @IBOutlet weak var viewAnimate: UIView!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var textDescript: UITextView!
    @IBOutlet weak var fechaLb: UILabel!
    @IBOutlet weak var catLb: UILabel!
    @IBOutlet weak var imgImageView: UIImageView!
    
    var Nombre = ""
    var categoria = ""
    var fecha = ""
    var descripcion = ""
    var imagen = ""
    
    var connectWifi = Bool()
    
    func segueClick3() {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameLb.text = Nombre
        self.textDescript.text = descripcion
        self.catLb.text = categoria
        self.fechaLb.text = fecha
        
        self.connectWifi = connectedToNetwork()
        
        let imgUrl = NSURL(string: imagen)
        
        if connectWifi == true {
            let dataImage = NSData(contentsOf: (imgUrl as? URL)!)
            self.imgImageView.image = UIImage(data: dataImage as! Data)
            
            self.imgImageView.layer.cornerRadius = self.imgImageView.bounds.size.width / 2.0
            self.imgImageView.clipsToBounds = true
            
        }else{
            ImageLoader.sharedLoader.imageForUrl(urlString: imagen, completionHandler:{(image: UIImage?, url: String) in
                
                self.imgImageView.image = image
                self.imgImageView.layer.cornerRadius = self.imgImageView.bounds.size.width / 2.0
                self.imgImageView.clipsToBounds = true
                
            })

        }
        
        self.viewAnimate.transform = CGAffineTransform(scaleX:700,y: 700)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
        UIView.animate(withDuration: 1, animations: {
            
            self.viewAnimate.layer.cornerRadius = self.viewAnimate.bounds.size.width / 2.0
            self.viewAnimate.clipsToBounds = true
            
            self.viewAnimate.transform = CGAffineTransform(scaleX:0.1,y: 0.1)
            self.viewAnimate.alpha = 0;
        })
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
