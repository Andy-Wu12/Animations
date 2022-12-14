//
//  ContentView.swift
//  Animations
//
//  Created by Andy Wu on 12/13/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
//        ImplicitAnimation()
//        ExplicitAnimation()
//        ControllingAnimationStack()
//        AnimatingGestures()
//        AnimatingTextGestureExample()
//        ShowHideViewsWithAnimations()
        CustomTransitionsWithViewModifier()
    }
}

struct ImplicitAnimation: View {
    @State private var animationAmount = 1.0
//     Implicit animation
    var body: some View {
        print(animationAmount)
        
        return VStack {
            Stepper("Scale amount", value: $animationAmount.animation(
                .easeInOut(duration: 1)
                .repeatCount(3, autoreverses: true)
            ), in: 1...10)
            
            Spacer()
            
            Button("Tap Me") {
                animationAmount += 1
            }
            .padding(40)
            .background(.red)
            .foregroundColor(.white)
            .clipShape(Circle())
            .scaleEffect(animationAmount)
            
            Spacer()
        }
    }
}

struct ExplicitAnimation: View {
    @State private var animationAmount = 0.0
    
    var body: some View {
        Button("Tap Me") {
            // withAnimation closure causes changes from new state to automatically be animated
            withAnimation(.interpolatingSpring(stiffness: 5, damping: 1, initialVelocity: 10)) {
                animationAmount += 360
            }
        }
        .padding(50)
        .background(.red)
        .foregroundColor(.white)
        .clipShape(Circle())
        .rotation3DEffect(.degrees(animationAmount), axis: (x: 0, y: 1, z: 0))
    }
}

struct ControllingAnimationStack: View {
    @State private var enabled = false
    
    var body: some View {
        Button("Tap Me") {
            enabled.toggle()
        }
        .frame(width: 200, height: 200)
        .background(enabled ? .blue : .red)
        .animation(.default, value: enabled)
        .foregroundColor(.white)
        /// Order of modifiers rule also applies to animations. Swap commented and uncommented clipShape to see effect of this.
        /// Even better, move background modifier to after all the other modfiers and see how it completely ruined our clipShape animation.
        /// Only changes that occur BEFORE the animation() modifier get animated.
        /// If we have multiple animation() modifiers, each one controls everything before the previous animation modifer
        /// Notice how the animations run separately for the color and the shape change
        /// But if we comment out the first animation, the one below causes an undesired color change effect
        .clipShape(RoundedRectangle(cornerRadius: enabled ? 60 : 0))
        .animation(.interpolatingSpring(stiffness: 10, damping: 1), value: enabled)
//        .clipShape(RoundedRectangle(cornerRadius: enabled ? 60 : 0))
    }
}

struct AnimatingGestures: View {
    @State private var dragAmount = CGSize.zero
    
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [.yellow, .red]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(width: 300, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .offset(dragAmount)
                .gesture(
                    DragGesture()
                        .onChanged{ dragAmount = $0.translation }
//                        .onEnded { _ in dragAmount = .zero }
                        // Explicit release animation - desireable drag effect
                        .onEnded { _ in
                            withAnimation(.spring()) {
                                dragAmount = .zero
                            }
                        }
                )
                // Implicit animation for drag AND release - undesireable drag animationss
                //.animation(.spring(), value: dragAmount)
    }
}

struct AnimatingTextGestureExample: View {
    let letters = Array("Hello SwiftUI")
    @State private var enabled = false
    @State private var dragAmount = CGSize.zero
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<letters.count, id: \.self) { num in
                Text(String(letters[num]))
                    .padding(5)
                    .font(.title)
                    .background(enabled ? .blue : .red)
                    .offset(dragAmount)
                    .animation(.default.delay(Double(num) / 20), value: dragAmount)
            }
        }
        .gesture(
            DragGesture()
                .onChanged { dragAmount = $0.translation }
                .onEnded { _ in
                    dragAmount = .zero
                    enabled.toggle()
                }
        )
    }
}

struct ShowHideViewsWithAnimations: View {
    @State private var isShowingRed = false
    
    var body: some View {
        VStack {
            Button("Tap Me") {
                withAnimation() {
                    isShowingRed.toggle()
                }
            }
            if isShowingRed {
                Rectangle()
                    .fill(.red)
                    .frame(width: 200, height: 200)
                    .transition(.asymmetric(insertion: .opacity, removal: .slide))
            }
        }
    }
}

struct CustomTransitionsWithViewModifier: View {
    @State private var isShowingRed = false
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.blue)
                .frame(width: 200, height: 200)

            if isShowingRed {
                Rectangle()
                    .fill(.red)
                    .frame(width: 200, height: 200)
                    .transition(.pivot)
            }
        }
        .onTapGesture {
            withAnimation {
                isShowingRed.toggle()
            }
        }
    }
}

// Custom Transition stuff
struct CornerRotateModifier: ViewModifier {
    let amount: Double
    let anchor: UnitPoint
    
    func body(content: Content) -> some View {
        content
            /// Rotates around Z axis and gives ability to control ANCHOR POINT of rotation
            /// so that part of the view should be fixed in place as the center of rotation
            .rotationEffect(.degrees(amount), anchor: anchor)
            /// Stops view from being drawn outside of it's rectangular space
            .clipped()
    }
}

extension AnyTransition {
    static var pivot: AnyTransition {
        .modifier(active: CornerRotateModifier(amount: -90, anchor: .topLeading),
                  identity: CornerRotateModifier(amount: 0, anchor: .topLeading)
        )
    }
}
// End of Custom Transition stuff

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
