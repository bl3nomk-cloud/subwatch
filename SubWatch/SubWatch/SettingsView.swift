import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        NavigationStack {
            Form {
                Section("أسعار الصرف (كم وحدة مقابل 1 ر.س)") {
                    ForEach(["INR", "TRY", "NGN", "USD"], id: \.self) { code in
                        HStack {
                            Text(code)
                            Spacer()
                            Text(fmt(store.perSAR[code] ?? 0)).foregroundStyle(.secondary)
                        }
                    }
                    if let d = store.fxUpdated {
                        Text("آخر تحديث: \(d.formatted(date: .abbreviated, time: .shortened))").font(.caption).foregroundStyle(.secondary)
                    }
                    if let err = store.fxError {
                        Text(err).font(.caption).foregroundStyle(.orange)
                    }
                    Button {
                        Task { await store.refreshFX() }
                    } label: {
                        HStack {
                            Text("تحديث أسعار الصرف الآن")
                            if store.fxRefreshing { ProgressView() }
                        }
                    }.disabled(store.fxRefreshing)
                }
                Section("تنبيهات تغيّر الأسعار") {
                    Stepper(value: $store.threshold, in: 1...50, step: 1) {
                        Text("نبّهني إذا تغيّر سعر بأكثر من \(fmt(store.threshold))%")
                    }.onChange(of: store.threshold) { _ in store.save() }
                    Text("التنبيه يعمل عند تحديثك سعرًا يدويًا من صفحة الخدمة، لأن أسعار اشتراكات App Store لا تتوفر كبثّ حي رسمي لأي تطبيق.")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Section("عن البيانات") {
                    Text("الأسعار الأساسية من بحث 8–9 نوفمبر 2026 (صفحات المتاجر الرسمية ومتعقّبات موثقة، مع تاريخ تحقق لكل خدمة). التحويل للريال بسعر الصرف الحالي — والتوفير المعروض نظري حتى تملك حسابًا ورصيدًا من الدولة الأرخص.")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("الإعدادات")
        }
    }
}
