/*
  RMIT University Vietnam
  Course: COSC2659 iOS Development
  Semester: 2022B
  Assessment: Assignment 2
  Author: Huynh Dac Tan Dat
  ID: s3777091
  Created  date: 25/08/2022
  Last modified: 28/08/2022
  Acknowledgement: Acknowledge the resources that you use here.
*/

import SwiftUI

struct AddMoney: View {
    
    @ObservedObject var Games = PokerController()
    
    @State private var showingAlert = false

    
    // MARK: Animation Properties
    @State var expandCard: Bool = false
    @State var showContent: Bool = false
    @State var showLottieAnimation: Bool = false
    @Namespace var animation
    
    @Environment(\.presentationMode) var presentationMode: Binding
    
    var body: some View {
        VStack{
            // MARK: Header
            HStack{
                HStack{
                    Image(systemName: "giftcard")
                }
                .font(.largeTitle.bold())
                .foregroundColor(.white)
                
                Spacer()
                
                Button {
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("BACK")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
            }
            
            CardView()
            
            // MARK: Footer Content
            Text("Woohoo!")
                .font(.system(size: 35,weight: .bold))
            
            Text("You each earn a scratch card that can contain 50000 Dola !!")
                .kerning(1.02)
                .multilineTextAlignment(.center)
                .padding(.vertical)
            
            Button {
                
            } label: {
                Text("VIEW BALANCE")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.vertical,17)
                    .frame(maxWidth: .infinity)
                    .background {
                        Rectangle()
                            .fill(.linearGradient(colors: [Color("Color2"),Color("Color3")], startPoint: .leading, endPoint: .trailing))
                    }
            }
            .alert("Your Current Balance is: \(UserDefaults.standard.integer(forKey: "UserMoney"))", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            }
            .padding(.top,15)
        }
        .padding(15)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            Color("BG")
                .ignoresSafeArea()
        }
        .overlay(content: {
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(showContent ? 1 : 0)
                .ignoresSafeArea()
        })
        .overlay(content: {
            GeometryReader{proxy in
                let size = proxy.size
                
                if expandCard{
                    // MARK: Since Size Varies
                    // By Padding 15 + 15 = 30
                    GiftCardView(size: size)
                        .overlay(content: {
                            // MARK: Lottie Animation
                            if showLottieAnimation{
                                ResizableLottieView(fileName: "Party") { view in
                                    withAnimation(.easeInOut){
                                        showLottieAnimation = false
                                    }
                                }
                                .scaleEffect(1.4)
                                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                            }
                        })
                        .matchedGeometryEffect(id: "GIFTCARD", in: animation)
                        .transition(.asymmetric(insertion: .identity, removal: .offset(x: 1)))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.35)){
                                showContent = true
                                showLottieAnimation = true
                            }
                        }
                }
            }
            .padding(30)
        })
        .overlay(alignment: .topTrailing, content: {
            // MARK: Close Button
            Button {
                
                UserDefaults.standard.set(50000 + Games.players[3].UserMoney, forKey: "UserMoney")
                
                withAnimation(.easeInOut(duration: 0.35)){
                    showContent = false
                    showLottieAnimation = false
                }
                
                withAnimation(.easeInOut(duration: 0.35).delay(0.1)){
                    expandCard = false
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(15)
            }
            .opacity(showContent ? 1 : 0)
        })
        .preferredColorScheme(.dark)
        .navigationBarTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
    
    
    // MARK: Card View
    @ViewBuilder
    func CardView()->some View{
        GeometryReader{proxy in
            let size = proxy.size
            
            ScratchCardView(pointSize: 60) {
                // MARK: Gift Card
                if !expandCard{
                    GiftCardView(size: size)
                        .matchedGeometryEffect(id: "GIFTCARD", in: animation)
                }
            } overlay: {
                Image("Card")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.width * 0.9, height: size.width * 0.9,alignment: .topLeading)
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            } onFinish: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                    withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)){
                        expandCard = true
                    }
                }
            }
            .frame(width: size.width, height: size.height, alignment: .center)
        }
        .padding(15)
    }
    
    // MARK: Gift Card
    @ViewBuilder
    func GiftCardView(size: CGSize)->some View{
        VStack(spacing: 18){
            Image("Trophy")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
            
            Text("You Earn")
                .font(.callout)
                .foregroundColor(.gray)
            
                
            Text("$50000")
                .font(.title.bold())
                .foregroundColor(.black)
        }
        .padding(20)
        .frame(width: size.width * 0.9, height: size.width * 0.9)
        .background {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(.white)
        }
    }
    
}
