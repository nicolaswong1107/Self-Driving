//
//  ProfileViewController.swift
//  Self-Driving
//
//  Created by Nicolas Wong on 1/15/17.
//  Copyright © 2017 Nicolas Wong. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var tableview: UITableView!
    
    var post = [AnyObject]()
    var images = [UIImage]()
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadPost()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let username = userVal!["username"] as? String
        let email = userVal!["email"] as? String
        let photo = userVal!["photo"] as? String
        
        usernameLbl.text = username
        emailLbl.text = email
        
        if photo != "" {
            
            let imageURL = URL(string: photo!)!
            
            DispatchQueue.main.async(execute: {
                
                let imageData = try? Data(contentsOf: imageURL)
                
                if imageData != nil {
                    DispatchQueue.main.async(execute: {
                        self.profileImage.image = UIImage(data: imageData!)
                    })
                }
            })
            
        }
        
        //set profile image to rounded
        self.view.layoutIfNeeded()
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.clipsToBounds = true
        profileImage.layer.borderColor = UIColor.black.cgColor
        profileImage.layer.borderWidth = 1
        
        self.navigationItem.title = username
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.loadPost), for: UIControlEvents.valueChanged)
        tableview.addSubview(refreshControl)
    }

    func Notification(tit:String, msg:String, act:String){
        let alert = UIAlertController(title: tit, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: act, style: .default){ ACTION in self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func editIcon(_ sender: Any) {
        selectIcon()
    }
    
    func selectIcon() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    // selected image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        profileImage.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        // call func of uploading file to server
        uploadIcon()
    }
    
    func createBodyWithParams(_ parameters: [String: String]?, filePathKey: String?, imageDataKey: Data, boundary: String) -> Data {
        
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        let filename = "icon.jpg"
        
        let mimetype = "image/jpg"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey)
        body.appendString("\r\n")
        
        body.appendString("--\(boundary)--\r\n")
        
        return body as Data
        
    }
    
    func uploadIcon() {
        
        let id = userVal!["id"] as! String
        let url = URL(string: "http://52.77.216.12/uploadProfilePic.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let param = ["id" : id]
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    
        let imageData = UIImageJPEGRepresentation(profileImage.image!, 0.5)
    
        if imageData == nil {
            return
        }
        request.httpBody = createBodyWithParams(param, filePathKey: "file", imageDataKey: imageData!, boundary: boundary)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async(execute: {
                if error == nil {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                    
                        guard let parseJSON = json else {
                            print("Error while parsing")
                            return
                        }
                    
                        let id = parseJSON["id"]
                        
                        if id != nil {
                            UserDefaults.standard.set(parseJSON, forKey: "parseJSON")
                            userVal = UserDefaults.standard.value(forKey: "parseJSON") as? NSDictionary
                        } else {
                            // get main queue to communicate back to user

                        }
                        // error while jsoning
                    } catch {
                        // get main queue to communicate back to user

                    }
                    // error with php
                } else {
                    // get main queue to communicate back to user

                }
            })
            }.resume()
    }
    @IBAction func logout(_ sender: Any) {
        // remove saved information
        UserDefaults.standard.removeObject(forKey: "parseJSON")
        UserDefaults.standard.synchronize()
        
        // go to login page
        let loginvc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.present(loginvc, animated: true, completion: nil)
    }
    
    //tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ppost", for: indexPath) as! profileTVC
        
        let date = post[indexPath.row]["create_time"] as! String
        
        // converting date string to date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
        let newDate = dateFormatter.date(from: date)!
        
        //declare settings
        let from = newDate
        let now = Date()
        let components:NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth]
        let difference = (Calendar.current as NSCalendar).components(components, from: from, to: now, options: [])
        
        //calculate date
        if difference.second! <= 0{
            cell.date.text = "now."
        }
        if difference.second! > 0 && difference.minute! == 0{
            cell.date.text = "\(difference.second!)s."
        }
        if difference.minute! > 0 && difference.hour! == 0{
            cell.date.text = "\(difference.minute!)m."
        }
        if difference.hour! > 0 && difference.day! == 0{
            cell.date.text = "\(difference.hour!)h."
        }
        if difference.day! > 0 && difference.weekOfMonth! == 0{
            cell.date.text = "\(difference.day!)s."
        }
        if difference.weekOfMonth! > 0{
            cell.date.text = "\(difference.weekOfMonth!)w."
        }
        cell.name.text = userVal!["username"] as? String
        cell.icon.image = profileImage.image
        cell.content.text = post[indexPath.row]["introduction"] as? String
        cell.title.text = post[indexPath.row]["title"] as? String
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.accessoryType = UITableViewCellAccessoryType.none
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell {
            let index = tableview.indexPath(for: cell)!.row
            if segue.identifier == "post"{
                let postVC = segue.destination as! PostContentViewController
                postVC.hidesBottomBarWhenPushed = true
                postVC.postContent = post[index] as! NSDictionary
                
                let backitem = UIBarButtonItem()
                backitem.title = ""
                navigationItem.backBarButtonItem = backitem
            }
        }
    }
    
    func loadPost(){
        let id = userVal!["id"] as! String
        let url = URL(string: "http://52.77.216.12/guestPost.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = "id=\(id)"
        request.httpBody = body.data(using: .utf8)
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async(execute:{
                if error == nil{
                    do{
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                        self.post.removeAll(keepingCapacity: false)
                        self.images.removeAll(keepingCapacity: false)
                        self.tableview.reloadData()
                        
                        //save data to json
                        guard let parseJSON = json else{
                            print("Error while parsing")
                            return
                        }
                        
                        //get json
                        guard let comm = parseJSON["post"] else {
                            print(parseJSON["message"] ?? [NSDictionary]())
                            return
                        }
                        
                        //get post json to posts array
                        self.post = comm as! [AnyObject]
                        self.tableview.reloadData()
                        
                        //get user image
                        for i in 0 ..< self.post.count{
                            let photo = self.post[i]["photo"] as? String
                            
                            //if is empty icon set default icon to she/he
                            if !photo!.isEmpty {
                                let url = URL(string: photo!)!
                                let imgData = try? Data(contentsOf: url)
                                let image = UIImage(data: imgData!)!
                                self.images.append(image)
                            }else{
                                let image = UIImage(named: "noimage.png")
                                self.images.append(image!)
                            }
                            
                        }
                        
                        self.tableview.reloadData()
                        self.refreshControl.endRefreshing()
                    }catch{
                        print(error)
                    }
                }else{
                    print(error!)
                }
            })
            }.resume()
    }
}
extension NSMutableData {
    
    func appendString(_ string : String) {
        
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
        
    }
}
