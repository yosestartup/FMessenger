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
    
    var messageDictionary = [String:Message]()
    var messages = [Message]()
    var cellId = "cellId"
    var cach = NSCache<AnyObject, AnyObject>()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleNewMessage))
        
        //user is not logg
        checkIfUserIsLoggedIn()
        observeUserMessages()
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
    }
    
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
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = forUser
        navigationController?.pushViewController(chatLogController, animated: true)
    }
   
    func setupNavBarWithUser(user: User) {
        messages.removeAll()
        messageDictionary.removeAll()
        tableView.reloadData()
        observeUserMessages()
        let imageCache = NSCache<AnyObject, AnyObject>()
        var titleView: UIButton = UIButton()
      
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
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
        self.navigationItem.title = user.name
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        cell.cache = self.cach
        cell.message = messages[indexPath.row]
        return cell
    }
    func observeMessages() {
        let ref = Database.database().reference().child("messages")
       
        ref.observe(.childAdded) { (snap) in
       
            print(snap)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = self.messages[indexPath.row]
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value) { (snap) in
            guard let dictionary = snap.value as? [String:Any]? else {
                return
            }
            let user = User(dictionary: dictionary as! [String : AnyObject])
            user.id = chatPartnerId
            self.showChatController(forUser: user)
        }
        
        
    }
    var timer: Timer?
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
    
    @objc func handleReload() {
        self.messages = Array(self.messageDictionary.values)
        if (self.messages.count > 1) {
            self.messages.sort(by: { (messageF, messageS) -> Bool in
                return messageF.timestamp!.intValue > messageS.timestamp!.intValue
            })
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded) { (snap) in
            let userId = snap.key
            Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snap) in
              let messageId =  snap.key
                let messageRef = Database.database().reference().child("messages").child(messageId)
                messageRef.observeSingleEvent(of: .value, with: { (snap) in
                    if let dictionary = snap.value as? [String:Any] {
                        
                        let message = Message(dictionary: dictionary)
                        self.messages.append(message)
                        
                        if let chatPartnerId = message.chatPartnerId()  {
                            self.messageDictionary[chatPartnerId] = message
                            
                        
                        }
                        self.attemptReloadOfTable()
                       
                    }
                })
            })
        }
    }
    func attemptReloadOfTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.handleReload), userInfo: nil, repeats: false)
    }
    
    
}

