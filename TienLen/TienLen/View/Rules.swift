/*
  RMIT University Vietnam
  Course: COSC2659 iOS Development
  Semester: 2022B
  Assessment: Assignment 2
  Author: Huynh Dac Tan Dat
  ID: s3777091
  Created  date: 28/08/2022
  Last modified: 28/08/2022
  Acknowledgement: Acknowledge the resources that you use here.
*/
import SwiftUI

struct Rules: View {
    var body: some View {
        Text("Poker Rmit")
            .font(.title)
        
        Text("Poker rules from three to Ace and Two is largest")
        
        if let url = URL(string: "https://www.wikihow.com/Play-Poker"){
            Link("Porker Detail this Link", destination: url)
                .font(.headline)
                .tint(.blue)
        }
    }
}

struct Rules_Previews: PreviewProvider {
    static var previews: some View {
        Rules()
    }
}
