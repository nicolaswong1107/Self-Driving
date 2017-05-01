//
//  ViewPostTableViewController.swift
//  Self-Driving
//
//  Created by Nicolas Wong on 3/1/17.
//  Copyright © 2017 Nicolas Wong. All rights reserved.
//

import UIKit

class ViewPostTableViewController: UITableViewController {
    
    var posts = [AnyObject]()
    var photos = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(self.loadingPost), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadingPost()
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return posts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "posts", for: indexPath) as! ViewPostTableViewCell
        
        let post = posts[indexPath.row]
        let photo = photos[indexPath.row]
        let content = post["introduction"] as? String
        let name = post["name"] as? String
        let title = post["title"] as? String
        let date = post["create_time"] as! String
        
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
        
        cell.username.text = name
        cell.usericon.image = photo
        cell.content.text = content
        cell.titles.text = title
        cell.accessoryType = UITableViewCellAccessoryType.none
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell {
            let index = tableView.indexPath(for: cell)!.row
            if segue.identifier == "post"{
                let postVC = segue.destination as! PostContentViewController
                postVC.hidesBottomBarWhenPushed = true
                postVC.postContent = posts[index] as! NSDictionary
                
                let backitem = UIBarButtonItem()
                backitem.title = ""
                navigationItem.backBarButtonItem = backitem
            }
        }
    }
    
    func loadingPost(){
        let id = userVal!["id"] as! String
        let url = URL(string: "http://52.77.216.12/getPostList.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = "id=\(id)"
        request.httpBody = body.data(using: .utf8)
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async(execute:{
                if error == nil{
                    do{
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                        self.posts.removeAll(keepingCapacity: false)
                        self.photos.removeAll(keepingCapacity: false)
                        self.tableView.reloadData()
                        
                        //save data to json
                        guard let parseJSON = json else{
                            print("Error while parsing")
                            return
                        }
                        
                        //get json
                        guard let post = parseJSON["post"] else {
                            print(parseJSON["message"] ?? [NSDictionary]())
                            return
                        }
                        
                        //get post json to posts array
                        self.posts = post as! [AnyObject]
                        self.tableView.reloadData()
                        
                        //get user image
                        for i in 0 ..< self.posts.count{
                            let photo = self.posts[i]["photo"] as? String
                            
                            //if is empty icon set default icon to she/he
                            if !photo!.isEmpty {
                                let url = URL(string: photo!)!
                                let imgData = try? Data(contentsOf: url)
                                let image = UIImage(data: imgData!)!
                                self.photos.append(image)
                            }else{
                                let image = UIImage(named: "noimage.png")
                                self.photos.append(image!)
                            }
                        }
                        
                        self.tableView.reloadData()
                        self.refreshControl?.endRefreshing()
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



