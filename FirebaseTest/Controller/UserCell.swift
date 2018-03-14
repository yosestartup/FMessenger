//
//  UserCell.swift
//  FirebaseTest
//
//  Created by Александр on 03.03.18.
//  Copyright © 2018 hilton. All rights reserved.
//

import UIKit
import Firebase
class UserCell: UITableViewCell
{
    let time: UILabel = {
        let label = UILabel()
        //
         label.text = "HH:MM"
        label.font.withSize(12)
        label.textColor = UIColor.lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var cache = NSCache<AnyObject, AnyObject>()
    var message: Message?
    {
        didSet {
            setupNameAndProfile()
            
            if let seconds = message?.timestamp?.doubleValue {
                let timestampDate = NSDate(timeIntervalSince1970: seconds)
                let dateFormat = DateFormatter()
                dateFormat.dateFormat = "hh:mm:ss a"
                time.text = dateFormat.string(from: timestampDate as Date)
            }
            
            self.detailTextLabel?.text = message?.text
            
            
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    let profileImage: UIImageView = {
        let imageView = UIImageView()
        //imageView.image = UIImage(named: "logo-logomark")
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle , reuseIdentifier: reuseIdentifier)
        addSubview(time)
        addSubview(profileImage)
        
        //x,y, width, height
        profileImage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImage.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 50).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 50).isActive = true
        //x,y, width, height
        time.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        time.topAnchor.constraint(equalTo: self.topAnchor, constant: 17).isActive = true
        time.widthAnchor.constraint(equalToConstant: 100).isActive = true
        time.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
    }
    func setupNameAndProfile() {
        
        if let id = message?.chatPartnerId() {
            let ref = Database.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snap) in
                if let dictionary = snap.value as? [String: Any] {
                    self.textLabel?.text = dictionary["name"] as? String
                    if let profileImageUrl = dictionary["profileImageUrl"] {
                        
                        self.profileImage.loadImagesUsingCacheWithUrlString(urlString: profileImageUrl as! String, imageCache: self.cache)
                    }
                }
            })
        }

    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
