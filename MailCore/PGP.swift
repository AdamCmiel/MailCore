//
//  PGP.swift
//  MailCore
//
//  Created by Adam Cmiel on 1/19/16.
//  Copyright © 2016 Adam Cmiel. All rights reserved.
//

import Foundation

        
//        let req = NSMutableURLRequest(URL: NSURL(string: "http://pgp.mit.edu/pks/add")!)
//        let myReqString = "keytext=-----BEGIN+PGP+PUBLIC+KEY+BLOCK-----%0D%0AComment%3A+GPGTools+-+https%3A%2F%2Fgpgtools.org%0D%0A%0D%0AmQENBFaR%2BaMBCAC0HdIZzpqHXehCAhnAsraNzxcr27io1SfG7ba2fokv7wvI1qt5%0D%0Aliwg7Sw8%2BhGyz%2BN2npYHxcGylvMp8oUny1fwtmu5ZrKXiVXzgF0kaC%2FB8gapYF%2BU%0D%0AwG47oMhWze4B4p9rkY%2FZtMrKDUhrTeyE1Tx2gwAxN4hTcW0betJ0vuRcQMrvxO7h%0D%0AH7E0UHELyqzFSrKzeEzSOJb4qATjrjkxeXobv4juJyqBDvPlHGLzbYc3gxdEPhIG%0D%0AV1zkmGwJaeW7ckEtW5NEamfiL7rx5uefKqpwYImJLSiqlz2tAXi6kv98IvnK2mxN%0D%0AHN358zsyxXWcs%2BAF1UbWvxRe2d94bXCJRgUtABEBAAG0IGZvb2JhciAoZm9vYmFy%0D%0AYmF6KSA8Zm9vQGJhci5iYXo%2BiQE3BBMBCgAhBQJWkfmjAhsDBQsJCAcDBRUKCQgL%0D%0ABRYCAwEAAh4BAheAAAoJELljTzPk2JUzy%2FcH%2F3DtNRfhwKdG9k8EGZ0wiLxe36VK%0D%0A2eawNMbP4WRGIp%2FmFbeqsXe%2Fo1g21%2B%2FTbEboZdodzmjYNI06mvINH9Xz2beDyJqD%0D%0A6X%2Bx%2BP80zizR6YqOX4yGkI%2F1v5G7QsiLdvEEviXl3whTBppEVDcAfx31cW0gS%2F9t%0D%0A0FfRpqLacD0gfJvd4vYmSg0fBP4%2BL6fBPtfHkzd8SS2xpkgVZoqT0TF7XR82WfPN%0D%0A2pvqhhctuWlOgCqR7AEVdIFqDRa01NKGsb9f2fgPJcrCQTST3v8Ixd3RsuwZnAnH%0D%0AnNlFnJHr7OmstZ1gBrDeM8tuTV8KdA%2Btepz2JDjcfWyxLx05rbVuQAxr9Lm5AQ0E%0D%0AVpH5owEIANo1YDkLXPzLCjtkfXCoUnffY%2Fs%2F2PoMFJkokJzZy4tFtsxrxs%2BqO4pe%0D%0ATxjijqkR4JQ4yfiABvb8djBCqXk5FhRzlI3P8zcGMi%2FlUjUOCq7bg2lkw4Pq0bW6%0D%0AjfJ2sM5VS0k4tDOq2BdjVVzKfPMpIPU3glfy8%2FJvw%2FP66CQrOuB3iMEN9%2FTAdO8g%0D%0APmg5wVYkSMG7gd7OBKDjraPLlKpzRo6aKtr0nEARHCJ6hKIEQioV1lKibEje1Xd5%0D%0AtKan8816iMT5gVb33f2EdjwU1WZu6mnXKQBWOFIxGF6nR4wbHmLFcGyscccCj6MI%0D%0AdEDWs9mL3GMpHl8Mz0HerNGtNIMkWS8AEQEAAYkBHwQYAQoACQUCVpH5owIbDAAK%0D%0ACRC5Y08z5NiVM%2FKdB%2F0bxelQ%2B2P9IQFjPhc7ntQVlOzO%2FTNy%2BJv8WzPrWxJTopqh%0D%0AgrtBHexTQGyoYtt%2BZ2OAl7BfvpXW3RTXeEwYsE%2F15yNVH6kCidmpAerKXWfmHo38%0D%0Au%2B06AeAeGo72c3vEN9Vncd%2BEEylB4%2BlMICKydEopwmZTnrvGWGOqbNGJ%2FGbWDqOh%0D%0ATB10iu8wD0r1scTPnT3sxRVSXJJwjVMoodXZTSnlXShJUTsKIvLB2PXWXzBTiW3m%0D%0Ajc6YknNyEZ3iDMsq5y2epUtle8l8xepZtNyMBsHNztqH248yg8%2BOdN4GxMUaeCil%0D%0AsxtefvAgwEiOYXuFyyTp6GZiQD9k8RSfLcFLutg4%0D%0A%3DmIfk%0D%0A-----END+PGP+PUBLIC+KEY+BLOCK-----"
//        
//        //let myReqString = "keytext=foobar"
//        
//        let myReqData = myReqString.dataUsingEncoding(NSUTF8StringEncoding)
//        req.HTTPBody = myReqData
//        req.HTTPMethod = "POST"
//        
//        //let data = NSURLConnection.sendSynchronousRequest(req, returningResponse: nil)
//        let task = NSURLSession.sharedSession().dataTaskWithRequest(req) { (data, response, error) -> Void in
//            
//            guard error == nil else {
//                
//                print(error!.localizedDescription)
//                return
//            }
//            
//            let statusCode = (response as! NSHTTPURLResponse).statusCode
//            switch statusCode {
//                
//            case 500:
//                let returnString = String(data: data!, encoding: NSASCIIStringEncoding)
//                print("saving key failed")
//                print(returnString)
//                
//            case 200:
//                let returnString = String(data: data!, encoding: NSASCIIStringEncoding)
//                print("saving key succeeded")
//                print(returnString)
//                
//            default:
//                fatalError()
//                
//            }
//        }
//        
//        task.resume()
//        // Do any additional setup after loading the view, typically from a nib.