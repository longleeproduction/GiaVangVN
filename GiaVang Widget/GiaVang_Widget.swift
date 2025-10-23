//
//  GiaVang_Widget.swift
//  GiaVang Widget
//
//  Created by ORL on 23/10/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetEntry {
        WidgetEntry(date: Date(), goldSJC: nil, gold9999: nil, priceAg999: nil, currency: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> ()) {
        let entry = WidgetEntry(date: Date(), goldSJC: nil, gold9999: nil, priceAg999: nil, currency: nil)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> ()) {
        Task {
            // Fetch data from APIs
            var goldSJC: GoldPriceData?
            var gold9999: GoldPriceData?
            var priceAg999: GoldPriceData?
            var currency: CurrencyPriceData?

            do {
                // Fetch Gold SJC price
                let sjcRequest = GoldPriceRequest(
                    product: "Vàng miếng SJC",
                    city: "Hồ Chí Minh",
                    branch: "SJC"
                )
                let sjcResponse = try await DashboardService.shared.fetchGoldPrice(request: sjcRequest)
                goldSJC = sjcResponse.data
            } catch {
                print("Error fetching Gold SJC: \(error)")
            }

            do {
                // Fetch Gold 9999 price
                let gold9999Request = GoldPriceRequest()
                let gold9999Response = try await DashboardService.shared.fetchGoldPrice(request: gold9999Request)
                gold9999 = gold9999Response.data
            } catch {
                print("Error fetching Gold 9999: \(error)")
            }

            do {
                // Fetch Silver Ag999 price
                let ag999Request = GoldPriceRequest(
                    product: "Bạc thỏi Phú Quý 999",
                    city: "Hà Nội",
                    branch: "PHUQUY"
                )
                let ag999Response = try await DashboardService.shared.fetchGoldPrice(request: ag999Request)
                priceAg999 = ag999Response.data
            } catch {
                print("Error fetching Ag 999: \(error)")
            }

            do {
                // Fetch USD currency price
                let currencyRequest = CurrencyPriceRequest()
                let currencyResponse = try await DashboardService.shared.fetchCurrencyPrice(request: currencyRequest)
                currency = currencyResponse.data
            } catch {
                print("Error fetching currency: \(error)")
            }

            // Create entry with fetched data
            let currentDate = Date()
            let entry = WidgetEntry(
                date: currentDate,
                goldSJC: goldSJC,
                gold9999: gold9999,
                priceAg999: priceAg999,
                currency: currency
            )

            // Update widget every 15 minutes
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))

            completion(timeline)
        }
    }
}

struct WidgetEntry: TimelineEntry {
    let date: Date
    let goldSJC: GoldPriceData?
    let gold9999: GoldPriceData?
    let priceAg999: GoldPriceData?
    let currency: CurrencyPriceData?
}

struct GiaVang_WidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge, .systemExtraLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct GiaVang_Widget: Widget {
    let kind: String = "GiaVang_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            GiaVang_WidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Giá Vàng VN")
        .description("Theo dõi giá vàng và tỷ giá ngoại tệ")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Small Widget View
struct SmallWidgetView: View {
    let entry: WidgetEntry

    var body: some View {
        VStack(spacing: 6) {
            // Header
            HStack(spacing: 4) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 11))
                    .foregroundColor(.yellow)
                Text("Giá Vàng")
                    .font(.system(size: 11, weight: .bold))
                Spacer()
            }

            Divider()
                .padding(.vertical, -2)

            // Gold SJC
            if let goldSJC = entry.goldSJC {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Vàng SJC")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)

                    HStack(spacing: 4) {
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Mua")
                                .font(.system(size: 7))
                                .foregroundColor(.secondary)
                            Text(ApiDecryptor.decrypt(goldSJC.buyDisplay))
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.green)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(alignment: .trailing, spacing: 1) {
                            Text("Bán")
                                .font(.system(size: 7))
                                .foregroundColor(.secondary)
                            Text(ApiDecryptor.decrypt(goldSJC.sellDisplay))
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.red)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .padding(5)
                .background(Color.yellow.opacity(0.15))
                .cornerRadius(6)
            }

            // Gold 9999
            if let gold9999 = entry.gold9999 {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Vàng 9999")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)

                    HStack(spacing: 4) {
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Mua")
                                .font(.system(size: 7))
                                .foregroundColor(.secondary)
                            Text(ApiDecryptor.decrypt(gold9999.buyDisplay))
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.green)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(alignment: .trailing, spacing: 1) {
                            Text("Bán")
                                .font(.system(size: 7))
                                .foregroundColor(.secondary)
                            Text(ApiDecryptor.decrypt(gold9999.sellDisplay))
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.red)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .padding(5)
                .background(Color.orange.opacity(0.15))
                .cornerRadius(6)
            }

            Spacer(minLength: 0)

            // Update time
            Text(entry.date, style: .time)
                .font(.system(size: 7))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Medium Widget View
