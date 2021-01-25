//
//  TransciberViewModel.swift
//  Speechify
//
//  Created by Olorunshola Godwin on 23/01/2021.
//

import Foundation
import SwiftUI
import AVFoundation
import Combine

class TransciberViewModel: ObservableObject {
    
    var audioRecordingService = AudioRecordingService()
    private var subscribers = Set<AnyCancellable>()
    var player: AVAudioPlayer!
    private(set) var recordButtonTitle: LocalizedStringKey = "record"
    private(set) var playButtonTitle: LocalizedStringKey = "play"
    private(set) var isRecordingAudio: Bool = false
    private(set) var isPlayingAudio: Bool = false
    @Published private(set) var state = TransciberViewState.idle
    
    enum TransciberViewState {
        case idle
        case loading
        case failure(String)
        case success(String)
    }
    
    init() {
        audioRecordingService.isRecordingState
            .map({$0 ? "stop_record" : "record"})
            .assign(to: \.recordButtonTitle, on: self)
            .store(in: &subscribers)
        
        audioRecordingService.isRecordingState
            .assign(to: \.isRecordingAudio, on: self)
            .store(in: &subscribers)
        
        audioRecordingService.recordedAudioFileURL
            .mapError{ TranscriptionError.network(description: $0.localizedDescription) }
            .flatMap{ url in
                return TranscriberService().transcribeSpeech(recordedAudioURL: url)
            } .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self = self else { return }
                switch value {
                case .failure(let error):
                    self.state = TransciberViewState.failure(error.localizedDescription)
                case .finished:
                    break
                }
            } receiveValue: { [weak self] (transcribedSpeechResult) in
                if let text = transcribedSpeechResult.results.first?.alternatives.first?.transcript {
                    self?.state = .success(text)
                }
            }
            .store(in: &subscribers)
    }
    
    func recordAudio() {
        self.state = .loading
        audioRecordingService.startStopAudioRecording()
    }
    
    func test(url: URL) {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.play()
        }catch {
            print(error)
        }
    }
}
