import Foundation

class SwissEphemerisWrapper {
    private var initialized = false

    init() {
        initialize()
    }

    private func initialize() {
        guard !initialized else { return }
        let path = Bundle.main.bundlePath + "/ephe"
        swe_set_ephe_path(path)
        initialized = true
    }

    func julianDay(year: Int, month: Int, day: Int, hour: Double) -> Double {
        return swe_julday(year, month, day, hour, SE_GREG_CAL)
    }

    func calculatePlanet(
        julianDay: Double,
        planet: Int32,
        flags: Int32
    ) -> (longitude: Double, latitude: Double, distance: Double, speed: Double, retrograde: Bool, error: String?) {
        var xx = [Double](repeating: 0, count: 6)
        var serr = [CChar](repeating: 0, count: 256)
        var retflag: Int32 = 0

        retflag = swe_calc_ut(julianDay, planet, flags, &xx, &serr)

        let error = String(cString: serr)
        let hasError = !error.isEmpty && retflag < 0

        return (
            longitude: normalizeDegree(xx[0]),
            latitude: xx[1],
            distance: xx[2],
            speed: xx[3],
            retrograde: xx[3] < 0,
            error: hasError ? error : nil
        )
    }

    func calculateHouses(
        julianDay: Double,
        latitude: Double,
        longitude: Double
    ) -> (asc: Double, mc: Double, desc: Double, ic: Double, error: String?) {
        var cusps = [Double](repeating: 0, count: 13)
        var ascmc = [Double](repeating: 0, count: 10)
        var serr = [CChar](repeating: 0, count: 256)

        let ret = swe_houses(
            julianDay,
            latitude,
            longitude,
            Int32(ascii: "P"),
            &cusps,
            &ascmc,
            &serr
        )

        let error = String(cString: serr)

        return (
            asc: normalizeDegree(ascmc[0]),
            mc: normalizeDegree(ascmc[1]),
            desc: normalizeDegree(fmod(ascmc[0] + 180.0, 360.0)),
            ic: normalizeDegree(fmod(ascmc[1] + 180.0, 360.0)),
            error: ret < 0 ? error : nil
        )
    }

    private func normalizeDegree(_ deg: Double) -> Double {
        var d = deg.truncatingRemainder(dividingBy: 360.0)
        if d < 0 { d += 360.0 }
        return d
    }
}
