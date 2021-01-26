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

/**
 This class would be used to control the state of the Transcriber View.
 */
class TransciberViewModel: ObservableObject {
    
    private var audioRecordingService: AudioRecordingService
    private var audioTextHighlighter: PlayAudioWithTextHighlightingService
    private var transcriberApiService: TranscriberApiService
    private var subscribers = Set<AnyCancellable>()
    private(set) var recordButtonTitle: LocalizedStringKey = "record"
    private(set) var playButtonTitle: LocalizedStringKey = "play"
    private(set) var isRecordingAudio: Bool = false
    private(set) var isPlayingAudio: Bool = false
    private var recordedAudioURL: URL?
    private var transcriptionWithTimeStamp: GoogleSpeechToText.Alternative?
    @Published private(set) var state = TransciberViewState.idle
    
    init( audioRecordingService: AudioRecordingService,
          audioTextHighlighter: PlayAudioWithTextHighlightingService,
          transcriberApiService: TranscriberApiService) {
        self.audioRecordingService = audioRecordingService
        self.audioTextHighlighter = audioTextHighlighter
        self.transcriberApiService = transcriberApiService

        audioRecordingService.isRecordingState
            .map({$0 ? "stop_record" : "record"})
            .assign(to: \.recordButtonTitle, on: self)
            .store(in: &subscribers)
        
        audioRecordingService.isRecordingState
            .assign(to: \.isRecordingAudio, on: self)
            .store(in: &subscribers)
        
        audioRecordingService.recordedAudioFileURL
            .mapError{ TranscriptionError.network(description: $0.localizedDescription) }
            .flatMap{ url -> AnyPublisher<GoogleSpeechToText.Transcription,TranscriptionError> in
                self.recordedAudioURL = url
                return self.transcriberApiService.transcribeSpeech(recordedAudioURL: url)
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
                if let transcriptionWithTimeStamp = transcribedSpeechResult.results.first?.alternatives.first {
                    self?.transcriptionWithTimeStamp = transcriptionWithTimeStamp
                    self?.state = .success(
                        SentenceWithWordHighlighting(
                            beforeHighlightedString: transcriptionWithTimeStamp.transcript.capitalized
                        )
                    )
                }
            }
            .store(in: &subscribers)
    }
    
    func startStopAudioRecording() {
        self.state = .loading
        audioRecordingService.startStopAudioRecording()
    }
    
    func playAudio() {
        if let recordedAudioURL = recordedAudioURL,
           let transcriptionWithTimeStamp = transcriptionWithTimeStamp {
            audioTextHighlighter = PlayAudioWithTextHighlightingService()
            audioTextHighlighter.setup(
                audioURL: recordedAudioURL,
                transcribedSpeech: transcriptionWithTimeStamp
            )
            audioTextHighlighter.playAudioAndHighlightText()
        }
        audioTextHighlighter.sentenceWithHighlightedWord.sink(receiveValue: { (text) in
            self.state = .success(text)
        }).store(in: &subscribers)
    }
}

enum TransciberViewState {
    case idle
    case loading
    case failure(String)
    case success(SentenceWithWordHighlighting)
}
