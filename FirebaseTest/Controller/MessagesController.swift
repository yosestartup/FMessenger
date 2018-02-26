//
//  ViewController.swift
//  FirebaseTest
//
//  Created by Александр on 22.02.18.
//  Copyright © 2018 hilton. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class MessagesController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleNewMessage))
        
        //user is not logg
       checkIfUserIsLoggedIn()
    
    }
    
    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    
    func checkIfUserIsLoggedIn()  {
        
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            
            handleLogout()
        } else {
            if let uid = Auth.auth().currentUser?.uid {
                Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snap) in
                    if let dictionary = snap.value as? [String : Any]   {
                         self.navigationItem.title = dictionary["name"] as? String
                    }
                    
                })
            }
            
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @objc func handleLogout() {
        do {
            try  Auth.auth().signOut()
        } catch
            let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }
}

