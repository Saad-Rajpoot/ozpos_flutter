// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cart_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CartItemModel _$CartItemModelFromJson(Map<String, dynamic> json) {
  return _CartItemModel.fromJson(json);
}

/// @nodoc
mixin _$CartItemModel {
  String get lineItemId => throw _privateConstructorUsedError;
  String get itemId => throw _privateConstructorUsedError;
  String get itemName => throw _privateConstructorUsedError;
  String? get itemImage => throw _privateConstructorUsedError;
  double get unitPrice => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  double get totalPrice => throw _privateConstructorUsedError;
  String? get specialInstructions => throw _privateConstructorUsedError;
  List<String> get modifiers => throw _privateConstructorUsedError;
  DateTime get addedAt => throw _privateConstructorUsedError;

  /// Serializes this CartItemModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CartItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CartItemModelCopyWith<CartItemModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CartItemModelCopyWith<$Res> {
  factory $CartItemModelCopyWith(
    CartItemModel value,
    $Res Function(CartItemModel) then,
  ) = _$CartItemModelCopyWithImpl<$Res, CartItemModel>;
  @useResult
  $Res call({
    String lineItemId,
    String itemId,
    String itemName,
    String? itemImage,
    double unitPrice,
    int quantity,
    double totalPrice,
    String? specialInstructions,
    List<String> modifiers,
    DateTime addedAt,
  });
}

