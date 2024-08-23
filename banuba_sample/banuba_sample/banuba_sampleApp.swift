//
//  banuba_sampleApp.swift
//  banuba_sample
//
//  Created by Aysema Çam on 23.08.2024.
//

import SwiftUI
import BNBSdkApi


@main
struct banuba_sampleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

      var body: some Scene {
          WindowGroup {
            ContentView()
          }
      }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var banubaClientToken: String = "Qk5CIIXwGhVf/7ADgB5cvaTA46GtRSZeXfdXMGu07C7qlQ0n6d83azAjRwQ4/y1flxVZU01vhkUj7wJlmS6K9XW3aq/hxi+iSq3WV1OMJP/a2ZBs1ZPhoIXGz/F8P5xLq54xY8iGrEgXwnPwlvRKUtRETkrCqk9K2d73jvcxawrBQ0G9fvJxEJ3ZlX+dP7lzLJUaoKlyFGcQmQejXj6H1yncKveZWCyKR406UwRjp0U1lpvNI8zw8mekCclZLq/y4bhMyaSQh+sKJaku7aKKaZ/f3rZzkkUemApSk+OidGgdMWoJBv2q3vxJmaGADe4SekJf63rP4WG2LHFGqm4NELRx284wLHj3yLO9m7G/01uDripVpcBTisTemuVQkBI6xv40R03rONIa1WPr1chRBt8X4Ztm+KauA9jnjiSDik09DvDMZvLnBb0NAwDMOdga1M8Zxocjk7qbIgA/u80L5MHiVKbf6WlEmXH2sbSpQ7d1uysUVkHMroj7OK42cwHg/5z3C6LBNVW3t9493Hd3SdcupxttU6FA1Kru2FwNVUMuGFaFweXjugJVrt1YhPY/l+4rdstcRSrg1wn0gIH7BdTHNqXVpwBSxLyzBHI+YpgFkd5ZCPAfWcZl4CU3mENdpWnJhYAWy26YBHhZOFNQkmI="
    
       func application(
           _ application: UIApplication,
           didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
       ) -> Bool {
           BanubaSdkManager.initialize(
               resourcePath: [
                   Bundle.main.bundlePath + "/effects",
                   Bundle.main.bundlePath
               ],
               clientTokenString: banubaClientToken
           )

           // Kontrol: Efekt dizini var mı?
           let effectPath = Bundle.main.bundlePath + "/effects/CartoonOctopus"
           
           if FileManager.default.fileExists(atPath: effectPath) {
               print("Effect path exists: \(effectPath)")
           } else {
               print("Effect path does not exist: \(effectPath)")
           }

           return true
       }
   }
