// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_database.dart';

// ignore_for_file: type=lint
class $MenuSnapshotsTable extends MenuSnapshots
    with TableInfo<$MenuSnapshotsTable, MenuSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MenuSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _vendorUuidMeta =
      const VerificationMeta('vendorUuid');
  @override
  late final GeneratedColumn<String> vendorUuid = GeneratedColumn<String>(
      'vendor_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _branchUuidMeta =
      const VerificationMeta('branchUuid');
  @override
  late final GeneratedColumn<String> branchUuid = GeneratedColumn<String>(
      'branch_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
      'version', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [vendorUuid, branchUuid, payloadJson, version, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'menu_snapshots';
  @override
  VerificationContext validateIntegrity(Insertable<MenuSnapshot> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('vendor_uuid')) {
      context.handle(
          _vendorUuidMeta,
          vendorUuid.isAcceptableOrUnknown(
              data['vendor_uuid']!, _vendorUuidMeta));
    } else if (isInserting) {
      context.missing(_vendorUuidMeta);
    }
    if (data.containsKey('branch_uuid')) {
      context.handle(
          _branchUuidMeta,
          branchUuid.isAcceptableOrUnknown(
              data['branch_uuid']!, _branchUuidMeta));
    } else if (isInserting) {
      context.missing(_branchUuidMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {vendorUuid, branchUuid};
  @override
  MenuSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MenuSnapshot(
      vendorUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vendor_uuid'])!,
      branchUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}branch_uuid'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}version']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $MenuSnapshotsTable createAlias(String alias) {
    return $MenuSnapshotsTable(attachedDatabase, alias);
  }
}

class MenuSnapshot extends DataClass implements Insertable<MenuSnapshot> {
  /// Vendor UUID from auth session.
  final String vendorUuid;

  /// Branch UUID from auth session.
  final String branchUuid;

  /// Full JSON payload of the single-vendor response.
  final String payloadJson;

  /// Optional version string from API meta, if provided.
  final String? version;

  /// Last time this snapshot was updated.
  final DateTime updatedAt;
  const MenuSnapshot(
      {required this.vendorUuid,
      required this.branchUuid,
      required this.payloadJson,
      this.version,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['vendor_uuid'] = Variable<String>(vendorUuid);
    map['branch_uuid'] = Variable<String>(branchUuid);
    map['payload_json'] = Variable<String>(payloadJson);
    if (!nullToAbsent || version != null) {
      map['version'] = Variable<String>(version);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MenuSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return MenuSnapshotsCompanion(
      vendorUuid: Value(vendorUuid),
      branchUuid: Value(branchUuid),
      payloadJson: Value(payloadJson),
      version: version == null && nullToAbsent
          ? const Value.absent()
          : Value(version),
      updatedAt: Value(updatedAt),
    );
  }

  factory MenuSnapshot.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MenuSnapshot(
      vendorUuid: serializer.fromJson<String>(json['vendorUuid']),
      branchUuid: serializer.fromJson<String>(json['branchUuid']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      version: serializer.fromJson<String?>(json['version']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'vendorUuid': serializer.toJson<String>(vendorUuid),
      'branchUuid': serializer.toJson<String>(branchUuid),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'version': serializer.toJson<String?>(version),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MenuSnapshot copyWith(
          {String? vendorUuid,
          String? branchUuid,
          String? payloadJson,
          Value<String?> version = const Value.absent(),
          DateTime? updatedAt}) =>
      MenuSnapshot(
        vendorUuid: vendorUuid ?? this.vendorUuid,
        branchUuid: branchUuid ?? this.branchUuid,
        payloadJson: payloadJson ?? this.payloadJson,
        version: version.present ? version.value : this.version,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  MenuSnapshot copyWithCompanion(MenuSnapshotsCompanion data) {
    return MenuSnapshot(
      vendorUuid:
          data.vendorUuid.present ? data.vendorUuid.value : this.vendorUuid,
      branchUuid:
          data.branchUuid.present ? data.branchUuid.value : this.branchUuid,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      version: data.version.present ? data.version.value : this.version,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MenuSnapshot(')
          ..write('vendorUuid: $vendorUuid, ')
          ..write('branchUuid: $branchUuid, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('version: $version, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(vendorUuid, branchUuid, payloadJson, version, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MenuSnapshot &&
          other.vendorUuid == this.vendorUuid &&
          other.branchUuid == this.branchUuid &&
          other.payloadJson == this.payloadJson &&
          other.version == this.version &&
          other.updatedAt == this.updatedAt);
}

class MenuSnapshotsCompanion extends UpdateCompanion<MenuSnapshot> {
  final Value<String> vendorUuid;
  final Value<String> branchUuid;
  final Value<String> payloadJson;
  final Value<String?> version;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MenuSnapshotsCompanion({
    this.vendorUuid = const Value.absent(),
    this.branchUuid = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.version = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MenuSnapshotsCompanion.insert({
    required String vendorUuid,
    required String branchUuid,
    required String payloadJson,
    this.version = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : vendorUuid = Value(vendorUuid),
        branchUuid = Value(branchUuid),
        payloadJson = Value(payloadJson),
        updatedAt = Value(updatedAt);
  static Insertable<MenuSnapshot> custom({
    Expression<String>? vendorUuid,
    Expression<String>? branchUuid,
    Expression<String>? payloadJson,
    Expression<String>? version,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (vendorUuid != null) 'vendor_uuid': vendorUuid,
      if (branchUuid != null) 'branch_uuid': branchUuid,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (version != null) 'version': version,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MenuSnapshotsCompanion copyWith(
      {Value<String>? vendorUuid,
      Value<String>? branchUuid,
      Value<String>? payloadJson,
      Value<String?>? version,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return MenuSnapshotsCompanion(
      vendorUuid: vendorUuid ?? this.vendorUuid,
      branchUuid: branchUuid ?? this.branchUuid,
      payloadJson: payloadJson ?? this.payloadJson,
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (vendorUuid.present) {
      map['vendor_uuid'] = Variable<String>(vendorUuid.value);
    }
    if (branchUuid.present) {
      map['branch_uuid'] = Variable<String>(branchUuid.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MenuSnapshotsCompanion(')
          ..write('vendorUuid: $vendorUuid, ')
          ..write('branchUuid: $branchUuid, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('version: $version, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DbOrdersTable extends DbOrders with TableInfo<$DbOrdersTable, DbOrder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbOrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _queueNumberMeta =
      const VerificationMeta('queueNumber');
  @override
  late final GeneratedColumn<String> queueNumber = GeneratedColumn<String>(
      'queue_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _channelMeta =
      const VerificationMeta('channel');
  @override
  late final GeneratedColumn<String> channel = GeneratedColumn<String>(
      'channel', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orderTypeMeta =
      const VerificationMeta('orderType');
  @override
  late final GeneratedColumn<String> orderType = GeneratedColumn<String>(
      'order_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _paymentStatusMeta =
      const VerificationMeta('paymentStatus');
  @override
  late final GeneratedColumn<String> paymentStatus = GeneratedColumn<String>(
      'payment_status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _customerNameMeta =
      const VerificationMeta('customerName');
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
      'customer_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _customerPhoneMeta =
      const VerificationMeta('customerPhone');
  @override
  late final GeneratedColumn<String> customerPhone = GeneratedColumn<String>(
      'customer_phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _subtotalMeta =
      const VerificationMeta('subtotal');
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
      'subtotal', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _taxMeta = const VerificationMeta('tax');
  @override
  late final GeneratedColumn<double> tax = GeneratedColumn<double>(
      'tax', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
      'total', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _estimatedTimeMeta =
      const VerificationMeta('estimatedTime');
  @override
  late final GeneratedColumn<DateTime> estimatedTime =
      GeneratedColumn<DateTime>('estimated_time', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _specialInstructionsMeta =
      const VerificationMeta('specialInstructions');
  @override
  late final GeneratedColumn<String> specialInstructions =
      GeneratedColumn<String>('special_instructions', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        queueNumber,
        channel,
        orderType,
        paymentStatus,
        status,
        customerName,
        customerPhone,
        subtotal,
        tax,
        total,
        createdAt,
        estimatedTime,
        specialInstructions
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_orders';
  @override
  VerificationContext validateIntegrity(Insertable<DbOrder> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('queue_number')) {
      context.handle(
          _queueNumberMeta,
          queueNumber.isAcceptableOrUnknown(
              data['queue_number']!, _queueNumberMeta));
    } else if (isInserting) {
      context.missing(_queueNumberMeta);
    }
    if (data.containsKey('channel')) {
      context.handle(_channelMeta,
          channel.isAcceptableOrUnknown(data['channel']!, _channelMeta));
    } else if (isInserting) {
      context.missing(_channelMeta);
    }
    if (data.containsKey('order_type')) {
      context.handle(_orderTypeMeta,
          orderType.isAcceptableOrUnknown(data['order_type']!, _orderTypeMeta));
    } else if (isInserting) {
      context.missing(_orderTypeMeta);
    }
    if (data.containsKey('payment_status')) {
      context.handle(
          _paymentStatusMeta,
          paymentStatus.isAcceptableOrUnknown(
              data['payment_status']!, _paymentStatusMeta));
    } else if (isInserting) {
      context.missing(_paymentStatusMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('customer_name')) {
      context.handle(
          _customerNameMeta,
          customerName.isAcceptableOrUnknown(
              data['customer_name']!, _customerNameMeta));
    } else if (isInserting) {
      context.missing(_customerNameMeta);
    }
    if (data.containsKey('customer_phone')) {
      context.handle(
          _customerPhoneMeta,
          customerPhone.isAcceptableOrUnknown(
              data['customer_phone']!, _customerPhoneMeta));
    }
    if (data.containsKey('subtotal')) {
      context.handle(_subtotalMeta,
          subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta));
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    if (data.containsKey('tax')) {
      context.handle(
          _taxMeta, tax.isAcceptableOrUnknown(data['tax']!, _taxMeta));
    } else if (isInserting) {
      context.missing(_taxMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
          _totalMeta, total.isAcceptableOrUnknown(data['total']!, _totalMeta));
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('estimated_time')) {
      context.handle(
          _estimatedTimeMeta,
          estimatedTime.isAcceptableOrUnknown(
              data['estimated_time']!, _estimatedTimeMeta));
    } else if (isInserting) {
      context.missing(_estimatedTimeMeta);
    }
    if (data.containsKey('special_instructions')) {
      context.handle(
          _specialInstructionsMeta,
          specialInstructions.isAcceptableOrUnknown(
              data['special_instructions']!, _specialInstructionsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbOrder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbOrder(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      queueNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}queue_number'])!,
      channel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}channel'])!,
      orderType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}order_type'])!,
      paymentStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_status'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      customerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_name'])!,
      customerPhone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_phone']),
      subtotal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}subtotal'])!,
      tax: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}tax'])!,
      total: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      estimatedTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}estimated_time'])!,
      specialInstructions: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}special_instructions']),
    );
  }

  @override
  $DbOrdersTable createAlias(String alias) {
    return $DbOrdersTable(attachedDatabase, alias);
  }
}

class DbOrder extends DataClass implements Insertable<DbOrder> {
  /// Unique order id from backend (or derived).
  final String id;

  /// Queue/display number shown in UI.
  final String queueNumber;

  /// Channel name (e.g. "Pickup", "Delivery", "Dine-In", "UberEats").
  final String channel;

  /// Order type (delivery / takeaway / dinein).
  final String orderType;

  /// Payment status (paid / unpaid).
  final String paymentStatus;

  /// Order status (active / completed / cancelled).
  final String status;

  /// Customer display name.
  final String customerName;

  /// Optional customer phone.
  final String? customerPhone;

  /// Subtotal amount.
  final double subtotal;

  /// Tax amount.
  final double tax;

  /// Total amount.
  final double total;

  /// Created at timestamp (UTC).
  final DateTime createdAt;

  /// Estimated ready/serve time.
  final DateTime estimatedTime;

  /// Order-level special instructions / notes.
  final String? specialInstructions;
  const DbOrder(
      {required this.id,
      required this.queueNumber,
      required this.channel,
      required this.orderType,
      required this.paymentStatus,
      required this.status,
      required this.customerName,
      this.customerPhone,
      required this.subtotal,
      required this.tax,
      required this.total,
      required this.createdAt,
      required this.estimatedTime,
      this.specialInstructions});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['queue_number'] = Variable<String>(queueNumber);
    map['channel'] = Variable<String>(channel);
    map['order_type'] = Variable<String>(orderType);
    map['payment_status'] = Variable<String>(paymentStatus);
    map['status'] = Variable<String>(status);
    map['customer_name'] = Variable<String>(customerName);
    if (!nullToAbsent || customerPhone != null) {
      map['customer_phone'] = Variable<String>(customerPhone);
    }
    map['subtotal'] = Variable<double>(subtotal);
    map['tax'] = Variable<double>(tax);
    map['total'] = Variable<double>(total);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['estimated_time'] = Variable<DateTime>(estimatedTime);
    if (!nullToAbsent || specialInstructions != null) {
      map['special_instructions'] = Variable<String>(specialInstructions);
    }
    return map;
  }

  DbOrdersCompanion toCompanion(bool nullToAbsent) {
    return DbOrdersCompanion(
      id: Value(id),
      queueNumber: Value(queueNumber),
      channel: Value(channel),
      orderType: Value(orderType),
      paymentStatus: Value(paymentStatus),
      status: Value(status),
      customerName: Value(customerName),
      customerPhone: customerPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(customerPhone),
      subtotal: Value(subtotal),
      tax: Value(tax),
      total: Value(total),
      createdAt: Value(createdAt),
      estimatedTime: Value(estimatedTime),
      specialInstructions: specialInstructions == null && nullToAbsent
          ? const Value.absent()
          : Value(specialInstructions),
    );
  }

  factory DbOrder.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbOrder(
      id: serializer.fromJson<String>(json['id']),
      queueNumber: serializer.fromJson<String>(json['queueNumber']),
      channel: serializer.fromJson<String>(json['channel']),
      orderType: serializer.fromJson<String>(json['orderType']),
      paymentStatus: serializer.fromJson<String>(json['paymentStatus']),
      status: serializer.fromJson<String>(json['status']),
      customerName: serializer.fromJson<String>(json['customerName']),
      customerPhone: serializer.fromJson<String?>(json['customerPhone']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      tax: serializer.fromJson<double>(json['tax']),
      total: serializer.fromJson<double>(json['total']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      estimatedTime: serializer.fromJson<DateTime>(json['estimatedTime']),
      specialInstructions:
          serializer.fromJson<String?>(json['specialInstructions']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'queueNumber': serializer.toJson<String>(queueNumber),
      'channel': serializer.toJson<String>(channel),
      'orderType': serializer.toJson<String>(orderType),
      'paymentStatus': serializer.toJson<String>(paymentStatus),
      'status': serializer.toJson<String>(status),
      'customerName': serializer.toJson<String>(customerName),
      'customerPhone': serializer.toJson<String?>(customerPhone),
      'subtotal': serializer.toJson<double>(subtotal),
      'tax': serializer.toJson<double>(tax),
      'total': serializer.toJson<double>(total),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'estimatedTime': serializer.toJson<DateTime>(estimatedTime),
      'specialInstructions': serializer.toJson<String?>(specialInstructions),
    };
  }

  DbOrder copyWith(
          {String? id,
          String? queueNumber,
          String? channel,
          String? orderType,
          String? paymentStatus,
          String? status,
          String? customerName,
          Value<String?> customerPhone = const Value.absent(),
          double? subtotal,
          double? tax,
          double? total,
          DateTime? createdAt,
          DateTime? estimatedTime,
          Value<String?> specialInstructions = const Value.absent()}) =>
      DbOrder(
        id: id ?? this.id,
        queueNumber: queueNumber ?? this.queueNumber,
        channel: channel ?? this.channel,
        orderType: orderType ?? this.orderType,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        status: status ?? this.status,
        customerName: customerName ?? this.customerName,
        customerPhone:
            customerPhone.present ? customerPhone.value : this.customerPhone,
        subtotal: subtotal ?? this.subtotal,
        tax: tax ?? this.tax,
        total: total ?? this.total,
        createdAt: createdAt ?? this.createdAt,
        estimatedTime: estimatedTime ?? this.estimatedTime,
        specialInstructions: specialInstructions.present
            ? specialInstructions.value
            : this.specialInstructions,
      );
  DbOrder copyWithCompanion(DbOrdersCompanion data) {
    return DbOrder(
      id: data.id.present ? data.id.value : this.id,
      queueNumber:
          data.queueNumber.present ? data.queueNumber.value : this.queueNumber,
      channel: data.channel.present ? data.channel.value : this.channel,
      orderType: data.orderType.present ? data.orderType.value : this.orderType,
      paymentStatus: data.paymentStatus.present
          ? data.paymentStatus.value
          : this.paymentStatus,
      status: data.status.present ? data.status.value : this.status,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      customerPhone: data.customerPhone.present
          ? data.customerPhone.value
          : this.customerPhone,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      tax: data.tax.present ? data.tax.value : this.tax,
      total: data.total.present ? data.total.value : this.total,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      estimatedTime: data.estimatedTime.present
          ? data.estimatedTime.value
          : this.estimatedTime,
      specialInstructions: data.specialInstructions.present
          ? data.specialInstructions.value
          : this.specialInstructions,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbOrder(')
          ..write('id: $id, ')
          ..write('queueNumber: $queueNumber, ')
          ..write('channel: $channel, ')
          ..write('orderType: $orderType, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('status: $status, ')
          ..write('customerName: $customerName, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('subtotal: $subtotal, ')
          ..write('tax: $tax, ')
          ..write('total: $total, ')
          ..write('createdAt: $createdAt, ')
          ..write('estimatedTime: $estimatedTime, ')
          ..write('specialInstructions: $specialInstructions')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      queueNumber,
      channel,
      orderType,
      paymentStatus,
      status,
      customerName,
      customerPhone,
      subtotal,
      tax,
      total,
      createdAt,
      estimatedTime,
      specialInstructions);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbOrder &&
          other.id == this.id &&
          other.queueNumber == this.queueNumber &&
          other.channel == this.channel &&
          other.orderType == this.orderType &&
          other.paymentStatus == this.paymentStatus &&
          other.status == this.status &&
          other.customerName == this.customerName &&
          other.customerPhone == this.customerPhone &&
          other.subtotal == this.subtotal &&
          other.tax == this.tax &&
          other.total == this.total &&
          other.createdAt == this.createdAt &&
          other.estimatedTime == this.estimatedTime &&
          other.specialInstructions == this.specialInstructions);
}

class DbOrdersCompanion extends UpdateCompanion<DbOrder> {
  final Value<String> id;
  final Value<String> queueNumber;
  final Value<String> channel;
  final Value<String> orderType;
  final Value<String> paymentStatus;
  final Value<String> status;
  final Value<String> customerName;
  final Value<String?> customerPhone;
  final Value<double> subtotal;
  final Value<double> tax;
  final Value<double> total;
  final Value<DateTime> createdAt;
  final Value<DateTime> estimatedTime;
  final Value<String?> specialInstructions;
  final Value<int> rowid;
  const DbOrdersCompanion({
    this.id = const Value.absent(),
    this.queueNumber = const Value.absent(),
    this.channel = const Value.absent(),
    this.orderType = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.status = const Value.absent(),
    this.customerName = const Value.absent(),
    this.customerPhone = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.tax = const Value.absent(),
    this.total = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.estimatedTime = const Value.absent(),
    this.specialInstructions = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DbOrdersCompanion.insert({
    required String id,
    required String queueNumber,
    required String channel,
    required String orderType,
    required String paymentStatus,
    required String status,
    required String customerName,
    this.customerPhone = const Value.absent(),
    required double subtotal,
    required double tax,
    required double total,
    required DateTime createdAt,
    required DateTime estimatedTime,
    this.specialInstructions = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        queueNumber = Value(queueNumber),
        channel = Value(channel),
        orderType = Value(orderType),
        paymentStatus = Value(paymentStatus),
        status = Value(status),
        customerName = Value(customerName),
        subtotal = Value(subtotal),
        tax = Value(tax),
        total = Value(total),
        createdAt = Value(createdAt),
        estimatedTime = Value(estimatedTime);
  static Insertable<DbOrder> custom({
    Expression<String>? id,
    Expression<String>? queueNumber,
    Expression<String>? channel,
    Expression<String>? orderType,
    Expression<String>? paymentStatus,
    Expression<String>? status,
    Expression<String>? customerName,
    Expression<String>? customerPhone,
    Expression<double>? subtotal,
    Expression<double>? tax,
    Expression<double>? total,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? estimatedTime,
    Expression<String>? specialInstructions,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (queueNumber != null) 'queue_number': queueNumber,
      if (channel != null) 'channel': channel,
      if (orderType != null) 'order_type': orderType,
      if (paymentStatus != null) 'payment_status': paymentStatus,
      if (status != null) 'status': status,
      if (customerName != null) 'customer_name': customerName,
      if (customerPhone != null) 'customer_phone': customerPhone,
      if (subtotal != null) 'subtotal': subtotal,
      if (tax != null) 'tax': tax,
      if (total != null) 'total': total,
      if (createdAt != null) 'created_at': createdAt,
      if (estimatedTime != null) 'estimated_time': estimatedTime,
      if (specialInstructions != null)
        'special_instructions': specialInstructions,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DbOrdersCompanion copyWith(
      {Value<String>? id,
      Value<String>? queueNumber,
      Value<String>? channel,
      Value<String>? orderType,
      Value<String>? paymentStatus,
      Value<String>? status,
      Value<String>? customerName,
      Value<String?>? customerPhone,
      Value<double>? subtotal,
      Value<double>? tax,
      Value<double>? total,
      Value<DateTime>? createdAt,
      Value<DateTime>? estimatedTime,
      Value<String?>? specialInstructions,
      Value<int>? rowid}) {
    return DbOrdersCompanion(
      id: id ?? this.id,
      queueNumber: queueNumber ?? this.queueNumber,
      channel: channel ?? this.channel,
      orderType: orderType ?? this.orderType,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (queueNumber.present) {
      map['queue_number'] = Variable<String>(queueNumber.value);
    }
    if (channel.present) {
      map['channel'] = Variable<String>(channel.value);
    }
    if (orderType.present) {
      map['order_type'] = Variable<String>(orderType.value);
    }
    if (paymentStatus.present) {
      map['payment_status'] = Variable<String>(paymentStatus.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (customerPhone.present) {
      map['customer_phone'] = Variable<String>(customerPhone.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (tax.present) {
      map['tax'] = Variable<double>(tax.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (estimatedTime.present) {
      map['estimated_time'] = Variable<DateTime>(estimatedTime.value);
    }
    if (specialInstructions.present) {
      map['special_instructions'] = Variable<String>(specialInstructions.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbOrdersCompanion(')
          ..write('id: $id, ')
          ..write('queueNumber: $queueNumber, ')
          ..write('channel: $channel, ')
          ..write('orderType: $orderType, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('status: $status, ')
          ..write('customerName: $customerName, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('subtotal: $subtotal, ')
          ..write('tax: $tax, ')
          ..write('total: $total, ')
          ..write('createdAt: $createdAt, ')
          ..write('estimatedTime: $estimatedTime, ')
          ..write('specialInstructions: $specialInstructions, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DbOrderItemsTable extends DbOrderItems
    with TableInfo<$DbOrderItemsTable, DbOrderItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbOrderItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _orderIdMeta =
      const VerificationMeta('orderId');
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
      'order_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
      'price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _modifiersJsonMeta =
      const VerificationMeta('modifiersJson');
  @override
  late final GeneratedColumn<String> modifiersJson = GeneratedColumn<String>(
      'modifiers_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _instructionsMeta =
      const VerificationMeta('instructions');
  @override
  late final GeneratedColumn<String> instructions = GeneratedColumn<String>(
      'instructions', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, orderId, name, quantity, price, modifiersJson, instructions];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_order_items';
  @override
  VerificationContext validateIntegrity(Insertable<DbOrderItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('order_id')) {
      context.handle(_orderIdMeta,
          orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta));
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('modifiers_json')) {
      context.handle(
          _modifiersJsonMeta,
          modifiersJson.isAcceptableOrUnknown(
              data['modifiers_json']!, _modifiersJsonMeta));
    }
    if (data.containsKey('instructions')) {
      context.handle(
          _instructionsMeta,
          instructions.isAcceptableOrUnknown(
              data['instructions']!, _instructionsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbOrderItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbOrderItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      orderId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}order_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price'])!,
      modifiersJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}modifiers_json']),
      instructions: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}instructions']),
    );
  }

  @override
  $DbOrderItemsTable createAlias(String alias) {
    return $DbOrderItemsTable(attachedDatabase, alias);
  }
}

class DbOrderItem extends DataClass implements Insertable<DbOrderItem> {
  final int id;

  /// Foreign key to [DbOrders.id].
  final String orderId;
  final String name;
  final int quantity;
  final double price;

  /// JSON-encoded list of modifier lines ("Category: Selection").
  final String? modifiersJson;

  /// Item-level instructions.
  final String? instructions;
  const DbOrderItem(
      {required this.id,
      required this.orderId,
      required this.name,
      required this.quantity,
      required this.price,
      this.modifiersJson,
      this.instructions});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['order_id'] = Variable<String>(orderId);
    map['name'] = Variable<String>(name);
    map['quantity'] = Variable<int>(quantity);
    map['price'] = Variable<double>(price);
    if (!nullToAbsent || modifiersJson != null) {
      map['modifiers_json'] = Variable<String>(modifiersJson);
    }
    if (!nullToAbsent || instructions != null) {
      map['instructions'] = Variable<String>(instructions);
    }
    return map;
  }

  DbOrderItemsCompanion toCompanion(bool nullToAbsent) {
    return DbOrderItemsCompanion(
      id: Value(id),
      orderId: Value(orderId),
      name: Value(name),
      quantity: Value(quantity),
      price: Value(price),
      modifiersJson: modifiersJson == null && nullToAbsent
          ? const Value.absent()
          : Value(modifiersJson),
      instructions: instructions == null && nullToAbsent
          ? const Value.absent()
          : Value(instructions),
    );
  }

  factory DbOrderItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbOrderItem(
      id: serializer.fromJson<int>(json['id']),
      orderId: serializer.fromJson<String>(json['orderId']),
      name: serializer.fromJson<String>(json['name']),
      quantity: serializer.fromJson<int>(json['quantity']),
      price: serializer.fromJson<double>(json['price']),
      modifiersJson: serializer.fromJson<String?>(json['modifiersJson']),
      instructions: serializer.fromJson<String?>(json['instructions']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'orderId': serializer.toJson<String>(orderId),
      'name': serializer.toJson<String>(name),
      'quantity': serializer.toJson<int>(quantity),
      'price': serializer.toJson<double>(price),
      'modifiersJson': serializer.toJson<String?>(modifiersJson),
      'instructions': serializer.toJson<String?>(instructions),
    };
  }

  DbOrderItem copyWith(
          {int? id,
          String? orderId,
          String? name,
          int? quantity,
          double? price,
          Value<String?> modifiersJson = const Value.absent(),
          Value<String?> instructions = const Value.absent()}) =>
      DbOrderItem(
        id: id ?? this.id,
        orderId: orderId ?? this.orderId,
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        price: price ?? this.price,
        modifiersJson:
            modifiersJson.present ? modifiersJson.value : this.modifiersJson,
        instructions:
            instructions.present ? instructions.value : this.instructions,
      );
  DbOrderItem copyWithCompanion(DbOrderItemsCompanion data) {
    return DbOrderItem(
      id: data.id.present ? data.id.value : this.id,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      name: data.name.present ? data.name.value : this.name,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      price: data.price.present ? data.price.value : this.price,
      modifiersJson: data.modifiersJson.present
          ? data.modifiersJson.value
          : this.modifiersJson,
      instructions: data.instructions.present
          ? data.instructions.value
          : this.instructions,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbOrderItem(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('price: $price, ')
          ..write('modifiersJson: $modifiersJson, ')
          ..write('instructions: $instructions')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, orderId, name, quantity, price, modifiersJson, instructions);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbOrderItem &&
          other.id == this.id &&
          other.orderId == this.orderId &&
          other.name == this.name &&
          other.quantity == this.quantity &&
          other.price == this.price &&
          other.modifiersJson == this.modifiersJson &&
          other.instructions == this.instructions);
}

class DbOrderItemsCompanion extends UpdateCompanion<DbOrderItem> {
  final Value<int> id;
  final Value<String> orderId;
  final Value<String> name;
  final Value<int> quantity;
  final Value<double> price;
  final Value<String?> modifiersJson;
  final Value<String?> instructions;
  const DbOrderItemsCompanion({
    this.id = const Value.absent(),
    this.orderId = const Value.absent(),
    this.name = const Value.absent(),
    this.quantity = const Value.absent(),
    this.price = const Value.absent(),
    this.modifiersJson = const Value.absent(),
    this.instructions = const Value.absent(),
  });
  DbOrderItemsCompanion.insert({
    this.id = const Value.absent(),
    required String orderId,
    required String name,
    required int quantity,
    required double price,
    this.modifiersJson = const Value.absent(),
    this.instructions = const Value.absent(),
  })  : orderId = Value(orderId),
        name = Value(name),
        quantity = Value(quantity),
        price = Value(price);
  static Insertable<DbOrderItem> custom({
    Expression<int>? id,
    Expression<String>? orderId,
    Expression<String>? name,
    Expression<int>? quantity,
    Expression<double>? price,
    Expression<String>? modifiersJson,
    Expression<String>? instructions,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      if (name != null) 'name': name,
      if (quantity != null) 'quantity': quantity,
      if (price != null) 'price': price,
      if (modifiersJson != null) 'modifiers_json': modifiersJson,
      if (instructions != null) 'instructions': instructions,
    });
  }

  DbOrderItemsCompanion copyWith(
      {Value<int>? id,
      Value<String>? orderId,
      Value<String>? name,
      Value<int>? quantity,
      Value<double>? price,
      Value<String?>? modifiersJson,
      Value<String?>? instructions}) {
    return DbOrderItemsCompanion(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      modifiersJson: modifiersJson ?? this.modifiersJson,
      instructions: instructions ?? this.instructions,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (modifiersJson.present) {
      map['modifiers_json'] = Variable<String>(modifiersJson.value);
    }
    if (instructions.present) {
      map['instructions'] = Variable<String>(instructions.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbOrderItemsCompanion(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('price: $price, ')
          ..write('modifiersJson: $modifiersJson, ')
          ..write('instructions: $instructions')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxEntriesTable extends SyncOutboxEntries
    with TableInfo<$SyncOutboxEntriesTable, SyncOutboxEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
      'method', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
      'path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bodyJsonMeta =
      const VerificationMeta('bodyJson');
  @override
  late final GeneratedColumn<String> bodyJson = GeneratedColumn<String>(
      'body_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _correlationIdMeta =
      const VerificationMeta('correlationId');
  @override
  late final GeneratedColumn<String> correlationId = GeneratedColumn<String>(
      'correlation_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _nextRetryAtMeta =
      const VerificationMeta('nextRetryAt');
  @override
  late final GeneratedColumn<DateTime> nextRetryAt = GeneratedColumn<DateTime>(
      'next_retry_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        type,
        method,
        path,
        bodyJson,
        correlationId,
        status,
        retryCount,
        nextRetryAt,
        lastError,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox_entries';
  @override
  VerificationContext validateIntegrity(Insertable<SyncOutboxEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('method')) {
      context.handle(_methodMeta,
          method.isAcceptableOrUnknown(data['method']!, _methodMeta));
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
          _pathMeta, path.isAcceptableOrUnknown(data['path']!, _pathMeta));
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('body_json')) {
      context.handle(_bodyJsonMeta,
          bodyJson.isAcceptableOrUnknown(data['body_json']!, _bodyJsonMeta));
    }
    if (data.containsKey('correlation_id')) {
      context.handle(
          _correlationIdMeta,
          correlationId.isAcceptableOrUnknown(
              data['correlation_id']!, _correlationIdMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('next_retry_at')) {
      context.handle(
          _nextRetryAtMeta,
          nextRetryAt.isAcceptableOrUnknown(
              data['next_retry_at']!, _nextRetryAtMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncOutboxEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      method: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}method'])!,
      path: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}path'])!,
      bodyJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body_json']),
      correlationId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}correlation_id']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      nextRetryAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_retry_at'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SyncOutboxEntriesTable createAlias(String alias) {
    return $SyncOutboxEntriesTable(attachedDatabase, alias);
  }
}

class SyncOutboxEntry extends DataClass implements Insertable<SyncOutboxEntry> {
  final int id;

  /// Logical type of mutation, e.g. 'book_order', 'process_payment'.
  final String type;

  /// HTTP method to use when replaying (GET/POST/PATCH/etc.).
  final String method;

  /// Relative path for ApiClient, e.g. 'orders/book-order'.
  final String path;

  /// JSON-encoded request body (if any).
  final String? bodyJson;

  /// Optional idempotency/correlation id used to de-duplicate on server.
  final String? correlationId;

  /// Current status: 'pending', 'in_progress', 'failed', 'completed'.
  final String status;

  /// Number of retries attempted so far.
  final int retryCount;

  /// Earliest time at which this entry may be retried.
  final DateTime nextRetryAt;

  /// Last error message, if any.
  final String? lastError;

  /// When this entry was created.
  final DateTime createdAt;

  /// When this entry was last updated.
  final DateTime updatedAt;
  const SyncOutboxEntry(
      {required this.id,
      required this.type,
      required this.method,
      required this.path,
      this.bodyJson,
      this.correlationId,
      required this.status,
      required this.retryCount,
      required this.nextRetryAt,
      this.lastError,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['method'] = Variable<String>(method);
    map['path'] = Variable<String>(path);
    if (!nullToAbsent || bodyJson != null) {
      map['body_json'] = Variable<String>(bodyJson);
    }
    if (!nullToAbsent || correlationId != null) {
      map['correlation_id'] = Variable<String>(correlationId);
    }
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    map['next_retry_at'] = Variable<DateTime>(nextRetryAt);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SyncOutboxEntriesCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxEntriesCompanion(
      id: Value(id),
      type: Value(type),
      method: Value(method),
      path: Value(path),
      bodyJson: bodyJson == null && nullToAbsent
          ? const Value.absent()
          : Value(bodyJson),
      correlationId: correlationId == null && nullToAbsent
          ? const Value.absent()
          : Value(correlationId),
      status: Value(status),
      retryCount: Value(retryCount),
      nextRetryAt: Value(nextRetryAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncOutboxEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxEntry(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      method: serializer.fromJson<String>(json['method']),
      path: serializer.fromJson<String>(json['path']),
      bodyJson: serializer.fromJson<String?>(json['bodyJson']),
      correlationId: serializer.fromJson<String?>(json['correlationId']),
      status: serializer.fromJson<String>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      nextRetryAt: serializer.fromJson<DateTime>(json['nextRetryAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'method': serializer.toJson<String>(method),
      'path': serializer.toJson<String>(path),
      'bodyJson': serializer.toJson<String?>(bodyJson),
      'correlationId': serializer.toJson<String?>(correlationId),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'nextRetryAt': serializer.toJson<DateTime>(nextRetryAt),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SyncOutboxEntry copyWith(
          {int? id,
          String? type,
          String? method,
          String? path,
          Value<String?> bodyJson = const Value.absent(),
          Value<String?> correlationId = const Value.absent(),
          String? status,
          int? retryCount,
          DateTime? nextRetryAt,
          Value<String?> lastError = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      SyncOutboxEntry(
        id: id ?? this.id,
        type: type ?? this.type,
        method: method ?? this.method,
        path: path ?? this.path,
        bodyJson: bodyJson.present ? bodyJson.value : this.bodyJson,
        correlationId:
            correlationId.present ? correlationId.value : this.correlationId,
        status: status ?? this.status,
        retryCount: retryCount ?? this.retryCount,
        nextRetryAt: nextRetryAt ?? this.nextRetryAt,
        lastError: lastError.present ? lastError.value : this.lastError,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SyncOutboxEntry copyWithCompanion(SyncOutboxEntriesCompanion data) {
    return SyncOutboxEntry(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      method: data.method.present ? data.method.value : this.method,
      path: data.path.present ? data.path.value : this.path,
      bodyJson: data.bodyJson.present ? data.bodyJson.value : this.bodyJson,
      correlationId: data.correlationId.present
          ? data.correlationId.value
          : this.correlationId,
      status: data.status.present ? data.status.value : this.status,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      nextRetryAt:
          data.nextRetryAt.present ? data.nextRetryAt.value : this.nextRetryAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxEntry(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('method: $method, ')
          ..write('path: $path, ')
          ..write('bodyJson: $bodyJson, ')
          ..write('correlationId: $correlationId, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      type,
      method,
      path,
      bodyJson,
      correlationId,
      status,
      retryCount,
      nextRetryAt,
      lastError,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxEntry &&
          other.id == this.id &&
          other.type == this.type &&
          other.method == this.method &&
          other.path == this.path &&
          other.bodyJson == this.bodyJson &&
          other.correlationId == this.correlationId &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.nextRetryAt == this.nextRetryAt &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SyncOutboxEntriesCompanion extends UpdateCompanion<SyncOutboxEntry> {
  final Value<int> id;
  final Value<String> type;
  final Value<String> method;
  final Value<String> path;
  final Value<String?> bodyJson;
  final Value<String?> correlationId;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<DateTime> nextRetryAt;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const SyncOutboxEntriesCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.method = const Value.absent(),
    this.path = const Value.absent(),
    this.bodyJson = const Value.absent(),
    this.correlationId = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SyncOutboxEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required String method,
    required String path,
    this.bodyJson = const Value.absent(),
    this.correlationId = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : type = Value(type),
        method = Value(method),
        path = Value(path);
  static Insertable<SyncOutboxEntry> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? method,
    Expression<String>? path,
    Expression<String>? bodyJson,
    Expression<String>? correlationId,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<DateTime>? nextRetryAt,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (method != null) 'method': method,
      if (path != null) 'path': path,
      if (bodyJson != null) 'body_json': bodyJson,
      if (correlationId != null) 'correlation_id': correlationId,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (nextRetryAt != null) 'next_retry_at': nextRetryAt,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SyncOutboxEntriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? type,
      Value<String>? method,
      Value<String>? path,
      Value<String?>? bodyJson,
      Value<String?>? correlationId,
      Value<String>? status,
      Value<int>? retryCount,
      Value<DateTime>? nextRetryAt,
      Value<String?>? lastError,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return SyncOutboxEntriesCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      method: method ?? this.method,
      path: path ?? this.path,
      bodyJson: bodyJson ?? this.bodyJson,
      correlationId: correlationId ?? this.correlationId,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (bodyJson.present) {
      map['body_json'] = Variable<String>(bodyJson.value);
    }
    if (correlationId.present) {
      map['correlation_id'] = Variable<String>(correlationId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (nextRetryAt.present) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxEntriesCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('method: $method, ')
          ..write('path: $path, ')
          ..write('bodyJson: $bodyJson, ')
          ..write('correlationId: $correlationId, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$PosDatabase extends GeneratedDatabase {
  _$PosDatabase(QueryExecutor e) : super(e);
  $PosDatabaseManager get managers => $PosDatabaseManager(this);
  late final $MenuSnapshotsTable menuSnapshots = $MenuSnapshotsTable(this);
  late final $DbOrdersTable dbOrders = $DbOrdersTable(this);
  late final $DbOrderItemsTable dbOrderItems = $DbOrderItemsTable(this);
  late final $SyncOutboxEntriesTable syncOutboxEntries =
      $SyncOutboxEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [menuSnapshots, dbOrders, dbOrderItems, syncOutboxEntries];
}

typedef $$MenuSnapshotsTableCreateCompanionBuilder = MenuSnapshotsCompanion
    Function({
  required String vendorUuid,
  required String branchUuid,
  required String payloadJson,
  Value<String?> version,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$MenuSnapshotsTableUpdateCompanionBuilder = MenuSnapshotsCompanion
    Function({
  Value<String> vendorUuid,
  Value<String> branchUuid,
  Value<String> payloadJson,
  Value<String?> version,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$MenuSnapshotsTableFilterComposer
    extends Composer<_$PosDatabase, $MenuSnapshotsTable> {
  $$MenuSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get vendorUuid => $composableBuilder(
      column: $table.vendorUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get branchUuid => $composableBuilder(
      column: $table.branchUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$MenuSnapshotsTableOrderingComposer
    extends Composer<_$PosDatabase, $MenuSnapshotsTable> {
  $$MenuSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get vendorUuid => $composableBuilder(
      column: $table.vendorUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get branchUuid => $composableBuilder(
      column: $table.branchUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$MenuSnapshotsTableAnnotationComposer
    extends Composer<_$PosDatabase, $MenuSnapshotsTable> {
  $$MenuSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get vendorUuid => $composableBuilder(
      column: $table.vendorUuid, builder: (column) => column);

  GeneratedColumn<String> get branchUuid => $composableBuilder(
      column: $table.branchUuid, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MenuSnapshotsTableTableManager extends RootTableManager<
    _$PosDatabase,
    $MenuSnapshotsTable,
    MenuSnapshot,
    $$MenuSnapshotsTableFilterComposer,
    $$MenuSnapshotsTableOrderingComposer,
    $$MenuSnapshotsTableAnnotationComposer,
    $$MenuSnapshotsTableCreateCompanionBuilder,
    $$MenuSnapshotsTableUpdateCompanionBuilder,
    (
      MenuSnapshot,
      BaseReferences<_$PosDatabase, $MenuSnapshotsTable, MenuSnapshot>
    ),
    MenuSnapshot,
    PrefetchHooks Function()> {
  $$MenuSnapshotsTableTableManager(_$PosDatabase db, $MenuSnapshotsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MenuSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MenuSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MenuSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> vendorUuid = const Value.absent(),
            Value<String> branchUuid = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<String?> version = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MenuSnapshotsCompanion(
            vendorUuid: vendorUuid,
            branchUuid: branchUuid,
            payloadJson: payloadJson,
            version: version,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String vendorUuid,
            required String branchUuid,
            required String payloadJson,
            Value<String?> version = const Value.absent(),
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              MenuSnapshotsCompanion.insert(
            vendorUuid: vendorUuid,
            branchUuid: branchUuid,
            payloadJson: payloadJson,
            version: version,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MenuSnapshotsTableProcessedTableManager = ProcessedTableManager<
    _$PosDatabase,
    $MenuSnapshotsTable,
    MenuSnapshot,
    $$MenuSnapshotsTableFilterComposer,
    $$MenuSnapshotsTableOrderingComposer,
    $$MenuSnapshotsTableAnnotationComposer,
    $$MenuSnapshotsTableCreateCompanionBuilder,
    $$MenuSnapshotsTableUpdateCompanionBuilder,
    (
      MenuSnapshot,
      BaseReferences<_$PosDatabase, $MenuSnapshotsTable, MenuSnapshot>
    ),
    MenuSnapshot,
    PrefetchHooks Function()>;
typedef $$DbOrdersTableCreateCompanionBuilder = DbOrdersCompanion Function({
  required String id,
  required String queueNumber,
  required String channel,
  required String orderType,
  required String paymentStatus,
  required String status,
  required String customerName,
  Value<String?> customerPhone,
  required double subtotal,
  required double tax,
  required double total,
  required DateTime createdAt,
  required DateTime estimatedTime,
  Value<String?> specialInstructions,
  Value<int> rowid,
});
typedef $$DbOrdersTableUpdateCompanionBuilder = DbOrdersCompanion Function({
  Value<String> id,
  Value<String> queueNumber,
  Value<String> channel,
  Value<String> orderType,
  Value<String> paymentStatus,
  Value<String> status,
  Value<String> customerName,
  Value<String?> customerPhone,
  Value<double> subtotal,
  Value<double> tax,
  Value<double> total,
  Value<DateTime> createdAt,
  Value<DateTime> estimatedTime,
  Value<String?> specialInstructions,
  Value<int> rowid,
});

class $$DbOrdersTableFilterComposer
    extends Composer<_$PosDatabase, $DbOrdersTable> {
  $$DbOrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get queueNumber => $composableBuilder(
      column: $table.queueNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get channel => $composableBuilder(
      column: $table.channel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get orderType => $composableBuilder(
      column: $table.orderType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentStatus => $composableBuilder(
      column: $table.paymentStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerPhone => $composableBuilder(
      column: $table.customerPhone, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get tax => $composableBuilder(
      column: $table.tax, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get estimatedTime => $composableBuilder(
      column: $table.estimatedTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get specialInstructions => $composableBuilder(
      column: $table.specialInstructions,
      builder: (column) => ColumnFilters(column));
}

class $$DbOrdersTableOrderingComposer
    extends Composer<_$PosDatabase, $DbOrdersTable> {
  $$DbOrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get queueNumber => $composableBuilder(
      column: $table.queueNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get channel => $composableBuilder(
      column: $table.channel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get orderType => $composableBuilder(
      column: $table.orderType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentStatus => $composableBuilder(
      column: $table.paymentStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerName => $composableBuilder(
      column: $table.customerName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerPhone => $composableBuilder(
      column: $table.customerPhone,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get tax => $composableBuilder(
      column: $table.tax, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get estimatedTime => $composableBuilder(
      column: $table.estimatedTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get specialInstructions => $composableBuilder(
      column: $table.specialInstructions,
      builder: (column) => ColumnOrderings(column));
}

class $$DbOrdersTableAnnotationComposer
    extends Composer<_$PosDatabase, $DbOrdersTable> {
  $$DbOrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get queueNumber => $composableBuilder(
      column: $table.queueNumber, builder: (column) => column);

  GeneratedColumn<String> get channel =>
      $composableBuilder(column: $table.channel, builder: (column) => column);

  GeneratedColumn<String> get orderType =>
      $composableBuilder(column: $table.orderType, builder: (column) => column);

  GeneratedColumn<String> get paymentStatus => $composableBuilder(
      column: $table.paymentStatus, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => column);

  GeneratedColumn<String> get customerPhone => $composableBuilder(
      column: $table.customerPhone, builder: (column) => column);

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<double> get tax =>
      $composableBuilder(column: $table.tax, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get estimatedTime => $composableBuilder(
      column: $table.estimatedTime, builder: (column) => column);

  GeneratedColumn<String> get specialInstructions => $composableBuilder(
      column: $table.specialInstructions, builder: (column) => column);
}

class $$DbOrdersTableTableManager extends RootTableManager<
    _$PosDatabase,
    $DbOrdersTable,
    DbOrder,
    $$DbOrdersTableFilterComposer,
    $$DbOrdersTableOrderingComposer,
    $$DbOrdersTableAnnotationComposer,
    $$DbOrdersTableCreateCompanionBuilder,
    $$DbOrdersTableUpdateCompanionBuilder,
    (DbOrder, BaseReferences<_$PosDatabase, $DbOrdersTable, DbOrder>),
    DbOrder,
    PrefetchHooks Function()> {
  $$DbOrdersTableTableManager(_$PosDatabase db, $DbOrdersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbOrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbOrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbOrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> queueNumber = const Value.absent(),
            Value<String> channel = const Value.absent(),
            Value<String> orderType = const Value.absent(),
            Value<String> paymentStatus = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> customerName = const Value.absent(),
            Value<String?> customerPhone = const Value.absent(),
            Value<double> subtotal = const Value.absent(),
            Value<double> tax = const Value.absent(),
            Value<double> total = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> estimatedTime = const Value.absent(),
            Value<String?> specialInstructions = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DbOrdersCompanion(
            id: id,
            queueNumber: queueNumber,
            channel: channel,
            orderType: orderType,
            paymentStatus: paymentStatus,
            status: status,
            customerName: customerName,
            customerPhone: customerPhone,
            subtotal: subtotal,
            tax: tax,
            total: total,
            createdAt: createdAt,
            estimatedTime: estimatedTime,
            specialInstructions: specialInstructions,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String queueNumber,
            required String channel,
            required String orderType,
            required String paymentStatus,
            required String status,
            required String customerName,
            Value<String?> customerPhone = const Value.absent(),
            required double subtotal,
            required double tax,
            required double total,
            required DateTime createdAt,
            required DateTime estimatedTime,
            Value<String?> specialInstructions = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DbOrdersCompanion.insert(
            id: id,
            queueNumber: queueNumber,
            channel: channel,
            orderType: orderType,
            paymentStatus: paymentStatus,
            status: status,
            customerName: customerName,
            customerPhone: customerPhone,
            subtotal: subtotal,
            tax: tax,
            total: total,
            createdAt: createdAt,
            estimatedTime: estimatedTime,
            specialInstructions: specialInstructions,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DbOrdersTableProcessedTableManager = ProcessedTableManager<
    _$PosDatabase,
    $DbOrdersTable,
    DbOrder,
    $$DbOrdersTableFilterComposer,
    $$DbOrdersTableOrderingComposer,
    $$DbOrdersTableAnnotationComposer,
    $$DbOrdersTableCreateCompanionBuilder,
    $$DbOrdersTableUpdateCompanionBuilder,
    (DbOrder, BaseReferences<_$PosDatabase, $DbOrdersTable, DbOrder>),
    DbOrder,
    PrefetchHooks Function()>;
typedef $$DbOrderItemsTableCreateCompanionBuilder = DbOrderItemsCompanion
    Function({
  Value<int> id,
  required String orderId,
  required String name,
  required int quantity,
  required double price,
  Value<String?> modifiersJson,
  Value<String?> instructions,
});
typedef $$DbOrderItemsTableUpdateCompanionBuilder = DbOrderItemsCompanion
    Function({
  Value<int> id,
  Value<String> orderId,
  Value<String> name,
  Value<int> quantity,
  Value<double> price,
  Value<String?> modifiersJson,
  Value<String?> instructions,
});

class $$DbOrderItemsTableFilterComposer
    extends Composer<_$PosDatabase, $DbOrderItemsTable> {
  $$DbOrderItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get orderId => $composableBuilder(
      column: $table.orderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get modifiersJson => $composableBuilder(
      column: $table.modifiersJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get instructions => $composableBuilder(
      column: $table.instructions, builder: (column) => ColumnFilters(column));
}

class $$DbOrderItemsTableOrderingComposer
    extends Composer<_$PosDatabase, $DbOrderItemsTable> {
  $$DbOrderItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get orderId => $composableBuilder(
      column: $table.orderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modifiersJson => $composableBuilder(
      column: $table.modifiersJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get instructions => $composableBuilder(
      column: $table.instructions,
      builder: (column) => ColumnOrderings(column));
}

class $$DbOrderItemsTableAnnotationComposer
    extends Composer<_$PosDatabase, $DbOrderItemsTable> {
  $$DbOrderItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get orderId =>
      $composableBuilder(column: $table.orderId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<String> get modifiersJson => $composableBuilder(
      column: $table.modifiersJson, builder: (column) => column);

  GeneratedColumn<String> get instructions => $composableBuilder(
      column: $table.instructions, builder: (column) => column);
}

class $$DbOrderItemsTableTableManager extends RootTableManager<
    _$PosDatabase,
    $DbOrderItemsTable,
    DbOrderItem,
    $$DbOrderItemsTableFilterComposer,
    $$DbOrderItemsTableOrderingComposer,
    $$DbOrderItemsTableAnnotationComposer,
    $$DbOrderItemsTableCreateCompanionBuilder,
    $$DbOrderItemsTableUpdateCompanionBuilder,
    (
      DbOrderItem,
      BaseReferences<_$PosDatabase, $DbOrderItemsTable, DbOrderItem>
    ),
    DbOrderItem,
    PrefetchHooks Function()> {
  $$DbOrderItemsTableTableManager(_$PosDatabase db, $DbOrderItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbOrderItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbOrderItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbOrderItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> orderId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<double> price = const Value.absent(),
            Value<String?> modifiersJson = const Value.absent(),
            Value<String?> instructions = const Value.absent(),
          }) =>
              DbOrderItemsCompanion(
            id: id,
            orderId: orderId,
            name: name,
            quantity: quantity,
            price: price,
            modifiersJson: modifiersJson,
            instructions: instructions,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String orderId,
            required String name,
            required int quantity,
            required double price,
            Value<String?> modifiersJson = const Value.absent(),
            Value<String?> instructions = const Value.absent(),
          }) =>
              DbOrderItemsCompanion.insert(
            id: id,
            orderId: orderId,
            name: name,
            quantity: quantity,
            price: price,
            modifiersJson: modifiersJson,
            instructions: instructions,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DbOrderItemsTableProcessedTableManager = ProcessedTableManager<
    _$PosDatabase,
    $DbOrderItemsTable,
    DbOrderItem,
    $$DbOrderItemsTableFilterComposer,
    $$DbOrderItemsTableOrderingComposer,
    $$DbOrderItemsTableAnnotationComposer,
    $$DbOrderItemsTableCreateCompanionBuilder,
    $$DbOrderItemsTableUpdateCompanionBuilder,
    (
      DbOrderItem,
      BaseReferences<_$PosDatabase, $DbOrderItemsTable, DbOrderItem>
    ),
    DbOrderItem,
    PrefetchHooks Function()>;
typedef $$SyncOutboxEntriesTableCreateCompanionBuilder
    = SyncOutboxEntriesCompanion Function({
  Value<int> id,
  required String type,
  required String method,
  required String path,
  Value<String?> bodyJson,
  Value<String?> correlationId,
  Value<String> status,
  Value<int> retryCount,
  Value<DateTime> nextRetryAt,
  Value<String?> lastError,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$SyncOutboxEntriesTableUpdateCompanionBuilder
    = SyncOutboxEntriesCompanion Function({
  Value<int> id,
  Value<String> type,
  Value<String> method,
  Value<String> path,
  Value<String?> bodyJson,
  Value<String?> correlationId,
  Value<String> status,
  Value<int> retryCount,
  Value<DateTime> nextRetryAt,
  Value<String?> lastError,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$SyncOutboxEntriesTableFilterComposer
    extends Composer<_$PosDatabase, $SyncOutboxEntriesTable> {
  $$SyncOutboxEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get path => $composableBuilder(
      column: $table.path, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bodyJson => $composableBuilder(
      column: $table.bodyJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get correlationId => $composableBuilder(
      column: $table.correlationId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextRetryAt => $composableBuilder(
      column: $table.nextRetryAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SyncOutboxEntriesTableOrderingComposer
    extends Composer<_$PosDatabase, $SyncOutboxEntriesTable> {
  $$SyncOutboxEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get path => $composableBuilder(
      column: $table.path, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bodyJson => $composableBuilder(
      column: $table.bodyJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get correlationId => $composableBuilder(
      column: $table.correlationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextRetryAt => $composableBuilder(
      column: $table.nextRetryAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncOutboxEntriesTableAnnotationComposer
    extends Composer<_$PosDatabase, $SyncOutboxEntriesTable> {
  $$SyncOutboxEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get bodyJson =>
      $composableBuilder(column: $table.bodyJson, builder: (column) => column);

  GeneratedColumn<String> get correlationId => $composableBuilder(
      column: $table.correlationId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<DateTime> get nextRetryAt => $composableBuilder(
      column: $table.nextRetryAt, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncOutboxEntriesTableTableManager extends RootTableManager<
    _$PosDatabase,
    $SyncOutboxEntriesTable,
    SyncOutboxEntry,
    $$SyncOutboxEntriesTableFilterComposer,
    $$SyncOutboxEntriesTableOrderingComposer,
    $$SyncOutboxEntriesTableAnnotationComposer,
    $$SyncOutboxEntriesTableCreateCompanionBuilder,
    $$SyncOutboxEntriesTableUpdateCompanionBuilder,
    (
      SyncOutboxEntry,
      BaseReferences<_$PosDatabase, $SyncOutboxEntriesTable, SyncOutboxEntry>
    ),
    SyncOutboxEntry,
    PrefetchHooks Function()> {
  $$SyncOutboxEntriesTableTableManager(
      _$PosDatabase db, $SyncOutboxEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> method = const Value.absent(),
            Value<String> path = const Value.absent(),
            Value<String?> bodyJson = const Value.absent(),
            Value<String?> correlationId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<DateTime> nextRetryAt = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              SyncOutboxEntriesCompanion(
            id: id,
            type: type,
            method: method,
            path: path,
            bodyJson: bodyJson,
            correlationId: correlationId,
            status: status,
            retryCount: retryCount,
            nextRetryAt: nextRetryAt,
            lastError: lastError,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String type,
            required String method,
            required String path,
            Value<String?> bodyJson = const Value.absent(),
            Value<String?> correlationId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<DateTime> nextRetryAt = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              SyncOutboxEntriesCompanion.insert(
            id: id,
            type: type,
            method: method,
            path: path,
            bodyJson: bodyJson,
            correlationId: correlationId,
            status: status,
            retryCount: retryCount,
            nextRetryAt: nextRetryAt,
            lastError: lastError,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncOutboxEntriesTableProcessedTableManager = ProcessedTableManager<
    _$PosDatabase,
    $SyncOutboxEntriesTable,
    SyncOutboxEntry,
    $$SyncOutboxEntriesTableFilterComposer,
    $$SyncOutboxEntriesTableOrderingComposer,
    $$SyncOutboxEntriesTableAnnotationComposer,
    $$SyncOutboxEntriesTableCreateCompanionBuilder,
    $$SyncOutboxEntriesTableUpdateCompanionBuilder,
    (
      SyncOutboxEntry,
      BaseReferences<_$PosDatabase, $SyncOutboxEntriesTable, SyncOutboxEntry>
    ),
    SyncOutboxEntry,
    PrefetchHooks Function()>;

class $PosDatabaseManager {
  final _$PosDatabase _db;
  $PosDatabaseManager(this._db);
  $$MenuSnapshotsTableTableManager get menuSnapshots =>
      $$MenuSnapshotsTableTableManager(_db, _db.menuSnapshots);
  $$DbOrdersTableTableManager get dbOrders =>
      $$DbOrdersTableTableManager(_db, _db.dbOrders);
  $$DbOrderItemsTableTableManager get dbOrderItems =>
      $$DbOrderItemsTableTableManager(_db, _db.dbOrderItems);
  $$SyncOutboxEntriesTableTableManager get syncOutboxEntries =>
      $$SyncOutboxEntriesTableTableManager(_db, _db.syncOutboxEntries);
}
