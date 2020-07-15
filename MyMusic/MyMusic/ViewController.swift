//
//  ViewController.swift
//  MyMusic
//
//  Created by Test on 6/21/20.
//  Copyright © 2020 BennyTest. All rights reserved.
//

import UIKit
import AVKit


class ViewController: UIViewController, UICollectionViewDelegateFlowLayout,UITextFieldDelegate,UIScrollViewDelegate {

    @IBOutlet weak var searchjTextField: UITextField!
    @IBOutlet weak var musicCollection: UICollectionView!
    let cellID = "musicCell"
    let popupViewID = "popUpView"
    var musicModel = MusicViewModel()
    var musicList = [MusicModel]()
    var player = AVPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        musicCollection.delegate = self
        musicCollection.dataSource = self
        searchjTextField.delegate = self
        
     //   musicCollection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        
        musicCollection.register(UINib(nibName: "MusicCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: cellID)
    }
    
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

         return CGSize(width:collectionView.frame.width/2 - 5, height: 200)
     }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
        searchjTextField.resignFirstResponder()
    }
    

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.searchjTextField.resignFirstResponder()
        return true
    }

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if !textField.text!.isEmpty {
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//
//                self.searchjTextField.resignFirstResponder()
//            }
            
             let concurentQueue =  DispatchQueue(label: "com.queue.Concurrent", attributes: .concurrent)
            
            let text = textField.text!
            concurentQueue.async {
                
                self.musicModel.fetchMusicDataBasedOntext(musictext: text, completionHandler1: { success,list,error in
                    
                    if success {
                        
                        DispatchQueue.main.async {
                       
                            self.musicList = list!
                            
                            self.musicCollection.reloadData()
                            self.musicCollection.setNeedsLayout()
                           // textField.resignFirstResponder()
                        }
                    }
                    
                })
                
                
                
            }
        }
        
        else {
            
            musicList.removeAll()
            self.musicCollection.reloadData()
            self.musicCollection.setNeedsLayout()
            //textField.resignFirstResponder()
        }
        
        return true
    }
    
    

    
}

extension ViewController: UICollectionViewDelegate {
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//
//           return CGSize(width: collectionView.frame.size.width/3.2, height: 100)
//       }
    
}

let ImageAlbumToCache = NSCache<NSString, UIImage>()
let ImageArtistToCache = NSCache<NSString, UIImage>()
let previewTrackToCache = NSCache<NSString, NSData>()

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if musicList.count == 0 {
            
            musicCollection.isHidden = true
        }
        
        else {
            
            musicCollection.isHidden = false
        }
        return musicList.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! MusicCollectionViewCell
    
        
        cell.albumName.text = musicList[indexPath.row].albumName
        cell.artistName.text = musicList[indexPath.row].artist.artistName
        
        if let image = ImageAlbumToCache.object(forKey: musicList[indexPath.row].albumImageURL! as NSString) {
            
             cell.albumImage.image = image
            
            return cell
        }
        
        if let image = ImageArtistToCache.object(forKey: musicList[indexPath.row].albumImageURL! as NSString) {
            
             cell.artistImage.image = image
            
            return cell
        }
        
        musicModel.fetchImgeonText(musictext: musicList[indexPath.row].albumImageURL!,type: "album", completionHandler1: { success,image,error in
            
            
            if success {
        
                DispatchQueue.main.async {
                    
                     cell.albumImage.image = image
                }
                
               
            
                
                
            }
        
        
        
        })
        
        
        musicModel.fetchImgeonText(musictext: (musicList[indexPath.row].artist.artistPictureURL)!,type: "artist" ,completionHandler1: { success,image,error in
            
            
            if success {
        
                DispatchQueue.main.async {
                    
                     cell.artistImage.image = image
                }
                
               
            
                
                
            }
        
        
        
        })
        
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        searchjTextField.resignFirstResponder()
      
        let popUpViewVC = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(identifier: popupViewID) as! PopUpViewController
        
        popUpViewVC.musicList = musicList
        popUpViewVC.row = indexPath.row
        
        self.addChild(popUpViewVC)
        self.view.addSubview(popUpViewVC.view)
        popUpViewVC.view.frame = self.view.frame
        popUpViewVC.didMove(toParent: self)
        
        
        
    }
    
    
    
}


