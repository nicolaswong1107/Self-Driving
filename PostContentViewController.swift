//
//  PostContentViewController.swift
//  Self-Driving
//
//  Created by Nicolas Wong on 3/7/17.
//  Copyright © 2017 Nicolas Wong. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import GoogleMaps

class PostContentViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var googleMap: UIView!
    @IBOutlet weak var VideoControl: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var VideoView: UIView!
    @IBOutlet weak var playPause: UIButton!
    @IBOutlet weak var videoLenght: UILabel!
    @IBOutlet weak var videoSilder: UISlider!
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var postTit: UILabel!
    @IBOutlet weak var postText: UITextView!
    
    var postContent = NSDictionary()
    var locationDict:NSDictionary = [:]
    var path = GMSMutablePath()
    let marker = GMSMarker()
    var polyline = GMSPolyline()
    var isPlaying = true
    var player:AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //get post title to navigationItem title
        self.navigationItem.title = postContent["title"] as? String
        postTit.text = postContent["title"] as? String
        postText.text = postContent["introduction"] as? String
        postText.isEditable = false
        initializeMapAndPath()
        indicator.center = self.VideoControl.center
        initializeVideo()
        self.view.addSubview(VideoControl)
        VideoView.addSubview(indicator)
        setupGradientLayer()
        playPause.addTarget(self, action: #selector(handlePause), for: .touchUpInside)
        videoSilder.addTarget(self, action: #selector(handleSilderChange), for: .valueChanged)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tap.delegate = self
        VideoControl.addGestureRecognizer(tap)
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap2(_:)))
        tap2.delegate = self
        VideoView.addGestureRecognizer(tap2)
    }
    
    func handleSilderChange(){
        if let duration = player?.currentItem?.duration{
            let totalSecdons = CMTimeGetSeconds(duration)
            let value = Float64(videoSilder.value) * totalSecdons
            let seekTime = CMTime(value: Int64(value), timescale: 1)
            player?.seek(to: seekTime, completionHandler: { (completedSeek)
                in
            })
        }
    }
    
    func handlePause(){
        if isPlaying{
            player?.pause()
            playPause.setImage(#imageLiteral(resourceName: "play@80"), for: .normal)
        }else{
            player?.play()
            playPause.setImage(#imageLiteral(resourceName: "pause-80"), for: .normal)
        }
        isPlaying = !isPlaying
    }
    
    func handleTap(_ sender:UITapGestureRecognizer){
        if VideoControl.alpha == 1 {
            VideoControl.fadeOut()
        }
    }
    
    func handleTap2(_ sender:UITapGestureRecognizer){
        if VideoControl.alpha == 0{
            VideoControl.fadeIn()
        }
    }

    func initializeVideo(){
        let postId = postContent["post_id"] as? String
        let url = URL(string: "http://52.77.216.12/getContent.php")
        let session = URLSession.shared
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let postString = "postId=\(postId!)"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        let task = session.dataTask(with: request){ data, response, error in
            if error == nil{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                    
                    guard let parseJSON = json else {
                        print("Error while parsing")
                        return
                    }
                    
                    let content = (parseJSON["content"] as! NSArray).mutableCopy() as! NSMutableArray
                    let vpath = content.mutableArrayValue(forKey: "vpath")
                    
                    DispatchQueue.main.async {
                        let videoURL = URL(string: "http://52.77.216.12/\(vpath[0])")
                        self.player = AVPlayer(url: videoURL!)
                        let playerLayer = AVPlayerLayer(player: self.player)
                        playerLayer.frame = CGRect(x:0, y:0, width:self.VideoView.frame.width, height: self.VideoView.frame.height)
                        self.VideoView.layer.addSublayer(playerLayer)
                        self.player?.play()
                        
                        //observer to check video is ready
                        self.player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
                        
                        //track player progress
                        let interval = CMTime(value: 1, timescale: 2)
                        self.player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (progressTime) in
                            
                            //current time
                            let seconds = CMTimeGetSeconds(progressTime)
                            let secondsString = String(format: "%02d", Int(seconds) % 60)
                            let minutesString = String(format: "%02d", Int(seconds) / 60)
                            self.currentTime.text = "\(minutesString):\(secondsString)"
                            self.updateMakers(Int(seconds))
                            
                            //move silder thumb to video current duration
                            if let duration = self.player?.currentItem?.duration{
                                let durationSeconds = CMTimeGetSeconds(duration)
                                self.videoSilder.value =  Float(seconds / durationSeconds)
                            }
                        })
                    }
                }catch{
                    print("Fetch failed: \((error as NSError).localizedDescription)")
                }
            }else{
                print(error!)
            }
        }
        task.resume()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //check video is ready
        if keyPath == "currentItem.loadedTimeRanges"{
            indicator.stopAnimating()
            indicator.isHidden = true
            VideoControl.backgroundColor = UIColor.clear
            playPause.isHidden = false
            
            if let duration = player?.currentItem?.duration{
                let seconds = CMTimeGetSeconds(duration)
                
                let secondsText = Int(seconds) % 60
                let minutesText = String(format: "%02d", Int(seconds)/60)
                videoLenght.text = "\(minutesText):\(secondsText)"
            }
        }
    }
    
    func initializeMapAndPath(){
        let postId = postContent["post_id"] as? String
        let url = URL(string: "http://52.77.216.12/getContent.php")
        let session = URLSession.shared
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let postString = "postId=\(postId!)"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        let task = session.dataTask(with: request){ data, response, error in
            if error == nil{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                    
                    guard let parseJSON = json else {
                        print("Error while parsing")
                        return
                    }
                    
                    let location = parseJSON["location"]
                    self.locationDict = location as! NSDictionary
                    
                    guard let long = self.locationDict["longitude"] as? NSArray else{
                        return
                    }
                    guard let lati = self.locationDict["latitude"] as? NSArray else{
                        return
                    }
                    
                    //center location
                    let center = Int(lati.count / 2)
                    let centerLati = Double(String(describing: lati[center]))
                    let centerLong = Double(String(describing: long[center]))
                    
                    //doing in frontend
                    DispatchQueue.main.async {
                        let camera = GMSCameraPosition.camera(withLatitude: centerLati!, longitude: centerLong!, zoom: 17)
                        let mapView = GMSMapView.map(withFrame: self.googleMap.bounds, camera: camera)
                        self.googleMap.addSubview(mapView)
                        self.marker.position = CLLocationCoordinate2DMake(Double(String(describing: lati[0]))!, Double(String(describing: long[0]))!)
                        self.marker.title = "car"
                        self.marker.map = mapView
                        
                        //loop the location array value
                        for i in 0..<lati.count{
                            let Lati = Double(String(describing: lati[i]))
                            let Long = Double(String(describing: long[i]))
                            self.path.addLatitude(CLLocationDegrees(Lati!), longitude: CLLocationDegrees(Long!))
                        }
                        //add path to map
                        self.polyline = GMSPolyline(path: self.path)
                        self.polyline.strokeColor = .black
                        self.polyline.strokeWidth = 5
                        self.polyline.map = mapView
                    }
                }catch{
                    print("Fetch failed: \((error as NSError).localizedDescription)")
                }
            }else{
                print(error!)
            }
        }
        task.resume()
    }
    
    func updateMakers(_ second:Int){
        let postId = postContent["post_id"] as? String
        let url = URL(string: "http://52.77.216.12/getContent.php")
        let session = URLSession.shared
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let postString = "postId=\(postId!)"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        let task = session.dataTask(with: request){ data, response, error in
            if error == nil{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                    
                    guard let parseJSON = json else {
                        print("Error while parsing")
                        return
                    }
                    
                    let location = parseJSON["location"]
                    self.locationDict = location as! NSDictionary
                    guard let long = self.locationDict["longitude"] as? NSArray else{
                        return
                    }
                    guard let lati = self.locationDict["latitude"] as? NSArray else{
                        return
                    }
                    
                    if second >= 1 {
                        let Long = Double(String(describing: long[second-1]))
                        let Lati = Double(String(describing: lati[second-1]))
                        let coordinate = CLLocationCoordinate2D(latitude: Lati!, longitude: Long!)
                        self.updateMarker(coordinates: coordinate)
                    }
                }catch{
                    print("Fetch failed: \((error as NSError).localizedDescription)")
                }
            }else{
                print(error!)
            }
        }
        task.resume()
    }
    
    //move marker function
    func updateMarker(coordinates: CLLocationCoordinate2D) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.3)
        marker.position = coordinates
        CATransaction.commit()
    }
    
    func setupGradientLayer(){
        //video control layer color
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = VideoView.frame
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.9, 1.0]
        VideoControl.layer.addSublayer(gradientLayer)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "comment"{
            let commentVC = segue.destination as! commentVC
            commentVC.hidesBottomBarWhenPushed = true
            commentVC.comment = postContent
            
            let backitem = UIBarButtonItem()
            backitem.title = ""
            navigationItem.backBarButtonItem = backitem
        }
    }
}


extension UIView {
    //for video controller hide and show effect
    func fadeIn(duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)  }
    
    func fadeOut(duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }
    
    func longfadeOut(duration: TimeInterval = 0.5, delay: TimeInterval = 2.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }
    
}
