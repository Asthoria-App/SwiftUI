//
//  Appdelegete.swift
//  testbanuba
//
//  Created by Aysema Çam on 27.11.2024.
//

import Foundation
import UIKit
import BNBSdkApi

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var banubaClientToken: String = "Qk5CIAhN6cF2I1/nbV9KiulSFlQiD/eapSGhL/xw6kpM++m3qIBpeGIS6RPH8tCNEtpiG1bvmfEI74uvg/C4o1vrn1XJrab03cAt1kwYz43ALcoUER7koAhmzQ6XpofCEVSkOuuXRNxAZg8OnOtSC4HzPzYq3sFLvBQBbcl8eDx4x0gg/YSIJBkDu1r5O/uV/JfFy3MqEeXUHaDuVqDlRdX16EYX/w7McpWxuOtm54TXRThmswRPf/4pU3TNyECwISI/eqvLeARmdfBBaDJg7bjejAje97VCjtYY+G0dJzyKnWmINCd/A6AWOZJ8n+6Xgc5vCfgDTycC2Zh3EgCtwfIlqF3sT1NbPwr3T1Th0i2XnrHnm2RMHwN5pZUC+cJklfp3U+UHiEPkkUV9fmqzbF73oG1FtzkBblXYTXXeavow9hz00hmw+YIzeuBoK/5mY6vZcozG2x1rDq5Bg6dTeQcHk/r4XahVI6ucWyoUM1WSVaVVB8Nw3h9uyCc56NmJ6olpZqArdidl/URcy8ts3ZeBxp0VJkxAxn94D9X/4UvVD5CFsMPC2hARCWUs0JxGOHpT8ulHRc0iAisQnEQOX/Ji4Wj9GSAHrNUaUdbBcWHcWNe9G+ycE+jmr+ip6zDhAb1F9TWom49h4yVr3OYsSaAh"

    var window: UIWindow?

 
        func application(
            _ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {
            
            // Kaynakların doğru yolda olup olmadığını kontrol et
            let resourcesPath = Bundle.main.bundlePath + "/effects/bnb-resources"
            let effectsPath = Bundle.main.bundlePath + "/effects"
            
            if !FileManager.default.fileExists(atPath: resourcesPath) {
                print("Error: bnb-resources path not found!")
            } else {
                print("bnb-resources found at \(resourcesPath)")
            }

            if !FileManager.default.fileExists(atPath: effectsPath) {
                print("Error: effects path not found!")
            } else {
                print("effects found at \(effectsPath)")
            }
            
            // Banuba SDK'yı başlat
            BanubaSdkManager.initialize(
                resourcePath: [resourcesPath, effectsPath],
                clientTokenString: banubaClientToken
            )

        return true
    }
}


