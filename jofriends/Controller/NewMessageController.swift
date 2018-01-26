//
//  NewMessageController.swift
//  jofriends
//
//  Created by SnoopyKing on 2017/11/20.
//  Copyright © 2017年 SnoopyKing. All rights reserved.
//

import UIKit
import Firebase


class NewMessageController: UITableViewController {

    let cellId = "cellId"
    var users = [User]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        fetchUser()
    }
    
    func fetchUser(){
        Database.database().reference().child("users").observe(.childAdded) { (snapshot) in
            
            if let dic = snapshot.value as? [String:AnyObject]{
                let user = User()
                user.id = snapshot.key
                user.name = dic["name"] as? String
                user.email = dic["email"] as? String
                user.profileImageUrl = dic["profileImageUrl"] as? String
                self.users.append(user)
                //this will crash because of background thread, so lets use async
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }

        }
    }
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
//        cell.imageView?.image = UIImage(named: "cat2")
//        cell.imageView?.contentMode = .scaleAspectFill
        
        if let profileImageUrl = user.profileImageUrl{
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    var messageController : MessagesController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.messageController?.showChatLogControllerForUser(user: user)
            
        }
    }
}


