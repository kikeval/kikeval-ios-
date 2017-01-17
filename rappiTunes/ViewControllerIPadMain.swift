//
//  ViewControllerIPadMain.swift
//  rappiTunes
//
//  Created by HEART on 1/16/17.
//  Copyright © 2017 kalpani. All rights reserved.
//

import UIKit
import SystemConfiguration

class ViewControllerIPadMain: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewSplash: UIView!
    @IBOutlet weak var imgSplash: UIImageView!
    @IBOutlet weak var activ: UIView!
    @IBOutlet weak var cargarLbl: UILabel!
    
    let urlString = "https://itunes.apple.com/us/rss/topfreeapplications/limit=20/json"
    
    var nameArray = [String]()
    var categoryArray = [String]()
    var dateArray = [String]()
    var imageArray = [String]()
    var descrArray = [String]()
    
    var categoryArray2 = [String]()
    var dateArray2 = [String]()
    var imageArray2 = [String]()
    var descrArray2 = [String]()
    
    var petitions = [String:[String]]()
    
    var cacheArray = [String]()
    
    var nameRow = NSString()
    var catRow = NSString()
    var dateRow = NSString()
    var descripRow = NSString()
    var imageRow = NSString()
    
    var connectWifi = Bool()
    
    var array = NSMutableArray()
    
    var datesOnlyDict = NSMutableDictionary()
    var x = Int()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        myActivityIndicator.center = view.center
        myActivityIndicator.transform = CGAffineTransform(scaleX: 2, y: 2);
        myActivityIndicator.hidesWhenStopped = false
        myActivityIndicator.startAnimating()
        self.activ.addSubview(myActivityIndicator)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.connectWifi = connectedToNetwork()
        self.loadJsonUrl()
        
        UIView.animate(withDuration: 3.0, animations:{
            
            self.imgSplash.transform = CGAffineTransform(scaleX: 5,y: 5)
            self.imgSplash.alpha = 0;
            self.viewSplash.alpha = 0;
            self.Loading()
        })
    }
    
    func Loading() {
        let transform = CATransform3DTranslate(CATransform3DIdentity,-250, 20, 0)
        self.cargarLbl.layer.transform = transform
        UIView.animate(withDuration: 2.0, animations:{
            self.cargarLbl.layer.transform = CATransform3DIdentity
            self.cargarLbl.alpha = 1
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
    
    func uniq<S: Sequence, E: Hashable>(source: S) -> [E] where E==S.Iterator.Element {
        var seen: [E:Bool] = [:]
        return source.filter { seen.updateValue(true, forKey: $0) == nil }
    }
    
    func  arrayCategoryItems() {
        
        let varu = uniq(source: categoryArray)
        self.categoryArray = varu
        
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
                                    
                                    if let cat = nameDict.value(forKey: "category") as? NSDictionary {
                                        if let categoria = cat.value(forKey: "attributes") as? NSDictionary{
                                            if let itemCat = categoria.value(forKey: "label"){
                                                self.categoryArray.append(itemCat as! String)
                                            }
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
                self.arrayCategoryItems()
                OperationQueue.main.addOperation ({
                    self.collectionView.reloadData()
                })
                UIView.animate(withDuration: 3.0, animations:{
                    self.activ.alpha = 0
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
                                    
                                    if let cat = nameDict.value(forKey: "category") as? NSDictionary {
                                        if let categoria = cat.value(forKey: "attributes") as? NSDictionary{
                                            if let itemCat = categoria.value(forKey: "label"){
                                                
                                                self.categoryArray.append(itemCat as! String)
                                            }
                                        }
                                    }
                                    
                                    if let fecha = nameDict.value(forKey: "im:releaseDate") as? NSDictionary {
                                        if let fechaApp = fecha.value(forKey: "attributes") as? NSDictionary{
                                            if let itemFecha = fechaApp.value(forKey: "label"){
                                                
                                                self.dateArray.append(itemFecha as! String)
                                                print(self.dateArray)
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
                                                        print(image2)
                                                        
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
        OperationQueue.main.addOperation ({
            self.collectionView.reloadData()
        })
        UIView.animate(withDuration: 3.0, animations:{
            self.activ.alpha = 0
        })
        
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! CollectionViewCell
        
        cell.categoryLb.text = categoryArray[indexPath.row]
  
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
        
        self.catRow = categoryArray[indexPath.row] as NSString
        self.performSegue(withIdentifier: "apps", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "apps" {
            
            let viewControllerApps = segue.destination as! ViewControllerApps
            
            viewControllerApps.categoriaSegue = self.catRow as String
 
        }
    }
}
