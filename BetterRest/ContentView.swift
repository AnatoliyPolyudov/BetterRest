//
//  ContentView.swift
//  BetterRest
//
//  Created by Анатолий on 25.09.2020.
//

import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    let model = SleepCalculator()
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    var body: some View {
        
        NavigationView {
            VStack {
                Text("Время пробуждения")
                    .font(.title2)
                DatePicker(selection: $wakeUp, displayedComponents: .hourAndMinute, label: { Text("Введите время") })
                    .labelsHidden()
                Text("Желаемое количество сна")
                    .font(.title2)
                Stepper(value: $sleepAmount, in: 4...8) {
                    Text("\(sleepAmount, specifier: "%g")")
                        .font(.headline)
                }
                Text("Количество выпитых чашек кофе")
                    .font(.title2)
                Stepper(value: $coffeeAmount, in: 1...20) {
                    Text("\(coffeeAmount)")
                        .font(.headline)
                }
                Spacer()
                    .alert(isPresented: $showingAlert, content: {
                        Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("Ok")))
                    })
            }
            .padding()
            .navigationBarTitle("Отдыхать лучше")
            .navigationBarItems(leading:
                                    Button(action: calculateBedTime) {
                                        Text("Посчитать")
                                    }
            )
        }
    }
    
    func calculateBedTime() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        do {
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            showingAlert = true
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            alertMessage = formatter.string(from: sleepTime)
            alertTitle = "Идеальное время для сна..."
        } catch {
            alertTitle = "Ошибка"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
