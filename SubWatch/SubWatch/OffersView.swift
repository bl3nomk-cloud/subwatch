import SwiftUI

struct OffersView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.offers) { offer in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(offer.title).font(.headline)
                        Text(offer.details).font(.subheadline).foregroundStyle(.secondary)
                        if let deadline = offer.deadline {
                            let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: deadline)).day ?? 0
                            HStack {
                                Label("ينتهي بعد \(days) يوم", systemImage: "calendar.badge.clock")
                                    .font(.caption).bold()
                                    .foregroundStyle(days <= 30 ? .orange : .secondary)
                                Spacer()
                                Button("ذكّرني") { store.scheduleOfferReminders(offer) }
                                    .font(.caption)
                            }
                        }
                        if !offer.link.isEmpty, let url = URL(string: offer.link) {
                            Link("صفحة العرض الرسمية", destination: url).font(.caption)
                        }
                    }
                    .padding(.vertical, 4)
                }
                Section {
                    Text("العروض هنا مدخلة يدويًا من بحث موثق (نوفمبر 2026) — تحقق من الصفحة الرسمية قبل الاعتماد عليها، فالعروض تتغيّر بدون إشعار.")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("العروض والمواعيد")
        }
    }
}
