//
//  ContentView.swift
//  RunningReader
//
//  Created by Matt Crowder on 2/15/20.
//  Copyright © 2020 Matt. All rights reserved.
//

import SwiftUI
import SwiftDate

struct Value: Codable {
    var monday: String
    var tuesday: String
    var wednesday: String
    var thursday: String
    var friday: String
    var saturday: String
    var sunday: String
    var weekly: String
}
struct Response: Codable {
    var value: Value
    
}
struct ContentView: View {
    @State var distance: String = "Loading..."
    var body: some View {
        VStack {
            Text("\(self.distance)").font(.system(size: 60))
            if self.distance != "Loading..." {
                Button("Refresh") {
                    self.fetch()
                }                
            }
        }.onAppear(perform: self.onAppear)
    }
    private func fetch() {
        self.distance = "Loading..."
        guard let url = URL(string: "https://running-reader.netlify.com/.netlify/functions/get-week") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let d = try? JSONSerialization.jsonObject(with: data, options: [])
                guard let json = d as? [String: Any] else {
                    self.distance = "Failed to fetch"
                    return
                }
                guard let value = json["value"] as? [String: Any] else {
                    self.distance = "Failed to fetch"
                    return
                }
                let day = Date().toFormat("EEEE").lowercased()
                let v = value[day]
                guard let result = v as? Int else {
                    self.distance = "You have the day off!"
                    return
                }
                self.distance = String(result)
                
                return
            }
            
            self.distance = "Fetch failed: \(error?.localizedDescription ?? "Unknown error")"
        }.resume()
    }
    private func onAppear() {
        self.fetch()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
