//
//  loginViewController.swift
//  github
//
//  Created by Abhishek Pathak on 18/03/25.
//

import UIKit
public enum LoginError: String {
    case emptyUserId = "User Id is required"
    case invalidUserId = "User Id is invalid"
}
class LoginViewController: UIViewController,UITextFieldDelegate {

    // OUTLETS
    @IBOutlet weak var githubLogo: UIImageView!
    @IBOutlet weak var userIdtextField: UITextField!
    @IBOutlet weak var userIdLabel: UILabel!
    // ACTIONS
    @IBAction func proceedBtnTapped(_ sender: UIButton) {
        // GO TO PROFILE VIEWCONTROLLER
        userId = userIdtextField.text
        guard let userId = userId, !userId.isEmpty else {
            let alert = UIAlertController(title: "Error", message: LoginError.emptyUserId.rawValue, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    present(alert, animated: true)
                   return
               }
        if let nextVC = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController {
            nextVC.userID = self.userId
            navigationController?.pushViewController(nextVC, animated: true)
        } else{
            let alert = UIAlertController(title: "Error", message: LoginError.emptyUserId.rawValue, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    present(alert, animated: true)
        }
    }
    
    //VARIABLES
    var userId: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    func setUpUI(){
        self.githubLogo.image = UIImage(named: "github-logo")
        userIdtextField.delegate = self
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
            userId = textField.text
        }
    
}
