//
//  ContentView.swift
//  nightshift0.3.0
//
//  Created by Joshua Fitzgerald on 1/4/26.
//

import SwiftUI

struct ContentView: View {
    @State private var isPressed = false
    
    var body: some View {
        VStack {
            Button(action: {
                isPressed.toggle()
            }) {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
            }
            .buttonStyle(.plain)
            Text("Hello, world!")
                .foregroundStyle(isPressed ? .green : .primary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
