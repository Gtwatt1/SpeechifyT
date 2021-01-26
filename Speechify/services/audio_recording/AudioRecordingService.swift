//
//  AudioRecordingService.swift
//  Speechify
//
//  Created by Olorunshola Godwin on 23/01/2021.
//

import Foundation
import AVFoundation
import Combine

/**
 This class contains functions to start or stop recording audio
 */
class AudioRecordingService: NSObject, AVAudioRecorderDelegate {
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder?
    var audioRecorderController: AudioRecorderConfigurationController
    var recordedAudioFileURL: AnyPublisher<URL, Never> {
        return _recordedAudioFileURL.eraseToAnyPublisher()
    }
    var isRecordingState: AnyPublisher<Bool, Never> {
        return _isRecordingState.eraseToAnyPublisher()
    }
    private let _isRecordingState = PassthroughSubject<Bool, Never>()
    private let _recordedAudioFileURL = PassthroughSubject<URL, Never>()
    private var subscribers = Set<AnyCancellable>()

    init(audioRecorderController: AudioRecorderConfigurationController) {
        self.audioRecorderController = audioRecorderController
        audioRecorderController.checkAudioRecorderPermission()
    }
    
    func toggleAudioRecording() {
        if let _ = audioRecorder {
            stopAudioRecording()
        } else {
          startAudioRecording()
        }
    }
    
    private func startAudioRecording() {
        audioRecorder = audioRecorderController.setUpRecorder()
        _isRecordingState.send(true)
        audioRecorder?.delegate = self
        audioRecorder?.record()
    }
    
    private func stopAudioRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        _isRecordingState.send(false)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            _recordedAudioFileURL.send(recorder.url)
        } else {
            recorder.stop()
        }
    }
}
