//
//  ContentView.swift
//  Speechify
//
//  Created by Olorunshola Godwin on 23/01/2021.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = TransciberViewModel()
    var body: some View {
        VStack {
            Text("Help")
            TextField("", text: $viewModel.transcribedWord)
                .frame(height: 240)
                .border(Color.gray, width: 1)
            Spacer()
            HStack {
                Button(action: {
                    viewModel.recordAudio()
                }, label: {
                    Text("Record")
                        .frame(width: 100, height: 12)
                        .font(.system(size: 18))
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.gray)
                        .clipShape(Capsule())
                    
                })
                Button(action: {
                    
                }, label: {
                    Text("Play")
                        .frame(width: 120, height: 16)
                        .font(.system(size: 18))
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.gray)
                        .clipShape(Capsule())
                    
                })
            }
        }.padding(24)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
