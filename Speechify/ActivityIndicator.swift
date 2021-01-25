//
//  ActivityIndicator.swift
//  Speechify
//
//  Created by Olorunshola Godwin on 25/01/2021.
//

import Foundation
import SwiftUI

struct ActivityIndicator: UIViewRepresentable {

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: .large)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        uiView.startAnimating()
    }
}
