import Foundation
import SwiftUI

@MainActor
class EphemerisViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var calcMode: CalcMode = .geocentric
    @Published var positions: [PlanetPosition] = []
    @Published var houses: HousePositions?
    @Published var isCalculating: Bool = false
    @Published var errorMessage: String?

    private let engine: EphemerisEngine

    init(engine: EphemerisEngine = EphemerisEngine()) {
        self.engine = engine
    }

    func calculate() {
        isCalculating = true
        errorMessage = nil

        do {
            let (pos, housePos) = engine.calculatePositions(date: selectedDate, mode: calcMode)
            positions = pos
            houses = housePos
        } catch {
            errorMessage = error.localizedDescription
        }

        isCalculating = false
    }
}
