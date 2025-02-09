//
//  MetricsView.swift
//  EngineeringMode
//
//  Created by Vishrut Jha on 2/8/25.
//

import Charts
import MetricKit
import SwiftData
import SwiftUI

@available(iOS 17, *)
@Model
final class MetricRecord {
  var timestamp: Date

  // Performance Metrics
  var launchTime: Double
  var memoryUsage: Double
  var hangTime: Double
  var appExitNormalCount: Int
  var appExitAbnormalCount: Int
  var appRunTime: TimeInterval

  // Battery Metrics
  var cpuTime: Double
  var gpuTime: Double
  var locationActivityTime: Double
  var networkTransferUp: Double
  var networkTransferDown: Double
  var displayOnTime: Double

  // Disk Metrics
  var diskWritesCount: Double
  var diskReadCount: Double

  // Animation Metrics
  var scrollHitchTimeRatio: Double

  init(timestamp: Date = .now) {
    self.timestamp = timestamp
    self.launchTime = 0
    self.memoryUsage = 0
    self.hangTime = 0
    self.appExitNormalCount = 0
    self.appExitAbnormalCount = 0
    self.appRunTime = 0
    self.cpuTime = 0
    self.gpuTime = 0
    self.locationActivityTime = 0
    self.networkTransferUp = 0
    self.networkTransferDown = 0
    self.displayOnTime = 0
    self.diskWritesCount = 0
    self.diskReadCount = 0
    self.scrollHitchTimeRatio = 0
  }
}

@available(iOS 17, *)
class MetricsManager: NSObject, MXMetricManagerSubscriber {
  static let shared = MetricsManager()
  var modelContext: ModelContext?

  override init() {
    super.init()
    MXMetricManager.shared.add(self)
  }

  func didReceive(_ payloads: [MXMetricPayload]) {
    guard let context = modelContext else { return }

    for payload in payloads {
      let metrics = MetricRecord(timestamp: payload.timeStampEnd)

      // App Launch & Responsiveness
      if let launchMetrics = payload.applicationLaunchMetrics {
        metrics.launchTime = launchMetrics.histogrammedTimeToFirstDraw
          .bucketEnumerator.allObjects
          .compactMap { ($0 as? MXHistogramBucket)?.bucketEnd.value }
          .reduce(0.0, +)
      }

      // Memory
      if let memoryMetrics = payload.memoryMetrics {
        metrics.memoryUsage = memoryMetrics.peakMemoryUsage.value
      }

      // App Responsiveness
      if let responsivenessMetrics = payload
        .applicationResponsivenessMetrics
      {
        metrics.hangTime = responsivenessMetrics
          .histogrammedApplicationHangTime.bucketEnumerator.allObjects
          .compactMap { ($0 as? MXHistogramBucket)?.bucketEnd.value }
          .reduce(0.0, +)
      }

      // App Exit
      if let exitMetrics = payload.applicationExitMetrics {
        metrics.appExitNormalCount =
          exitMetrics.backgroundExitData.cumulativeNormalAppExitCount
        metrics.appExitAbnormalCount =
          exitMetrics.backgroundExitData.cumulativeAbnormalExitCount
      }

      // CPU & GPU
      if let cpuMetrics = payload.cpuMetrics {
        metrics.cpuTime = cpuMetrics.cumulativeCPUTime.value
      }

      if let gpuMetrics = payload.gpuMetrics {
        metrics.gpuTime = gpuMetrics.cumulativeGPUTime.value
      }

      // Network
      if let networkMetrics = payload.networkTransferMetrics {
        metrics.networkTransferUp =
          networkMetrics.cumulativeCellularUpload.value
        metrics.networkTransferDown =
          networkMetrics.cumulativeCellularDownload.value
      }

      // Location
      if let locationMetrics = payload.locationActivityMetrics {
        metrics.locationActivityTime =
          locationMetrics.cumulativeBestAccuracyForNavigationTime
          .value
      }

      // Disk I/O
      if let diskMetrics = payload.diskIOMetrics {
        metrics.diskWritesCount =
          diskMetrics.cumulativeLogicalWrites.value
      }

      // Animation
      if let animationMetrics = payload.animationMetrics {
        metrics.scrollHitchTimeRatio =
          animationMetrics.scrollHitchTimeRatio.value
      }

      context.insert(metrics)

      if let context = modelContext {
        do {
          try context.save()
        } catch {
          print("Failed to save MetricRecord: \(error)")
        }
      }

    }
  }
}

