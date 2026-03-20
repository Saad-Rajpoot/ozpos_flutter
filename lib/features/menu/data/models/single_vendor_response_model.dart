// Complete single-vendor API response model
// API: GET single-vendor/{vendor_uuid}/{branch_uuid}

List<SingleVendorMenuV2Model> _parseMenuV2List(dynamic value) {
  if (value == null) return [];
  if (value is! List) return [];
  final result = <SingleVendorMenuV2Model>[];
  for (final item in value) {
    if (item is Map) {
      try {
        result.add(SingleVendorMenuV2Model.fromJson(
          Map<String, dynamic>.from(item),
        ));
      } catch (_) {
        // Skip malformed menu entries
      }
    }
  }
  return result;
}

class SingleVendorResponseModel {
  final bool success;
  final SingleVendorDataModel data;
  final SingleVendorResponseMeta? meta;

  const SingleVendorResponseModel({
    required this.success,
    required this.data,
    this.meta,
  });

  factory SingleVendorResponseModel.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'] as Map<String, dynamic>?;
    if (dataJson == null) {
      throw FormatException('Missing "data" in single-vendor response');
    }
    return SingleVendorResponseModel(
      success: json['success'] as bool? ?? false,
      data: SingleVendorDataModel.fromJson(dataJson),
      meta: json['meta'] != null
          ? SingleVendorResponseMeta.fromJson(
              json['meta'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'data': data.toJson(),
        if (meta != null) 'meta': meta!.toJson(),
      };
}

class SingleVendorResponseMeta {
  final SingleVendorRequest? request;
  final String? version;

  SingleVendorResponseMeta({this.request, this.version});

  factory SingleVendorResponseMeta.fromJson(Map<String, dynamic> json) {
    return SingleVendorResponseMeta(
      request: json['request'] != null
          ? SingleVendorRequest.fromJson(
              json['request'] as Map<String, dynamic>,
            )
          : null,
      version: json['version'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (request != null) 'request': request!.toJson(),
        'version': version,
      };
}

class SingleVendorRequest {
  final String? vendorUuid;
  final String? branchUuid;

  SingleVendorRequest({this.vendorUuid, this.branchUuid});

  factory SingleVendorRequest.fromJson(Map<String, dynamic> json) {
    return SingleVendorRequest(
      vendorUuid: json['vendor_uuid'] as String?,
      branchUuid: json['branch_uuid'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'vendor_uuid': vendorUuid,
        'branch_uuid': branchUuid,
      };
}

class SingleVendorDataModel {
  final SingleVendorVendorModel? vendor;
  final SingleVendorBranchModel branch;

  const SingleVendorDataModel({
    this.vendor,
    required this.branch,
  });

  factory SingleVendorDataModel.fromJson(Map<String, dynamic> json) {
    final branchJson = json['branch'];
    if (branchJson == null || branchJson is! Map<String, dynamic>) {
      throw FormatException(
        'Missing or invalid "branch" in single-vendor response',
      );
    }
    return SingleVendorDataModel(
      vendor: json['vendor'] != null
          ? SingleVendorVendorModel.fromJson(
              json['vendor'] as Map<String, dynamic>,
            )
          : null,
      branch: SingleVendorBranchModel.fromJson(branchJson),
    );
  }

  Map<String, dynamic> toJson() => {
        if (vendor != null) 'vendor': vendor!.toJson(),
        'branch': branch.toJson(),
      };
}

class SingleVendorVendorModel {
  final String? uuid;
  final String? name;
  final String? email;
  final String? contact;
  final String? vendorLogo;
  final String? image;
  final String? mapApiKey;
  final String? address;
  final String? streetAddress;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;
  final String? countryCode;
  final String? lat;
  final String? lang;
  final String? mapAddress;
  final String? status;
  final String? mainColor;
  final String? fontColor;
  final String? currencySymbol;
  final String? currencySymbolPosition;
  final String? createdAt;
  final String? updatedAt;

  SingleVendorVendorModel({
    this.uuid,
    this.name,
    this.email,
    this.contact,
    this.vendorLogo,
    this.image,
    this.mapApiKey,
    this.address,
    this.streetAddress,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    this.countryCode,
    this.lat,
    this.lang,
    this.mapAddress,
    this.status,
    this.mainColor,
    this.fontColor,
    this.currencySymbol,
    this.currencySymbolPosition,
    this.createdAt,
    this.updatedAt,
  });

  factory SingleVendorVendorModel.fromJson(Map<String, dynamic> json) {
    return SingleVendorVendorModel(
      uuid: json['uuid'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      contact: json['contact'] as String?,
      vendorLogo: json['vendor_logo'] as String?,
      image: json['image'] as String?,
      mapApiKey: json['map_api_key'] as String?,
      address: json['address'] as String?,
      streetAddress: json['street_address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      zipCode: json['zip_code'] as String?,
      country: json['country'] as String?,
      countryCode: json['country_code'] as String?,
      lat: json['lat'] as String?,
      lang: json['lang'] as String?,
      mapAddress: json['map_address'] as String?,
      status: json['status'] as String?,
      mainColor: json['main_color'] as String?,
      fontColor: json['font_color'] as String?,
      currencySymbol: json['currency_symbol'] as String?,
      currencySymbolPosition: json['currency_symbol_position'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'name': name,
        'email': email,
        'contact': contact,
        'vendor_logo': vendorLogo,
        'image': image,
        'address': address,
        'street_address': streetAddress,
        'city': city,
        'state': state,
        'zip_code': zipCode,
        'country': country,
        'country_code': countryCode,
        'lat': lat,
        'lang': lang,
        'map_address': mapAddress,
        'status': status,
        'main_color': mainColor,
        'font_color': fontColor,
        'currency_symbol': currencySymbol,
        'currency_symbol_position': currencySymbolPosition,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}

/// Branch tax config from API: data.branch.tax
class SingleVendorBranchTaxModel {
  final bool? taxEnable;
  final String? taxName;
  final String? taxType; // e.g. "percentage"
  /// Tax value (e.g. 10 for 10%, 2.5 for 2.5%). API may send int or double.
  final double? taxValue;
  final bool? taxInclusive;

  SingleVendorBranchTaxModel({
    this.taxEnable,
    this.taxName,
    this.taxType,
    this.taxValue,
    this.taxInclusive,
  });

  factory SingleVendorBranchTaxModel.fromJson(Map<String, dynamic> json) {
    final taxValueRaw = json['tax_value'];
    double? taxValue;
    if (taxValueRaw != null) {
      if (taxValueRaw is num) {
        taxValue = taxValueRaw.toDouble();
      } else if (taxValueRaw is String) {
        taxValue = double.tryParse(taxValueRaw);
      }
    }
    return SingleVendorBranchTaxModel(
      taxEnable: json['tax_enable'] as bool?,
      taxName: json['tax_name'] as String?,
      taxType: json['tax_type'] as String?,
      taxValue: taxValue,
      taxInclusive: json['tax_inclusive'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'tax_enable': taxEnable,
        'tax_name': taxName,
        'tax_type': taxType,
        'tax_value': taxValue,
        'tax_inclusive': taxInclusive,
      };
}

class SingleVendorBranchModel {
  final String? uuid;
  final bool? isDefault;
  final String? referenceNo;
  final String? name;
  final String? countryCode;
  final String? phone;
  final String? email;
  final String? address;
  final String? streetAddress;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;
  final String? mapAddress;
  final String? lat;
  final String? lang;
  final String? timezone;
  final String? status;
  final String? vendorStatus;
  final String? deliveryStatus;
  final String? pickupStatus;
  final String? ubereatsStatus;
  final String? stockManagementMode;
  final bool? hasStockManagement;
  final bool? loyaltyEnabled;
  final bool? vouchersEnabled;
  final bool? onlineOrderingEnabled;
  final String? onlineTheme;
  final String? onlineMenuViewSetting;
  final String? onlineCartSticky;
  final String? onlineThemeMode;
  final String? licenseNumber;
  final String? maxOrderAmount;
  final String? currencySymbol;
  final String? currencySymbolPosition;
  final String? smsgateway;
  final String? ownDriver;
  final String? deliveryMinimumOrderAmount;
  final String? pickupMinimumOrderAmount;
  final String? avgDeliveryTime;
  final String? avgPickupTime;
  final bool? enableStripeConnect;
  final String? stripeAccountStatus;
  final List<SingleVendorPlatformFee>? platformFee;
  final SingleVendorBranchTaxModel? tax;
  final List<SingleVendorWorkingHours>? workingHours;
  final List<SingleVendorDeliveryHours>? deliveryHours;
  final List<SingleVendorPickupHours>? pickupHours;
  final List<Map<String, dynamic>>? holidays;
  final List<SingleVendorSlider>? sliders;
  final SingleVendorOrderSetting? orderSetting;
  final SingleVendorBranchOption? branchOption;
  final String? createdAt;
  final String? updatedAt;
  final List<SingleVendorMenuV2Model> menuV2;
  final SingleVendorLoyaltyProgram? loyaltyProgram;
  final List<SingleVendorLoyaltyRule>? loyaltyRules;
  final List<SingleVendorVoucher>? vouchers;

  SingleVendorBranchModel({
    this.uuid,
    this.isDefault,
    this.referenceNo,
    this.name,
    this.countryCode,
    this.phone,
    this.email,
    this.address,
    this.streetAddress,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    this.mapAddress,
    this.lat,
    this.lang,
    this.timezone,
    this.status,
    this.vendorStatus,
    this.deliveryStatus,
    this.pickupStatus,
    this.ubereatsStatus,
    this.stockManagementMode,
    this.hasStockManagement,
    this.loyaltyEnabled,
    this.vouchersEnabled,
    this.onlineOrderingEnabled,
    this.onlineTheme,
    this.onlineMenuViewSetting,
    this.onlineCartSticky,
    this.onlineThemeMode,
    this.licenseNumber,
    this.maxOrderAmount,
    this.currencySymbol,
    this.currencySymbolPosition,
    this.smsgateway,
    this.ownDriver,
    this.deliveryMinimumOrderAmount,
    this.pickupMinimumOrderAmount,
    this.avgDeliveryTime,
    this.avgPickupTime,
    this.enableStripeConnect,
    this.stripeAccountStatus,
    this.platformFee,
    this.tax,
    this.workingHours,
    this.deliveryHours,
    this.pickupHours,
    this.holidays,
    this.sliders,
    this.orderSetting,
    this.branchOption,
    this.createdAt,
    this.updatedAt,
    this.menuV2 = const [],
    this.loyaltyProgram,
    this.loyaltyRules,
    this.vouchers,
  });

  factory SingleVendorBranchModel.fromJson(Map<String, dynamic> json) {
    return SingleVendorBranchModel(
      uuid: json['uuid'] as String?,
      isDefault: json['is_default'] as bool?,
      referenceNo: json['reference_no'] as String?,
      name: json['name'] as String?,
      countryCode: json['country_code'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      streetAddress: json['street_address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      zipCode: json['zip_code'] as String?,
      country: json['country'] as String?,
      mapAddress: json['map_address'] as String?,
      lat: json['lat'] as String?,
      lang: json['lang'] as String?,
      timezone: json['timezone'] as String?,
      status: json['status'] as String?,
      vendorStatus: json['vendor_status'] as String?,
      deliveryStatus: json['delivery_status'] as String?,
      pickupStatus: json['pickup_status'] as String?,
      ubereatsStatus: json['ubereats_status'] as String?,
      stockManagementMode: json['stock_management_mode'] as String?,
      hasStockManagement: json['has_stock_management'] as bool?,
      loyaltyEnabled: json['loyalty_enabled'] as bool?,
      vouchersEnabled: json['vouchers_enabled'] as bool?,
      onlineOrderingEnabled: json['online_ordering_enabled'] as bool?,
      onlineTheme: json['online_theme'] as String?,
      onlineMenuViewSetting: json['online_menu_view_setting'] as String?,
      onlineCartSticky: json['online_cart_sticky'] as String?,
      onlineThemeMode: json['online_theme_mode'] as String?,
      licenseNumber: json['license_number'] as String?,
      maxOrderAmount: json['max_order_amount'] as String?,
      currencySymbol: json['currency_symbol'] as String?,
      currencySymbolPosition: json['currency_symbol_position'] as String?,
      smsgateway: json['smsgateway'] as String?,
      ownDriver: json['own_driver'] as String?,
      deliveryMinimumOrderAmount:
          json['delivery_minimum_order_amount'] as String?,
      pickupMinimumOrderAmount: json['pickup_minimum_order_amount'] as String?,
      avgDeliveryTime: json['avg_delivery_time'] as String?,
      avgPickupTime: json['avg_pickup_time'] as String?,
      enableStripeConnect: json['enable_stripe_connect'] as bool?,
      stripeAccountStatus: json['stripe_account_status'] as String?,
      platformFee: (json['platform_fee'] as List?)
          ?.map(
            (v) => SingleVendorPlatformFee.fromJson(
              v as Map<String, dynamic>,
            ),
          )
          .toList(),
      tax: json['tax'] != null
          ? SingleVendorBranchTaxModel.fromJson(
              json['tax'] as Map<String, dynamic>,
            )
          : null,
      workingHours: (json['working_hours'] as List?)
          ?.map((v) => SingleVendorWorkingHours.fromJson(
              v as Map<String, dynamic>,
            ))
          .toList(),
      deliveryHours: (json['delivery_hours'] as List?)
          ?.map((v) => SingleVendorDeliveryHours.fromJson(
              v as Map<String, dynamic>,
            ))
          .toList(),
      pickupHours: (json['pickup_hours'] as List?)
          ?.map((v) => SingleVendorPickupHours.fromJson(
              v as Map<String, dynamic>,
            ))
          .toList(),
      holidays: (json['holidays'] as List?)
          ?.map((v) => Map<String, dynamic>.from(v as Map))
          .toList(),
      sliders: (json['sliders'] as List?)
          ?.map((v) => SingleVendorSlider.fromJson(v as Map<String, dynamic>))
          .toList(),
      orderSetting: json['order_setting'] != null
          ? SingleVendorOrderSetting.fromJson(
              json['order_setting'] as Map<String, dynamic>,
            )
          : null,
      branchOption: json['branch_option'] != null
          ? SingleVendorBranchOption.fromJson(
              json['branch_option'] as Map<String, dynamic>,
            )
          : null,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      menuV2: _parseMenuV2List(json['menu_v2'] ?? json['menuV2']),
      loyaltyProgram: json['loyalty_program'] != null
          ? SingleVendorLoyaltyProgram.fromJson(
              json['loyalty_program'] as Map<String, dynamic>,
            )
          : null,
      loyaltyRules: (json['loyalty_rules'] as List?)
          ?.map((v) => SingleVendorLoyaltyRule.fromJson(
              v as Map<String, dynamic>,
            ))
          .toList(),
      vouchers: (json['vouchers'] as List?)
          ?.map((v) => SingleVendorVoucher.fromJson(
              v as Map<String, dynamic>,
            ))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'is_default': isDefault,
        'reference_no': referenceNo,
        'name': name,
        'country_code': countryCode,
        'phone': phone,
        'email': email,
        'address': address,
        'street_address': streetAddress,
        'city': city,
        'state': state,
        'zip_code': zipCode,
        'country': country,
        'map_address': mapAddress,
        'lat': lat,
        'lang': lang,
        'timezone': timezone,
        'status': status,
        'vendor_status': vendorStatus,
        'delivery_status': deliveryStatus,
        'pickup_status': pickupStatus,
        'ubereats_status': ubereatsStatus,
        'stock_management_mode': stockManagementMode,
        'has_stock_management': hasStockManagement,
        'loyalty_enabled': loyaltyEnabled,
        'vouchers_enabled': vouchersEnabled,
        'online_ordering_enabled': onlineOrderingEnabled,
        'online_theme': onlineTheme,
        'online_menu_view_setting': onlineMenuViewSetting,
        'online_cart_sticky': onlineCartSticky,
        'online_theme_mode': onlineThemeMode,
        'license_number': licenseNumber,
        'max_order_amount': maxOrderAmount,
        'currency_symbol': currencySymbol,
        'currency_symbol_position': currencySymbolPosition,
        'smsgateway': smsgateway,
        'own_driver': ownDriver,
        'delivery_minimum_order_amount': deliveryMinimumOrderAmount,
        'pickup_minimum_order_amount': pickupMinimumOrderAmount,
        'avg_delivery_time': avgDeliveryTime,
        'avg_pickup_time': avgPickupTime,
        'enable_stripe_connect': enableStripeConnect,
        'stripe_account_status': stripeAccountStatus,
        if (platformFee != null)
          'platform_fee': platformFee!.map((v) => v.toJson()).toList(),
        if (tax != null) 'tax': tax!.toJson(),
        if (workingHours != null)
          'working_hours': workingHours!.map((v) => v.toJson()).toList(),
        if (deliveryHours != null)
          'delivery_hours': deliveryHours!.map((v) => v.toJson()).toList(),
        if (pickupHours != null)
          'pickup_hours': pickupHours!.map((v) => v.toJson()).toList(),
        if (holidays != null) 'holidays': holidays,
        if (sliders != null) 'sliders': sliders!.map((v) => v.toJson()).toList(),
        if (orderSetting != null) 'order_setting': orderSetting!.toJson(),
        if (branchOption != null) 'branch_option': branchOption!.toJson(),
        'created_at': createdAt,
        'updated_at': updatedAt,
        'menu_v2': menuV2.map((v) => v.toJson()).toList(),
        if (loyaltyProgram != null) 'loyalty_program': loyaltyProgram!.toJson(),
        if (loyaltyRules != null)
          'loyalty_rules': loyaltyRules!.map((v) => v.toJson()).toList(),
        if (vouchers != null)
          'vouchers': vouchers!.map((v) => v.toJson()).toList(),
      };
}

class SingleVendorWorkingHours {
  final String? dayOfWeek;
  final List<SingleVendorPeriodList>? periodList;
  final String? type;
  final String? status;

  SingleVendorWorkingHours({
    this.dayOfWeek,
    this.periodList,
    this.type,
    this.status,
  });

  factory SingleVendorWorkingHours.fromJson(Map<String, dynamic> json) {
    return SingleVendorWorkingHours(
      dayOfWeek: json['day_of_week'] as String?,
      periodList: (json['period_list'] as List?)
          ?.map((v) => SingleVendorPeriodList.fromJson(
              v as Map<String, dynamic>,
            ))
          .toList(),
      type: json['type'] as String?,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'day_of_week': dayOfWeek,
        if (periodList != null)
          'period_list': periodList!.map((v) => v.toJson()).toList(),
        'type': type,
        'status': status,
      };
}

class SingleVendorDeliveryHours extends SingleVendorWorkingHours {
  SingleVendorDeliveryHours({
    super.dayOfWeek,
    super.periodList,
    super.type,
    super.status,
  });

  factory SingleVendorDeliveryHours.fromJson(Map<String, dynamic> json) {
    return SingleVendorDeliveryHours(
      dayOfWeek: json['day_of_week'] as String?,
      periodList: (json['period_list'] as List?)
          ?.map((v) => SingleVendorPeriodList.fromJson(
              v as Map<String, dynamic>,
            ))
          .toList(),
      type: json['type'] as String?,
      status: json['status'] as String?,
    );
  }
}

class SingleVendorPickupHours extends SingleVendorWorkingHours {
  SingleVendorPickupHours({
    super.dayOfWeek,
    super.periodList,
    super.type,
    super.status,
  });

  factory SingleVendorPickupHours.fromJson(Map<String, dynamic> json) {
    return SingleVendorPickupHours(
      dayOfWeek: json['day_of_week'] as String?,
      periodList: (json['period_list'] as List?)
          ?.map((v) => SingleVendorPeriodList.fromJson(
              v as Map<String, dynamic>,
            ))
          .toList(),
      type: json['type'] as String?,
      status: json['status'] as String?,
    );
  }
}

class SingleVendorPeriodList {
  final String? startTime;
  final String? endTime;

  SingleVendorPeriodList({this.startTime, this.endTime});

  factory SingleVendorPeriodList.fromJson(Map<String, dynamic> json) {
    return SingleVendorPeriodList(
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
    );
  }

  Map<String, dynamic> toJson() =>
      {'start_time': startTime, 'end_time': endTime};
}

class SingleVendorSlider {
  final int? id;
  final String? image;
  final String? imageType;
  final String? status;

  SingleVendorSlider({this.id, this.image, this.imageType, this.status});

  factory SingleVendorSlider.fromJson(Map<String, dynamic> json) {
    return SingleVendorSlider(
      id: json['id'] as int?,
      image: json['image'] as String?,
      imageType: json['image_type'] as String?,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'image': image,
        'image_type': imageType,
        'status': status,
      };
}

class SingleVendorPlatformFee {
  final String? platformFeeFor;
  final String? platformFeeType;
  final double? platformFeeValue;
  final String? platformFeeCollection;

  SingleVendorPlatformFee({
    this.platformFeeFor,
    this.platformFeeType,
    this.platformFeeValue,
    this.platformFeeCollection,
  });

  factory SingleVendorPlatformFee.fromJson(Map<String, dynamic> json) {
    return SingleVendorPlatformFee(
      platformFeeFor: json['platform_fee_for'] as String?,
      platformFeeType: json['platform_fee_type'] as String?,
      platformFeeValue: (json['platform_fee_value'] as num?)?.toDouble(),
      platformFeeCollection: json['platform_fee_collection'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'platform_fee_for': platformFeeFor,
        'platform_fee_type': platformFeeType,
        'platform_fee_value': platformFeeValue,
        'platform_fee_collection': platformFeeCollection,
      };
}

class SingleVendorMenuV2Model {
  final int? id;
  final String? name;
  final String? subtitle;
  final String? status;
  final bool? isDefault;
  final String? menuType;
  final String? ueExternalId;
  final int? version;
  final bool? isAvailable;
  final bool? isAvailableOnUe;
  final List<SingleVendorCategoryModel> categories;
  final List<SingleVendorSchedule>? schedules;
  final String? createdAt;
  final String? updatedAt;

  SingleVendorMenuV2Model({
    this.id,
    this.name,
    this.subtitle,
    this.status,
    this.isDefault,
    this.menuType,
    this.ueExternalId,
    this.version,
    this.isAvailable,
    this.isAvailableOnUe,
    this.categories = const [],
    this.schedules,
    this.createdAt,
    this.updatedAt,
  });

  factory SingleVendorMenuV2Model.fromJson(Map<String, dynamic> json) {
    // API uses snake_case 'menu_type'; accept camelCase 'menuType' as fallback
    final menuType = json['menu_type'] as String? ?? json['menuType'] as String?;
    return SingleVendorMenuV2Model(
      id: json['id'] as int?,
      name: json['name'] as String?,
      subtitle: json['subtitle'] as String?,
      status: json['status'] as String?,
      isDefault: json['is_default'] as bool?,
      menuType: menuType,
      ueExternalId: json['ue_external_id'] as String?,
      version: json['version'] as int?,
      isAvailable: json['is_available'] as bool?,
      isAvailableOnUe: json['is_available_on_ue'] as bool?,
      categories: (json['categories'] as List?)
              ?.map((v) => SingleVendorCategoryModel.fromJson(
                  v as Map<String, dynamic>,
                ))
              .toList() ??
          [],
      schedules: (json['schedules'] as List?)
          ?.map((v) =>
              SingleVendorSchedule.fromJson(v as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'subtitle': subtitle,
        'status': status,
        'is_default': isDefault,
        'menu_type': menuType,
        'ue_external_id': ueExternalId,
        'version': version,
        'is_available': isAvailable,
        'is_available_on_ue': isAvailableOnUe,
        'categories': categories.map((v) => v.toJson()).toList(),
        if (schedules != null)
          'schedules': schedules!.map((v) => v.toJson()).toList(),
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}

class SingleVendorOrderSettingCharge {
  final int? startRange;
  final int? endRange;
  final double? charge;

  SingleVendorOrderSettingCharge({
    this.startRange,
    this.endRange,
    this.charge,
  });

  factory SingleVendorOrderSettingCharge.fromJson(Map<String, dynamic> json) {
    return SingleVendorOrderSettingCharge(
      startRange: json['start_range'] as int?,
      endRange: json['end_range'] as int?,
      charge: (json['charge'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'start_range': startRange,
        'end_range': endRange,
        'charge': charge,
      };
}

class SingleVendorOrderSetting {
  final bool? freeDelivery;
  final String? freeDeliveryDistance;
  final String? freeDeliveryAmount;
  final String? minOrderValue;
  final String? maxDeliveryRangeKm;
  final List<SingleVendorOrderSettingCharge>? charges;
  final dynamic orderAssignManually;
  final dynamic orderRefresh;
  final dynamic orderCommission;
  final dynamic orderDashboardDefaultTime;
  final dynamic vendorOrderMaxTime;
  final dynamic deliveryChargeType;
  final String? onlineFlatMenuDiscountPercent;
  final String? onlineFlatDiscountAfterAmount;
  final String? minOrderAmountDelivery;
  final String? minOrderAmountTakeaway;
  final int? avgDeliveryTimeMin;
  final int? avgPickupTimeMin;

  SingleVendorOrderSetting({
    this.freeDelivery,
    this.freeDeliveryDistance,
    this.freeDeliveryAmount,
    this.minOrderValue,
    this.maxDeliveryRangeKm,
    this.charges,
    this.orderAssignManually,
    this.orderRefresh,
    this.orderCommission,
    this.orderDashboardDefaultTime,
    this.vendorOrderMaxTime,
    this.deliveryChargeType,
    this.onlineFlatMenuDiscountPercent,
    this.onlineFlatDiscountAfterAmount,
    this.minOrderAmountDelivery,
    this.minOrderAmountTakeaway,
    this.avgDeliveryTimeMin,
    this.avgPickupTimeMin,
  });

  factory SingleVendorOrderSetting.fromJson(Map<String, dynamic> json) {
    return SingleVendorOrderSetting(
      freeDelivery: json['free_delivery'] as bool?,
      freeDeliveryDistance: json['free_delivery_distance']?.toString(),
      freeDeliveryAmount: json['free_delivery_amount']?.toString(),
      minOrderValue: json['min_order_value']?.toString(),
      maxDeliveryRangeKm: json['max_delivery_range_km']?.toString(),
      charges: (json['charges'] as List?)
          ?.map(
            (v) => SingleVendorOrderSettingCharge.fromJson(
              v as Map<String, dynamic>,
            ),
          )
          .toList(),
      orderAssignManually: json['order_assign_manually'],
      orderRefresh: json['orderRefresh'],
      orderCommission: json['order_commission'],
      orderDashboardDefaultTime: json['order_dashboard_default_time'],
      vendorOrderMaxTime: json['vendor_order_max_time'],
      deliveryChargeType: json['delivery_charge_type'],
      onlineFlatMenuDiscountPercent:
          json['online_flat_menu_discount_percent']?.toString(),
      onlineFlatDiscountAfterAmount:
          json['online_flat_discount_after_amount']?.toString(),
      minOrderAmountDelivery: json['min_order_amount_delivery']?.toString(),
      minOrderAmountTakeaway: json['min_order_amount_takeaway']?.toString(),
      avgDeliveryTimeMin: json['avg_delivery_time_min'] as int?,
      avgPickupTimeMin: json['avg_pickup_time_min'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'free_delivery': freeDelivery,
        'free_delivery_distance': freeDeliveryDistance,
        'free_delivery_amount': freeDeliveryAmount,
        'min_order_value': minOrderValue,
        'max_delivery_range_km': maxDeliveryRangeKm,
        if (charges != null)
          'charges': charges!.map((v) => v.toJson()).toList(),
        'order_assign_manually': orderAssignManually,
        'orderRefresh': orderRefresh,
        'order_commission': orderCommission,
        'order_dashboard_default_time': orderDashboardDefaultTime,
        'vendor_order_max_time': vendorOrderMaxTime,
        'delivery_charge_type': deliveryChargeType,
        'online_flat_menu_discount_percent': onlineFlatMenuDiscountPercent,
        'online_flat_discount_after_amount': onlineFlatDiscountAfterAmount,
        'min_order_amount_delivery': minOrderAmountDelivery,
        'min_order_amount_takeaway': minOrderAmountTakeaway,
        'avg_delivery_time_min': avgDeliveryTimeMin,
        'avg_pickup_time_min': avgPickupTimeMin,
      };
}

class SingleVendorSchedule {
  final int? dayOfWeek;
  final String? startTime;
  final String? endTime;
  final dynamic channel;
  final dynamic daypart;

  SingleVendorSchedule({
    this.dayOfWeek,
    this.startTime,
    this.endTime,
    this.channel,
    this.daypart,
  });

  factory SingleVendorSchedule.fromJson(Map<String, dynamic> json) {
    return SingleVendorSchedule(
      dayOfWeek: json['day_of_week'] as int?,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      channel: json['channel'],
      daypart: json['daypart'],
    );
  }

  Map<String, dynamic> toJson() => {
        'day_of_week': dayOfWeek,
        'start_time': startTime,
        'end_time': endTime,
        'channel': channel,
        'daypart': daypart,
      };
}

class SingleVendorCategoryModel {
  final String? name;
  final String? subtitle;
  final String? description;
  final String? imageUrl;
  final String? ueExternalId;
  final int? sortOrder;
  final bool? isAvailable;
  final List<SingleVendorItemModel> items;

  SingleVendorCategoryModel({
    this.name,
    this.subtitle,
    this.description,
    this.imageUrl,
    this.ueExternalId,
    this.sortOrder,
    this.isAvailable,
    this.items = const [],
  });

  factory SingleVendorCategoryModel.fromJson(Map<String, dynamic> json) {
    return SingleVendorCategoryModel(
      name: json['name'] as String?,
      subtitle: json['subtitle'] as String?,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      ueExternalId: json['ue_external_id'] as String?,
      sortOrder: json['sort_order'] as int?,
      isAvailable: json['is_available'] as bool?,
      items: (json['items'] as List?)
              ?.map((v) => SingleVendorItemModel.fromJson(
                  v as Map<String, dynamic>,
                ))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'subtitle': subtitle,
        'description': description,
        'image_url': imageUrl,
        'ue_external_id': ueExternalId,
        'sort_order': sortOrder,
        'is_available': isAvailable,
        'items': items.map((v) => v.toJson()).toList(),
      };
}

class SingleVendorItemModel {
  final String? name;
  final String? subtitle;
  final String? description;
  final String? imageUrl;
  final String? sku;
  final String? price;
  final int? priceCents;
  final String? currency;
  final bool? isAvailable;
  final bool? featured;
  final int? calories;
  final String? ueExternalId;
  final int? sortOrder;
  final List<Map<String, dynamic>>? images;
  final dynamic primaryImage;
  final List<SingleVendorModifierGroup>? modifierGroups;
  final List<dynamic>? dietaryLabels;
  final List<dynamic>? allergens;
  final SingleVendorNutrition? nutrition;
  final List<dynamic>? ingredients;
  final List<dynamic>? additives;
  final dynamic quantityRule;

  SingleVendorItemModel({
    this.name,
    this.subtitle,
    this.description,
    this.imageUrl,
    this.sku,
    this.price,
    this.priceCents,
    this.currency,
    this.isAvailable,
    this.featured,
    this.calories,
    this.ueExternalId,
    this.sortOrder,
    this.images,
    this.primaryImage,
    this.modifierGroups,
    this.dietaryLabels,
    this.allergens,
    this.nutrition,
    this.ingredients,
    this.additives,
    this.quantityRule,
  });

  factory SingleVendorItemModel.fromJson(Map<String, dynamic> json) {
    return SingleVendorItemModel(
      name: json['name'] as String?,
      subtitle: json['subtitle'] as String?,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      sku: json['sku'] as String?,
      price: json['price']?.toString(),
      priceCents: json['price_cents'] as int?,
      currency: json['currency'] as String?,
      isAvailable: json['is_available'] as bool?,
      featured: json['featured'] as bool?,
      calories: json['calories'] as int?,
      ueExternalId: json['ue_external_id'] as String?,
      sortOrder: json['sort_order'] as int?,
      images: (json['images'] as List?)
          ?.map((v) => Map<String, dynamic>.from(v as Map))
          .toList(),
      primaryImage: json['primary_image'],
      modifierGroups: (json['modifier_groups'] as List?)
          ?.map((v) => SingleVendorModifierGroup.fromJson(
              v as Map<String, dynamic>,
            ))
          .toList(),
      dietaryLabels: json['dietary_labels'] as List?,
      allergens: json['allergens'] as List?,
      nutrition: json['nutrition'] != null
          ? SingleVendorNutrition.fromJson(
              json['nutrition'] as Map<String, dynamic>,
            )
          : null,
      ingredients: json['ingredients'] as List?,
      additives: json['additives'] as List?,
      quantityRule: json['quantity_rule'],
    );
  }

  double get priceAsDouble {
    final p = double.tryParse(price ?? '');
    return p ?? 0.0;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'subtitle': subtitle,
        'description': description,
        'image_url': imageUrl,
        'sku': sku,
        'price': price,
        'price_cents': priceCents,
        'currency': currency,
        'is_available': isAvailable,
        'featured': featured,
        'calories': calories,
        'ue_external_id': ueExternalId,
        'sort_order': sortOrder,
        if (images != null) 'images': images,
        'primary_image': primaryImage,
        if (modifierGroups != null)
          'modifier_groups':
              modifierGroups!.map((v) => v.toJson()).toList(),
        if (dietaryLabels != null) 'dietary_labels': dietaryLabels,
        if (allergens != null) 'allergens': allergens,
        if (nutrition != null) 'nutrition': nutrition!.toJson(),
        if (ingredients != null) 'ingredients': ingredients,
        if (additives != null) 'additives': additives,
        'quantity_rule': quantityRule,
      };
}

class SingleVendorModifierGroup {
  final String? name;
  final String? title;
  final String? description;
  final String? displayType;
  final bool? isAvailable;
  final String? ueExternalId;
  final int? sortOrder;
  final List<SingleVendorModifier>? modifiers;
  final SingleVendorQuantityRule? quantityRule;

  SingleVendorModifierGroup({
    this.name,
    this.title,
    this.description,
    this.displayType,
    this.isAvailable,
    this.ueExternalId,
    this.sortOrder,
    this.modifiers,
    this.quantityRule,
  });

  factory SingleVendorModifierGroup.fromJson(Map<String, dynamic> json) {
    return SingleVendorModifierGroup(
      name: json['name'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      displayType: json['display_type'] as String?,
      isAvailable: json['is_available'] as bool?,
      ueExternalId: json['ue_external_id'] as String?,
      sortOrder: json['sort_order'] as int?,
      modifiers: (json['modifiers'] as List?)
          ?.map((v) => SingleVendorModifier.fromJson(
              v as Map<String, dynamic>,
            ))
          .toList(),
      quantityRule: json['quantity_rule'] != null
          ? SingleVendorQuantityRule.fromJson(
              json['quantity_rule'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'title': title,
        'description': description,
        'display_type': displayType,
        'is_available': isAvailable,
        'ue_external_id': ueExternalId,
        'sort_order': sortOrder,
        if (modifiers != null)
          'modifiers': modifiers!.map((v) => v.toJson()).toList(),
        if (quantityRule != null) 'quantity_rule': quantityRule!.toJson(),
      };
}

class SingleVendorModifier {
  final String? name;
  final String? price;
  final int? priceCents;
  final bool? isAvailable;
  final int? calories;
  final String? ueExternalId;
  final int? sortOrder;
  final List<SingleVendorModifierGroup>? modifierGroups;

  SingleVendorModifier({
    this.name,
    this.price,
    this.priceCents,
    this.isAvailable,
    this.calories,
    this.ueExternalId,
    this.sortOrder,
    this.modifierGroups,
  });

  factory SingleVendorModifier.fromJson(Map<String, dynamic> json) {
    return SingleVendorModifier(
      name: json['name'] as String?,
      price: json['price']?.toString(),
      priceCents: json['price_cents'] as int?,
      isAvailable: json['is_available'] as bool?,
      calories: json['calories'] as int?,
      ueExternalId: json['ue_external_id'] as String?,
      sortOrder: json['sort_order'] as int?,
      modifierGroups: (json['modifier_groups'] as List?)
          ?.map((v) => SingleVendorModifierGroup.fromJson(
              v as Map<String, dynamic>,
            ))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        'price_cents': priceCents,
        'is_available': isAvailable,
        'calories': calories,
        'ue_external_id': ueExternalId,
        'sort_order': sortOrder,
        if (modifierGroups != null)
          'modifier_groups':
              modifierGroups!.map((v) => v.toJson()).toList(),
      };
}

class SingleVendorQuantityRule {
  final int? minSelections;
  final int? maxSelections;
  final bool? isRequired;

  SingleVendorQuantityRule({
    this.minSelections,
    this.maxSelections,
    this.isRequired,
  });

  factory SingleVendorQuantityRule.fromJson(Map<String, dynamic> json) {
    return SingleVendorQuantityRule(
      minSelections: json['min_selections'] as int?,
      maxSelections: json['max_selections'] as int?,
      isRequired: json['is_required'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'min_selections': minSelections,
        'max_selections': maxSelections,
        'is_required': isRequired,
      };
}

class SingleVendorNutrition {
  final int? kcal;
  final String? proteinG;
  final String? carbsG;
  final String? sugarG;
  final String? fatG;
  final String? satFatG;
  final String? fiberG;
  final int? sodiumMg;

  SingleVendorNutrition({
    this.kcal,
    this.proteinG,
    this.carbsG,
    this.sugarG,
    this.fatG,
    this.satFatG,
    this.fiberG,
    this.sodiumMg,
  });

  factory SingleVendorNutrition.fromJson(Map<String, dynamic> json) {
    return SingleVendorNutrition(
      kcal: json['kcal'] as int?,
      proteinG: json['protein_g']?.toString(),
      carbsG: json['carbs_g']?.toString(),
      sugarG: json['sugar_g']?.toString(),
      fatG: json['fat_g']?.toString(),
      satFatG: json['sat_fat_g']?.toString(),
      fiberG: json['fiber_g']?.toString(),
      sodiumMg: json['sodium_mg'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'kcal': kcal,
        'protein_g': proteinG,
        'carbs_g': carbsG,
        'sugar_g': sugarG,
        'fat_g': fatG,
        'sat_fat_g': satFatG,
        'fiber_g': fiberG,
        'sodium_mg': sodiumMg,
      };
}

class SingleVendorBranchOption {
  final String? ownDriver;
  final String? promoCode;
  final String? reviews;
  final String? liveTracking;
  final String? advanceTableBooking;
  final String? qrcodeStatus;
  final String? qrcodeLink;
  final bool? otp;
  final String? transactionFeeRate;
  final String? privacyPage;
  final String? termsPage;
  final String? aboutUsPage;
  final String? refundPage;
  final String? companyPage;
  final String? feedbackPage;

  SingleVendorBranchOption({
    this.ownDriver,
    this.promoCode,
    this.reviews,
    this.liveTracking,
    this.advanceTableBooking,
    this.qrcodeStatus,
    this.qrcodeLink,
    this.otp,
    this.transactionFeeRate,
    this.privacyPage,
    this.termsPage,
    this.aboutUsPage,
    this.refundPage,
    this.companyPage,
    this.feedbackPage,
  });

  factory SingleVendorBranchOption.fromJson(Map<String, dynamic> json) {
    return SingleVendorBranchOption(
      ownDriver: json['own_driver'] as String?,
      promoCode: json['promo_code'] as String?,
      reviews: json['reviews'] as String?,
      liveTracking: json['live_tracking'] as String?,
      advanceTableBooking: json['advance_table_booking'] as String?,
      qrcodeStatus: json['qrcode_status'] as String?,
      qrcodeLink: json['qrcode_link'] as String?,
      otp: json['otp'] as bool?,
      transactionFeeRate: json['transaction_fee_rate']?.toString(),
      privacyPage: json['privacy_page'] as String?,
      termsPage: json['terms_page'] as String?,
      aboutUsPage: json['about_us_page'] as String?,
      refundPage: json['refund_page'] as String?,
      companyPage: json['company_page'] as String?,
      feedbackPage: json['feedback_page'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'own_driver': ownDriver,
        'promo_code': promoCode,
        'reviews': reviews,
        'live_tracking': liveTracking,
        'advance_table_booking': advanceTableBooking,
        'qrcode_status': qrcodeStatus,
        'qrcode_link': qrcodeLink,
        'otp': otp,
        'transaction_fee_rate': transactionFeeRate,
        'privacy_page': privacyPage,
        'terms_page': termsPage,
        'about_us_page': aboutUsPage,
        'refund_page': refundPage,
        'company_page': companyPage,
        'feedback_page': feedbackPage,
      };
}

class SingleVendorLoyaltyProgram {
  final bool? enabled;
  final String? earnMode;
  final int? pointsPerCurrency;
  final int? visitPoints;
  final int? pointsPerCurrencyUnitForRedeem;
  final SingleVendorLoyaltySettings? settings;
  final String? createdAt;
  final String? updatedAt;

  SingleVendorLoyaltyProgram({
    this.enabled,
    this.earnMode,
    this.pointsPerCurrency,
    this.visitPoints,
    this.pointsPerCurrencyUnitForRedeem,
    this.settings,
    this.createdAt,
    this.updatedAt,
  });

  factory SingleVendorLoyaltyProgram.fromJson(Map<String, dynamic> json) {
    return SingleVendorLoyaltyProgram(
      enabled: json['enabled'] as bool?,
      earnMode: json['earn_mode'] as String?,
      pointsPerCurrency: json['points_per_currency'] as int?,
      visitPoints: json['visit_points'] as int?,
      pointsPerCurrencyUnitForRedeem:
          json['points_per_currency_unit_for_redeem'] as int?,
      settings: json['settings'] != null
          ? SingleVendorLoyaltySettings.fromJson(
              json['settings'] as Map<String, dynamic>,
            )
          : null,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'earn_mode': earnMode,
        'points_per_currency': pointsPerCurrency,
        'visit_points': visitPoints,
        'points_per_currency_unit_for_redeem': pointsPerCurrencyUnitForRedeem,
        if (settings != null) 'settings': settings!.toJson(),
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}

class SingleVendorLoyaltySettings {
  final int? minPointsToRedeem;
  final String? redeemType;
  final int? pointsExpiryDays;
  final int? welcomeBonusPoints;
  final int? birthdayBonusPoints;
  final int? anniversaryBonusPoints;

  SingleVendorLoyaltySettings({
    this.minPointsToRedeem,
    this.redeemType,
    this.pointsExpiryDays,
    this.welcomeBonusPoints,
    this.birthdayBonusPoints,
    this.anniversaryBonusPoints,
  });

  factory SingleVendorLoyaltySettings.fromJson(Map<String, dynamic> json) {
    return SingleVendorLoyaltySettings(
      minPointsToRedeem: json['min_points_to_redeem'] as int?,
      redeemType: json['redeem_type'] as String?,
      pointsExpiryDays: json['points_expiry_days'] as int?,
      welcomeBonusPoints: json['welcome_bonus_points'] as int?,
      birthdayBonusPoints: json['birthday_bonus_points'] as int?,
      anniversaryBonusPoints:
          json['anniversary_bonus_points'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'min_points_to_redeem': minPointsToRedeem,
        'redeem_type': redeemType,
        'points_expiry_days': pointsExpiryDays,
        'welcome_bonus_points': welcomeBonusPoints,
        'birthday_bonus_points': birthdayBonusPoints,
        'anniversary_bonus_points': anniversaryBonusPoints,
      };
}

class SingleVendorLoyaltyRule {
  final String? channel;
  final String? earnMode;
  final double? pointsPerCurrency;
  final int? pointsPerItem;
  final int? fixedPoints;
  final int? priority;
  final bool? active;
  final String? startsAt;
  final String? endsAt;
  final SingleVendorConstraints? constraints;

  SingleVendorLoyaltyRule({
    this.channel,
    this.earnMode,
    this.pointsPerCurrency,
    this.pointsPerItem,
    this.fixedPoints,
    this.priority,
    this.active,
    this.startsAt,
    this.endsAt,
    this.constraints,
  });

  factory SingleVendorLoyaltyRule.fromJson(Map<String, dynamic> json) {
    return SingleVendorLoyaltyRule(
      channel: json['channel'] as String?,
      earnMode: json['earn_mode'] as String?,
      pointsPerCurrency: (json['points_per_currency'] as num?)?.toDouble(),
      pointsPerItem: json['points_per_item'] as int?,
      fixedPoints: json['fixed_points'] as int?,
      priority: json['priority'] as int?,
      active: json['active'] as bool?,
      startsAt: json['starts_at'] as String?,
      endsAt: json['ends_at'] as String?,
      constraints: json['constraints'] != null
          ? SingleVendorConstraints.fromJson(
              json['constraints'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'channel': channel,
        'earn_mode': earnMode,
        'points_per_currency': pointsPerCurrency,
        'points_per_item': pointsPerItem,
        'fixed_points': fixedPoints,
        'priority': priority,
        'active': active,
        'starts_at': startsAt,
        'ends_at': endsAt,
        if (constraints != null) 'constraints': constraints!.toJson(),
      };
}

class SingleVendorConstraints {
  final int? minSpendAmount;

  SingleVendorConstraints({this.minSpendAmount});

  factory SingleVendorConstraints.fromJson(Map<String, dynamic> json) {
    return SingleVendorConstraints(
      minSpendAmount: json['min_spend_amount'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {'min_spend_amount': minSpendAmount};
}

class SingleVendorVoucher {
  final String? code;
  final String? title;
  final String? description;
  final String? discountType;
  final int? discountValue;
  final int? minOrderAmountCents;
  final int? maxDiscountAmountCents;
  final String? startAt;
  final String? expiresAt;
  final int? usageLimit;
  final int? perCustomerLimit;
  final bool? isBearer;
  final bool? isActive;
  final SingleVendorVoucherMeta? meta;
  final String? createdAt;
  final String? updatedAt;

  SingleVendorVoucher({
    this.code,
    this.title,
    this.description,
    this.discountType,
    this.discountValue,
    this.minOrderAmountCents,
    this.maxDiscountAmountCents,
    this.startAt,
    this.expiresAt,
    this.usageLimit,
    this.perCustomerLimit,
    this.isBearer,
    this.isActive,
    this.meta,
    this.createdAt,
    this.updatedAt,
  });

  factory SingleVendorVoucher.fromJson(Map<String, dynamic> json) {
    return SingleVendorVoucher(
      code: json['code'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      discountType: json['discount_type'] as String?,
      discountValue: json['discount_value'] as int?,
      minOrderAmountCents: json['min_order_amount_cents'] as int?,
      maxDiscountAmountCents: json['max_discount_amount_cents'] as int?,
      startAt: json['start_at'] as String?,
      expiresAt: json['expires_at'] as String?,
      usageLimit: json['usage_limit'] as int?,
      perCustomerLimit: json['per_customer_limit'] as int?,
      isBearer: json['is_bearer'] as bool?,
      isActive: json['is_active'] as bool?,
      meta: json['meta'] != null
          ? SingleVendorVoucherMeta.fromJson(
              json['meta'] as Map<String, dynamic>,
            )
          : null,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'title': title,
        'description': description,
        'discount_type': discountType,
        'discount_value': discountValue,
        'min_order_amount_cents': minOrderAmountCents,
        'max_discount_amount_cents': maxDiscountAmountCents,
        'start_at': startAt,
        'expires_at': expiresAt,
        'usage_limit': usageLimit,
        'per_customer_limit': perCustomerLimit,
        'is_bearer': isBearer,
        'is_active': isActive,
        if (meta != null) 'meta': meta!.toJson(),
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}

class SingleVendorVoucherMeta {
  final String? color;
  final String? icon;

  SingleVendorVoucherMeta({this.color, this.icon});

  factory SingleVendorVoucherMeta.fromJson(Map<String, dynamic> json) {
    return SingleVendorVoucherMeta(
      color: json['color'] as String?,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'color': color, 'icon': icon};
}
