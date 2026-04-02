import Foundation
import SwiftUI

@MainActor
class SearchViewModel: ObservableObject {
    @Published var selectedPlanet: Planet = .sun
    @Published var targetDegree: Double = 0.0
    @Published var startDate: Date = Calendar.current.date(from: DateComponents(year: 2024, month: 1, day: 1)) ?? Date()
    @Published var endDate: Date = Date()
    @Published var tolerance: Double = 0.0001
    @Published var calcMode: CalcMode = .geocentric
    @Published var results: [SearchResult] = []
    @Published var isSearching: Bool = false
    @Published var progress: Double = 0.0
    @Published var errorMessage: String?

    private let searchEngine: DegreeSearchEngine
    private var shouldCancel = false

    init(searchEngine: DegreeSearchEngine = DegreeSearchEngine()) {
        self.searchEngine = searchEngine
    }

    func search() {
        isSearching = true
        progress = 0.0
        results = []
        errorMessage = nil
        shouldCancel = false

        let target = targetDegree.truncatingRemainder(dividingBy: 360.0)
        let searchTarget = target < 0 ? target + 360.0 : target

        Task.detached { [weak self] in
            guard let self = self else { return }

            let searchResults = self.searchEngine.search(
                planet: self.selectedPlanet,
                targetDegree: searchTarget,
                startDate: self.startDate,
                endDate: self.endDate,
                tolerance: self.tolerance,
                mode: self.calcMode,
                progress: { prog in
                    Task { @MainActor in
                        self.progress = prog
                    }
                },
                cancellation: { [weak self] in
                    self?.shouldCancel ?? false
                }
            )

            Task { @MainActor in
                self.results = searchResults
                self.isSearching = false
            }
        }
    }

    func cancel() {
        shouldCancel = true
    }
}
