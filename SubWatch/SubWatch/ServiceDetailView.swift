import SwiftUI

struct ServiceDetailView: View {
    @EnvironmentObject var store: Store
    let serviceID: UUID
    @State private var showingEdit = false

    private var service: ServiceItem? { store.services.first(where: { $0.id == serviceID }) }

    var body: some View {
        Group {
            if let svc = service {
                List {
                    Section {
                        HStack {
                            Text(svc.name).font(.title3).bold()
                            Spacer()
                            Button {
                                store.toggleFavorite(id: svc.id)
                            } label {
                                Image(systemName: svc.isFavorite ? "star.fill" : "star")
                                    .foregroundStyle(.yellow)
                            }.buttonStyle(.plain)
                        }
                        if !svc.note.isEmpty {
                            Text(svc.note).font(.caption).foregroundStyle(.secondary)
                        }
                        Text("آخر تحقق من الأسعار: \(svc.lastVerified)").font(.caption2).foregroundStyle(.tertiary)
                    }
                    Section("السعر الشهري بكل دولة (مرتّب من الأرخص)") {
                        ForEach(svc.prices.sorted { store.sarCost($0) < store.sarCost($1) }, id: \.region.rawValue) { p in
                            HStack {
                                Text("\(p.region.flag) \(p.region.nameAR)").font(.subheadline)
                                Text(p.channel).font(.caption2).foregroundStyle(.tertiary)
                                Spacer()
                                VStack(alignment: .trailing, spacing: 1) {
                                    Text("\(fmt(p.amount)) \(p.region.currencySymbol)").font(.subheadline)
                                    Text("≈ \(fmt(store.sarCost(p))) ر.س").font(.caption).foregroundStyle(Color(red: 0.55, green: 0.42, blue: 1.0))
                                }
                            }
                        }
                    }
                    if let ch = store.cheapest(svc), let sa = store.saudiPrice(svc), ch.price.region != .saudi {
                        Section("الخلاصة") {
                            Text("الأرخص شهريًا: \(ch.price.region.nameAR) بكلفة \(fmt(ch.sar)) ر.س مقابل \(fmt(store.sarCost(sa))) ر.س من المتجر السعودي — توفير \(fmt(store.sarCost(sa) - ch.sar)) ر.س كل شهر (\(fmt(store.sarCost(sa) * 12 - ch.sar * 12)) ر.س بالسنة).")
                                .font(.subheadline)
                            Text("التوفير نظري حتى تملك حسابًا ووسيلة دفع/رصيدًا من تلك الدولة.").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    Section {
                        Button("تعديل الأسعار") { showingEdit = true }
                    }
                }
                .navigationTitle(svc.nameEN)
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $showingEdit) { EditPricesView(serviceID: svc.id) }
            } else {
                Text("الخدمة غير موجودة").foregroundStyle(.secondary)
            }
        }
    }
}

struct EditPricesView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    let serviceID: UUID
    @State private var amounts: [Region: String] = [:]
    @State private var channels: [Region: String] = [:]

    var body: some View {
        NavigationStack {
            Form {
                Section("السعر الشهري بعملة كل دولة") {
                    ForEach(Region.allCases) { region in
                        HStack {
                            Text("\(region.flag) \(region.nameAR)").frame(width: 110, alignment: .leading)
                            TextField("—", text: binding(for: region))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                            Picker("", selection: channelBinding(for: region)) {
                                Text("App Store").tag("App Store")
                                Text("Web").tag("Web")
                            }.pickerStyle(.menu).labelsHidden()
                        }
                    }
                }
                Text("اترك خانة فارغة إذا لم يتغيّر سعر تلك الدولة. أي تعديل يُحفظ بسجل التغيّرات، ويصلك تنبيه إذا تجاوز حدّ التنبيه في الإعدادات.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            .navigationTitle("تعديل الأسعار")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("إلغاء") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("حفظ") { saveAll(); dismiss() } }
            }
            .onAppear { preload() }
        }
    }

    private func preload() {
        guard let svc = store.services.first(where: { $0.id == serviceID }) else { return }
        for p in svc.prices {
            amounts[p.region] = fmt(p.amount)
            channels[p.region] = p.channel
        }
    }

    private func binding(for region: Region) -> Binding<String> {
        Binding(get: { amounts[region] ?? "" }, set: { amounts[region] = $0 })
    }
    private func channelBinding(for region: Region) -> Binding<String> {
        Binding(get: { channels[region] ?? "App Store" }, set: { channels[region] = $0 })
    }

    private func saveAll() {
        guard let svc = store.services.first(where: { $0.id == serviceID }) else { return }
        for region in Region.allCases {
            guard let txt = amounts[region], let val = Double(txt.replacingOccurrences(of: ",", with: ".")) else { continue }
            let existing = svc.prices.first(where: { $0.region == region })
            if existing == nil || abs(existing!.amount - val) > 0.001 {
                store.updatePrice(serviceID: serviceID, region: region, newAmount: val, channel: channels[region] ?? "App Store")
            }
        }
    }
}

struct AddServiceView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var nameEN = ""
    @State private var amounts: [Region: String] = [:]

    var body: some View {
        NavigationStack {
            Form {
                Section("الخدمة") {
                    TextField("الاسم بالعربي", text: $name)
                    TextField("Name in English", text: $nameEN)
                }
                Section("السعر الشهري (اختياري لكل دولة)") {
                    ForEach(Region.allCases) { region in
                        HStack {
                            Text("\(region.flag) \(region.nameAR)").frame(width: 110, alignment: .leading)
                            TextField("—", text: Binding(get: { amounts[region] ?? "" }, set: { amounts[region] = $0 }))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                            Text(region.currencySymbol).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("خدمة جديدة")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("إلغاء") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("إضافة") { add(); dismiss() }.disabled(name.isEmpty)
                }
            }
        }
    }

    private func add() {
        var prices: [RegionPrice] = []
        for region in Region.allCases {
            if let txt = amounts[region], let val = Double(txt.replacingOccurrences(of: ",", with: ".")) {
                prices.append(RegionPrice(region: region, amount: val, channel: "App Store"))
            }
        }
        let f = DateFormatter(); f.calendar = Calendar(identifier: .gregorian); f.dateFormat = "yyyy-MM-dd"
        store.addService(ServiceItem(name: name, nameEN: nameEN.isEmpty ? name : nameEN, category: "مخصص",
                                     prices: prices, lastVerified: f.string(from: Date()), note: "أضفتها يدويًا."))
    }
}
