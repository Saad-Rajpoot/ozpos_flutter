import 'package:equatable/equatable.dart';
import '../../domain/entities/reports_entities.dart';
import 'kpi_card_model.dart';
import 'order_funnel_model.dart';
import 'service_speed_model.dart';
import 'payment_method_model.dart';
import 'discount_impact_model.dart';
import 'hourly_sales_model.dart';
import 'category_sale_model.dart';
import 'top_selling_item_model.dart';
import 'needs_attention_model.dart';
import 'staff_performance_model.dart';
import 'snapshot_banner_model.dart';

/// Model class for ReportsData JSON serialization/deserialization
class ReportsModel extends Equatable {
  final List<KPICardModel> kpiCards;
  final List<OrderFunnelStageModel> orderFunnel;
  final ServiceSpeedDataModel serviceSpeed;
  final List<PaymentMethodModel> paymentMethods;
  final List<DiscountImpactModel> discountsImpact;
  final List<HourlySalesPointModel> hourlySalesTrend;
  final List<CategorySaleModel> categorySales;
  final List<TopSellingItemModel> topSellingItems;
  final List<NeedsAttentionItemModel> needsAttention;
  final List<StaffPerformanceModel> staffPerformance;
  final SnapshotBannerModel snapshotBanner;

  const ReportsModel({
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

  /// Convert JSON to ReportsModel
  factory ReportsModel.fromJson(Map<String, dynamic> json) {
    final kpiCards =
        (json['kpiCards'] as List<dynamic>?)
            ?.map((item) => KPICardModel.fromJson(item as Map<String, dynamic>))
            .toList() ??
        <KPICardModel>[];

    final orderFunnel =
        (json['orderFunnel'] as List<dynamic>?)
            ?.map(
              (item) =>
                  OrderFunnelStageModel.fromJson(item as Map<String, dynamic>),
            )
            .toList() ??
        <OrderFunnelStageModel>[];

    final serviceSpeed = ServiceSpeedDataModel.fromJson(
      json['serviceSpeed'] as Map<String, dynamic>,
    );

    final paymentMethods =
        (json['paymentMethods'] as List<dynamic>?)
            ?.map(
              (item) =>
                  PaymentMethodModel.fromJson(item as Map<String, dynamic>),
            )
            .toList() ??
        <PaymentMethodModel>[];

    final discountsImpact =
        (json['discountsImpact'] as List<dynamic>?)
            ?.map(
              (item) =>
                  DiscountImpactModel.fromJson(item as Map<String, dynamic>),
            )
            .toList() ??
        <DiscountImpactModel>[];

    final hourlySalesTrend =
        (json['hourlySalesTrend'] as List<dynamic>?)
            ?.map(
              (item) =>
                  HourlySalesPointModel.fromJson(item as Map<String, dynamic>),
            )
            .toList() ??
        <HourlySalesPointModel>[];

    final categorySales =
        (json['categorySales'] as List<dynamic>?)
            ?.map(
              (item) =>
                  CategorySaleModel.fromJson(item as Map<String, dynamic>),
            )
            .toList() ??
        <CategorySaleModel>[];

    final topSellingItems =
        (json['topSellingItems'] as List<dynamic>?)
            ?.map(
              (item) =>
                  TopSellingItemModel.fromJson(item as Map<String, dynamic>),
            )
            .toList() ??
        <TopSellingItemModel>[];

    final needsAttention =
        (json['needsAttention'] as List<dynamic>?)
            ?.map(
              (item) => NeedsAttentionItemModel.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList() ??
        <NeedsAttentionItemModel>[];

    final staffPerformance =
        (json['staffPerformance'] as List<dynamic>?)
            ?.map(
              (item) =>
                  StaffPerformanceModel.fromJson(item as Map<String, dynamic>),
            )
            .toList() ??
        <StaffPerformanceModel>[];

    final snapshotBanner = SnapshotBannerModel.fromJson(
      json['snapshotBanner'] as Map<String, dynamic>,
    );

    return ReportsModel(
      kpiCards: kpiCards,
      orderFunnel: orderFunnel,
      serviceSpeed: serviceSpeed,
      paymentMethods: paymentMethods,
      discountsImpact: discountsImpact,
      hourlySalesTrend: hourlySalesTrend,
      categorySales: categorySales,
      topSellingItems: topSellingItems,
      needsAttention: needsAttention,
      staffPerformance: staffPerformance,
      snapshotBanner: snapshotBanner,
    );
  }

  /// Convert ReportsModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'kpiCards': kpiCards.map((item) => item.toJson()).toList(),
      'orderFunnel': orderFunnel.map((item) => item.toJson()).toList(),
      'serviceSpeed': serviceSpeed.toJson(),
      'paymentMethods': paymentMethods.map((item) => item.toJson()).toList(),
      'discountsImpact': discountsImpact.map((item) => item.toJson()).toList(),
      'hourlySalesTrend': hourlySalesTrend
          .map((item) => item.toJson())
          .toList(),
      'categorySales': categorySales.map((item) => item.toJson()).toList(),
      'topSellingItems': topSellingItems.map((item) => item.toJson()).toList(),
      'needsAttention': needsAttention.map((item) => item.toJson()).toList(),
      'staffPerformance': staffPerformance
          .map((item) => item.toJson())
          .toList(),
      'snapshotBanner': snapshotBanner.toJson(),
    };
  }

  /// Convert ReportsModel to ReportsData entity
  ReportsData toEntity() {
    return ReportsData(
      kpiCards: kpiCards.map((item) => item.toEntity()).toList(),
      orderFunnel: orderFunnel.map((item) => item.toEntity()).toList(),
      serviceSpeed: serviceSpeed.toEntity(),
      paymentMethods: paymentMethods.map((item) => item.toEntity()).toList(),
      discountsImpact: discountsImpact.map((item) => item.toEntity()).toList(),
      hourlySalesTrend: hourlySalesTrend
          .map((item) => item.toEntity())
          .toList(),
      categorySales: categorySales.map((item) => item.toEntity()).toList(),
      topSellingItems: topSellingItems.map((item) => item.toEntity()).toList(),
      needsAttention: needsAttention.map((item) => item.toEntity()).toList(),
      staffPerformance: staffPerformance
          .map((item) => item.toEntity())
          .toList(),
      snapshotBanner: snapshotBanner.toEntity(),
    );
  }

  /// Create ReportsModel from ReportsData entity
  factory ReportsModel.fromEntity(ReportsData entity) {
    return ReportsModel(
      kpiCards: entity.kpiCards
          .map((item) => KPICardModel.fromEntity(item))
          .toList(),
      orderFunnel: entity.orderFunnel
          .map((item) => OrderFunnelStageModel.fromEntity(item))
          .toList(),
      serviceSpeed: ServiceSpeedDataModel.fromEntity(entity.serviceSpeed),
      paymentMethods: entity.paymentMethods
          .map((item) => PaymentMethodModel.fromEntity(item))
          .toList(),
      discountsImpact: entity.discountsImpact
          .map((item) => DiscountImpactModel.fromEntity(item))
          .toList(),
      hourlySalesTrend: entity.hourlySalesTrend
          .map((item) => HourlySalesPointModel.fromEntity(item))
          .toList(),
      categorySales: entity.categorySales
          .map((item) => CategorySaleModel.fromEntity(item))
          .toList(),
      topSellingItems: entity.topSellingItems
          .map((item) => TopSellingItemModel.fromEntity(item))
          .toList(),
      needsAttention: entity.needsAttention
          .map((item) => NeedsAttentionItemModel.fromEntity(item))
          .toList(),
      staffPerformance: entity.staffPerformance
          .map((item) => StaffPerformanceModel.fromEntity(item))
          .toList(),
      snapshotBanner: SnapshotBannerModel.fromEntity(entity.snapshotBanner),
    );
  }

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
