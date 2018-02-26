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
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        fetchUser()
        
        
     
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
    }
    
    func fetchUser() {
        Database.database().reference().child("users").observe(.childAdded) { (snap) in
            
            if let dictionary = snap.value as? [String:Any]
            {
                var user = User(dictionary: dictionary as [String : AnyObject])
                self.users.append(user)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
       
        }
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        cell.imageView?.image = UIImage(named: "nedstark")
        
        return cell
    }

}




class UserCell: UITableViewCell
{
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle , reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
