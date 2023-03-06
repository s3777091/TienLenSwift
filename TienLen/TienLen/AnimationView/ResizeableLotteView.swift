/*
  RMIT University Vietnam
  Course: COSC2659 iOS Development
  Semester: 2022B
  Assessment: Assignment 2
  Author: Huynh Dac Tan Dat
  ID: s3777091
  Created  date: 18/08/2022
  Last modified: 28/08/2022
  Acknowledgement: Acknowledge the resources that you use here.
*/

import SwiftUI
import Lottie

struct ResizableLottieView: UIViewRepresentable {
    var fileName: String
    // MARK: Callback When Animation Finishes
    var onFinish: (AnimationView)->()
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        setupView(for: view)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
    
    func setupView(for to: UIView){
        // MARK: Setting Up Lottie View
        let animationView = AnimationView(name: fileName,bundle: .main)
        animationView.backgroundColor = .clear
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        // MARK: For Optimized Memory
        animationView.shouldRasterizeWhenIdle = true
        
        let constraints = [
            animationView.widthAnchor.constraint(equalTo: to.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: to.heightAnchor),
        ]
        
        to.addSubview(animationView)
        to.addConstraints(constraints)
        
        animationView.play{_ in
            onFinish(animationView)
        }
    }
}
