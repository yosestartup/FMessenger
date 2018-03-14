//
//  NewMessageController.swift
//  FirebaseTest
//
//  Created by Александр on 25.02.18.
//  Copyright © 2018 hilton. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class NewMessageController: UITableViewController {

    
    let cellId = "cellId"
    let imageCache = NSCache<AnyObject, AnyObject>()
    var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        fetchUser()
        
        
     
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 99
    }
    func fetchUser() {
        Database.database().reference().child("users").observe(.childAdded) { (snap) in
            
            if let dictionary = snap.value as? [String:Any]
            {
                var user = User(dictionary: dictionary as [String : AnyObject])
                user.id = snap.key
                self.users.append(user)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
       
        }
    }
    
    var messagesController: MessagesController?
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.messagesController?.showChatController(forUser: user)
            
        }
    }
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? UserCell
        
        
        let user = users[indexPath.row]
        cell?.textLabel?.text = user.name
        cell?.detailTextLabel?.text = user.email
        
        if let profileImageUrl = user.profileImageUrl {
            cell?.profileImage.loadImagesUsingCacheWithUrlString(urlString: profileImageUrl, imageCache: imageCache)
        }
       
      
        return cell!
        }
    

}







extension UIImageView {
    func loadImagesUsingCacheWithUrlString (urlString: String, imageCache: NSCache<AnyObject, AnyObject>) {
        
        self.image = nil
        let url = NSURL(string: urlString)
        
        
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        
        URLSession.shared.dataTask(with: url as URL!, completionHandler: { (data, response, error) in
            
            if (error != nil) {
                print(error)
                return
            }
            DispatchQueue.main.async {
                
                if let downloadedImage = UIImage(data:data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                self.image = downloadedImage
                }
                
            }
            
            
        }).resume()
}
}