struct ChartContainer<Content: View>: View {
  let title: String
  let content: Content
  let legendItems: [(color: Color, label: String)]

  init(
    title: String, legendItems: [(color: Color, label: String)],
    @ViewBuilder content: () -> Content
  ) {
    self.title = title
    self.legendItems = legendItems
    self.content = content()
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.headline)

      content
        .frame(height: 200)
        .chartXAxis {
          AxisMarks(values: .stride(by: .day)) { _ in
            AxisGridLine()
            AxisTick()
            AxisValueLabel(format: .dateTime.day().month())
          }
        }
        .chartYAxis {
          AxisMarks { _ in
            AxisGridLine()
            AxisTick()
            AxisValueLabel()
          }
        }

      // Legend
      if !legendItems.isEmpty {
        HStack(spacing: 16) {
          ForEach(legendItems.indices, id: \.self) { index in
            HStack(spacing: 4) {
              Circle()
                .fill(legendItems[index].color)
                .frame(width: 8, height: 8)
              Text(legendItems[index].label)
                .font(.caption)
                .foregroundColor(.secondary)
            }
          }
        }
        .padding(.top, 4)
      }
    }
    .padding()
    .background(Color.gray.opacity(0.1))
    .cornerRadius(10)
    .shadow(radius: 2, y: 1)
  }
}

@available(iOS 17, *)
struct MetricsContentView: View {
  @Environment(\.modelContext) private var modelContext

  static var sevenDaysAgo: Date {
    Calendar.current.date(byAdding: .day, value: -7, to: .now)!
  }

  @Query(
    filter: #Predicate<MetricRecord> { record in
      record.timestamp > sevenDaysAgo
    },
    sort: \MetricRecord.timestamp
  ) private var metrics: [MetricRecord]

  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        // Performance Metrics
        ChartContainer(
          title: "Launch Time",
          legendItems: [
            (color: .blue, label: "Launch Duration")
          ]
        ) {
          Chart(metrics) { metric in
            LineMark(
              x: .value("Date", metric.timestamp),
              y: .value("Time", metric.launchTime)
            )
            .foregroundStyle(.blue)
          }
        }

        ChartContainer(
          title: "Memory Usage",
          legendItems: [
            (color: .green, label: "Peak Memory")
          ]
        ) {
          Chart(metrics) { metric in
            BarMark(
              x: .value("Date", metric.timestamp),
              y: .value("Memory", metric.memoryUsage)
            )
            .foregroundStyle(.green)
          }
        }

        // Battery Metrics
        ChartContainer(
          title: "CPU & GPU Time",
          legendItems: [
            (color: .red, label: "CPU Time"),
            (color: .orange, label: "GPU Time"),
          ]
        ) {
          Chart(metrics) { metric in
            LineMark(
              x: .value("Date", metric.timestamp),
              y: .value("CPU Time", metric.cpuTime)
            )
            .foregroundStyle(.red)
            LineMark(
              x: .value("Date", metric.timestamp),
              y: .value("GPU Time", metric.gpuTime)
            )
            .foregroundStyle(.orange)
          }
        }

        // Network Metrics
        ChartContainer(
          title: "Network Transfer",
          legendItems: [
            (color: .blue, label: "Upload"),
            (color: .green, label: "Download"),
          ]
        ) {
          Chart(metrics) { metric in
            BarMark(
              x: .value("Date", metric.timestamp),
              y: .value("Upload", metric.networkTransferUp)
            )
            .foregroundStyle(.blue)
            BarMark(
              x: .value("Date", metric.timestamp),
              y: .value("Download", metric.networkTransferDown)
            )
            .foregroundStyle(.green)
          }
        }

        // Disk I/O Metrics
        ChartContainer(
          title: "Disk Activity",
          legendItems: [
            (color: .purple, label: "Writes")
          ]
        ) {
          Chart(metrics) { metric in
            LineMark(
              x: .value("Date", metric.timestamp),
              y: .value("Writes", Double(metric.diskWritesCount))
            )
            .foregroundStyle(.purple)
          }
        }

        MetricsStatsView(metrics: metrics)
      }
      .padding()
    }
    .onAppear {
      MetricsManager.shared.modelContext = modelContext
    }
  }
}

@available(iOS 17, *)
struct MetricsStatsView: View {
  let metrics: [MetricRecord]

