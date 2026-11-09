import Foundation

enum Region: String, CaseIterable, Codable, Identifiable {
    case saudi, india, turkiye, nigeria
    var id: String { rawValue }
    var nameAR: String {
        switch self {
        case .saudi: return "السعودية"
        case .india: return "الهند"
        case .turkiye: return "تركيا"
        case .nigeria: return "نيجيريا"
        }
    }
    var flag: String {
        switch self {
        case .saudi: return "🇸🇦"
        case .india: return "🇮🇳"
        case .turkiye: return "🇹🇷"
        case .nigeria: return "🇳🇬"
        }
    }
    var currencyCode: String {
        switch self {
        case .saudi: return "SAR"
        case .india: return "INR"
        case .turkiye: return "TRY"
        case .nigeria: return "NGN"
        }
    }
    var currencySymbol: String {
        switch self {
        case .saudi: return "ر.س"
        case .india: return "₹"
        case .turkiye: return "₺"
        case .nigeria: return "₦"
        }
    }
}

struct RegionPrice: Codable, Identifiable {
    var region: Region
    var amount: Double
    var channel: String // "App Store" or "Web"
    var id: String { region.rawValue }
}

struct ServiceItem: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var nameEN: String
    var category: String
    var prices: [RegionPrice]
    var lastVerified: String
    var note: String = ""
    var isFavorite: Bool = false
}

struct PriceChange: Codable, Identifiable {
    var id: UUID = UUID()
    var serviceName: String
    var region: Region
    var oldSAR: Double
    var newSAR: Double
    var date: Date = Date()
    var percent: Double { oldSAR == 0 ? 0 : (newSAR - oldSAR) / oldSAR * 100 }
}

struct Offer: Codable, Identifiable {
    var id: UUID = UUID()
    var title: String
    var details: String
    var deadline: Date?
    var link: String = ""
}

func fmt(_ v: Double) -> String {
    if v == v.rounded() { return String(format: "%.0f", v) }
    return String(format: "%.2f", v)
}
