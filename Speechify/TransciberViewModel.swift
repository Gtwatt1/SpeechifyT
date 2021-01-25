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
    @Published var transcribedWord: String = ""
    
    init() {
        audioRecordingService.recordedAudioFileURL
            .mapError{ WeatherError.network(description: $0.localizedDescription) }
            .flatMap{ url in
                return TranscriberService().transcribeSpeech(recordedAudioURL: url)
            } .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self = self else { return }
                switch value {
                case .failure:
                    break
                case .finished:
                    break
                }
            } receiveValue: { [weak self] (transcribedSpeechResult) in
                                if let text = transcribedSpeechResult.results.first?.alternatives.first?.transcript {
                                    self?.transcribedWord = text
                                }
            }
            .store(in: &subscribers)
    }
    
    func recordAudio() {
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
