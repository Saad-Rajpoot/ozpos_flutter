import 'package:equatable/equatable.dart';

/// Component types enum
enum DocketComponentType {
  text,
  variable,
  logo,
  separator,
  box,
  columns,
  itemTable,
  qrCode,
  barcode,
  space,
  customText,
}

/// Component model for docket designer
class DocketComponentModel extends Equatable {
  final String id;
  final DocketComponentType type;
  final Map<String, dynamic> properties;
  final double x;
  final double y;
  final double width;
  final double height;
  final List<DocketComponentModel> children;

  const DocketComponentModel({
    required this.id,
    required this.type,
    required this.properties,
    this.x = 0,
    this.y = 0,
    this.width = 300,
    this.height = 50,
    this.children = const [],
  });

  DocketComponentModel copyWith({
    String? id,
    DocketComponentType? type,
    Map<String, dynamic>? properties,
    double? x,
    double? y,
    double? width,
    double? height,
    List<DocketComponentModel>? children,
  }) {
    return DocketComponentModel(
      id: id ?? this.id,
      type: type ?? this.type,
      properties: properties ?? this.properties,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      children: children ?? this.children,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'properties': properties,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'children': children.map((c) => c.toJson()).toList(),
    };
  }

  factory DocketComponentModel.fromJson(Map<String, dynamic> json) {
    return DocketComponentModel(
      id: json['id'] as String,
      type: DocketComponentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DocketComponentType.text,
      ),
      properties: Map<String, dynamic>.from(json['properties'] as Map),
      x: (json['x'] as num?)?.toDouble() ?? 0,
      y: (json['y'] as num?)?.toDouble() ?? 0,
      width: (json['width'] as num?)?.toDouble() ?? 300,
      height: (json['height'] as num?)?.toDouble() ?? 50,
      children: (json['children'] as List<dynamic>?)
              ?.map((c) =>
                  DocketComponentModel.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props =>
      [id, type, properties, x, y, width, height, children];
}

/// Available variables for docket templates
class DocketVariables {
  static const List<Map<String, String>> available = [
    {'key': 'restaurant', 'label': 'Restaurant Name'},
    {'key': 'orderid', 'label': 'Order ID'},
    {'key': 'date', 'label': 'Date'},
    {'key': 'time', 'label': 'Time'},
    {'key': 'table', 'label': 'Table Number'},
    {'key': 'server', 'label': 'Server Name'},
    {'key': 'items', 'label': 'Order Items'},
    {'key': 'subtotal', 'label': 'Subtotal'},
    {'key': 'tax', 'label': 'Tax'},
    {'key': 'total', 'label': 'Total'},
    {'key': 'payment', 'label': 'Payment Method'},
    {'key': 'change', 'label': 'Change'},
    {'key': 'customer', 'label': 'Customer Name'},
    {'key': 'phone', 'label': 'Phone Number'},
  ];

  static String getVariableLabel(String key) {
    final variable = available.firstWhere(
      (v) => v['key'] == key,
      orElse: () => {'key': key, 'label': key},
    );
    return variable['label'] ?? key;
  }
}
