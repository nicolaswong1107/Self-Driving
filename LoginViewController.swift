//
//  ViewController.swift
//  Self-Driving
//
//  Created by Nicolas Wong on 12/27/16.
//  Copyright © 2016 Nicolas Wong. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pwdField: UITextField!
    @IBOutlet weak var pwdView: UIButton!
    var pwdString:String!
    override func viewDidLoad() {
    }
    
    //tap login
    @IBAction func LoginTapped(_ sender: Any) {
        let username = emailField.text
        let password = pwdField.text
        
        if username != "" || password != ""{
            if (username?.isEmail)!{
            self.view.endEditing(true)
            DoLogin(user: username!, pwd: password!)
            }else{
                Notification(tit: "Notification", msg: "please enter valid email!", action: "OK")
            }
        }else{
        Notification(tit: "Error" , msg: "Username and password must required!", action: "OK")
        }
    }
    
    //do login process
    func DoLogin(user:String, pwd:String){
        let url = URL(string: "http://52.77.216.12/IOSLogin.php")
        let session = URLSession.shared
        
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let postString = "user=\(user)&pwd=\(pwd)"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        let task = session.dataTask(with: request){ data, response, error in
            if error == nil{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                    
                    guard let parseJSON = json else {
                        print("Error while parsing")
                        return
                    }
                    
                    let id = parseJSON["id"] as? String
                    
                    if(id != nil){
                        //put json.data to userDefaults
                        UserDefaults.standard.set(parseJSON, forKey: "parseJSON")
                        userVal = UserDefaults.standard.value(forKey: "parseJSON") as? NSDictionary
                        DispatchQueue.main.async(execute: {appDelegate.login()})
                    }else{
                        let message = parseJSON["islogin"] as! String
                        DispatchQueue.main.async(execute: {self.Notification(tit: "Error", msg: message, action: "OK")})
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
    
    // Set showpwdBtn show
    func passwordViewConfig(){
        pwdView.setTitle("Show", for: UIControlState.normal)
    }
    
    // set showpwdBtn show/off
    @IBAction func PwdViewAction(_ sender: Any) {
        pwdString = pwdField.text
        if pwdView.currentTitle! == "Show"{
            pwdView.setTitle("Hide", for: UIControlState.normal)
            pwdField.isSecureTextEntry = false
            pwdField.text = nil
            pwdField.text = pwdString
        }else{
            pwdView.setTitle("Show", for: UIControlState.normal)
            pwdField.isSecureTextEntry = true
            pwdField.text = pwdString
        }
    }
    
    //alert method
    func Notification(tit:String, msg: String, action: String) -> Void {
        let alert = UIAlertController(title: tit, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: action, style: .default, handler:nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // hide keyboard
        self.view.endEditing(false)
    }
}
