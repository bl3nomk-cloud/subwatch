import Foundation
import UserNotifications

struct PersistedData: Codable {
    var services: [ServiceItem]
    var changes: [PriceChange]
    var offers: [Offer]
    var perSAR: [String: Double]
    var fxUpdated: Date?
    var threshold: Double
}

@MainActor
final class Store: ObservableObject {
    @Published var services: [ServiceItem] = []
    @Published var changes: [PriceChange] = []
    @Published var offers: [Offer] = []
    @Published var perSAR: [String: Double] = Seed.fallbackPerSAR
    @Published var fxUpdated: Date? = nil
    @Published var threshold: Double = 5.0
    @Published var fxRefreshing: Bool = false
    @Published var fxError: String? = nil

    private var fileURL: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("subwatch-data.json")
    }

    init() { load() }

    func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode(PersistedData.self, from: data) {
            services = decoded.services
            changes = decoded.changes
            offers = decoded.offers
            perSAR = decoded.perSAR
            fxUpdated = decoded.fxUpdated
            threshold = decoded.threshold
        } else {
            services = Seed.services()
            offers = Seed.offers()
            save()
        }
    }

    func save() {
        let data = PersistedData(services: services, changes: changes, offers: offers,
                                 perSAR: perSAR, fxUpdated: fxUpdated, threshold: threshold)
        if let encoded = try? JSONEncoder().encode(data) {
            try? encoded.write(to: fileURL, options: .atomic)
        }
    }

    // MARK: - Money

    func sarCost(_ price: RegionPrice) -> Double {
        let rate = perSAR[price.region.currencyCode] ?? 0
        if price.region == .saudi { return price.amount }
        guard rate > 0 else { return price.amount }
        return price.amount / rate
    }

    func cheapest(_ service: ServiceItem) -> (price: RegionPrice, sar: Double)? {
        service.prices.map { ($0, sarCost($0)) }.min(by: { $0.1 < $1.1 }).map { (price: $0.0, sar: $0.1) }
    }

    func saudiPrice(_ service: ServiceItem) -> RegionPrice? {
        service.prices.first(where: { $0.region == .saudi })
    }

    func savingPercent(_ service: ServiceItem) -> Double? {
        guard let sa = saudiPrice(service), let ch = cheapest(service) else { return nil }
        let saCost = sarCost(sa)
        guard saCost > 0, ch.price.region != .saudi else { return nil }
        return (saCost - ch.sar) / saCost * 100
    }

    // MARK: - Editing

    func updatePrice(serviceID: UUID, region: Region, newAmount: Double, channel: String) {
        guard let idx = services.firstIndex(where: { $0.id == serviceID }) else { return }
        var svc = services[idx]
        if let pIdx = svc.prices.firstIndex(where: { $0.region == region }) {
            let old = svc.prices[pIdx]
            let oldSAR = sarCost(old)
            svc.prices[pIdx] = RegionPrice(region: region, amount: newAmount, channel: channel)
            let newSAR = sarCost(svc.prices[pIdx])
            if abs(newAmount - old.amount) > 0.001 {
                let change = PriceChange(serviceName: svc.name, region: region, oldSAR: oldSAR, newSAR: newSAR)
                changes.insert(change, at: 0)
                if abs(change.percent) >= threshold {
                    notify(title: "تغيّر سعر: \(svc.name)",
                           body: "\(region.nameAR): كان \(fmt(oldSAR)) ر.س وصار \(fmt(newSAR)) ر.س (\(String(format: "%+.1f", change.percent))%)")
                }
            }
        } else {
            svc.prices.append(RegionPrice(region: region, amount: newAmount, channel: channel))
        }
        svc.lastVerified = todayString()
        services[idx] = svc
        save()
    }

    func addService(_ svc: ServiceItem) {
        services.append(svc)
        save()
    }

    func deleteService(id: UUID) {
        services.removeAll { $0.id == id }
        save()
    }

    func toggleFavorite(id: UUID) {
        guard let idx = services.firstIndex(where: { $0.id == id }) else { return }
        services[idx].isFavorite.toggle()
        save()
    }

    func clearChanges() {
        changes.removeAll()
        save()
    }

    // MARK: - FX

    func refreshFX() async {
        fxRefreshing = true
        fxError = nil
        defer { fxRefreshing = false }
        do {
            let url = URL(string: "https://open.er-api.com/v6/latest/SAR")!
            let (data, _) = try await URLSession.shared.data(from: url)
            struct Resp: Decodable { let result: String; let rates: [String: Double] }
            let resp = try JSONDecoder().decode(Resp.self, from: data)
            guard resp.result == "success" else { throw URLError(.badServerResponse) }
            var merged = perSAR
            for code in ["INR", "TRY", "NGN", "USD"] {
                if let r = resp.rates[code] { merged[code] = r }
            }
            perSAR = merged
            fxUpdated = Date()
            save()
        } catch {
            fxError = "تعذّر تحديث أسعار الصرف — الأرقام المعروضة بآخر سعر محفوظ."
        }
    }

    // MARK: - Notifications

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func notify(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let req = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req)
    }

    func scheduleOfferReminders(_ offer: Offer) {
        guard let deadline = offer.deadline else { return }
        requestNotificationPermission()
        let center = UNUserNotificationCenter.current()
        for daysBefore in [7, 1] {
            guard let fireDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: deadline),
                  fireDate > Date() else { continue }
            let content = UNMutableNotificationContent()
            content.title = "موعد عرض يقترب"
            content.body = "\(offer.title) — ينتهي بعد \(daysBefore == 7 ? "أسبوع" : "يوم")."
            content.sound = .default
            let comps = Calendar.current.dateComponents([.year, .month, .day, .hour], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            let req = UNNotificationRequest(identifier: "offer-\(offer.id.uuidString)-\(daysBefore)", content: content, trigger: trigger)
            center.add(req)
        }
        notify(title: "تم ضبط التذكير", body: offer.title)
    }

    private func todayString() -> String {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }
}