struct MediumWidgetView: View {
    let entry: WidgetEntry

    var body: some View {
        VStack(spacing: 4) {
            // Header
            HStack(spacing: 4) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 13))
                    .foregroundColor(.yellow)
                Text("Giá Vàng & Tỷ Giá")
                    .font(.system(size: 13, weight: .bold))
                Spacer()
                Text(entry.date, style: .time)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }

            Divider()
                .padding(.vertical, -1)

            // 2x2 Grid Layout
            VStack(spacing: 4) {
                // Top Row: Gold SJC & Gold 9999
                HStack(spacing: 4) {
                    // Gold SJC
                    if let goldSJC = entry.goldSJC {
                        MediumPriceCard(
                            icon: "circle.hexagongrid.fill",
                            iconColor: .yellow,
                            title: "Vàng miếng SJC",
                            buyPrice: ApiDecryptor.decrypt(goldSJC.buyDisplay),
                            sellPrice: ApiDecryptor.decrypt(goldSJC.sellDisplay),
                            buyPercent: ApiDecryptor.decrypt(goldSJC.buyPercent),
                            sellPercent: ApiDecryptor.decrypt(goldSJC.sellPercent),
                            buyDelta: ApiDecryptor.decrypt(goldSJC.buyDelta),
                            sellDelta: ApiDecryptor.decrypt(goldSJC.sellDelta),
                            backgroundColor: Color.yellow.opacity(0.15)
                        )
                    }

                    // Gold 9999
                    if let gold9999 = entry.gold9999 {
                        MediumPriceCard(
                            icon: "circle.hexagongrid.fill",
                            iconColor: .orange,
                            title: "Vàng nhẫn 9999",
                            buyPrice: ApiDecryptor.decrypt(gold9999.buyDisplay),
                            sellPrice: ApiDecryptor.decrypt(gold9999.sellDisplay),
                            buyPercent: ApiDecryptor.decrypt(gold9999.buyPercent),
                            sellPercent: ApiDecryptor.decrypt(gold9999.sellPercent),
                            buyDelta: ApiDecryptor.decrypt(gold9999.buyDelta),
                            sellDelta: ApiDecryptor.decrypt(gold9999.sellDelta),
                            backgroundColor: Color.orange.opacity(0.15)
                        )
                    }
                }

                // Bottom Row: Silver Ag999 & Currency USD
                HStack(spacing: 4) {
                    // Silver Ag999
                    if let priceAg999 = entry.priceAg999 {
                        MediumPriceCard(
                            icon: "circle.hexagongrid.fill",
                            iconColor: .gray,
                            title: "Bạc thỏi Phú Quý 999",
                            buyPrice: ApiDecryptor.decrypt(priceAg999.buyDisplay),
                            sellPrice: ApiDecryptor.decrypt(priceAg999.sellDisplay),
                            buyPercent: ApiDecryptor.decrypt(priceAg999.buyPercent),
                            sellPercent: ApiDecryptor.decrypt(priceAg999.sellPercent),
                            buyDelta: ApiDecryptor.decrypt(priceAg999.buyDelta),
                            sellDelta: ApiDecryptor.decrypt(priceAg999.sellDelta),
                            backgroundColor: Color.gray.opacity(0.15)
                        )
                    }

                    // Currency USD
                    if let currency = entry.currency {
                        MediumPriceCard(
                            icon: "dollarsign.circle.fill",
                            iconColor: .green,
                            title: "Tỷ giá USD",
                            buyPrice: ApiDecryptor.decrypt(currency.buyDisplay),
                            sellPrice: ApiDecryptor.decrypt(currency.sellDisplay),
                            buyPercent: ApiDecryptor.decrypt(currency.buyPercent),
                            sellPercent: ApiDecryptor.decrypt(currency.sellPercent),
                            buyDelta: ApiDecryptor.decrypt(currency.buyDelta),
                            sellDelta: ApiDecryptor.decrypt(currency.sellDelta),
                            backgroundColor: Color.green.opacity(0.15)
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Medium Price Card Component
struct MediumPriceCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let buyPrice: String
    let sellPrice: String
    let buyPercent: String
    let sellPercent: String
    let buyDelta: String
    let sellDelta: String
    let backgroundColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // Header
            HStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 8))
                    .foregroundColor(iconColor)
                Text(title)
                    .font(.system(size: 9, weight: .semibold))
                    .lineLimit(1)
            }

            // Prices
            VStack(alignment: .leading, spacing: 1) {
                // Buy
                HStack(spacing: 1) {
                    Text("M:")
                        .font(.system(size: 7))
                        .foregroundColor(.secondary)
                        .frame(width: 14, alignment: .leading)
                    Text(buyPrice)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.green)
                        .lineLimit(1)
                        .minimumScaleFactor(0.4)
                    Spacer()
                    HStack(spacing: 0) {
                        Image(systemName: getDeltaIcon(buyDelta))
                            .font(.system(size: 7))
                            .foregroundColor(getDeltaColor(buyDelta))
                        Text(buyPercent)
                            .font(.system(size: 7))
                            .foregroundColor(getDeltaColor(buyDelta))
                            .lineLimit(1)
                    }
                }

                // Sell
                HStack(spacing: 1) {
                    Text("B:")
                        .font(.system(size: 7))
                        .foregroundColor(.secondary)
                        .frame(width: 14, alignment: .leading)
                    Text(sellPrice)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.red)
                        .lineLimit(1)
                        .minimumScaleFactor(0.4)
                    Spacer()
                    HStack(spacing: 0) {
                        Image(systemName: getDeltaIcon(sellDelta))
                            .font(.system(size: 7))
                            .foregroundColor(getDeltaColor(sellDelta))
                        Text(sellPercent)
                            .font(.system(size: 7))
                            .foregroundColor(getDeltaColor(sellDelta))
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding(5)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(backgroundColor)
        .cornerRadius(6)
    }
}

