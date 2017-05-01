//
//  PostViewController.swift
//  Self-Driving
//
//  Created by Nicolas Wong on 1/15/17.
//  Copyright © 2017 Nicolas Wong. All rights reserved.
//

import UIKit
import SwiftHTTP

class PostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    let id = userVal!["id"] as? String
    let fileName = "gpsVideo.mp4"
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    @IBOutlet weak var postTitle: UITextField!
    @IBOutlet weak var content: UIText!
    @IBOutlet weak var uploading: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uploading.isHidden = true
        
    }
    
    @IBAction func takeVideo(_ sender: Any) {
        let capture = self.storyboard!.instantiateViewController(withIdentifier: "capture") as! CameraViewController
        capture.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(capture, animated: true)
        
        // remove title from back button
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {        
        // hide keyboard
        self.view.endEditing(false)
    }
    
    //tap button and open post
    @IBAction func addPost(_ sender: Any) {
        openPost()
    }
    
    func openPost(){
        let fileURL = documentsURL.appendingPathComponent(fileName)
        let url = "http://52.77.216.12/writePost.php"
        let cont = content.text
        let tit = postTitle.text
        do{
            let opt = try HTTP.POST(url, parameters: ["id":id!, "title":tit!, "content":cont!, "json":jsonDict ,"file":Upload(fileUrl:fileURL)])
            opt.progress = { progress in
                print("progress: \(progress)") //this will be between 0 and 1.
                //asyns task to frontend
                DispatchQueue.main.async(execute:{
                    self.uploading.isHidden = false
                    self.uploading.startAnimating()
                })
            }
            opt.start(){response in
                self.Notification(tit: "Notification", msg: response.text!, action: "OK")
                //"Post Success"
                DispatchQueue.main.async(execute:{
                    self.uploading.isHidden = true
                    self.uploading.stopAnimating()
                })
            }
        }catch let error{
            print("got an error creating the request: \(error)")
        }
        
    }
    
    //clear text
    @IBAction func clearText(_ sender: Any) {
        self.content.text = ""
    }
    
    func Notification(tit:String, msg: String, action: String) -> Void {
        let alert = UIAlertController(title: tit, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: action, style: .default, handler:nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
