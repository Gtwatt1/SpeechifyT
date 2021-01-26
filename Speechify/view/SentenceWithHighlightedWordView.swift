//
//  HighlightedTextView.swift
//  Speechify
//
//  Created by Olorunshola Godwin on 26/01/2021.
//

import Foundation

import SwiftUI

/**
 Custom view that takes in a sentence and highlight some specified words.
 */
struct SentenceWithHighlightedWordView: View {
    var sentence: SentenceWithWordHighlighting
    
    var body: some View {
        Group {
            Text(sentence.beforeHighlightedWord)
            +
            Text(sentence.highlightedWord.capitalized)
                .foregroundColor(Color("active_button"))
                .bold()
            +
            Text(sentence.afterHighlightedWord)
        }.font(.title)
        .foregroundColor(Color.black)
        .padding()
        .frame(width:UIScreen.main.bounds.width - 48 , height: 240, alignment: .topLeading)
        .border(Color.secondary, width: 1)
    }
}

struct HighlightedTextView_Previews: PreviewProvider {
    static var previews: some View {
        let sentence = SentenceWithWordHighlighting(
            beforeHighlightedString: "What is ",
            highlightedWord: "going on",
            afterHighlightedString: " here today")
        SentenceWithHighlightedWordView(sentence: sentence)
    }
}
