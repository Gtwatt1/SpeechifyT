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
    
    private let audioURL: URL
    private var player: AVPlayer
    let playerTimeIntervalPublisher = PassthroughSubject<TimeInterval, Never>()
    
    init(audioURL: URL) {
        self.audioURL = audioURL
        player = AVPlayer(url: audioURL)
    }
    
    func playAudio() {
        player.play()
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1,
                                                           preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
                                       queue: nil) { [weak self] time in
            self?.playerTimeIntervalPublisher.send(time.seconds)
        }
    }
 
}
