import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            EphemeridesTab()
                .tabItem {
                    Label("Ephemerides", systemImage: "sun.max.fill")
                }

            DegreeSearchTab()
                .tabItem {
                    Label("Degree Search", systemImage: "magnifyingglass")
                }
        }
    }
}

struct EphemeridesTab: View {
    @StateObject private var viewModel = EphemerisViewModel()
    @State private var selectedTimeHour = 12
    @State private var selectedTimeMinute = 0

    var body: some View {
        NavigationView {
            Form {
                Section("Date & Time (UTC)") {
                    DatePicker("Date", selection: $viewModel.selectedDate, displayedComponents: .date)

                    HStack {
                        Text("Time (UTC)")
                        Spacer()
                        Picker("Hour", selection: $selectedTimeHour) {
                            ForEach(0..<24) { hour in
                                Text(String(format: "%02d", hour)).tag(hour)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 80)

                        Text(":")

                        Picker("Minute", selection: $selectedTimeMinute) {
                            ForEach(0..<60) { minute in
                                Text(String(format: "%02d", minute)).tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 80)
                    }
                }

                Section("Calculation Mode") {
                    Picker("Mode", selection: $viewModel.calcMode) {
                        ForEach(CalcMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    Button(action: {
                        var calendar = Calendar(identifier: .gregorian)
                        calendar.timeZone = TimeZone(identifier: "UTC")!
                        var components = calendar.dateComponents([.year, .month, .day], from: viewModel.selectedDate)
                        components.hour = selectedTimeHour
                        components.minute = selectedTimeMinute
                        components.second = 0
                        if let date = calendar.date(from: components) {
                            viewModel.selectedDate = date
                        }
                        viewModel.calculate()
                    }) {
                        HStack {
                            Spacer()
                            if viewModel.isCalculating {
                                ProgressView()
                            } else {
                                Text("Calculate")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(viewModel.isCalculating)
                }

                if let houses = viewModel.houses {
                    Section("Angles (Greenwich)") {
                        HStack {
                            Text("ASC")
                            Spacer()
                            Text(houses.ascString).fontWeight(.medium)
                        }
                        HStack {
                            Text("MC")
                            Spacer()
                            Text(houses.mcString).fontWeight(.medium)
                        }
                        HStack {
                            Text("DESC")
                            Spacer()
                            Text(houses.descString).fontWeight(.medium)
                        }
                        HStack {
                            Text("IC")
                            Spacer()
                            Text(houses.icString).fontWeight(.medium)
                        }
                    }
                }

                if !viewModel.positions.isEmpty {
                    Section("Planetary Positions") {
                        ForEach(viewModel.positions) { position in
                            HStack {
                                Text(position.planet.rawValue)
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text(position.degreeString)
                                        .fontWeight(.medium)
                                        .font(.system(.body, design: .monospaced))
                                    if position.retrograde {
                                        Text("Rx")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                    }
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Ephemerides")
        }
    }
}

struct DegreeSearchTab: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var degreeText = "0.0"

    var body: some View {
        NavigationView {
            Form {
                Section("Planet") {
                    Picker("Planet", selection: $viewModel.selectedPlanet) {
                        ForEach(Planet.allCases) { planet in
                            Text(planet.rawValue).tag(planet)
                        }
                    }
                }

                Section("Target Degree") {
                    TextField("Degree (0-360)", text: $degreeText)
                        .keyboardType(.decimalPad)
                    Text("Tolerance: ±\(viewModel.tolerance)°")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section("Date Range (UTC)") {
                    DatePicker("Start Date", selection: $viewModel.startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $viewModel.endDate, displayedComponents: .date)
                }

                Section("Mode") {
                    Picker("Mode", selection: $viewModel.calcMode) {
                        ForEach(CalcMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    if viewModel.isSearching {
                        VStack {
                            ProgressView(value: viewModel.progress)
                                .progressViewStyle(.linear)
                            Text("\(Int(viewModel.progress * 100))%")
                                .font(.caption)

                            Button("Cancel") {
                                viewModel.cancel()
                            }
                            .foregroundColor(.red)
                        }
                    } else {
                        Button(action: {
                            if let degree = Double(degreeText) {
                                viewModel.targetDegree = degree
                                viewModel.search()
                            }
                        }) {
                            HStack {
                                Spacer()
                                Text("Search")
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                        }
                    }
                }

                if !viewModel.results.isEmpty {
                    Section("Results (\(viewModel.results.count))") {
                        ForEach(viewModel.results) { result in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(result.planet.rawValue)
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text(String(format: "%.5f°", result.degree))
                                        .font(.system(.body, design: .monospaced))
                                }
                                HStack {
                                    Text(result.dateString)
                                    Spacer()
                                    Text(result.timeString + " UTC")
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Degree Search")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
