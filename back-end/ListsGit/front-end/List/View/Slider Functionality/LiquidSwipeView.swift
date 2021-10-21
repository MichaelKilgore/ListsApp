//
//  ContentView.swift
//  LiquidSwipeSwiftUI
//
//  Created by Mark Goldin on 08/08/2019.
//  Copyright © 2019 Exyte. All rights reserved.
//

import SwiftUI

struct LiquidSwipeView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var leftData: SliderData
    @State var originalLeftData: SliderData
    @State var colorIndex: Int
    
    @State var rightData = SliderData(side: .right, startPosition: 100.0)

    @State var pageIndex = 0
    @State var topSlider = SliderSide.right
    @State var sliderOffset: CGFloat = 0
    
    @Binding var done: [Bool] // sets to true when animation is fully done
    //if done[1] changes to true then change done[0] to false and reset the slider and then set done[1] to false

    var body: some View {
        ZStack {
            //content()
            slider(data: $leftData, done: $done)
                .onChange(of: done[1]) { _ in
                    done[0] = false
                    done[1] = false
                    //leftData = originalLeftData
                    withAnimation(.spring(dampingFraction: 0.5)) {
                        $leftData.wrappedValue = $leftData.wrappedValue.initial(position: originalLeftData.centerY) //set initial TODO
                    }
                }
            //slider(data: $rightData)
        }
        .edgesIgnoringSafeArea(.vertical)
    }

    func slider(data: Binding<SliderData>, done: Binding<[Bool]>) -> some View {
        let value = data.wrappedValue
        return ZStack {
            wave(data: data, done: $done)
            button(data: value)
        }
        .zIndex(topSlider == value.side ? 1 : 0)
        .offset(x: value.side == .left ? -sliderOffset : sliderOffset)
    }

    func content() -> some View {
        return Rectangle().foregroundColor(Config.colors[pageIndex]) //random number
    }

    func button(data: SliderData) -> some View {
        let aw = (data.side == .left ? 1 : -1) * Config.arrowWidth / 2
        let ah = Config.arrowHeight / 2
        return ZStack {
            circle(radius: Config.buttonRadius).stroke().opacity(0.2)
            polyline(-aw, -ah, aw, 0, -aw, ah).stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 2) //.foregroundColor(colorScheme == .dark ? .white : .black)
        }
        .offset(data.buttonOffset)
        .opacity(data.buttonOpacity)
    }

    func wave(data: Binding<SliderData>, done: Binding<[Bool]>) -> some View {
        let gesture = DragGesture().onChanged {
            
            self.topSlider = data.wrappedValue.side
            data.wrappedValue = data.wrappedValue.drag(value: $0)
            
        }
        .onEnded {
            
            if data.wrappedValue.isCancelled(value: $0) { //if he didnt swipe far enough then cancel
                withAnimation(.spring(dampingFraction: 0.5)) {
                    data.wrappedValue = data.wrappedValue.initial(position: originalLeftData.centerY) //set initial TODO
                }
            } else {
                self.swipe(data: data, done: $done)
            }
             
        }
        .simultaneously(with: TapGesture().onEnded {
            @State var fake: [Bool] = [false,false]
            self.topSlider = data.wrappedValue.side
            self.swipe(data: data, done: $fake)
            
        })
        if (self.done[0] == false) {
            return AnyView(WaveView(data: data.wrappedValue).gesture(gesture)
                //.foregroundColor(Config.colors[index(of: data.wrappedValue)]))
                .foregroundColor(Config.colors[colorIndex]))
        } else {
            return AnyView(WaveView(data: data.wrappedValue)
                //.foregroundColor(Config.colors[index(of: data.wrappedValue)]))
                .foregroundColor(Config.colors[colorIndex]))
        }
    }

    private func swipe(data: Binding<SliderData>, done: Binding<[Bool]>) {
        withAnimation() {
            data.wrappedValue = data.wrappedValue.final()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.pageIndex = self.index(of: data.wrappedValue)
            print("done set to true")
            self.done[0] = true
            self.leftData = self.leftData.final()

            self.sliderOffset = 100
            withAnimation(.spring(dampingFraction: 0.5)) {
                self.sliderOffset = 0
            }
        }
    }

    private func index(of data: SliderData) -> Int {
        if data.side == .left {
            return pageIndex
        } else {
            return pageIndex
        }
    }

    private func circle(radius: Double) -> Path {
        return Path { path in
            path.addEllipse(in: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2))
        }
    }

    private func polyline(_ values: Double...) -> Path {
        return Path { path in
            path.move(to: CGPoint(x: values[0], y: values[1]))
            for i in stride(from: 2, to: values.count, by: 2) {
                path.addLine(to: CGPoint(x: values[i], y: values[i + 1]))
            }
        }
    }

}
