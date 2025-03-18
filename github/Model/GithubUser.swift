//
//  GithubUser.swift
//  github
//
//  Created by Abhishek Pathak on 11/03/25.
//

import Foundation

struct GithubUser: Codable {
    let login: String
    let avatarUrl: String
    let bio: String?
    let id: Int?
}
