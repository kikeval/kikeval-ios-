//
//  ViewController.swift
//  rappiTunes
//
//  Created by HEART on 1/13/17.
//  Copyright © 2017 kalpani. All rights reserved.
//

import UIKit
import SystemConfiguration



class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBAction func backAction(_ sender: Any) {
        
        
        UIView.animate(withDuration: 1, animations: {
            
            self.animateTransitionView.layer.cornerRadius = self.animateTransitionView.bounds.size.width / 2.0
            self.animateTransitionView.clipsToBounds = true
            
            self.animateTransitionView.transform = CGAffineTransform(scaleX:700,y: 700)
            self.animateTransitionView.alpha = 1;
        })
        
        
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            
            self.segueClick2()
            
        })
    }
   
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var animateTransitionView: UIView!
    
    let urlString = "https://itunes.apple.com/us/rss/topfreeapplications/limit=20/json"
 
    var nameArray = [String]()
    var categoryArray = [String]()
    var dateArray = [String]()
    var imageArray = [String]()
    var descrArray = [String]()
    
    var cacheArray = [String]()
    var itemCateg = NSString()

    var nameRow = NSString()
    var catRow = NSString()
    var dateRow = NSString()
    var descripRow = NSString()
    var imageRow = NSString()
    
    var connectWifi = Bool()
    
    var categoriaSegue = ""
    
    var array = NSMutableArray()
   
 
    func segueClick2() {
    
        dismiss(animated: true, completion: nil)
    
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.connectWifi = connectedToNetwork()
        self.loadJsonUrl()
        
       self.animateTransitionView.transform = CGAffineTransform(scaleX:700,y: 700)
 
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      

        UIView.animate(withDuration: 1, animations: {
            
            self.animateTransitionView.layer.cornerRadius = self.animateTransitionView.bounds.size.width / 2.0
            self.animateTransitionView.clipsToBounds = true
            
            self.animateTransitionView.transform = CGAffineTransform(scaleX:0.1,y: 0.1)
            self.animateTransitionView.alpha = 0;
            
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

    func loadJsonUrl() {
        
        if connectWifi == true {
            
            print("getURL_____________________________________")
            
            let url = NSURL(string: urlString)
            URLSession.shared.dataTask(with: (url as? URL)!, completionHandler: {(data, response, error) -> Void in
                
                if let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                    
                    if let jsonObjectDos = jsonObject!.value(forKey: "feed") as? NSDictionary {
                        
                        if let jsonObjectName = jsonObjectDos.value(forKey: "entry") as? NSArray {
                            
                            for apps in jsonObjectName{
                                
                                if let nameDict = apps as? NSDictionary {
                                    
                                    if let cat = nameDict.value(forKey: "category") as? NSDictionary {
                                        if let categoria = cat.value(forKey: "attributes") as? NSDictionary{
                                            if let itemCat = categoria.value(forKey: "label"){
                                                
                                                self.itemCateg = itemCat as! NSString
                                                
                                                if self.itemCateg .isEqual(self.categoriaSegue){
                                                    
                                                    print("categoria: \(categoria)")
                                                    
                                                    
                                                    self.categoryArray.append(itemCat as! String)
                                                    
                                                    if let name = nameDict.value(forKey: "im:name") as? NSDictionary {
                                                        if let name2 = name.value(forKey: "label"){
                                                            self.nameArray.append(name2 as! String)
                                                        }
                                                    }
                                                    
                                                    if let descrip = nameDict.value(forKey: "summary") as? NSDictionary {
                                                        if let descrption = descrip.value(forKey: "label"){
                                                            self.descrArray.append(descrption as! String)
                                                        }
                                                    }
                                                    
                                                    
                                                    if let fecha = nameDict.value(forKey: "im:releaseDate") as? NSDictionary {
                                                        if let fechaApp = fecha.value(forKey: "attributes") as? NSDictionary{
                                                            if let itemFecha = fechaApp.value(forKey: "label"){
                                                                self.dateArray.append(itemFecha as! String)
                                                            }
                                                            
                                                        }
                                                    }
                                                    
                                                    
                                                    if let image = nameDict.value(forKey: "im:image") as? NSArray {
                                                        var i : Int = 0
                                                        for img in image{
                                                            if i == 0{
                                                                if let imgStr = img as? NSDictionary {
                                                                    if let image2 = imgStr.value(forKey: "label"){
                                                                        self.imageArray.append(image2 as! String)
                                                                        i = 1
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        
                                                    }
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }
                }
                OperationQueue.main.addOperation ({
                    self.tableView.reloadData()
                })
               
            }).resume()
            
        }else{
            
            print("NOgetURL_____________________________________")
            
            self.array = modelDB.getInstance().getAllArticles()
            
            let post = self.array as [AnyObject];
            
            if let firstSuchElement = post.first {
                
                let str: String = firstSuchElement.value(forKey: "cache") as! String
                
                let dataStr = str.data(using: .utf8)!
                
                if let jsonObject = try? JSONSerialization.jsonObject(with: dataStr, options: .allowFragments) as? NSDictionary {
                    
                    if let jsonObjectDos = jsonObject!.value(forKey: "feed") as? NSDictionary {
                        
                        if let jsonObjectName = jsonObjectDos.value(forKey: "entry") as? NSArray {
                            
                            for apps in jsonObjectName{
                                
                                if let nameDict = apps as? NSDictionary {
                                    
                                    if let cat = nameDict.value(forKey: "category") as? NSDictionary {
                                        if let categoria = cat.value(forKey: "attributes") as? NSDictionary{
                                            if let itemCat = categoria.value(forKey: "label"){
                                                
                                                self.itemCateg = itemCat as! NSString
                                                
                                                if self.itemCateg .isEqual(self.categoriaSegue){
                                                    
                                                    self.categoryArray.append(itemCat as! String)
                                                    
                                                    if let name = nameDict.value(forKey: "im:name") as? NSDictionary {
                                                        if let name2 = name.value(forKey: "label"){
                                                            self.nameArray.append(name2 as! String)
                                                        }
                                                    }
                                                    
                                                    if let descrip = nameDict.value(forKey: "summary") as? NSDictionary {
                                                        if let descrption = descrip.value(forKey: "label"){
                                                            self.descrArray.append(descrption as! String)
                                                        }
                                                    }
                                                    
                                                    if let fecha = nameDict.value(forKey: "im:releaseDate") as? NSDictionary {
                                                        if let fechaApp = fecha.value(forKey: "attributes") as? NSDictionary{
                                                            if let itemFecha = fechaApp.value(forKey: "label"){
                                                                self.dateArray.append(itemFecha as! String)
                                                            }
                                                            
                                                        }
                                                    }
                                                    
                                                    if let image = nameDict.value(forKey: "im:image") as? NSArray {
                                                        var i : Int = 0
                                                        for img in image{
                                                            if i == 0{
                                                                if let imgStr = img as? NSDictionary {
                                                                    if let image2 = imgStr.value(forKey: "label"){
                                                                        self.imageArray.append(image2 as! String)
                                                                        i = 1
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        
                                                    }
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                    }
                                    
                                }
                            }
                        }
                        
                    }
                    
                }
            }
            
            
        }
        OperationQueue.main.addOperation ({
            self.tableView.reloadData()
        })
   
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        let imgUrl = NSURL(string: imageArray[indexPath.row])
        
        
        cell.nameLb.text = nameArray[indexPath.row]
        cell.categoryLb.text = categoryArray[indexPath.row]
        cell.dateLb.text = dateArray[indexPath.row]
        
        cell.imageVIewApp.layer.cornerRadius = cell.imageVIewApp.bounds.size.width / 2.0
        cell.imageVIewApp.clipsToBounds = true
        
        
       if connectWifi == true {
            let dataImage = NSData(contentsOf: (imgUrl as? URL)!)
            cell.imageVIewApp.image = UIImage(data: dataImage as! Data)
        
       }else{
            ImageLoader.sharedLoader.imageForUrl(urlString: imageArray[indexPath.row], completionHandler:{(image: UIImage?, url: String) in
                
                cell.imageView?.image = image
            })
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        
        self.nameRow = nameArray[indexPath.row] as NSString
        self.catRow = categoryArray[indexPath.row] as NSString
        self.dateRow = dateArray[indexPath.row] as NSString
        self.descripRow = descrArray[indexPath.row] as NSString
        self.imageRow = imageArray[indexPath.row] as NSString
        
        
        
        
        
        UIView.animate(withDuration: 1.0, animations: {
            
            self.animateTransitionView.layer.cornerRadius = self.animateTransitionView.bounds.size.width / 2.0
            self.animateTransitionView.clipsToBounds = true
            
            self.animateTransitionView.transform = CGAffineTransform(scaleX: 700,y: 700)
            self.animateTransitionView.alpha = 1;
            
        })
        
        
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            
            self.segueClick()
            
        })
        
    }
    
    func segueClick() {
        
        self.performSegue(withIdentifier: "segueDetail", sender: self)
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.alpha = 0
        let transform = CATransform3DTranslate(CATransform3DIdentity,-250, 20, 0)
        cell.layer.transform = transform

        UIView.animate(withDuration: 1.0){
            cell.alpha = 1.0
            cell.layer.transform = CATransform3DIdentity
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueDetail" {
            
            let viewControllerCategory = segue.destination as! ViewControllerCategory
            
            viewControllerCategory.Nombre = self.nameRow as String
            viewControllerCategory.categoria = self.catRow as String
            viewControllerCategory.fecha = self.dateRow as String
            viewControllerCategory.descripcion = self.descripRow as String
            viewControllerCategory.imagen = self.imageRow as String
            
 
        }
    }
    
    
}

