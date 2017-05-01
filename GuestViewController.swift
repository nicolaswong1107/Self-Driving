//
//  GuestViewController.swift
//  Self-Driving
//
//  Created by Nicolas Wong on 3/1/17.
//  Copyright © 2017 Nicolas Wong. All rights reserved.
//

import UIKit

class GuestViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl: UIRefreshControl!
    
    //guest information
    var guest = NSDictionary()
    var post = [AnyObject]()
    var images = [UIImage]()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadPost()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let username = guest["name"] as? String
        let email = guest["email"] as? String
        let photo = guest["photo"] as? String
        
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
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.loadPost), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)

        
        self.view.layoutIfNeeded()
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.clipsToBounds = true
        profileImage.layer.borderColor = UIColor.black.cgColor
        profileImage.layer.borderWidth = 1
        
        self.navigationItem.title = username        
    }

    func Notification(tit:String, msg:String, act:String){
        let alert = UIAlertController(title: tit, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: act, style: .default){ ACTION in self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post.count
    }
    
    func  tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gpost", for: indexPath) as! GuestTVC
        
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
        cell.name.text = post[indexPath.row]["name"] as? String
        cell.content.text = post[indexPath.row]["introduction"] as? String
        cell.icon.image = images[indexPath.row]
        cell.Title.text = post[indexPath.row]["title"] as? String
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.accessoryType = UITableViewCellAccessoryType.none
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell {
            let index = tableView.indexPath(for: cell)!.row
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
        let id = guest["blogger_id"] as? String
        let url = URL(string: "http://52.77.216.12/guestPost.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = "id=\(id!)"
        request.httpBody = body.data(using: .utf8)
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async(execute:{
                if error == nil{
                    do{
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                        self.post.removeAll(keepingCapacity: false)
                        self.images.removeAll(keepingCapacity: false)
                        self.tableView.reloadData()
                        
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
                        self.tableView.reloadData()
                        
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
                        
                        self.tableView.reloadData()
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