// MARK: - Large Widget View
struct LargeWidgetView: View {
    let entry: WidgetEntry

    var body: some View {
        VStack(spacing: 6) {
            // Header
            HStack(spacing: 4) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 18))
                    .foregroundColor(.yellow)
                Text("Giá Vàng & Tỷ Giá")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                VStack(alignment: .trailing, spacing: 1) {
                    Text("Cập nhật")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                    Text(entry.date, style: .time)
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
            }

            Divider()
                .padding(.vertical, -1)

            // Gold SJC
            if let goldSJC = entry.goldSJC {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "circle.hexagongrid.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.yellow)
                        Text("Vàng miếng SJC")
                            .font(.system(size: 13, weight: .bold))
                        Spacer()
                        Text(goldSJC.dateUpdate)
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)
                    }

                    HStack(spacing: 6) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Mua vào")
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                            Text(ApiDecryptor.decrypt(goldSJC.buyDisplay))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.green)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)

                            HStack(spacing: 2) {
                                Image(systemName: getDeltaIcon(ApiDecryptor.decrypt(goldSJC.buyDelta)))
                                    .font(.system(size: 8))
                                    .foregroundColor(getDeltaColor(ApiDecryptor.decrypt(goldSJC.buyDelta)))
                                Text(ApiDecryptor.decrypt(goldSJC.buyDelta))
                                    .font(.system(size: 9))
                                    .foregroundColor(getDeltaColor(ApiDecryptor.decrypt(goldSJC.buyDelta)))
                                Text("(\(ApiDecryptor.decrypt(goldSJC.buyPercent)))")
                                    .font(.system(size: 8))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Divider()

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Bán ra")
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                            Text(ApiDecryptor.decrypt(goldSJC.sellDisplay))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.red)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)

                            HStack(spacing: 2) {
                                Image(systemName: getDeltaIcon(ApiDecryptor.decrypt(goldSJC.sellDelta)))
                                    .font(.system(size: 8))
                                    .foregroundColor(getDeltaColor(ApiDecryptor.decrypt(goldSJC.sellDelta)))
                                Text(ApiDecryptor.decrypt(goldSJC.sellDelta))
                                    .font(.system(size: 9))
                                    .foregroundColor(getDeltaColor(ApiDecryptor.decrypt(goldSJC.sellDelta)))
                                Text("(\(ApiDecryptor.decrypt(goldSJC.sellPercent)))")
                                    .font(.system(size: 8))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(8)
                .background(Color.yellow.opacity(0.15))
                .cornerRadius(8)
            } else {
                ProgressView()
                    .frame(maxHeight: .infinity)
            }

            // Gold 9999
            if let gold9999 = entry.gold9999 {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "circle.hexagongrid.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.orange)
                        Text("Vàng nhẫn 9999")
                            .font(.system(size: 13, weight: .bold))
                        Spacer()
                        Text(gold9999.dateUpdate)
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)
                    }

                    HStack(spacing: 6) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Mua vào")
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                            Text(ApiDecryptor.decrypt(gold9999.buyDisplay))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.green)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)

                            HStack(spacing: 2) {
                                Image(systemName: getDeltaIcon(ApiDecryptor.decrypt(gold9999.buyDelta)))
                                    .font(.system(size: 8))
                                    .foregroundColor(getDeltaColor(ApiDecryptor.decrypt(gold9999.buyDelta)))
                                Text(ApiDecryptor.decrypt(gold9999.buyDelta))
                                    .font(.system(size: 9))
                                    .foregroundColor(getDeltaColor(ApiDecryptor.decrypt(gold9999.buyDelta)))
                                Text("(\(ApiDecryptor.decrypt(gold9999.buyPercent)))")
                                    .font(.system(size: 8))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Divider()

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Bán ra")
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                            Text(ApiDecryptor.decrypt(gold9999.sellDisplay))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.red)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)

                            HStack(spacing: 2) {
                                Image(systemName: getDeltaIcon(ApiDecryptor.decrypt(gold9999.sellDelta)))
                                    .font(.system(size: 8))
                                    .foregroundColor(getDeltaColor(ApiDecryptor.decrypt(gold9999.sellDelta)))
                                Text(ApiDecryptor.decrypt(gold9999.sellDelta))
                                    .font(.system(size: 9))
                                    .foregroundColor(getDeltaColor(ApiDecryptor.decrypt(gold9999.sellDelta)))
                                Text("(\(ApiDecryptor.decrypt(gold9999.sellPercent)))")
                                    .font(.system(size: 8))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(8)
                .background(Color.orange.opacity(0.15))
                .cornerRadius(8)
            }

            // Currency USD
            if let currency = entry.currency {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.green)
                        Text("Tỷ giá USD")
                            .font(.system(size: 13, weight: .bold))
                        Spacer()
                        Text(currency.dateUpdate)
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)
                    }

                    HStack(spacing: 6) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Mua vào")
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                            Text(ApiDecryptor.decrypt(currency.buyDisplay))
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.green)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)

                            HStack(spacing: 2) {
                                Image(systemName: getDeltaIcon(ApiDecryptor.decrypt(currency.buyDelta)))
                                    .font(.system(size: 8))
                                    .foregroundColor(getDeltaColor(ApiDecryptor.decrypt(currency.buyDelta)))
                                Text(ApiDecryptor.decrypt(currency.buyPercent))
                                    .font(.system(size: 9))
                                    .foregroundColor(getDeltaColor(ApiDecryptor.decrypt(currency.buyDelta)))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Divider()

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Chuyển khoản")
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                            Text(ApiDecryptor.decrypt(currency.transferDisplay))
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.blue)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)

                            HStack(spacing: 2) {
                                Image(systemName: getDeltaIcon(ApiDecryptor.decrypt(currency.transferDelta)))
                                    .font(.system(size: 8))
                                    .foregroundColor(getDeltaColor(ApiDecryptor.decrypt(currency.transferDelta)))
                                Text(ApiDecryptor.decrypt(currency.transferPercent))
                                    .font(.system(size: 9))
                                    .foregroundColor(getDeltaColor(ApiDecryptor.decrypt(currency.transferDelta)))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Divider()

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Bán ra")
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                            Text(ApiDecryptor.decrypt(currency.sellDisplay))
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.red)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)

                            HStack(spacing: 2) {
                                Image(systemName: getDeltaIcon(ApiDecryptor.decrypt(currency.sellDelta)))
                                    .font(.system(size: 8))
                                    .foregroundColor(getDeltaColor(ApiDecryptor.decrypt(currency.sellDelta)))
                                Text(ApiDecryptor.decrypt(currency.sellPercent))
                                    .font(.system(size: 9))
                                    .foregroundColor(getDeltaColor(ApiDecryptor.decrypt(currency.sellDelta)))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(8)
                .background(Color.green.opacity(0.15))
                .cornerRadius(8)
            }

            Spacer(minLength: 0)
        }
    }
}

// MARK: - Helper Functions
private func getDeltaIcon(_ delta: String) -> String {
    if delta.hasPrefix("-") {
        return "arrow.down"
    } else if delta.hasPrefix("+") {
        return "arrow.up"
    } else {
        return "minus"
    }
}

private func getDeltaColor(_ delta: String) -> Color {
    if delta.hasPrefix("-") {
        return .red
    } else if delta.hasPrefix("+") {
        return .green
    } else {
        return .secondary
    }
}

// MARK: - Previews
#Preview(as: .systemSmall) {
    GiaVang_Widget()
} timeline: {
    WidgetEntry(date: .now, goldSJC: nil, gold9999: nil, priceAg999: nil, currency: nil)
}

#Preview(as: .systemMedium) {
    GiaVang_Widget()
} timeline: {
    WidgetEntry(date: .now, goldSJC: nil, gold9999: nil, priceAg999: nil, currency: nil)
}

#Preview(as: .systemLarge) {
    GiaVang_Widget()
} timeline: {
    WidgetEntry(date: .now, goldSJC: nil, gold9999: nil, priceAg999: nil, currency: nil)
}
