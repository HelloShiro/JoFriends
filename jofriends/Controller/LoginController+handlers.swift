//
//  LoginController+handlers.swift
//  jofriends
//
//  Created by SnoopyKing on 2017/11/20.
//  Copyright © 2017年 SnoopyKing. All rights reserved.
//

import UIKit
import Firebase

extension LoginController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func handleRegister(){
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else{
            print("Form is not valid")
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil{
                print(error!)
                return
            }
            guard let uid = user?.uid else{
                return
            }
            //successfully authenticted user
            let imageName = UUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
            
            if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1){
                
//            if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!){
                storageRef.putData(uploadData, metadata: nil
                    , completion: { (metadata, error) in
                        if error != nil {
                            print(error!)
                            return
                        }
                        if let profileImageUrl = metadata?.downloadURL()?.absoluteString{
                            let values = ["name":name,"email":email,"profileImageUrl":profileImageUrl]
                            self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])
                        }
                        
                })
            }
        }
    }
    
    private func registerUserIntoDatabaseWithUID(uid:String,values:[String:AnyObject]){
        let ref = Database.database().reference()
        let usersRef  = ref.child("users").child(uid)

        usersRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err!)
                return
            }
//            self.messagesController.navigationItem.title = values["name"] as! String
            let user = User()
            //this setter potentially crashes if key don't match
            user.email = values["email"] as? String
            user.name = values["name"] as? String
            user.profileImageUrl = values["profileImageUrl"] as? String
            self.messagesController.setupNavBarWithUser(user: user)
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    @objc func handleSelectProfileImageView(){
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker : UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        }else if let originalImg = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImg
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }

        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
}
