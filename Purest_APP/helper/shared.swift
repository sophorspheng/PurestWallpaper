//
//  shared.swift
//  Note001
//
//  Created by Sophors Pheng on 7/29/24.
//

import Foundation


import Foundation
class UserData2 {
    static let shared = UserData2()
    
    var username: String?
    var isAdmin: Bool = false
    private init() {}
    

}
