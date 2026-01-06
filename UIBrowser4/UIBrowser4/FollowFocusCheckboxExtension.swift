//
//  FollowFocusCheckboxExtension.swift
//  UIBrowser3
//
//  Created by Bill Cheeseman on 2019-04-18.
//  Copyright © 2019-2020 PFiddlesoft. All rights reserved.
//

import Cocoa

/**
 The FollowFocusCheckboxExtension.swift file implements an extension on MasterSplitItemViewController dedicated to UI Browser's Follow Focus checkbox.
 */
extension MasterSplitItemViewController {
    
    // MARK: - ACTION METHODS
    
    /**
     Follows focus in the target application when the user selects the Follow Focus checkbox.
     
     - note: The equivalent UI Browser 2 method is \-\[PFBrowserController followFocusButtonAction:\], also called in \-followFocusMenuAction:.
     
     - parameter sender: The FollowFocus checkbox that sent the action.
     */
    @IBAction func followFocus(_ sender: NSButton) {
        // Action method connected from the FollowFocus checkbox to First Responder in Main.storyboard.
        // This is a thin wrapper that calls the testable helper method with the real workspace.
        handleFollowFocus(sender: sender, workspace: .shared)
    }

    /// Helper method with dependencies injected for testability.
    func handleFollowFocus(sender: NSButton, workspace: NSWorkspace) {
        let notificationCenter = workspace.notificationCenter

        // The MainContentViewController is a singleton, so we can access it here.
        if let mainController = MainContentViewController.sharedInstance {
            if sender.state == .on {
                // When the user turns on "Follow Focus", we start observing for when the frontmost application changes.
                notificationCenter.addObserver(mainController, selector: #selector(MainContentViewController.frontmostApplicationDidChange(_:)), name: NSWorkspace.didActivateApplicationNotification, object: nil)
            } else {
                // When the user turns it off, we stop observing.
                notificationCenter.removeObserver(mainController, name: NSWorkspace.didActivateApplicationNotification, object: nil)
            }
        }
    }
    
}
