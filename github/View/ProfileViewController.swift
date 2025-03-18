import UIKit

class ProfileViewController: UIViewController {
    
    // OUTLETS
    @IBOutlet weak var userProfilePicture: UIImageView!{
        didSet{
            userProfilePicture.isHidden = true
        }
    }
    @IBOutlet weak var bio: UILabel!{
        didSet{
            bio.isHidden = true
        }
    }
    @IBOutlet weak var userName: UILabel!{
        didSet{
            userName.isHidden = true
        }
    }
    
    // VARIABLES
    var user: GithubUser?
    var id: Int?
    var userID: String? = "AbhiPathaj"
    var activityIndicator = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        Task {
            await setData()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // Setup UI & Activity Indicator
    func setupUI() {
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    func setupProfilePicture() {
        bio.isHidden = false
        userProfilePicture.isHidden = false
        userName.isHidden = false
        userProfilePicture.layer.cornerRadius = userProfilePicture.frame.height / 2
        userProfilePicture.clipsToBounds = true
        userProfilePicture.contentMode = .scaleAspectFill
    }

    // Fetch GitHub User Data
    func getUserData() async throws -> GithubUser? {
        try await Task.sleep(nanoseconds: 2_000_000_000) // Non-blocking delay
        
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
        return try decoder.decode(GithubUser.self, from: data)
    }

    // Set Data after API Call
    func setData() async {
         showLoading()
        do {
            if let userData = try await getUserData() {
                user = userData
                 updateUI()
            } else {
                 updateUI(withError: "User data not available")
            }
        } catch {
             updateUI(withError: "Error: \(error.localizedDescription)")
        }
         hideLoading()
    }
    
    // Update UI
    @MainActor
    func updateUI() {
        userName.text = user?.name
        bio.text = user?.bio
        id = user?.id

        if let avatarUrl = user?.avatarUrl {
            downloadImage(from: avatarUrl) { image in
                DispatchQueue.main.async {
                    self.userProfilePicture.image = image
                    self.setupProfilePicture()
                }
            }
        }
    }

    // Update UI on Error
    @MainActor
    func updateUI(withError message: String) {
        userName.text = message
        bio.text = ""
    }
    
    // Download Image
    func downloadImage(from url: String, completion: @escaping (UIImage?) -> Void) {
        guard let imageUrl = URL(string: url) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: imageUrl) { data, _, error in
            if let data = data, error == nil {
                completion(UIImage(data: data))
            } else {
                completion(nil)
            }
        }.resume()
    }
}

// MARK: - Activity Indicator Extension
extension ProfileViewController {
    @MainActor
    func showLoading() {
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }

    @MainActor
    func hideLoading() {
        activityIndicator.stopAnimating()
        view.isUserInteractionEnabled = true
    }
}
