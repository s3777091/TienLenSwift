/*
  RMIT University Vietnam
  Course: COSC2659 iOS Development
  Semester: 2022B
  Assessment: Assignment 2
  Author: Huynh Dac Tan Dat
  ID: s3777091
  Created  date: 09/08/2022
  Last modified: 28/08/2022
  Acknowledgement: Acknowledge the resources that you use here.
*/

import SwiftUI

@main
struct TienLenApp: App {    
    var body: some Scene {
        WindowGroup {
            
            MainView().onAppear{
                playSoundBackGround(sound: "background", type: "mp3")
            }
            
        }
    }
}
