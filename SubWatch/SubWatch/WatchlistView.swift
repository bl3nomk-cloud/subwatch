import SwiftUI

struct WatchlistView: View {
    @EnvironmentObject var store: Store
    @State private var showingAdd = false

    private var sortedServices: [ServiceItem] {
        store.services.sorted { a, b in
            if a.isFavorite != b.isFavorite { return a.isFavorite && !b.isFavorite }
            return a.name < b.name
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if !store.changes.isEmpty {
                    Section("آخر التغيّرات") {
                        ForEach(store.changes.prefix(5)) { ch in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(ch.serviceName) — \(ch.region.nameAR)").font(.subheadline).bold()
                                    Text("كان \(fmt(ch.oldSAR)) وصار \(fmt(ch.newSAR)) ر.س").font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(String(format: "%+.1f%%", ch.percent))
                                    .font(.caption).bold()
                                    .foregroundStyle(ch.percent > 0 ? .red : .green)
                            }
                        }
                        Button("مسح سجل التغيّرات", role: .destructive) { store.clearChanges() }
                            .font(.caption)
                    }
                }

                Section("اشتراكاتي — الأرخص شهريًا") {
                    ForEach(sortedServices) { svc in
                        NavigationLink(destination: ServiceDetailView(serviceID: svc.id)) {
                            ServiceRow(service: svc)
                        }
                    }
                    .onDelete { offsets in
                        for i in offsets { store.deleteService(id: sortedServices[i].id) }
                    }
                }

                Section {
                    Text("الأسعار الأساسية محققة بتاريخ 8 نوفمبر 2026 من صفحات المتاجر الرسمية ومتعقّبات أسعار — وليست بثًا حيًا. حدّث أي سعر يدويًا من صفحة الخدمة، وسيُسجَّل التغيّر ويُنبَّهك إذا تجاوز حدّك.")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("منبّه أسعار الاشتراكات")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showingAdd = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showingAdd) { AddServiceView() }
        }
    }
}

struct ServiceRow: View {
    @EnvironmentObject var store: Store
    let service: ServiceItem

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(service.name).font(.headline)
                    if service.isFavorite { Image(systemName: "star.fill").foregroundStyle(.yellow).font(.caption) }
                }
                if let ch = store.cheapest(service) {
                    Text("الأرخص: \(ch.price.region.flag) \(ch.price.region.nameAR) — \(fmt(ch.price.amount)) \(ch.price.region.currencySymbol)")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Text("آخر تحقق: \(service.lastVerified)").font(.caption2).foregroundStyle(.tertiary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                if let ch = store.cheapest(service) {
                    Text("\(fmt(ch.sar)) ر.س").font(.headline).foregroundStyle(Color(red: 0.55, green: 0.42, blue: 1.0))
                    Text("/ شهر").font(.caption2).foregroundStyle(.secondary)
                }
                if let save = store.savingPercent(service) {
                    Text("أوفر بـ \(fmt(save))% من السعودي").font(.caption2).foregroundStyle(.green)
                }
            }
        }
        .padding(.vertical, 2)
    }
}
