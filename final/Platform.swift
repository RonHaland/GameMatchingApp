//
//  Platform.swift
//  final
//
//  Created by Benjamin Dagg on 10/30/17.
//  Copyright © 2017 Benjamin Dagg. All rights reserved.
//

enum Platform: String {
    
    case PC
    case XboxOne
    case Xbox360
    case PS3
    case PS4
    
    static func stringToCase(string: String)->Platform{
        
        switch string {
        case "PC":
            return Platform.PC
        case "XboxOne":
            return Platform.XboxOne
        case "Xbox360":
            return Platform.Xbox360
        case "PS3":
            return Platform.PS3
        default:
            return Platform.PS4
            
        }
        
    }

    
}
