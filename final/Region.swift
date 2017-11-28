//
//  Region.swift
//  final
//
//  Created by Benjamin Dagg on 10/30/17.
//  Copyright © 2017 Benjamin Dagg. All rights reserved.
//

enum Region : String {
    
    case NA
    case SA
    case Europe
    case Asia
    
    static func stringToCase(string: String)->Region{
        
        switch string {
        case "N. America":
            return Region.NA
        case "NA":
            return Region.NA
        case "S. America":
            return Region.SA
        case "SA":
            return Region.SA
        case "Europe":
            return Region.Europe
        default:
            return Region.Asia
            
        }
        
    }
    
}
