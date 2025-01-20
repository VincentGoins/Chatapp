//
//  ViewController.swift
//  chatapp
//
//  Created by Vincent Goins on 1/16/25.
//

import UIKit
import Firebase

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var textField: UITextField!
    
    // Gets an array of data from the datasnapshot class.
    // Each element in array contains an index with
    // a specific node in the Firebase Database.
    var messages: [DataSnapshot] = [DataSnapshot]()
    
   // var users: [DataSnapshot] = [DataSnapshot]()
    
    // Getting a reference to Database to read or write to it.
    var ref: DatabaseReference!
    
    // Identifies listeners for database events.
    private var _refHandle: DatabaseHandle!
    
   
    // Global variable to assign the user to.
    var user: String = ""
    
    func ConfigureDatabase(){
        // Accessing the database contents through a reference
        ref = Database.database().reference()
        
        // Writing to the database through the childAdded event type,
        // using the child named messages. Creates a Datasnapshot to
        // append to the database array. Listener is assigned to look for changes
        // within the database
        _refHandle = self.ref.child("messages").observe(.childAdded, with: {
            (snapShot) in
            
            //Appending and inserting into the Database cells and Table cells. Using count - 1 because of 0 indexing.
            self.messages.append(snapShot)
            self.tableView.insertRows(at: [IndexPath(row: self.messages.count - 1, section: 0)], with: .automatic)
            
        })
        
        
       /* self.ref.child("users").observe(.value) { (snapshot) in
            self.users.append(snapshot)
        }*/
    }
    
    // Controls what happens when the return key is pressed on a keyboard.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.text?.count == 0 {
            return false
        }
        
        
        let Data = [Constants.MessageFields.text : textField.text!]
        SendMessage(data: Data)
        self.view.endEditing(true)
        textField.text = ""
        return true
    }
    
   
    
    // Using a dictionary with [String : String] because that's how Firebase formats its messages.
    func SendMessage(data: [String : String]){
        var packet = data
        packet[Constants.MessageFields.dateTime] = Utilities().getCurrentTime()
        packet[Constants.MessageFields.user] = self.user
        
        // Setting the new child's value to the packet value in the Database.
        self.ref.child("messages").childByAutoId().setValue(packet)
    }
    
    // Everytime this view appears this method is called
    override func viewWillAppear(_ animated: Bool) {
       
        
        // Checking if the current user is authorized!
        if Auth.auth().currentUser == nil {
           
            
            // Making the viewcontroller go to the login page
            // because there is no currentUser information!
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "fireBaseLogin")
            
            self.navigationController?.present(vc!, animated: true, completion: nil)

            
        }
        
        getUserName{
            username in
            self.user = username!
        }
        
        textField.attributedPlaceholder = NSAttributedString(
            string: "Message"
            , attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.gray.withAlphaComponent(0.7)]
            )
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        
        // Gets the value of the message datasnapshot
        // and assigns its text value to the text of the
        // cell.
        let messageSnapshot = self.messages[indexPath.row]
        let message = messageSnapshot.value as! Dictionary<String, String>
        let text = (message[Constants.MessageFields.user] ?? "No User") + ": " + (message[Constants.MessageFields.text] ?? "No message")
        let time = message[Constants.MessageFields.dateTime]
        
        
        
        var content = cell.defaultContentConfiguration()
        content.text = text
        content.secondaryText = time
        cell.contentConfiguration = content
        
        return cell
        
    }
    
    
    
   
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
       // Logout before the app has started after being terminated!
       do{
            try Auth.auth().signOut()
            print("Signed In")
        }
        catch{
            print("not signed in")
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.textField.delegate = self
        
        ConfigureDatabase()
         
        // Broadcasts notifcation to registered observers
        // to allow them to listen to events and respond.
        // (name) gives the event to listen for.
        NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(keyboardWillShow),
                    name: UIResponder.keyboardWillShowNotification,
                    object: nil
                )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        
    
        // Gets a TapGestureRecognizer to remove the keyboard when you tap off the text
        // field.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginRegisterViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    
    }

    //Causes the view to end the editing of the field it was editing.
    @objc func dismissKeyboard(){
       view.endEditing(true)
    }
    
    
    
    @objc func keyboardWillShow(_ sender: NSNotification){
        // Gathers the keyboard event information and
        // the Frame of the rectangle containing the keyboard
        if let userInfo = sender.userInfo,
           let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            
            // Making sure there is a text field
            let activeTextField = self.textField {
                
                // Getting keyboard height
                let keyboardHeight = keyboardFrame.cgRectValue.height
                
                // Get the frame of the text field in the window's coordinate space
                let textFieldFrame = activeTextField.convert(activeTextField.bounds, to: self.view)
                let textFieldBottomY = textFieldFrame.origin.y + textFieldFrame.height
                
                let screenHeight = UIScreen.main.bounds.height
                let keyboardTopY = screenHeight - keyboardHeight
                
                // Check if the text field is covered by the keyboard
                if textFieldBottomY > keyboardTopY {
                    let offset = textFieldBottomY - keyboardTopY
                    UIView.animate(withDuration: 0.3) {
                        activeTextField.transform = CGAffineTransform(translationX: 0, y: -offset)
                    }
                }
            }
        
        }
    
    
    @objc func keyboardWillHide(_ sender: NSNotification){
        // Move the text field back to its original position
        
        if let activeTextField = self.textField{
            UIView.animate(withDuration: 0.3) {
                activeTextField.transform = CGAffineTransform(translationX: 0, y: 0)
                
            }
        }
    }
    
   
    
    // Calls the database asynchronously to get the username
    // data that was stored during registration.
    func getUserName(completion: @escaping (String?) -> Void){
     if let email = Auth.auth().currentUser?.email{
        
         let safeEmail = email.replacingOccurrences(of: ".", with: ",")
         
         self.ref.child("users").child(safeEmail).observeSingleEvent(of: .value, with: {(snapshot) in
            
             if let userData = snapshot.value as? [String: Any],
              let user = userData["username"] as? String{
                 
                 completion(user)
                 
             }
             else{
                 
                 completion("blank")
                 
             }
         })
     }
        else{
            completion("No User")
        }
    }

}

