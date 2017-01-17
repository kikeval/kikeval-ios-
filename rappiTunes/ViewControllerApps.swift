//
//  ViewControllerApps.swift
//  rappiTunes
//
//  Created by HEART on 1/16/17.
//  Copyright © 2017 kalpani. All rights reserved.
//

import UIKit
import SystemConfiguration

class ViewControllerApps: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionApp: UICollectionView!
    @IBOutlet weak var titleSegue: UILabel!
    @IBAction func btnBack(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    let urlString = "https://itunes.apple.com/us/rss/topfreeapplications/limit=20/json"
    
    var nameArray = [String]()
    var categoryArray = [String]()
    var dateArray = [String]()
    var imageArray = [String]()
    var descrArray = [String]()
    
    var categoriaSegue = ""
    var destinationCat = ""
 
    var connectWifi = Bool()
    
    var array = NSMutableArray()
    
    var itemCateg = NSString()
    
    var nameRow = NSString()
    var catRow = NSString()
    var dateRow = NSString()
    var descripRow = NSString()
    var imageRow = NSString()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleSegue.text = self.categoriaSegue
        
        self.collectionApp.delegate = self
        self.collectionApp.dataSource = self
        
        self.connectWifi = connectedToNetwork()
        self.loadJsonUrl()
        
        print(connectWifi);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! CollectionViewCellApps
        
        let imgUrl = NSURL(string: imageArray[indexPath.row])
        
        cell.nameLb.text = self.nameArray[indexPath.row]
        cell.dateLb.text = self.dateArray[indexPath.row]
        cell.catAppLb.text = self.dateArray[indexPath.row]

        cell.imageViewApp.layer.cornerRadius = cell.imageViewApp.bounds.size.width / 2.0
        cell.imageViewApp.clipsToBounds = true
        
        
        if connectWifi == true {
            let dataImage = NSData(contentsOf: (imgUrl as? URL)!)
            cell.imageViewApp.image = UIImage(data: dataImage as! Data)
            
        }else{
            ImageLoader.sharedLoader.imageForUrl(urlString: imageArray[indexPath.row], completionHandler:{(image: UIImage?, url: String) in
                
                cell.imageViewApp?.image = image
            })
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
        
        self.nameRow = nameArray[indexPath.row] as NSString
        self.catRow = categoryArray[indexPath.row] as NSString
        self.dateRow = dateArray[indexPath.row] as NSString
        self.descripRow = descrArray[indexPath.row] as NSString
        self.imageRow = imageArray[indexPath.row] as NSString
        
        self.performSegue(withIdentifier: "descript", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "descript" {
            
            let viewControllerDetalle = segue.destination as! ViewControllerDetalle
            
            viewControllerDetalle.nombre = self.nameRow as String
            viewControllerDetalle.cat = self.catRow as String
            viewControllerDetalle.date = self.dateRow as String
            viewControllerDetalle.descript = self.descripRow as String
            viewControllerDetalle.img = self.imageRow as String
            
  
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
                    self.collectionApp.reloadData()
                })
//                UIView.animate(withDuration: 3.0, animations:{
//                    self.activ.alpha = 0
//                })
                
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
            self.collectionApp.reloadData()
        })
//        UIView.animate(withDuration: 3.0, animations:{
//            self.activ.alpha = 0
//        })
        
    }

    
        
    


}