struct MusicModel {
    
    var musicID = Int()
    var albumName : String?
    var artistName : String?
    var albumImageURL : String?
    var artistImageURL : String?
    var preview : String?
    var artist = MusicArtist()
    var duration = Int()
    
}

struct MusicArtist {
    
    var artistID = Int()
    var artistName : String?
    var artistPictureURL : String?
}


//let imageToCahe = NSCache<NSString, UIImage>()

class MusicViewModel {
    
    
    var musicModel  =  MusicModel()
    var musicList  =  [MusicModel]()
    
    func fetchImgeonText(musictext:String,type:String, completionHandler1: @escaping (Bool,UIImage,Error?)->Void) {
        
        let request = NSMutableURLRequest(url: NSURL(string: musictext)! as URL,
            cachePolicy: .useProtocolCachePolicy,
        timeoutInterval: 10.0)
        
        
        let session = URLSession.shared
               let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                
                guard let dataValue = data else {
                    
                    print(error)
                    return
                }
                
               
                
                if let image = UIImage(data: dataValue) {
                    
                    if type == "album" {
                        
                         ImageAlbumToCache.setObject(image, forKey: musictext as NSString)
                    }
                    
                    else {
                        
                         ImageArtistToCache.setObject(image, forKey: musictext as NSString)
                    }
                   
                    
                    completionHandler1(true,image,nil)
                }
                
            
                
                
        })
        
        dataTask.resume()
        
        
    }
    
    
    func fetchMusicDataBasedOntext(musictext:String, completionHandler1: @escaping (Bool,[MusicModel]?,Error?)->Void) {
        
        
        let headers = [
            "x-rapidapi-host": "deezerdevs-deezer.p.rapidapi.com",
            "x-rapidapi-key": "da637b6328mshaf3d62a927ad73bp14b0d9jsn87944401328b"
        ]

        let text = String(musictext.filter { !" \n\t\r".contains($0) })
        
       let request = NSMutableURLRequest(url: NSURL(string: "https://deezerdevs-deezer.p.rapidapi.com/search?q="+text) as! URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
      

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            do {        if (error != nil) {
                print(error)
            } else {
               
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                
                if let object = json as? [String:Any]{
                              // json is a dictionary
                 
                    
                    let modelData = object["data"] as? [Any]
                    
                  
                   //m print(modelData![0])
                    
                    /*
                     
                     Loop through each modelData item, create a album model and
                     append to the list
                     
                     
                     */
                
                    self.musicList.removeAll()
                    
                    if modelData == nil || modelData?.count == 0 {
                        
                        return
                    }
                    
                    for index in 0...modelData!.count - 1 {
                        
                        
                        let albumModel = modelData?[index] as? [String:Any]

                        let albumData = albumModel?["album"] as? [String:Any]

                      
                        self.musicModel.albumImageURL = albumData?["cover_medium"] as? String
                        
                        let artist = albumModel?["artist"] as? [String:Any]
                        self.musicModel.artist.artistPictureURL = artist?["picture_medium"] as? String
                        self.musicModel.artist.artistName = artist?["name"] as? String
                        self.musicModel.musicID = albumData?["id"] as! Int
                          print(albumData?["title"])
                        self.musicModel.albumName = albumModel?["title_short"] as? String
                        self.musicModel.preview = albumModel?["preview"] as? String
                        self.musicModel.duration = albumModel?["duration"] as! Int
                        
                        self.musicList.append(self.musicModel)
                        
                    }
 
                    
                    completionHandler1(true,self.musicList,nil)
                  }
                
                }
                
                
            }catch {
                
                print(error.localizedDescription)
            }
        })

        dataTask.resume()
        
        
    }
    
    
}

