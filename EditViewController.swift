//
//  EditViewController.swift
//  Self-Driving
//
//  Created by Nicolas Wong on 2/1/17.
//  Copyright © 2017 Nicolas Wong. All rights reserved.
//

import UIKit

class EditViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var userField: UITextField!
    @IBOutlet weak var pwdField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()                

    }
    
    @IBAction func saveProfile(_ sender: Any) {
        if emailField.text!.isEmail == true{
//            if pwdField.text == pwdAga.text && pwdField.text != "" && pwdAga.text != ""{
                    edit()
            }else{
                Notification(tit: "Notification", msg: "please enter valid email!", act: "OK")
            }
//        }else{
//            Notification(tit: "Notification", msg: "please enter same password twice, if not edit", act: "OK")
//        }
    }
    
    func edit(){
        let email = emailField.text
        let name = userField.text
        let pwd = pwdField.text
        let id = userVal!["id"] as! String
//        editProfileIOS.php  editUser.php
        
        var request = URLRequest(url: NSURL(string: "http://52.77.216.12/editProfileIOS.php") as! URL)
        request.httpMethod = "POST"
        let postString = "id=\(id)&email=\(email!)&name=\(name!)&pwd=\(pwd!)"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil{
                print("error = \(error!)")
                return
            }
                print("response: \(response!)")
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                print("result: \(json!)")
                
                guard let parseJSON = json else {
                    print("Error while parsing")
                    return
                }
                
                let id = parseJSON["id"] as? String
                
                if(id != nil){
                    UserDefaults.standard.set(parseJSON, forKey: "parseJSON")
                    userVal = UserDefaults.standard.value(forKey: "parseJSON") as? NSDictionary
                    DispatchQueue.main.async(execute: {self.Notification(tit: "Notification", msg: "update successful", act: "OK")})
                }else{
                    DispatchQueue.main.async(execute: {self.Notification(tit: "Error", msg: "update fail", act: "OK")})
                }
            }catch{
                print("Fetch failed: \((error as NSError).localizedDescription)")
            }
        }
        task.resume()
    }
    
    func Notification(tit:String, msg:String, act:String){
        let alert = UIAlertController(title: "Notification", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: act, style: .default){ ACTION in self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // hide keyboard
        self.view.endEditing(false)
    }
}
