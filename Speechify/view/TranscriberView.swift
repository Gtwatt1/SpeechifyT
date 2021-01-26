//
//  ContentView.swift
//  Speechify
//
//  Created by Olorunshola Godwin on 23/01/2021.
//

import SwiftUI

/**
 App View.
 */
struct TranscriberView: View {
    @ObservedObject var viewModel = TransciberViewModel(
        audioRecordingService: AudioRecordingService(
            audioRecorderController: AudioRecorderConfigurationController()),
        audioTextHighlighter: PlayAudioWithTextHighlightingService(),
        transcriberApiService: TranscriberApiService(),
        audioPlayer: AudioPlayerService()
    )
    
    let pageDescription: LocalizedStringKey = "transription_view_description"
    var body: some View {
        VStack {
            Text(pageDescription)
                .accessibility(addTraits: .isStaticText)
                .accessibility(label: Text(LocalizedStringKey("transription_view_description")))
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
                        errorView(failure)
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
    
    func errorView(_ failure: String) -> Alert {
        Alert(title: Text(LocalizedStringKey("alert")),
              message: Text(failure),
              dismissButton: .default(Text("Ok!"),
                                      action: {
                                        viewModel.dismissAlert()
                                      }))
    }
    
    func transcriptionResultTextField(
        _ result: SentenceWithWordHighlighting = SentenceWithWordHighlighting()
    ) -> some View {
        SentenceWithHighlightedWordView(sentence: result)
            .accessibility(label: Text(LocalizedStringKey("transcribed_speech")))
    }
    
    var mediaButtons: some View {
        HStack {
            Button(action: {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                viewModel.toggleAudioRecording()
            }, label: {
                Text(viewModel.recordButtonTitle)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: 100, height: 20)
                    .font(.body)
                    .padding()
                    .foregroundColor(.white)
                    .background(viewModel.isPlayingAudio ? Color.secondary : Color("active_button") )
                    .clipShape(Capsule())
                    .animation(.spring())
            }) .disabled(viewModel.isPlayingAudio)
            .accessibility(label: viewModel.isRecordingAudio ?
                            Text(LocalizedStringKey("stop_record")) :
                            Text(LocalizedStringKey("start_record")))
            .accessibility(hint: viewModel.isRecordingAudio ?
                            Text(LocalizedStringKey("stop_record_voice")):
                            Text(LocalizedStringKey("start_record_voice")))
            .accessibility(addTraits: .isButton)


            Button(action: {
                viewModel.playAudio()
            }, label: {
                Text(viewModel.playButtonTitle)
                    .frame(width: 120, height: 20)
                    .font(.body)
                    .padding()
                    .foregroundColor(.white)
                    .background(viewModel.isRecordingAudio ? Color.secondary : Color("active_button"))
                    .clipShape(Capsule())
                    .animation(.spring())
            }).disabled(viewModel.isRecordingAudio)
            .accessibility(label: viewModel.isPlayingAudio ?
                            Text(LocalizedStringKey("stop_play_record")) :
                            Text(LocalizedStringKey("play_record") ))
            .accessibility(hint: viewModel.isPlayingAudio ?
                            Text(LocalizedStringKey("stop_play_audio_voice")) :
                            Text(LocalizedStringKey("start_play_audio_voice") ))
            .accessibility(addTraits: .isButton)
        }
    }
}

struct TranscriberView_Previews: PreviewProvider {
    static var previews: some View {
        TranscriberView()
    }
}
