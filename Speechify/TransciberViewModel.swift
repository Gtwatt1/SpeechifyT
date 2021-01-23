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
    
    init() {
        audioRecordingService.recordedAudioFileURL
            .sink { (url) in
                self.test(url: url)
                
            } .store(in: &subscribers)
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
