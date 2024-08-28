//
//  story_photo_editApp.swift
//  story_photo_edit
//
//  Created by Aysema Çam on 19.08.2024.
//

import SwiftUI


@main
struct story_photo_editApp: App {
    // Register the custom AppDelegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            StoryEditView()
        }
    }
}

import UIKit
import IQKeyboardManagerSwift

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.resignOnTouchOutside = false
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 10
        return true
    }
}
