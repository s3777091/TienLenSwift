/*
  RMIT University Vietnam
  Course: COSC2659 iOS Development
  Semester: 2022B
  Assessment: Assignment 2
  Author: Huynh Dac Tan Dat
  ID: s3777091
  Created  date: 19/08/2022
  Last modified: 28/08/2022
  Acknowledgement: Acknowledge the resources that you use here.
*/

import AVFoundation

var audioPlayer : AVAudioPlayer?


func playSound(sound: String, type: String){
    if let path = Bundle.main.path(forResource: sound, ofType: type){
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer?.volume = 0.8
            audioPlayer?.play()
        } catch {
            print("Error: could not find and play sound")
        }
    }
}

func playSoundBackGround(sound: String, type: String){
    if let path = Bundle.main.path(forResource: sound, ofType: type){
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer?.volume = 0.1
            audioPlayer?.prepareToPlay()
            audioPlayer?.numberOfLoops = -1
            
            audioPlayer?.play()
        } catch {
            print("Error: could not find and play sound")
        }
    }
}