/// @nodoc
class _$CartItemModelCopyWithImpl<$Res, $Val extends CartItemModel>
    implements $CartItemModelCopyWith<$Res> {
  _$CartItemModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CartItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lineItemId = null,
    Object? itemId = null,
    Object? itemName = null,
    Object? itemImage = freezed,
    Object? unitPrice = null,
    Object? quantity = null,
    Object? totalPrice = null,
    Object? specialInstructions = freezed,
    Object? modifiers = null,
    Object? addedAt = null,
  }) {
    return _then(
      _value.copyWith(
            lineItemId: null == lineItemId
                ? _value.lineItemId
                : lineItemId // ignore: cast_nullable_to_non_nullable
                      as String,
            itemId: null == itemId
                ? _value.itemId
                : itemId // ignore: cast_nullable_to_non_nullable
                      as String,
            itemName: null == itemName
                ? _value.itemName
                : itemName // ignore: cast_nullable_to_non_nullable
                      as String,
            itemImage: freezed == itemImage
                ? _value.itemImage
                : itemImage // ignore: cast_nullable_to_non_nullable
                      as String?,
            unitPrice: null == unitPrice
                ? _value.unitPrice
                : unitPrice // ignore: cast_nullable_to_non_nullable
                      as double,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as int,
            totalPrice: null == totalPrice
                ? _value.totalPrice
                : totalPrice // ignore: cast_nullable_to_non_nullable
                      as double,
            specialInstructions: freezed == specialInstructions
                ? _value.specialInstructions
                : specialInstructions // ignore: cast_nullable_to_non_nullable
                      as String?,
            modifiers: null == modifiers
                ? _value.modifiers
                : modifiers // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            addedAt: null == addedAt
                ? _value.addedAt
                : addedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CartItemModelImplCopyWith<$Res>
    implements $CartItemModelCopyWith<$Res> {
  factory _$$CartItemModelImplCopyWith(
    _$CartItemModelImpl value,
    $Res Function(_$CartItemModelImpl) then,
  ) = __$$CartItemModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String lineItemId,
    String itemId,
    String itemName,
    String? itemImage,
    double unitPrice,
    int quantity,
    double totalPrice,
    String? specialInstructions,
    List<String> modifiers,
    DateTime addedAt,
  });
}

/// @nodoc
class __$$CartItemModelImplCopyWithImpl<$Res>
    extends _$CartItemModelCopyWithImpl<$Res, _$CartItemModelImpl>
    implements _$$CartItemModelImplCopyWith<$Res> {
  __$$CartItemModelImplCopyWithImpl(
    _$CartItemModelImpl _value,
    $Res Function(_$CartItemModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CartItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lineItemId = null,
    Object? itemId = null,
    Object? itemName = null,
    Object? itemImage = freezed,
    Object? unitPrice = null,
    Object? quantity = null,
    Object? totalPrice = null,
    Object? specialInstructions = freezed,
    Object? modifiers = null,
    Object? addedAt = null,
  }) {
    return _then(
      _$CartItemModelImpl(
        lineItemId: null == lineItemId
            ? _value.lineItemId
            : lineItemId // ignore: cast_nullable_to_non_nullable
                  as String,
        itemId: null == itemId
            ? _value.itemId
            : itemId // ignore: cast_nullable_to_non_nullable
                  as String,
        itemName: null == itemName
            ? _value.itemName
            : itemName // ignore: cast_nullable_to_non_nullable
                  as String,
        itemImage: freezed == itemImage
            ? _value.itemImage
            : itemImage // ignore: cast_nullable_to_non_nullable
                  as String?,
        unitPrice: null == unitPrice
            ? _value.unitPrice
            : unitPrice // ignore: cast_nullable_to_non_nullable
                  as double,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as int,
        totalPrice: null == totalPrice
            ? _value.totalPrice
            : totalPrice // ignore: cast_nullable_to_non_nullable
                  as double,
        specialInstructions: freezed == specialInstructions
            ? _value.specialInstructions
            : specialInstructions // ignore: cast_nullable_to_non_nullable
                  as String?,
        modifiers: null == modifiers
            ? _value._modifiers
            : modifiers // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        addedAt: null == addedAt
            ? _value.addedAt
            : addedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CartItemModelImpl extends _CartItemModel {
  const _$CartItemModelImpl({
    required this.lineItemId,
    required this.itemId,
    required this.itemName,
    this.itemImage,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    this.specialInstructions,
    final List<String> modifiers = const [],
    required this.addedAt,
  }) : _modifiers = modifiers,
       super._();

  factory _$CartItemModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CartItemModelImplFromJson(json);

  @override
  final String lineItemId;
  @override
  final String itemId;
  @override
  final String itemName;
  @override
  final String? itemImage;
  @override
  final double unitPrice;
  @override
  final int quantity;
  @override
  final double totalPrice;
  @override
  final String? specialInstructions;
  final List<String> _modifiers;
  @override
  @JsonKey()
  List<String> get modifiers {
    if (_modifiers is EqualUnmodifiableListView) return _modifiers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_modifiers);
  }

  @override
  final DateTime addedAt;

  @override
  String toString() {
    return 'CartItemModel(lineItemId: $lineItemId, itemId: $itemId, itemName: $itemName, itemImage: $itemImage, unitPrice: $unitPrice, quantity: $quantity, totalPrice: $totalPrice, specialInstructions: $specialInstructions, modifiers: $modifiers, addedAt: $addedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CartItemModelImpl &&
            (identical(other.lineItemId, lineItemId) ||
                other.lineItemId == lineItemId) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.itemImage, itemImage) ||
                other.itemImage == itemImage) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.totalPrice, totalPrice) ||
                other.totalPrice == totalPrice) &&
            (identical(other.specialInstructions, specialInstructions) ||
                other.specialInstructions == specialInstructions) &&
            const DeepCollectionEquality().equals(
              other._modifiers,
              _modifiers,
            ) &&
            (identical(other.addedAt, addedAt) || other.addedAt == addedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    lineItemId,
    itemId,
    itemName,
    itemImage,
    unitPrice,
    quantity,
    totalPrice,
    specialInstructions,
    const DeepCollectionEquality().hash(_modifiers),
    addedAt,
  );

  /// Create a copy of CartItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CartItemModelImplCopyWith<_$CartItemModelImpl> get copyWith =>
      __$$CartItemModelImplCopyWithImpl<_$CartItemModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CartItemModelImplToJson(this);
  }
}

abstract class _CartItemModel extends CartItemModel {
  const factory _CartItemModel({
    required final String lineItemId,
    required final String itemId,
    required final String itemName,
    final String? itemImage,
    required final double unitPrice,
    required final int quantity,
    required final double totalPrice,
    final String? specialInstructions,
    final List<String> modifiers,
    required final DateTime addedAt,
  }) = _$CartItemModelImpl;
  const _CartItemModel._() : super._();

  factory _CartItemModel.fromJson(Map<String, dynamic> json) =
      _$CartItemModelImpl.fromJson;

  @override
  String get lineItemId;
  @override
  String get itemId;
  @override
  String get itemName;
  @override
  String? get itemImage;
  @override
  double get unitPrice;
  @override
  int get quantity;
  @override
  double get totalPrice;
  @override
  String? get specialInstructions;
  @override
  List<String> get modifiers;
  @override
  DateTime get addedAt;

  /// Create a copy of CartItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CartItemModelImplCopyWith<_$CartItemModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
