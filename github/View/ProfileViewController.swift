//
//  ProfileViewController.swift
//  github
//
//  Created by Abhishek Pathak on 11/03/25.
//

import UIKit

class ProfileViewController: UIViewController {
    //OUTLETS
    @IBOutlet weak var userProfilePicture: UIImageView!
    @IBOutlet weak var userName: UILabel!
    //ACTIONS
    
    //VARIABLES
    var user: GithubUser?
    var id: Int??
    var userID: String? = "Abhishekpathak2"
    override func viewDidLoad() {
        super.viewDidLoad()
        Task{
            await setData()
        }
    }
    //METHODS
    func getUserData() async throws -> (GithubUser?,NSError){
        let endPoint = "https://api.github.com/users/\(userID ?? "")"
        guard let url = URL(string: endPoint) else{
            throw NSError(domain: "Invalid URL", code: 1001, userInfo: nil)
        }
        let (data,response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else{
            throw NSError(domain: "Failed to fetch data", code: 1002, userInfo: nil)
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let user: GithubUser? = try decoder.decode(GithubUser.self, from: data)
        return (user,NSError(domain: "No Error", code: 1000, userInfo: nil))
    }
    func setData() async {
        do{
            let(userData,error) =  try await getUserData()
            guard let userData = userData else {
                self.userName.text = error.localizedDescription
                return
            }
            self.user = userData
            self.userName.text = self.user?.login
            self.id = self.user?.id
            downloadImage(from: self.user?.avatarUrl ?? "") { image in
                if let img = image {
                    self.userProfilePicture.image = img
                }
            }
        }catch{
           
        }
    }
    func downloadImage(from url: String, completion: @escaping (UIImage?) -> Void) {
        guard let imageUrl = URL(string: url) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: imageUrl) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}
