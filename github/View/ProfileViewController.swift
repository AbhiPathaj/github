//
//  ProfileViewController.swift
//  github
//
//  Created by Abhishek Pathak on 11/03/25.
//

import UIKit

class ProfileViewController: UIViewController {
    // OUTLETS
    @IBOutlet weak var userProfilePicture: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    // VARIABLES
    var user: GithubUser?
    var id: Int?
    var userID: String? = "Abhishekpathak2"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await setData()
        }
    }
    
    // METHODS
    func getUserData() async throws -> GithubUser? {
        let endPoint = "https://api.github.com/users/\(userID ?? "")"
        guard let url = URL(string: endPoint) else {
            throw NSError(domain: "Invalid URL", code: 1001, userInfo: nil)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "Failed to fetch data", code: 1002, userInfo: nil)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let user = try decoder.decode(GithubUser.self, from: data)
        return user
    }
    
    func setData() async {
        do {
            if let userData = try await getUserData() {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.user = userData
                    self.userName.text = self.user?.login
                    self.id = self.user?.id
                    
                    self.downloadImage(from: self.user?.avatarUrl ?? "") { image in
                        DispatchQueue.main.async {
                            self.userProfilePicture.image = image
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.userName.text = "User data not available"
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.userName.text = "Error: \(error.localizedDescription)"
            }
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
            completion(image)
        }.resume()
    }
}