  var latestMetric: MetricRecord? {
    metrics.last
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Additional Statistics")
        .font(.headline)

      VStack(alignment: .leading, spacing: 12) {
        // App Exits
        StatRow(
          title: "Normal App Exits",
          value: "\(latestMetric?.appExitNormalCount ?? 0)"
        )
        StatRow(
          title: "Abnormal App Exits",
          value: "\(latestMetric?.appExitAbnormalCount ?? 0)"
        )

        // Location
        StatRow(
          title: "Location Activity Time",
          value: String(
            format: "%.2f s",
            latestMetric?.locationActivityTime ?? 0)
        )

        // App Runtime
        StatRow(
          title: "Total Runtime",
          value: String(
            format: "%.2f s",
            latestMetric?.appRunTime ?? 0)
        )

        // Display
        StatRow(
          title: "Display On Time",
          value: String(
            format: "%.2f s",
            latestMetric?.displayOnTime ?? 0)
        )

        // Animation
        StatRow(
          title: "Scroll Hitch Ratio",
          value: String(
            format: "%.3f",
            latestMetric?.scrollHitchTimeRatio ?? 0)
        )
      }
      .padding()
      .background(Color.gray.opacity(0.1))
      .cornerRadius(10)
    }
  }
}

struct StatRow: View {
  let title: String
  let value: String

  var body: some View {
    HStack {
      Text(title)
        .foregroundColor(.secondary)
      Spacer()
      Text(value)
        .fontWeight(.medium)
    }
  }
}

struct MetricsView: View {
  var body: some View {
    NavigationStack {
      Group {
        if #available(iOS 17, *) {
          MetricsContentView()
            .modelContainer(for: MetricRecord.self)

        } else {
          VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
              .font(.largeTitle)
              .foregroundColor(.orange)

            Text("iOS 17 Required")
              .font(.title2)
              .fontWeight(.semibold)

            Text(
              "App Metrics visualization is only available on iOS 17 and above."
            )
            .multilineTextAlignment(.center)
            .foregroundColor(.secondary)
          }
          .padding()
        }
      }
      .navigationTitle("App Metrics (MetricKit)")
    }
  }
}

@available(iOS 17, *)
extension MetricRecord {
  static var previewData: [MetricRecord] {
    let calendar = Calendar.current
    let now = Date()

    return (0..<7).map { dayOffset in
      let record = MetricRecord(
        timestamp: calendar.date(
          byAdding: .day, value: -dayOffset, to: now)!
      )

      // Performance Metrics
      record.launchTime = Double.random(in: 0.8...2.5)
      record.memoryUsage = Double.random(in: 150...450)
      record.hangTime = Double.random(in: 0...0.3)

      // App Exit Stats
      record.appExitNormalCount = Int.random(in: 5...15)
      record.appExitAbnormalCount = Int.random(in: 0...2)

      // Runtime Stats
      record.appRunTime = Double.random(in: 1800...7200)  // 30 mins to 2 hours
      record.displayOnTime = Double.random(in: 900...3600)  // 15 mins to 1 hour

      // Resource Usage
      record.cpuTime = Double.random(in: 20...80)
      record.gpuTime = Double.random(in: 10...40)

      // Network (in MB)
      record.networkTransferUp = Double.random(in: 5...50)
      record.networkTransferDown = Double.random(in: 20...200)

      // Location & Animation
      record.locationActivityTime = Double.random(in: 0...600)  // 0-10 minutes
      record.scrollHitchTimeRatio = Double.random(in: 0...0.05)

      // Disk I/O (in MB)
      record.diskWritesCount = Double.random(in: 1...10)

      return record
    }
  }
}

@available(iOS 17, *)
struct MetricsPreviewContainer: View {
  var body: some View {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
      for: MetricRecord.self, configurations: config)

    // Insert preview data and save immediately
    let context = container.mainContext
    for record in MetricRecord.previewData {
      context.insert(record)
    }
    try? context.save()

    return MetricsContentView()
      .modelContainer(container)
  }
}

struct MetricsPreviewFallback: View {
  var body: some View {
    Text("iOS 17 or later is required")
  }
}

#Preview {
  NavigationStack {
    ViewThatFits {
      if #available(iOS 17, *) {
        MetricsPreviewContainer()
      } else {
        MetricsPreviewFallback()
      }
    }
  }
}
