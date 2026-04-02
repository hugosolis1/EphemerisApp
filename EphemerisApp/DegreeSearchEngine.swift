import Foundation

class DegreeSearchEngine {
    private let engine: EphemerisEngine

    init(engine: EphemerisEngine = EphemerisEngine()) {
        self.engine = engine
    }

    /// Search for when a planet reaches a specific degree within a date range
    /// - Parameters:
    ///   - planet: The planet to search for
    ///   - targetDegree: Target degree (0-360)
    ///   - startDate: Start of search range
    ///   - endDate: End of search range
    ///   - tolerance: Acceptable tolerance in degrees (default 0.0001)
    ///   - mode: Geocentric or heliocentric
    ///   - progress: Progress callback (0.0 to 1.0)
    ///   - cancellation: Check for cancellation
    /// - Returns: Array of SearchResult
    func search(
        planet: Planet,
        targetDegree: Double,
        startDate: Date,
        endDate: Date,
        tolerance: Double = 0.0001,
        mode: CalcMode,
        progress: ((Double) -> Void)? = nil,
        cancellation: (() -> Bool)? = nil
    ) -> [SearchResult] {
        var results: [SearchResult] = []

        let totalSeconds = endDate.timeIntervalSince(startDate)
        let scanInterval: TimeInterval = 3600 // 1 hour
        var currentTime = startDate

        // Phase 1: Scan by 1-hour increments to find crossings
        var crossings: [(Date, Date)] = []
        var prevPosition = engine.calculatePlanetAt(date: currentTime, planet: planet, mode: mode)
        var prevDegree = prevPosition.longitude

        var scanned: TimeInterval = 0

        while currentTime < endDate {
            if let shouldCancel = cancellation, shouldCancel() {
                break
            }

            currentTime = min(currentTime.addingTimeInterval(scanInterval), endDate)
            scanned += scanInterval

            progress?(scanned / totalSeconds)

            let currentPosition = engine.calculatePlanetAt(date: currentTime, planet: planet, mode: mode)
            let currentDegree = currentPosition.longitude

            // Check for crossing
            if hasCrossed(
                from: prevDegree,
                to: currentDegree,
                target: targetDegree,
                retrograde: currentPosition.retrograde
            ) {
                crossings.append((currentTime.addingTimeInterval(-scanInterval), currentTime))
            }

            prevDegree = currentDegree
            prevPosition = currentPosition
        }

        // Phase 2: Binary search each crossing to refine precision
        for (start, end) in crossings {
            if let shouldCancel = cancellation, shouldCancel() {
                break
            }

            let refined = binarySearch(
                planet: planet,
                targetDegree: targetDegree,
                startDate: start,
                endDate: end,
                tolerance: tolerance,
                mode: mode
            )

            if let result = refined {
                results.append(result)
            }
        }

        progress?(1.0)
        return results
    }

    private func hasCrossed(from: Double, to: Double, target: Double, retrograde: Bool) -> Bool {
        if retrograde {
            return degreeBetweenReversed(from: from, to: to, contains: target)
        } else {
            return degreeBetween(from: from, to: to, contains: target)
        }
    }

    private func degreeBetween(from: Double, to: Double, contains target: Double) -> Bool {
        if from <= to {
            return target >= from && target <= to
        } else {
            return target >= from || target <= to
        }
    }

    private func degreeBetweenReversed(from: Double, to: Double, contains target: Double) -> Bool {
        if from >= to {
            return target <= from && target >= to
        } else {
            return target <= from || target >= to
        }
    }

    private func binarySearch(
        planet: Planet,
        targetDegree: Double,
        startDate: Date,
        endDate: Date,
        tolerance: Double,
        mode: CalcMode
    ) -> SearchResult? {
        var low = startDate
        var high = endDate

        // Binary search to ~1 second precision
        for _ in 0..<50 {
            let mid = Date(timeIntervalSince1970: (low.timeIntervalSince1970 + high.timeIntervalSince1970) / 2.0)
            let position = engine.calculatePlanetAt(date: mid, planet: planet, mode: mode)
            let diff = angularDistance(from: position.longitude, to: targetDegree)

            if diff <= tolerance {
                return SearchResult(
                    planet: planet,
                    degree: position.longitude,
                    date: mid,
                    isRetrograde: position.retrograde
                )
            }

            // Determine which half to search
            let lowPos = engine.calculatePlanetAt(date: low, planet: planet, mode: mode)
            let midPos = engine.calculatePlanetAt(date: mid, planet: planet, mode: mode)

            let crossesLower = hasCrossed(
                from: lowPos.longitude,
                to: midPos.longitude,
                target: targetDegree,
                retrograde: midPos.retrograde
            )

            if crossesLower {
                high = mid
            } else {
                low = mid
            }
        }

        // Return best approximation
        let mid = Date(timeIntervalSince1970: (low.timeIntervalSince1970 + high.timeIntervalSince1970) / 2.0)
        let position = engine.calculatePlanetAt(date: mid, planet: planet, mode: mode)

        if angularDistance(from: position.longitude, to: targetDegree) <= tolerance * 10 {
            return SearchResult(
                planet: planet,
                degree: position.longitude,
                date: mid,
                isRetrograde: position.retrograde
            )
        }

        return nil
    }

    private func angularDistance(from: Double, to: Double) -> Double {
        var diff = abs(from - to)
        if diff > 180 {
            diff = 360 - diff
        }
        return diff
    }
}
