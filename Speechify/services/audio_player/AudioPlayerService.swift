//
//  AudioPlayerService.swift
//  Speechify
//
//  Created by Olorunshola Godwin on 26/01/2021.
//

import Foundation
import AVFoundation
import Combine

/**
 This class would be used for playing recorded audio from a url.
 */
class AudioPlayerService {
    
    private var audioURL: URL!
    private var player: AVPlayer?
    private let _playerTimeIntervalPublisher = PassthroughSubject<TimeInterval, Never>()
    private var subscribers = Set<AnyCancellable>()
    private let _isPlayingAudio = PassthroughSubject<Bool, Never>()
    var isPlayingAudioState: Bool = false {
        didSet {
            _isPlayingAudio.send(isPlayingAudioState)
        }
    }
    var playerTimeIntervalPublisher: AnyPublisher<TimeInterval, Never> {
        return _playerTimeIntervalPublisher.eraseToAnyPublisher()
    }
    
    var isPlayingAudio: AnyPublisher<Bool, Never> {
        return _isPlayingAudio.eraseToAnyPublisher()
    }
    
    func setup(audioURL: URL) {
        self.audioURL = audioURL
        player = AVPlayer(url: audioURL)
    }
    
    func playStopAudio() {
        
        if !isPlayingAudioState {
            playAudio()
        } else {
            stopAudio()
        }
    }
    
    private func playAudio() {
        isPlayingAudioState = true
        player?.play()
        player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1,
                                                            preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
                                        queue: nil) { [weak self] time in
            self?._playerTimeIntervalPublisher.send(time.seconds)
        }
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)
            .sink { _ in
                self.isPlayingAudioState = false
            }.store(in: &subscribers)
    }
    
    private func stopAudio() {
        player = nil
        isPlayingAudioState = false
    }
}
