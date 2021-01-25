//
//  ContentView.swift
//  Speechify
//
//  Created by Olorunshola Godwin on 23/01/2021.
//

import SwiftUI

struct TranscriberView: View {
    @ObservedObject var viewModel = TransciberViewModel()
    let pageDescription: LocalizedStringKey = "transription_view_description"
    var body: some View {
        VStack {
            Text(pageDescription)
            switch viewModel.state {
            case .idle:
                transcriptionResultTextField()
            case .loading:
                ZStack {
                    transcriptionResultTextField()
                    ActivityIndicator()
                }
            case .failure(let failure):
                transcriptionResultTextField()
                    .alert(isPresented: .constant(true)) {
                    Alert(title: Text("Alert"),
                          message: Text(failure),
                          dismissButton: .default(Text("Ok!")))
                }
            case .success(let transcribedWord):
                transcriptionResultTextField(transcribedWord)
                    .frame(height: 240)
                    .border(Color.gray, width: 1)
            }

            Spacer()
            mediaButtons
        }.padding(24)
    }
    
    func transcriptionResultTextField(_ result: String = "") -> some View {
        Text(result)
            .padding()
            .frame(width:UIScreen.main.bounds.width - 48 , height: 240, alignment: .topLeading)
            .border(Color.gray, width: 1)
    }
    
    var mediaButtons: some View {
        HStack {
            Button(action: {
                viewModel.recordAudio()
            }, label: {
                Text(viewModel.recordButtonTitle)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: 100, height: 12)
                    .font(.system(size: 12))
                    .padding()
                    .foregroundColor(.white)
                    .background(viewModel.isPlayingAudio ? Color("inactive_button") : Color("active_button") )
                    .clipShape(Capsule())
                    .animation(.spring())
            }) .disabled(viewModel.isPlayingAudio)

            Button(action: {
                
            }, label: {
                Text("Play")
                    .frame(width: 120, height: 16)
                    .font(.system(size: 12))
                    .padding()
                    .foregroundColor(.white)
                    .background(viewModel.isRecordingAudio ? Color("inactive_button") : Color("active_button"))
                    .clipShape(Capsule())
                    .animation(.spring())
            }).disabled(viewModel.isRecordingAudio)

        }
    }
}

struct TranscriberView_Previews: PreviewProvider {
    static var previews: some View {
        TranscriberView()
    }
}
