import Foundation

enum Seed {
    static func services() -> [ServiceItem] {
        let v = "2026-11-08"
        return [
            ServiceItem(name: "يوتيوب بريميوم", nameEN: "YouTube Premium", category: "فيديو",
                        prices: [RegionPrice(region: .saudi, amount: 39.99, channel: "App Store"),
                                 RegionPrice(region: .india, amount: 195, channel: "App Store"),
                                 RegionPrice(region: .turkiye, amount: 159.99, channel: "App Store"),
                                 RegionPrice(region: .nigeria, amount: 2200, channel: "App Store")],
                        lastVerified: v, note: "سعر الهند وتركيا من متعقّبات أسعار المتجر. سعر الشراء من الويب أرخص عادة (السعودي 29.99).", isFavorite: true),
            ServiceItem(name: "يوتيوب بريميوم العائلي", nameEN: "YouTube Premium Family", category: "فيديو",
                        prices: [RegionPrice(region: .saudi, amount: 74.99, channel: "App Store"),
                                 RegionPrice(region: .india, amount: 389, channel: "App Store")],
                        lastVerified: "2026-11-02", note: "سعر الهند حسب تجارب مستخدمين موثقة. العائلة تتطلب نفس الدولة والمنزل.", isFavorite: true),
            ServiceItem(name: "يوتيوب بريميوم لايت", nameEN: "YouTube Premium Lite", category: "فيديو",
                        prices: [RegionPrice(region: .saudi, amount: 21.99, channel: "App Store")],
                        lastVerified: v, note: "من الويب السعودي: 16.99 شهريًا."),
            ServiceItem(name: "أبل ميوزك", nameEN: "Apple Music", category: "موسيقى",
                        prices: [RegionPrice(region: .saudi, amount: 23.99, channel: "App Store"),
                                 RegionPrice(region: .india, amount: 139, channel: "App Store"),
                                 RegionPrice(region: .turkiye, amount: 89.99, channel: "App Store"),
                                 RegionPrice(region: .nigeria, amount: 1700, channel: "App Store")],
                        lastVerified: v),
            ServiceItem(name: "سبوتيفاي بريميوم", nameEN: "Spotify Premium", category: "موسيقى",
                        prices: [RegionPrice(region: .saudi, amount: 23.99, channel: "Web"),
                                 RegionPrice(region: .india, amount: 139, channel: "Web"),
                                 RegionPrice(region: .turkiye, amount: 115, channel: "Web"),
                                 RegionPrice(region: .nigeria, amount: 1600, channel: "Web")],
                        lastVerified: v, note: "لا يُباع عبر App Store في الدول الأربع — الأسعار من موقع سبوتيفاي الرسمي."),
            ServiceItem(name: "آيكلاود+ 200GB", nameEN: "iCloud+ 200 GB", category: "تخزين",
                        prices: [RegionPrice(region: .saudi, amount: 12.99, channel: "App Store"),
                                 RegionPrice(region: .india, amount: 219, channel: "App Store"),
                                 RegionPrice(region: .turkiye, amount: 169.99, channel: "App Store"),
                                 RegionPrice(region: .nigeria, amount: 4500, channel: "App Store")],
                        lastVerified: v),
            ServiceItem(name: "تيليجرام بريميوم", nameEN: "Telegram Premium", category: "تواصل",
                        prices: [RegionPrice(region: .saudi, amount: 20.99, channel: "App Store"),
                                 RegionPrice(region: .india, amount: 319, channel: "App Store"),
                                 RegionPrice(region: .turkiye, amount: 189.99, channel: "App Store"),
                                 RegionPrice(region: .nigeria, amount: 4950, channel: "App Store")],
                        lastVerified: v),
            ServiceItem(name: "دولينجو سوبر", nameEN: "Duolingo Super", category: "تعليم",
                        prices: [RegionPrice(region: .saudi, amount: 37.99, channel: "App Store"),
                                 RegionPrice(region: .india, amount: 199, channel: "App Store"),
                                 RegionPrice(region: .turkiye, amount: 139.99, channel: "App Store"),
                                 RegionPrice(region: .nigeria, amount: 4500, channel: "App Store")],
                        lastVerified: v, note: "سعر نيجيريا من متعقّب فقط — غير مؤكد على صفحة المتجر.")
        ]
    }

    static func offers() -> [Offer] {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Asia/Riyadh")!
        let aiPlusDeadline = cal.date(from: DateComponents(year: 2026, month: 12, day: 31))!
        return [
            Offer(title: "Google AI Plus مجانًا 12 شهر (طلاب، السعودية)",
                  details: "تفعيل قبل نهاية 2026 من حساب Gmail شخصي — جامعة الطائف عبر SheerID. السعر العادي 4.99$ شهريًا و400GB.",
                  deadline: aiPlusDeadline, link: "https://one.google.com"),
            Offer(title: "حزمة طالب: AI Pro + يوتيوب بريميوم بسعر مخفّض",
                  details: "السعودية مؤهلة رسميًا، حتى 4 سنوات متتالية مع إعادة تحقق SheerID سنويًا. السعر يظهر فقط أثناء التسجيل.",
                  deadline: nil, link: "https://one.google.com"),
            Offer(title: "تذكير منهجي: أسعار الهند بالبطاقات",
                  details: "بطاقات هدايا أبل الهندية: SEAGM علاوة ~12%، وPhone91 أرخص حسابيًا لكنه متجر غير موثّق — جرّب بأصغر فئة أولًا إن جرّبت.",
                  deadline: nil, link: "")
        ]
    }

    // Units of foreign currency per 1 SAR (fallback, 8 Nov 2026)
    static let fallbackPerSAR: [String: Double] = [
        "SAR": 1.0,
        "INR": 25.06,
        "TRY": 13.35,
        "NGN": 358.42,
        "USD": 0.2667
    ]
}
