/*
  RMIT University Vietnam
  Course: COSC2659 iOS Development
  Semester: 2022B
  Assessment: Assignment 2
  Author: Huynh Dac Tan Dat
  ID: s3777091
  Created  date: 26/08/2022
  Last modified: 28/08/2022
  Acknowledgement: Acknowledge the resources that you use here.
*/

import SwiftUI

struct Components: View {
    var body: some View {
        Text("Components is where I keep extension")
    }
}

struct Components_Previews: PreviewProvider {
    static var previews: some View {
        Components()
    }
}

struct CardView: View {
    let card: Card
    var body: some View {
        Image(card.filename)
            .resizable()
            .frame(width: 75, height: 110)
    }
}

struct CustomCorner: Shape{
    var corners: UIRectCorner
    var radius: CGFloat
    func path(in rect: CGRect) -> Path {
        
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        
        return Path(path.cgPath)
    }
}


struct GrowingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct PagerView<Content: View>: View {
    let pageCount: Int
    @State var ignore: Bool = false
    

    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()


    @Binding var currentIndex: Int {
        didSet {
            if (!ignore) {
                currentFloatIndex = CGFloat(currentIndex)
            }
        }
    }

    @State var currentFloatIndex: CGFloat = 0 {
        didSet {
            ignore = true
            currentIndex = min(max(Int(currentFloatIndex.rounded()), 0), self.pageCount - 1)
            ignore = false
        }
    }
    let content: Content

    @GestureState private var offsetX: CGFloat = 0

    init(pageCount: Int, currentIndex: Binding<Int>, @ViewBuilder content: () -> Content) {
        self.pageCount = pageCount
        self._currentIndex = currentIndex
        self.content = content()
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                self.content.frame(width: geometry.size.width)
            }
            .frame(width: geometry.size.width, alignment: .leading)
            .offset(x: -CGFloat(self.currentFloatIndex) * geometry.size.width)
            .offset(x: self.offsetX)
            .animation(.linear, value:offsetX)
            .highPriorityGesture(
                DragGesture().updating(self.$offsetX) { value, state, _ in
                    state = value.translation.width
                }
                .onEnded({ (value) in
                    let offset = value.translation.width / geometry.size.width
                    let offsetPredicted = value.predictedEndTranslation.width / geometry.size.width
                    let newIndex = CGFloat(self.currentFloatIndex) - offset

                    self.currentFloatIndex = newIndex

                    withAnimation(.easeOut) {
                        if(offsetPredicted < -0.5 && offset > -0.5) {
                            self.currentFloatIndex = CGFloat(min(max(Int(newIndex.rounded() + 1), 0), self.pageCount - 1))
                        } else if (offsetPredicted > 0.5 && offset < 0.5) {
                            self.currentFloatIndex = CGFloat(min(max(Int(newIndex.rounded() - 1), 0), self.pageCount - 1))
                        } else {
                            self.currentFloatIndex = CGFloat(min(max(Int(newIndex.rounded()), 0), self.pageCount - 1))
                        }
                    }
                })
            )
        }
        .onChange(of: currentIndex, perform: { value in
            // this is probably animated twice, if the tab change occurs because of the drag gesture
            withAnimation(.easeOut) {
                currentFloatIndex = CGFloat(value)
            }
        }).onReceive(self.timer) { _ in
            withAnimation(.easeOut) {
                self.currentIndex = (self.currentIndex + 1) % (self.pageCount == 0 ? 1 : self.pageCount)
            }
        }
        
    }
}


// MARK: Extensions for Making UI Design Faster
extension View {
    func hLeading()->some View{
        self
            .frame(maxWidth: .infinity,alignment: .leading)
    }
    
    func hTrailing()->some View{
        self
            .frame(maxWidth: .infinity,alignment: .trailing)
    }
    
    func hCenter()->some View{
        self
            .frame(maxWidth: .infinity,alignment: .center)
    }
    
    func VCenter()->some View{
        self
            .frame(maxHeight: .infinity,alignment: .center)
    }
    
    func vTop()->some View{
        self
            .frame(maxHeight: .infinity,alignment: .top)
    }
    
    func vBottom()->some View{
        self
            .frame(maxHeight: .infinity,alignment: .bottom)
    }
}

// MARK: Custom View
struct ScratchCardView<Content: View,Overlay: View>: View {
    var content: Content
    var overlay: Overlay
    // MARK: Properties
    var pointSize: CGFloat
    // MARK: Callback when the Scratch Card is Fully Visible
    var onFinish: ()->()
    
    init(pointSize: CGFloat,@ViewBuilder content: @escaping()->Content, @ViewBuilder overlay: @escaping()->Overlay, onFinish: @escaping () -> Void) {
        self.content = content()
        self.overlay = overlay()
        self.pointSize = pointSize
        self.onFinish = onFinish
    }
    
    // MARK: Animation Properties
    @State var isScratched: Bool = false
    @State var disableGesture: Bool = false
    @State var dragPoints: [CGPoint] = []
    @State var animateCard: [Bool] = [false,false]
    var body: some View {
        GeometryReader {proxy in
            let size = proxy.size
            ZStack{
                // MARK: Logic is Simple
                // We're Going to Mask the Content Bit by Bit Based on Drag Location
                // Thus It will Starts Drawing the Content View Over the Overlay View
                overlay
                    .opacity(disableGesture ? 0 : 1)
                
                content
                    .mask {
                        if disableGesture{
                            Rectangle()
                        }else{
                            PointShape(points: dragPoints)
                             // MARK: Applying Stoke So that It will be Applying Circle For Each Point
                                 .stroke(style: StrokeStyle(lineWidth: isScratched ? (size.width * 1.4) : pointSize, lineCap: .round, lineJoin: .round))
                        }
                    }
                    // MARK: Adding Gesture
                    .gesture(
                        DragGesture(minimumDistance: disableGesture ? 100000 : 0)
                            .onChanged({ value in
                                // MARK: Stopping Animation When First Touch Registered
                                if dragPoints.isEmpty{
                                    withAnimation(.easeInOut){
                                        animateCard[0] = false
                                        animateCard[1] = false
                                    }
                                }
                                // MARK: Adding Points
                                dragPoints.append(value.location)
                            })
                            .onEnded({ _ in
                                // MARK: Checking If Atleast One Portion is Scratched
                                if !dragPoints.isEmpty{
                                    // MARK: Scratching Whole Card
                                    withAnimation(.easeInOut(duration: 0.35)){
                                        isScratched = true
                                    }
                                    
                                    // Callback
                                    onFinish()
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35){
                                        disableGesture = true
                                    }
                                }
                            })
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .rotation3DEffect(.init(degrees: animateCard[0] ? 4 : 0), axis: (x: 1, y: 0, z: 0))
            .rotation3DEffect(.init(degrees: animateCard[1] ? 4 : 0), axis: (x: 0, y: 1, z: 0))
            .onAppear {
                // MARK: SwiftUI Bug
                // WorkAround:
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)){
                        animateCard[0] = true
                    }
                    
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.8)){
                        animateCard[1] = true
                    }
                }
            }
        }
    }
}

// MARK: Custom Path Shape Based on Drag Locations
struct PointShape: Shape{
    var points: [CGPoint]
    // MARK: Since We Need Animation
    var animatableData: [CGPoint]{
        get{points}
        set{points = newValue}
    }
    
    func path(in rect: CGRect) -> Path {
        Path{path in
            if let first = points.first{
                path.move(to: first)
                path.addLines(points)
            }
        }
    }
}
