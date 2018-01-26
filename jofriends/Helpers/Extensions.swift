//
//  Extensions.swift
//  jofriends
//
//  Created by SnoopyKing on 2017/11/21.
//  Copyright © 2017年 SnoopyKing. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView{
    
    
    
    func loadImageUsingCacheWithUrlString(urlString: String){
        self.image = nil
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject){
            self.image = cachedImage as? UIImage
            return
        }
            //otherwise fire off a new download
            let url = URL(string: urlString)
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }
                DispatchQueue.main.async {
                    if let downloadedImage = UIImage(data: data!){
                        imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                        self.image = downloadedImage
                    }
                }
            }).resume()
        }
}
