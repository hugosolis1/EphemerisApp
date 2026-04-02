import Foundation

class EphemerisEngine {
    private let wrapper: SwissEphemerisWrapper

    // Greenwich coordinates
    private let defaultLat: Double = 51.4769
    private let defaultLon: Double = 0.0005

    init(wrapper: SwissEphemerisWrapper = SwissEphemerisWrapper()) {
        self.wrapper = wrapper
    }

    func calculatePositions(
        date: Date,
        mode: CalcMode
    ) -> ([PlanetPosition], HousePositions) {
        let calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let year = components.year!
        let month = components.month!
        let day = components.day!
        let hour = Double(components.hour!) + Double(components.minute!) / 60.0 + Double(components.second!) / 3600.0

        let jd = wrapper.julianDay(year: year, month: month, day: day, hour: hour)

        var positions: [PlanetPosition] = []

        let planets: [Planet] = [.sun, .moon, .mercury, .venus, .mars, .jupiter, .saturn, .uranus, .neptune, .pluto, .trueNode, .meanNode]

        for planet in planets {
            let result = wrapper.calculatePlanet(julianDay: jd, planet: planet.seBody, flags: mode.flags)

            positions.append(PlanetPosition(
                planet: planet,
                longitude: result.longitude,
                latitude: result.latitude,
                distance: result.distance,
                speed: result.speed,
                retrograde: result.retrograde
            ))
        }

        let houses = wrapper.calculateHouses(julianDay: jd, latitude: defaultLat, longitude: defaultLon)

        let housePositions = HousePositions(
            ascendant: houses.asc,
            descendant: houses.desc,
            midheaven: houses.mc,
            ic: houses.ic
        )

        return (positions, housePositions)
    }

    func calculatePlanetAt(
        date: Date,
        planet: Planet,
        mode: CalcMode
    ) -> PlanetPosition {
        let calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let jd = wrapper.julianDay(
            year: components.year!,
            month: components.month!,
            day: components.day!,
            hour: Double(components.hour!) + Double(components.minute!) / 60.0 + Double(components.second!) / 3600.0
        )

        let result = wrapper.calculatePlanet(julianDay: jd, planet: planet.seBody, flags: mode.flags)

        return PlanetPosition(
            planet: planet,
            longitude: result.longitude,
            latitude: result.latitude,
            distance: result.distance,
            speed: result.speed,
            retrograde: result.retrograde
        )
    }
}
