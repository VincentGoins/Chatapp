//
//  Utilities.swift
//  chatapp
//
//  Created by Vincent Goins on 1/18/25.
//

import Foundation
import UIKit

class Utilities{
    
    
    func ShowAlert(title: String, message: String, viewcontroller: UIViewController){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        //Alert becomes a viewcontroller itself.
        viewcontroller.present(alert, animated: true, completion: nil)
    }
    
    
    //Gets current time
    func getCurrentTime()-> String{
        let date = Date()
        
        //DateFormatter formats the date string
        let formatter = DateFormatter()
        
        //Choosing from the enum values in the DateFormatter class
        
        //The date style is set to none because we're only using time.
        formatter.dateStyle = .none
        
        //short, medium, and long cases will give you different amounts of
        //information regarding the time.
        formatter.timeStyle = .short
        
        let time = formatter.string(from: date)
        
        return time
    }
}
