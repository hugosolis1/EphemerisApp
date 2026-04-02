import Foundation

class AscendantCalculator {
    private let wrapper: SwissEphemerisWrapper

    // Greenwich coordinates
    let latitude: Double = 51.4769
    let longitude: Double = 0.0005
    let locationName: String = "Greenwich, London"

    init(wrapper: SwissEphemerisWrapper = SwissEphemerisWrapper()) {
        self.wrapper = wrapper
    }

    func calculateHouses(for date: Date) -> HousePositions {
        let calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let jd = wrapper.julianDay(
            year: components.year!,
            month: components.month!,
            day: components.day!,
            hour: Double(components.hour!) + Double(components.minute!) / 60.0 + Double(components.second!) / 3600.0
        )

        let houses = wrapper.calculateHouses(
            julianDay: jd,
            latitude: latitude,
            longitude: longitude
        )

        return HousePositions(
            ascendant: houses.asc,
            descendant: houses.desc,
            midheaven: houses.mc,
            ic: houses.ic
        )
    }
}
