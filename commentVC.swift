//
//  commentTVC.swift
//  Self-Driving
//
//  Created by Nicolas Wong on 3/31/17.
//  Copyright © 2017 Nicolas Wong. All rights reserved.
//

import UIKit

class commentVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var selfIcon: UIImageView!
    @IBOutlet weak var selfName: UILabel!
    @IBOutlet weak var commentText: UIText!
    @IBOutlet weak var tableView: UITableView!

    var images = [UIImage]()
    var comments = [AnyObject]()
    var comment = NSDictionary()
    var refreshControl: UIRefreshControl!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadComment()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = comment["title"] as? String
        selfName.text = userVal?["username"] as? String
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.loadComment), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        let photo = userVal?["photo"] as? String
        if photo != "" {
            
            let imageURL = URL(string: photo!)!
            
            DispatchQueue.main.async(execute: {
                
                let imageData = try? Data(contentsOf: imageURL)
                
                if imageData != nil {
                    DispatchQueue.main.async(execute: {
                        self.selfIcon.image = UIImage(data: imageData!)
                    })
                }
            })
            
        }
        selfIcon.layer.cornerRadius = selfIcon.frame.size.width/2
        selfIcon.clipsToBounds = true

    }
    
    //tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "comment", for: indexPath) as! commentTVC
        
        let date = comments[indexPath.row]["create_time"] as? String
        
        // converting date string to date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
        let newDate = dateFormatter.date(from: date!)!
        
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
        cell.name.text = comments[indexPath.row]["name"] as? String
        cell.comment.text = comments[indexPath.row]["content"] as? String
        cell.icon.image = images[indexPath.row]
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
    }
    
    func loadComment(){
        let pId = comment["post_id"] as! String
        let url = URL(string: "http://52.77.216.12/readComment.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = "postId=\(pId)"
        request.httpBody = body.data(using: .utf8)
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async(execute:{
                if error == nil{
                    do{
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                        self.comments.removeAll(keepingCapacity: false)
                        self.images.removeAll(keepingCapacity: false)
                        self.tableView.reloadData()
                        
                        //save data to json
                        guard let parseJSON = json else{
                            print("Error while parsing")
                            return
                        }
                        
                        //get json
                        guard let comm = parseJSON["comment"] else {
                            print(parseJSON["message"] ?? [NSDictionary]())
                            return
                        }
                        
                        //get post json to posts array
                        self.comments = comm as! [AnyObject]
                        self.tableView.reloadData()
                        
                        //get user image
                        for i in 0 ..< self.comments.count{
                            let photo = self.comments[i]["photo"] as? String
                            
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
    
    @IBAction func submitComment(_ sender: Any) {
        let com = commentText.text!
        let pId = comment["post_id"] as! String
        let id = userVal?["id"] as! String
        let url = URL(string: "http://52.77.216.12/postComment.php")!
        if !commentText.text.isEmpty {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let body = "pid=\(pId)&id=\(id)&comment=\(com)"
            request.httpBody = body.data(using: .utf8)
            URLSession.shared.dataTask(with: request) { data, response, error in
                }.resume()
            commentText.text = ""
            tableView.reloadData()
        }else{
            commentText.text = "please enter soem text"
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // hide keyboard
        self.view.endEditing(false)
    }
}
