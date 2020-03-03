//
//  ContentView.swift
//  RunningReader
//
//  Created by Matt Crowder on 2/15/20.
//  Copyright © 2020 Matt. All rights reserved.
//

import SwiftUI
import SwiftDate
struct Week: Decodable {
    var sunday: Double?
    var monday: Double?
    var tuesday: Double?
    var wednesday: Double?
    var thursday: Double?
    var friday: Double?
    var saturday: Double?
    
    func getValue(for day: Int) -> Double? {
        switch day {
        case 1:
            return self.sunday
        case 2:
            return self.monday
        case 3:
            return self.tuesday
        case 4:
            return self.wednesday
        case 5:
            return self.thursday
        case 6:
            return self.friday
        case 7:
            return self.saturday
        default:
            return 0
        }
    }
}


private func numberToDay(_ day: Int) -> String {
    switch day {
    case 1:
        return "Sunday"
    case 2:
        return "Monday"
    case 3:
        return "Tuesday"
    case 4:
        return "Wednesday"
    case 5:
        return "Thursday"
    case 6:
        return "Friday"
    case 7:
        return "Saturday"
    default:
        return "Invalid date"
    }
}
struct ActivityIndicator: UIViewRepresentable {
    
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}


struct ContentView: View {
    @State var isLoading: Bool = true
    @State var distance: String = "Loading..."
    @State var year: [Week] = []
    @State var week: Int = -1
    @State var day: Int = -1
    var body: some View {
        VStack {
            if !self.isLoading {
                Text(self.getDate())
                
                HStack {
                    Button("-1") {
                        self.changeDay(-1)
                    }
                    Text("\(self.year[self.week].getValue(for: self.day) ?? 0, specifier: "%.1f")").font(.system(size: 60))
                    Button("+1") {
                        self.changeDay(1)
                    }
                }
                Button("Refresh") {
                    self.fetch()
                }.padding()
                Button("Reset") {
                    self.week = Date().weekOfYear - 1
                    self.day = Date().day
                }
            } else {
                ActivityIndicator(isAnimating: .constant(true), style: .large)
            }
        }.onAppear(perform: self.onAppear)
    }
    private func getDate() -> String {
        let calendar = Calendar.current
        let dateComponents = DateComponents(calendar: calendar, timeZone: .current, era: nil, year: Date().year, month: nil, day: nil, hour: nil, minute: nil, second: nil, nanosecond: nil, weekday: self.day, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: self.week + 1, yearForWeekOfYear: nil)
        let date = calendar.date(from: dateComponents)!
        return date.toFormat("EEEE MM/dd")
    }
    private func changeDay(_ number: Int) {
        if day + number == 0 {
            day = 7
            week -= 1
            return
        }
        
        if day + number == 8 {
            day = 1
            week += 1
            return
        }
        
        day += number
        
    }
    private func fetch() {
        self.isLoading = true
        guard let url = URL(string: "https://running-reader.netlify.com/.netlify/functions/get-weeks") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.distance = "Fetch failed: \(error.localizedDescription)"
                return
            }
            guard let data = data else {
                self.distance = "Failed to unwrap data"
                return
            }
            do {
                let year = try JSONDecoder().decode([Week].self, from: data)
                let week = self.week == -1 ? Date().weekOfYear - 1 : self.week
                let day = self.day == -1 ? Date().day : self.day
                
                self.distance = String(year[week].getValue(for: day) ?? 0)
                
                self.year = year
                self.week = week
                self.day = day
                self.isLoading = false
            } catch {
                self.distance = "Failed to decode \(error.localizedDescription)"
            }
            
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
