//
//  SignUpViewController.swift
//  Self-Driving
//
//  Created by Nicolas Wong on 12/27/16.
//  Copyright © 2016 Nicolas Wong. All rights reserved.
//

import UIKit
import Foundation

class SignUpViewController: UIViewController {
    
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var pwdField: UITextField!
    @IBOutlet weak var pwdAgain: UITextField!
    

    @IBAction func SignUpTapped(_ sender: UIButton) {
        if emailField.text != "" && nameField.text != "" && pwdField.text != "" && pwdAgain.text != ""{
            if pwdField.text == pwdAgain.text{
                if emailField.text!.isEmail == true{
                    signIn()
                }else{
                    Notification(tit: "Notification", msg: "please enter valid email!", act: "OK")
                }
            }else{
                Notification(tit: "Notification", msg: "Please enter same password twice!", act: "OK")
            }
        }else{
            Notification(tit: "Notification", msg: "Please fill all block!", act: "OK")
        }
    }
    
    func signIn(){
        let email = emailField.text
        let name = nameField.text
        let pwd = pwdField.text
        
        var request = URLRequest(url: NSURL(string: "http://52.77.216.12/register.php") as! URL)
        request.httpMethod = "POST"
        let postString = "email=\(email!)&name=\(name!)&password=\(pwd!)"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil{
                print("error = \(error!)")
                return
            }else{
                print("response = \(response!)")
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200{
                print("statusCode: \(httpStatus.statusCode)")
                print("response: \(response!)")
            }
            do{
                let json : NSDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                print("result: \(json)")
                let checkName = json.object(forKey: "checkName")as! Bool
                let checkEmail = json.object(forKey: "checkEmail")as! Bool
                if checkEmail == false{
                    DispatchQueue.main.async (execute: {self.Notification(tit: "Error", msg: "This email has been registered.", act: "OK")})
                }else if checkName == false{
                    DispatchQueue.main.async(execute: {self.Notification(tit: "Error", msg: "This username has been used.", act: "OK")})
                }
                if checkName && checkEmail == true{
                    DispatchQueue.main.async(execute: {self.Notification(tit: "Notification", msg: "Registration is successful.", act: "OK")})
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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

    }    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // hide keyboard
        self.view.endEditing(false)
    }
}
