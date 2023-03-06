/*
  RMIT University Vietnam
  Course: COSC2659 iOS Development
  Semester: 2022B
  Assessment: Assignment 2
  Author: Huynh Dac Tan Dat
  ID: s3777091
  Created  date: 23/08/2022
  Last modified: 28/08/2022
  Acknowledgement: Acknowledge the resources that you use here.
*/

import SwiftUI

struct MoneyView: View {
    
    
    @Binding var player: PlayerPorker
    @Binding var totalAmount: Float
    
    var CurrentTottal : Float
    
    var body: some View {
        VStack(spacing: 15){
            
            // Custom Slider....
            HStack{
                Image(player.playerImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 35, height: 35)
                    .padding(5)
                    .clipShape(Circle())
                
                Text(player.playerName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(totalAmount.rounded().cleanValue)")
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
            
            }
            
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .center), content: {
                GeometryReader { geometry in
                    // TODO: - there might be a need for horizontal and vertical alignments
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .foregroundColor(.gray)
                        Rectangle()
                            .foregroundColor(.accentColor)
                            .frame(width: geometry.size.width * CGFloat(self.totalAmount / CurrentTottal))
                    }
                    .cornerRadius(12)
                    .gesture(DragGesture(minimumDistance: 0)
                        .onChanged({ value in
                            // TODO: - maybe use other logic here
                            DispatchQueue.main.async {
                                self.totalAmount = min(Float(max(0, CGFloat(value.location.x / geometry.size.width * CGFloat(CurrentTottal)))),
                                                       CurrentTottal)
                            }
                        
                        }))
                }
            })
            
        }
        .padding()
    }
    
}

extension Float {
    var cleanValue: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
