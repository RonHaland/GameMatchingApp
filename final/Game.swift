//
//  Game.swift
//  final
//
//  Created by Benjamin Dagg on 10/26/17.
//  Copyright © 2017 Benjamin Dagg. All rights reserved.
//

import Foundation
import UIKit

class Game {
    
    var title:String
    var id:String
    var icon:UIImage?
    var platform:Platform
    
    init(title:String, id:String, icon: UIImage?,platform:Platform){
        self.title = title
        self.id = id
        self.icon = icon
        self.platform = platform
    }
    
}
