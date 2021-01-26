//
//  HighlightedString.swift
//  Speechify
//
//  Created by Olorunshola Godwin on 26/01/2021.
//

import Foundation

/**
 This struct represents a sentence with a word highlighted.
 */
struct SentenceWithWordHighlighting: Equatable {
    let beforeHighlightedWord: String
    let highlightedWord: String
    let afterHighlightedWord: String
   
    init(beforeHighlightedString: String = "",
         highlightedWord: String = "",
         afterHighlightedString: String = "") {
        self.beforeHighlightedWord = beforeHighlightedString
        self.highlightedWord = highlightedWord
        self.afterHighlightedWord = afterHighlightedString
    }
}
