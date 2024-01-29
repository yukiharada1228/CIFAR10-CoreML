//
//  ContentView.swift
//  CIFAR10-CoreML
//
//  Created by yukiharada on 2024/01/29.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var isCameraViewShown = false
    @State private var capturedImage: UIImage?
    @State private var classificationLabel = "CIFAR10-CoreML"
    
    private let model: ResNet20CIFAR10 = {
        do {
            let config = MLModelConfiguration()
            return try ResNet20CIFAR10(configuration: config)
        } catch {
            fatalError("Couldn't create ResNet20: \(error)")
        }
    }()
    
    private func classifyImage() {
        guard let image = capturedImage?.croppedSquareAndResizedTo(size: CGSize(width: 32, height: 32)),
              let buffer = image.toBuffer(),
              let output = try? model.prediction(image: buffer) else {
            return
        }
        self.classificationLabel = output.classLabel
    }
    
    var body: some View {
        VStack {
            Text(classificationLabel)
                .font(.title)
                .padding()
            
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 320, height: 320)
                    .cornerRadius(10)
                    .padding()
            } else {
                Text("No image available")
                    .foregroundColor(.gray)
                    .padding()
            }
            
            HStack {
                Spacer()
                Button("Open Camera") {
                    isCameraViewShown.toggle()
                }
                .buttonStyle(ActionButtonStyle(color: .blue))
                .sheet(isPresented: $isCameraViewShown) {
                    CameraView(isShown: $isCameraViewShown, image: $capturedImage)
                }
                
                Button("Classify") {
                    classifyImage()
                }
                .buttonStyle(ActionButtonStyle(color: capturedImage != nil ? .green : .gray))
                .disabled(capturedImage == nil)
                Spacer()
            }
            .padding(.bottom)
        }
    }
}

struct ActionButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(.white)
            .background(color)
            .cornerRadius(10)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
