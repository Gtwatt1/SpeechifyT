//
//  TextHighlighting.swift
//  Speechify
//
//  Created by Olorunshola Godwin on 26/01/2021.
//

import Foundation
import Combine

/**
 This class would be used for playing audio and also highlighting the currently spoken text.
 */
class PlayAudioWithTextHighlightingService {
    var audioPlayer: AudioPlayerService!
    private var transcribedSpeech: GoogleSpeechToText.Alternative!
    private var subscribers = Set<AnyCancellable>()
    private var wordsTimeStamp: [Double] = []
    private var wordIndexArray: [WordIndexArray] = []
    private let _sentenceWithHighlightedWord = PassthroughSubject<SentenceWithWordHighlighting, Never>()
    var sentenceWithHighlightedWord: AnyPublisher<SentenceWithWordHighlighting, Never> {
        return _sentenceWithHighlightedWord.eraseToAnyPublisher()
    }
    
    func setup(audioURL: URL,
         transcribedSpeech: GoogleSpeechToText.Alternative ) {
        audioPlayer = AudioPlayerService(audioURL: audioURL)
        self.transcribedSpeech = transcribedSpeech
        segmentTranscriptionIntoTimeInterval()
    }
    
    private func segmentTranscriptionIntoTimeInterval() {
        var temp = ""
        if let words = transcribedSpeech?.words {
            for word in words {
                let start = temp.endIndex
                temp += word.word + " "
                wordIndexArray.append(
                    WordIndexArray(
                        startIndex: start,
                        endIndex: temp.index(
                                    start,
                            offsetBy: word.word.count)))
                var startTimeString = word.startTime
                startTimeString.removeLast()
                if let startTime = Double(startTimeString) {
                    wordsTimeStamp.append(startTime)
                }
            }
            wordsTimeStamp.append(Double.infinity)
        }
    }
    
    func playAudioAndHighlightText() {
        audioPlayer.playAudio()
        audioPlayer.playerTimeIntervalPublisher.sink { [weak self] value in
            self?.highlightTextWithTime(time: value)
        }
        .store(in: &subscribers)
    }
    
    private func highlightTextWithTime(time: Double) {
        var i = 0
        while i < wordsTimeStamp.count - 1 {
            if wordsTimeStamp[i] <= time && time <= wordsTimeStamp[i + 1] {
                let transcript = transcribedSpeech.transcript
                let highlightedString = transcript[wordIndexArray[i].startIndex..<wordIndexArray[i].endIndex]
                let beforeHighlightedString = transcript[transcript.startIndex..<wordIndexArray[i].startIndex]
                let afterHighlightedString = transcript[wordIndexArray[i].endIndex..<transcript.endIndex]
                
                let sentenceWithHighlighting = SentenceWithWordHighlighting(beforeHighlightedString: String(beforeHighlightedString),
                                                                            highlightedWord: String(highlightedString),
                                                 afterHighlightedString: String(afterHighlightedString))
                _sentenceWithHighlightedWord.send(sentenceWithHighlighting)
                break
            }
            i += 1
        }
    }
}


struct WordIndexArray {
    var startIndex: String.Index
    var endIndex:  String.Index
}
