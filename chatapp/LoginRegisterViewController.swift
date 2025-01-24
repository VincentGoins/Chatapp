//
//  LoginRegisterViewController.swift
//  chatapp
//
//  Created by Vincent Goins on 1/18/25.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuthInterop



class LoginRegisterViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var emailText: UITextField!
    

    @IBOutlet weak var passwordText: UITextField!
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        loginButton((Any).self)
        return true
    }
    
    
    @IBAction func loginButton(_ sender: Any) {
        
        if(!CheckInput()){
            return
        }
       
        
        let email = emailText.text
        let password = passwordText.text
        
        // Checks the database within Firebase to see if you're an existing user
        Auth.auth().signIn(withEmail: email!, password: password!, completion: { (user, error) in
            
            if let error = error{
                Utilities().ShowAlert(title: "Error!", message: "Incorrect Username or Password", viewcontroller: self)
                
                print(error.localizedDescription)
                return
            }
            else{
                print("Signed In")
                self.dismiss(animated: true)
                 
            }
        })
            
        }
    
   
    // Checking if both the username and password have a sufficient amount of
    // characters.
    func CheckInput() -> Bool{
        if emailText.text?.count ?? 0 < 6{
            emailText.backgroundColor = UIColor.red.withAlphaComponent(0.5)
            return false
        }
        else{
            emailText.backgroundColor = UIColor.white
           
        }
        if passwordText.text?.count ?? 0 < 6{
            passwordText.backgroundColor = UIColor.red.withAlphaComponent(0.5)
            return false
        }
        else{
            passwordText.backgroundColor = UIColor.white
            
        }
        
        
        return true
    }
           
    
    
    
    // Registering the user.
    @IBAction func registerButton(_ sender: Any) {
        if(!CheckInput()){
            return
        }
        
        // Getting a reference to Database
        let ref = Database.database().reference()
        
        // Gets the registration alert screen
        let alert = UIAlertController(title: "Register", message: "Please check Password", preferredStyle: .alert)
        
        
        alert.addTextField{
            (textField) in
            textField.placeholder = "Create Username"
        }
        
        //Creating a field for the user to type the new password!
        alert.addTextField{(textField) in
            textField.placeholder = "Retype Password"
        }
       
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {
            (action) in
            
            // Collecting the second value of the input text in the above textfield.
            let passwordConfirm = alert.textFields![1] as UITextField
            if passwordConfirm.text!.isEqual(self.passwordText.text!){
                
                
                let email = self.emailText.text
                let password = self.passwordText.text
                
                // Creates a new user with the input credentials.
                Auth.auth().createUser(withEmail: email!, password: password!, completion: { (user, error) in
                    if let error = error{
                        Utilities().ShowAlert(title: "Error", message: error.localizedDescription, viewcontroller: self)
                        return
                    }
                })
                
                
               // Creating username
                let userName = alert.textFields![0] as UITextField
                
                if(userName.text?.count ?? 0 < 1){
                    Utilities().ShowAlert(title: "Error", message: "Please input valid Username!", viewcontroller: self)
                    return
                }
                
                // Firebase keys can't contain '.' so replace it with ','
                let safeEmail = email!.replacingOccurrences(of: ".", with: ",")
                
                // Creates an email container for the user data and stores the input
                // username with it.
                ref.child("users").child(safeEmail).observeSingleEvent(of: .value){
                    (snapshot) in
                    
                    if snapshot.exists(){
                        Utilities().ShowAlert(title: "Error", message: "Email already exists!", viewcontroller: self)
                    }else{
                        
                        let userData = ["username": userName.text!]
                        
                        ref.child("users").child(safeEmail).setValue(userData){
                            error,_ in
                            
                            if let error = error{
                                print(error.localizedDescription)
                            }
                            else{
                                print("Good to go!")
                            }
                            
                        }
                    }
                }
                
                 
                
            }
            else{
                // If the password in the textField doesn't match the one in the password
                // text box.
                Utilities().ShowAlert(title: "Error", message: "Passwords don't match", viewcontroller: self)
            }
            
            
        }))
       
        
        self.present(alert, animated: true, completion: nil)
        

    }
    
    
    @IBAction func forgotButton(_ sender: Any) {
        
        // Checking if there is the proper amount of text for email.
        if emailText.text?.count ?? 0 < 6{
            emailText.backgroundColor = UIColor.red.withAlphaComponent(0.5)
            return
        }
        else{
            emailText.backgroundColor = UIColor.white

        }
        
        
        let alert = UIAlertController(title: "Password Reset", message: "Are you sure you want to change your password?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: {
            (action) in
            
           
                
            // Sends password to user's email!
            Auth.auth().sendPasswordReset(withEmail: self.emailText.text!, completion: { (error) in
                
                if let error = error{
                    Utilities().ShowAlert(title: "Error!", message: error.localizedDescription, viewcontroller: self)
                    return
                }
                else{
                    Utilities().ShowAlert(title: "Confirmed!", message: "Email has been sent!", viewcontroller: self)
                }
            })
            
            
            
            
        }))

                self.present(alert, animated: true)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.passwordText.delegate = self
        
        // Changing the placeholder text to have more color.
        emailText.attributedPlaceholder = NSAttributedString(
            string: "Email"
            , attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.gray.withAlphaComponent(0.7)]
            )
        passwordText.attributedPlaceholder = NSAttributedString(
            string: "Password"
            , attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.gray.withAlphaComponent(0.7)]
            )
        
       
        // Gets a TapGestureRecognizer to remove the keyboard when you tap off the text
        // field.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginRegisterViewController.dismissKeyboard))
        
        
        view.addGestureRecognizer(tap)
        
        
        
    }
    
    // Causes the view to end the editing of the field it was editing.
    @objc func dismissKeyboard(){
       view.endEditing(true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
