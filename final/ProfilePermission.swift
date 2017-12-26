//
//  ProfilePermission.swift
//  final
//
//  Created by Benjamin Dagg on 12/4/17.
//  Copyright © 2017 Benjamin Dagg. All rights reserved.
//

/*
 Permissions for when user goes to profile view controller. If the profile that the user is viewing is their own profile then the ProfilePermission is set to EDIT_AND_VIEW. If the user is viewing a profile that is not theirs, then ProfilePermission set to VIEW_ONLY. Buttons that let the user edit the profile are disabled when in VIEW_ONLY.
 */

import Foundation

enum ProfilePermission {
    
    case EDIT_AND_VIEW
    case VIEW_ONLY
}
