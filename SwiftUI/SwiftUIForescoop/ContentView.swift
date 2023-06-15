//
//  ContentView.swift
//  SwiftUIForescoop
//
//  Created by fox on 15/06/2023.
//

import SwiftUI
import Forescoop

struct ContentView: View {
    let user = try? User(map: Definition().json(jsonFile: "User"))
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, \(user?.name ?? "")!")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
