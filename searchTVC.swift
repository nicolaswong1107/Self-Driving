//
//  searchTVC.swift
//  Self-Driving
//
//  Created by Nicolas Wong on 2/15/17.
//  Copyright © 2017 Nicolas Wong. All rights reserved.
//

import UIKit

class searchTVC: UITableViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    var users = [AnyObject]()
    var photos = [UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.barTintColor = .white
        searchBar.showsCancelButton = false
    }
    
    //did change search text
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //php request
        doSearch(searchBar.text!)
    }
    
    //being text editing show cancle button
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
//        searchBar.showsScopeBar = true
    }
    
    //cancle button click
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(false)
        searchBar.showsCancelButton = false
        searchBar.text = ""
        
        //clean
        users.removeAll(keepingCapacity: false)
        photos.removeAll(keepingCapacity: false)
        tableView.reloadData()
//        searchBar.showsScopeBar = false
//        doSearch("")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {        
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! searchCell
        
        let user = users[indexPath.row]
        let photo = photos[indexPath.row]
        let username = user["name"] as? String
        cell.Uname.text = username
        cell.Uimage.image = photo
        
        return cell
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
//        doSearch(searchBar.text!)
    }
    
    func doSearch(_ word: String){
        let id = userVal!["id"] as! String
        let word = searchBar.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let url = URL(string: "http://52.77.216.12/search.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = "id=\(id)&word=\(word)"
        request.httpBody = body.data(using: .utf8)
        URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async(execute:{
                    if error == nil{
                    do{
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        //clean up
                        self.users.removeAll(keepingCapacity: false)
                        self.photos.removeAll(keepingCapacity: false)
                        self.tableView.reloadData()
                        
                        //save data to json
                        guard let parseJSON = json else{
                            print("Error while parsing")
                            return
                        }
                        //get url array
                        guard let parseUSERS = parseJSON["users"] else {
                            print(parseJSON["message"] ?? [NSDictionary]())
                            return
                        }
                        
                        //append user array to self.users
                        self.users = parseUSERS as! [AnyObject]
                        
                        //get user image
                        for i in 0 ..< self.users.count{
                            let photo = self.users[i]["photo"] as? String
                            
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
                        //reload data
                        self.tableView.reloadData()
                        
                    }catch{
                        print(error)
                    }
                    }else{
                        print(error!)
                    }
                })
            }.resume()
    }
    
    //make segue to another view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell {
            let index = tableView.indexPath(for: cell)!.row
            if segue.identifier == "guest"{
                let guestVC = segue.destination as! GuestViewController
                guestVC.guest = users[index] as! NSDictionary
                
                let backitem = UIBarButtonItem()
                backitem.title = ""
                navigationItem.backBarButtonItem = backitem                
            }
        }
    }
}
