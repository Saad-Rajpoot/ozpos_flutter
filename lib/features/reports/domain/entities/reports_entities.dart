import 'package:equatable/equatable.dart';

/// Main reports data entity containing all dashboard information
class ReportsData extends Equatable {
  final List<KPICard> kpiCards;
  final List<OrderFunnelStage> orderFunnel;
  final ServiceSpeedData serviceSpeed;
  final List<PaymentMethod> paymentMethods;
  final List<DiscountImpact> discountsImpact;
  final List<HourlySalesPoint> hourlySalesTrend;
  final List<CategorySale> categorySales;
  final List<TopSellingItem> topSellingItems;
  final List<NeedsAttentionItem> needsAttention;
  final List<StaffPerformance> staffPerformance;
  final SnapshotBanner snapshotBanner;

  const ReportsData({
    required this.kpiCards,
    required this.orderFunnel,
    required this.serviceSpeed,
    required this.paymentMethods,
    required this.discountsImpact,
    required this.hourlySalesTrend,
    required this.categorySales,
    required this.topSellingItems,
    required this.needsAttention,
    required this.staffPerformance,
    required this.snapshotBanner,
  });

  @override
  List<Object?> get props => [
    kpiCards,
    orderFunnel,
    serviceSpeed,
    paymentMethods,
    discountsImpact,
    hourlySalesTrend,
    categorySales,
    topSellingItems,
    needsAttention,
    staffPerformance,
    snapshotBanner,
  ];
}

/// KPI Card entity for dashboard metrics
class KPICard extends Equatable {
  final String label;
  final String value;
  final String delta;
  final bool positive;
  final String color;

  const KPICard({
    required this.label,
    required this.value,
    required this.delta,
    required this.positive,
    required this.color,
  });

  @override
  List<Object?> get props => [label, value, delta, positive, color];
}

/// Order funnel stage entity
class OrderFunnelStage extends Equatable {
  final String label;
  final int value;
  final int max;
  final String color;

  const OrderFunnelStage({
    required this.label,
    required this.value,
    required this.max,
    required this.color,
  });

  @override
  List<Object?> get props => [label, value, max, color];
}

/// Service speed data entity
class ServiceSpeedData extends Equatable {
  final String avgTime;
  final String avgTimeLabel;
  final String prepTime;
  final String serviceTime;
  final List<ServiceSpeedSection> chartSections;

  const ServiceSpeedData({
    required this.avgTime,
    required this.avgTimeLabel,
    required this.prepTime,
    required this.serviceTime,
    required this.chartSections,
  });

  @override
  List<Object?> get props => [
    avgTime,
    avgTimeLabel,
    prepTime,
    serviceTime,
    chartSections,
  ];
}

/// Service speed chart section entity
class ServiceSpeedSection extends Equatable {
  final int value;
  final String color;

  const ServiceSpeedSection({required this.value, required this.color});

  @override
  List<Object?> get props => [value, color];
}

/// Payment method entity
class PaymentMethod extends Equatable {
  final String method;
  final int percentage;
  final String color;

  const PaymentMethod({
    required this.method,
    required this.percentage,
    required this.color,
  });

  @override
  List<Object?> get props => [method, percentage, color];
}

/// Discount impact entity
class DiscountImpact extends Equatable {
  final String category;
  final int value;

  const DiscountImpact({required this.category, required this.value});

  @override
  List<Object?> get props => [category, value];
}

/// Hourly sales trend data point entity
class HourlySalesPoint extends Equatable {
  final int hour;
  final int value;

  const HourlySalesPoint({required this.hour, required this.value});

  @override
  List<Object?> get props => [hour, value];
}

/// Category sales entity
class CategorySale extends Equatable {
  final String name;
  final String amount;
  final double percentage;
  final String color;

  const CategorySale({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.color,
  });

  @override
  List<Object?> get props => [name, amount, percentage, color];
}

/// Top selling item entity
class TopSellingItem extends Equatable {
  final String emoji;
  final String name;
  final String revenue;
  final String rank;
  final String orders;

  const TopSellingItem({
    required this.emoji,
    required this.name,
    required this.revenue,
    required this.rank,
    required this.orders,
  });

  @override
  List<Object?> get props => [emoji, name, revenue, rank, orders];
}

/// Needs attention item entity
class NeedsAttentionItem extends Equatable {
  final String emoji;
  final String name;
  final String revenue;
  final String orders;

  const NeedsAttentionItem({
    required this.emoji,
    required this.name,
    required this.revenue,
    required this.orders,
  });

  @override
  List<Object?> get props => [emoji, name, revenue, orders];
}

/// Staff performance entity
class StaffPerformance extends Equatable {
  final String initial;
  final String name;
  final String orders;
  final String upsells;
  final String efficiency;
  final String color;

  const StaffPerformance({
    required this.initial,
    required this.name,
    required this.orders,
    required this.upsells,
    required this.efficiency,
    required this.color,
  });

  @override
  List<Object?> get props => [
    initial,
    name,
    orders,
    upsells,
    efficiency,
    color,
  ];
}

/// Today's snapshot banner entity
class SnapshotBanner extends Equatable {
  final String title;
  final String summary;

  const SnapshotBanner({required this.title, required this.summary});

  @override
  List<Object?> get props => [title, summary];
}
