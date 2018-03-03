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

class MessagesController: UITableViewController, UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleNewMessage))
        
        //user is not logg
        
        checkIfUserIsLoggedIn()
       
    
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        checkIfUserIsLoggedIn()
//    }
    func fetchUsersAndSetNavBarTitle() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snap) in
            if let dictionary = snap.value as? [String : Any]   {
                
                self.navigationItem.title = dictionary["name"] as? String
                
                let user = User(dictionary: dictionary as [String : AnyObject])
                self.setupNavBarWithUser(user: user)
                
            }
            
        })
    }
    
    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    
    func checkIfUserIsLoggedIn()  {
        
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            
            handleLogout()
        } else {
           fetchUsersAndSetNavBarTitle()
            }
            
            
        }
    
    @objc func showChatController(forUser: User) {
        let chatLogController = ChatLogController()
        chatLogController.user = forUser
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    func setupNavBarWithUser(user: User) {
        let imageCache = NSCache<AnyObject, AnyObject>()
        var titleView: UIButton = UIButton()
      
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        //d
  
 
        let profileImage = UIImageView()
        
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        profileImage.clipsToBounds = true
        profileImage.contentMode = .scaleAspectFill
        profileImage.layer.cornerRadius = 20

        
        
        if let profileImageUrl = user.profileImageUrl {
            profileImage.loadImagesUsingCacheWithUrlString(urlString: profileImageUrl, imageCache: imageCache)
        containerView.addSubview(profileImage)
            
        profileImage.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 40).isActive =  true
            
            
        }
        let nameLabel = UILabel()
        containerView.addSubview(nameLabel)
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leftAnchor.constraint(equalTo: profileImage.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImage.heightAnchor).isActive = true
        
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        
        
        
        self.navigationItem.titleView = titleView
        
        //titleView.addTarget(self, action: #selector(showChatController), for: .touchUpInside)
        
        
    
        self.navigationItem.title = user.name
        
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
        loginController.messagesController = self
        present(loginController, animated: true, completion: nil)
    }
 
}

