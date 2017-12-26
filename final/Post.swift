//
//  Post.swift
//  final
//
//  Created by Benjamin Dagg on 11/30/17.
//  Copyright © 2017 Benjamin Dagg. All rights reserved.
//

import Foundation
import UIKit

class Post {
    
    var gameTitle:String
    var gameImg:UIImage?
    var platform:Platform
    var region:Region
    var gamertag:String
    var postDate:Date
    var message:String?
    
    init() {
        self.gameTitle = ""
        self.gameImg = nil
        self.platform = Platform.PC
        self.region = Region.Asia
        self.gamertag = ""
        self.postDate = Date()
        self.message = nil
    }
    
    init(gameTitle:String,gameImg:UIImage,platform:Platform, gamertag:String,postDate:Date,region:Region, message: String?){
        self.gameTitle = gameTitle
        self.gameImg = gameImg
        self.platform = platform
        self.gamertag = gamertag
        self.postDate = postDate
        self.region = region
        self.message = message
    }
    
}
