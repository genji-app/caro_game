// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Bank {

@JsonKey(name: 'bankId') String get bankId;@JsonKey(name: 'publicRss') int get publicRss;@JsonKey(name: 'type') int get type;@JsonKey(name: 'accountName') String? get accountName;@JsonKey(name: 'accountNumber') String? get accountNumber;
/// Create a copy of Bank
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BankCopyWith<Bank> get copyWith => _$BankCopyWithImpl<Bank>(this as Bank, _$identity);

  /// Serializes this Bank to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Bank&&(identical(other.bankId, bankId) || other.bankId == bankId)&&(identical(other.publicRss, publicRss) || other.publicRss == publicRss)&&(identical(other.type, type) || other.type == type)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bankId,publicRss,type,accountName,accountNumber);

@override
String toString() {
  return 'Bank(bankId: $bankId, publicRss: $publicRss, type: $type, accountName: $accountName, accountNumber: $accountNumber)';
}


}

/// @nodoc
abstract mixin class $BankCopyWith<$Res>  {
  factory $BankCopyWith(Bank value, $Res Function(Bank) _then) = _$BankCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'bankId') String bankId,@JsonKey(name: 'publicRss') int publicRss,@JsonKey(name: 'type') int type,@JsonKey(name: 'accountName') String? accountName,@JsonKey(name: 'accountNumber') String? accountNumber
});




}
/// @nodoc
class _$BankCopyWithImpl<$Res>
    implements $BankCopyWith<$Res> {
  _$BankCopyWithImpl(this._self, this._then);

  final Bank _self;
  final $Res Function(Bank) _then;

/// Create a copy of Bank
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bankId = null,Object? publicRss = null,Object? type = null,Object? accountName = freezed,Object? accountNumber = freezed,}) {
  return _then(_self.copyWith(
bankId: null == bankId ? _self.bankId : bankId // ignore: cast_nullable_to_non_nullable
as String,publicRss: null == publicRss ? _self.publicRss : publicRss // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,accountName: freezed == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String?,accountNumber: freezed == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Bank].
extension BankPatterns on Bank {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Bank value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Bank() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Bank value)  $default,){
final _that = this;
switch (_that) {
case _Bank():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Bank value)?  $default,){
final _that = this;
switch (_that) {
case _Bank() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'bankId')  String bankId, @JsonKey(name: 'publicRss')  int publicRss, @JsonKey(name: 'type')  int type, @JsonKey(name: 'accountName')  String? accountName, @JsonKey(name: 'accountNumber')  String? accountNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Bank() when $default != null:
return $default(_that.bankId,_that.publicRss,_that.type,_that.accountName,_that.accountNumber);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'bankId')  String bankId, @JsonKey(name: 'publicRss')  int publicRss, @JsonKey(name: 'type')  int type, @JsonKey(name: 'accountName')  String? accountName, @JsonKey(name: 'accountNumber')  String? accountNumber)  $default,) {final _that = this;
switch (_that) {
case _Bank():
return $default(_that.bankId,_that.publicRss,_that.type,_that.accountName,_that.accountNumber);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'bankId')  String bankId, @JsonKey(name: 'publicRss')  int publicRss, @JsonKey(name: 'type')  int type, @JsonKey(name: 'accountName')  String? accountName, @JsonKey(name: 'accountNumber')  String? accountNumber)?  $default,) {final _that = this;
switch (_that) {
case _Bank() when $default != null:
return $default(_that.bankId,_that.publicRss,_that.type,_that.accountName,_that.accountNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Bank implements Bank {
  const _Bank({@JsonKey(name: 'bankId') required this.bankId, @JsonKey(name: 'publicRss') required this.publicRss, @JsonKey(name: 'type') required this.type, @JsonKey(name: 'accountName') this.accountName, @JsonKey(name: 'accountNumber') this.accountNumber});
  factory _Bank.fromJson(Map<String, dynamic> json) => _$BankFromJson(json);

@override@JsonKey(name: 'bankId') final  String bankId;
@override@JsonKey(name: 'publicRss') final  int publicRss;
@override@JsonKey(name: 'type') final  int type;
@override@JsonKey(name: 'accountName') final  String? accountName;
@override@JsonKey(name: 'accountNumber') final  String? accountNumber;

/// Create a copy of Bank
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BankCopyWith<_Bank> get copyWith => __$BankCopyWithImpl<_Bank>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BankToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Bank&&(identical(other.bankId, bankId) || other.bankId == bankId)&&(identical(other.publicRss, publicRss) || other.publicRss == publicRss)&&(identical(other.type, type) || other.type == type)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bankId,publicRss,type,accountName,accountNumber);

@override
String toString() {
  return 'Bank(bankId: $bankId, publicRss: $publicRss, type: $type, accountName: $accountName, accountNumber: $accountNumber)';
}


}

/// @nodoc
abstract mixin class _$BankCopyWith<$Res> implements $BankCopyWith<$Res> {
  factory _$BankCopyWith(_Bank value, $Res Function(_Bank) _then) = __$BankCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'bankId') String bankId,@JsonKey(name: 'publicRss') int publicRss,@JsonKey(name: 'type') int type,@JsonKey(name: 'accountName') String? accountName,@JsonKey(name: 'accountNumber') String? accountNumber
});




}
/// @nodoc
class __$BankCopyWithImpl<$Res>
    implements _$BankCopyWith<$Res> {
  __$BankCopyWithImpl(this._self, this._then);

  final _Bank _self;
  final $Res Function(_Bank) _then;

/// Create a copy of Bank
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bankId = null,Object? publicRss = null,Object? type = null,Object? accountName = freezed,Object? accountNumber = freezed,}) {
  return _then(_Bank(
bankId: null == bankId ? _self.bankId : bankId // ignore: cast_nullable_to_non_nullable
as String,publicRss: null == publicRss ? _self.publicRss : publicRss // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,accountName: freezed == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String?,accountNumber: freezed == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Transaction {

@JsonKey(name: 'id') int get id;@JsonKey(name: 'transactionCode') String get transactionCode;@JsonKey(name: 'amount') num get amount;@JsonKey(name: 'type') int get type;@JsonKey(name: 'status') int get status;@JsonKey(name: 'slipType') int get slipType;@JsonKey(name: 'statusDescription') String get statusDescription;@JsonKey(name: 'bankSent') Bank get bankSent;@JsonKey(name: 'bankReceive') Bank get bankReceive;@JsonKey(name: 'requestTime') int get requestTime;@JsonKey(name: 'responseTime') int get responseTime;@JsonKey(name: 'notes') String? get notes;
/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionCopyWith<Transaction> get copyWith => _$TransactionCopyWithImpl<Transaction>(this as Transaction, _$identity);

  /// Serializes this Transaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Transaction&&(identical(other.id, id) || other.id == id)&&(identical(other.transactionCode, transactionCode) || other.transactionCode == transactionCode)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.slipType, slipType) || other.slipType == slipType)&&(identical(other.statusDescription, statusDescription) || other.statusDescription == statusDescription)&&(identical(other.bankSent, bankSent) || other.bankSent == bankSent)&&(identical(other.bankReceive, bankReceive) || other.bankReceive == bankReceive)&&(identical(other.requestTime, requestTime) || other.requestTime == requestTime)&&(identical(other.responseTime, responseTime) || other.responseTime == responseTime)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,transactionCode,amount,type,status,slipType,statusDescription,bankSent,bankReceive,requestTime,responseTime,notes);

@override
String toString() {
  return 'Transaction(id: $id, transactionCode: $transactionCode, amount: $amount, type: $type, status: $status, slipType: $slipType, statusDescription: $statusDescription, bankSent: $bankSent, bankReceive: $bankReceive, requestTime: $requestTime, responseTime: $responseTime, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $TransactionCopyWith<$Res>  {
  factory $TransactionCopyWith(Transaction value, $Res Function(Transaction) _then) = _$TransactionCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') int id,@JsonKey(name: 'transactionCode') String transactionCode,@JsonKey(name: 'amount') num amount,@JsonKey(name: 'type') int type,@JsonKey(name: 'status') int status,@JsonKey(name: 'slipType') int slipType,@JsonKey(name: 'statusDescription') String statusDescription,@JsonKey(name: 'bankSent') Bank bankSent,@JsonKey(name: 'bankReceive') Bank bankReceive,@JsonKey(name: 'requestTime') int requestTime,@JsonKey(name: 'responseTime') int responseTime,@JsonKey(name: 'notes') String? notes
});


$BankCopyWith<$Res> get bankSent;$BankCopyWith<$Res> get bankReceive;

}
/// @nodoc
class _$TransactionCopyWithImpl<$Res>
    implements $TransactionCopyWith<$Res> {
  _$TransactionCopyWithImpl(this._self, this._then);

  final Transaction _self;
  final $Res Function(Transaction) _then;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? transactionCode = null,Object? amount = null,Object? type = null,Object? status = null,Object? slipType = null,Object? statusDescription = null,Object? bankSent = null,Object? bankReceive = null,Object? requestTime = null,Object? responseTime = null,Object? notes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,transactionCode: null == transactionCode ? _self.transactionCode : transactionCode // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as num,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,slipType: null == slipType ? _self.slipType : slipType // ignore: cast_nullable_to_non_nullable
as int,statusDescription: null == statusDescription ? _self.statusDescription : statusDescription // ignore: cast_nullable_to_non_nullable
as String,bankSent: null == bankSent ? _self.bankSent : bankSent // ignore: cast_nullable_to_non_nullable
as Bank,bankReceive: null == bankReceive ? _self.bankReceive : bankReceive // ignore: cast_nullable_to_non_nullable
as Bank,requestTime: null == requestTime ? _self.requestTime : requestTime // ignore: cast_nullable_to_non_nullable
as int,responseTime: null == responseTime ? _self.responseTime : responseTime // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BankCopyWith<$Res> get bankSent {
  
  return $BankCopyWith<$Res>(_self.bankSent, (value) {
    return _then(_self.copyWith(bankSent: value));
  });
}/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BankCopyWith<$Res> get bankReceive {
  
  return $BankCopyWith<$Res>(_self.bankReceive, (value) {
    return _then(_self.copyWith(bankReceive: value));
  });
}
}


/// Adds pattern-matching-related methods to [Transaction].
extension TransactionPatterns on Transaction {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Transaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Transaction value)  $default,){
final _that = this;
switch (_that) {
case _Transaction():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Transaction value)?  $default,){
final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  int id, @JsonKey(name: 'transactionCode')  String transactionCode, @JsonKey(name: 'amount')  num amount, @JsonKey(name: 'type')  int type, @JsonKey(name: 'status')  int status, @JsonKey(name: 'slipType')  int slipType, @JsonKey(name: 'statusDescription')  String statusDescription, @JsonKey(name: 'bankSent')  Bank bankSent, @JsonKey(name: 'bankReceive')  Bank bankReceive, @JsonKey(name: 'requestTime')  int requestTime, @JsonKey(name: 'responseTime')  int responseTime, @JsonKey(name: 'notes')  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that.id,_that.transactionCode,_that.amount,_that.type,_that.status,_that.slipType,_that.statusDescription,_that.bankSent,_that.bankReceive,_that.requestTime,_that.responseTime,_that.notes);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  int id, @JsonKey(name: 'transactionCode')  String transactionCode, @JsonKey(name: 'amount')  num amount, @JsonKey(name: 'type')  int type, @JsonKey(name: 'status')  int status, @JsonKey(name: 'slipType')  int slipType, @JsonKey(name: 'statusDescription')  String statusDescription, @JsonKey(name: 'bankSent')  Bank bankSent, @JsonKey(name: 'bankReceive')  Bank bankReceive, @JsonKey(name: 'requestTime')  int requestTime, @JsonKey(name: 'responseTime')  int responseTime, @JsonKey(name: 'notes')  String? notes)  $default,) {final _that = this;
switch (_that) {
case _Transaction():
return $default(_that.id,_that.transactionCode,_that.amount,_that.type,_that.status,_that.slipType,_that.statusDescription,_that.bankSent,_that.bankReceive,_that.requestTime,_that.responseTime,_that.notes);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  int id, @JsonKey(name: 'transactionCode')  String transactionCode, @JsonKey(name: 'amount')  num amount, @JsonKey(name: 'type')  int type, @JsonKey(name: 'status')  int status, @JsonKey(name: 'slipType')  int slipType, @JsonKey(name: 'statusDescription')  String statusDescription, @JsonKey(name: 'bankSent')  Bank bankSent, @JsonKey(name: 'bankReceive')  Bank bankReceive, @JsonKey(name: 'requestTime')  int requestTime, @JsonKey(name: 'responseTime')  int responseTime, @JsonKey(name: 'notes')  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that.id,_that.transactionCode,_that.amount,_that.type,_that.status,_that.slipType,_that.statusDescription,_that.bankSent,_that.bankReceive,_that.requestTime,_that.responseTime,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Transaction implements Transaction {
  const _Transaction({@JsonKey(name: 'id') required this.id, @JsonKey(name: 'transactionCode') required this.transactionCode, @JsonKey(name: 'amount') required this.amount, @JsonKey(name: 'type') required this.type, @JsonKey(name: 'status') required this.status, @JsonKey(name: 'slipType') required this.slipType, @JsonKey(name: 'statusDescription') required this.statusDescription, @JsonKey(name: 'bankSent') required this.bankSent, @JsonKey(name: 'bankReceive') required this.bankReceive, @JsonKey(name: 'requestTime') required this.requestTime, @JsonKey(name: 'responseTime') required this.responseTime, @JsonKey(name: 'notes') this.notes});
  factory _Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);

@override@JsonKey(name: 'id') final  int id;
@override@JsonKey(name: 'transactionCode') final  String transactionCode;
@override@JsonKey(name: 'amount') final  num amount;
@override@JsonKey(name: 'type') final  int type;
@override@JsonKey(name: 'status') final  int status;
@override@JsonKey(name: 'slipType') final  int slipType;
@override@JsonKey(name: 'statusDescription') final  String statusDescription;
@override@JsonKey(name: 'bankSent') final  Bank bankSent;
@override@JsonKey(name: 'bankReceive') final  Bank bankReceive;
@override@JsonKey(name: 'requestTime') final  int requestTime;
@override@JsonKey(name: 'responseTime') final  int responseTime;
@override@JsonKey(name: 'notes') final  String? notes;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionCopyWith<_Transaction> get copyWith => __$TransactionCopyWithImpl<_Transaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Transaction&&(identical(other.id, id) || other.id == id)&&(identical(other.transactionCode, transactionCode) || other.transactionCode == transactionCode)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.slipType, slipType) || other.slipType == slipType)&&(identical(other.statusDescription, statusDescription) || other.statusDescription == statusDescription)&&(identical(other.bankSent, bankSent) || other.bankSent == bankSent)&&(identical(other.bankReceive, bankReceive) || other.bankReceive == bankReceive)&&(identical(other.requestTime, requestTime) || other.requestTime == requestTime)&&(identical(other.responseTime, responseTime) || other.responseTime == responseTime)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,transactionCode,amount,type,status,slipType,statusDescription,bankSent,bankReceive,requestTime,responseTime,notes);

@override
String toString() {
  return 'Transaction(id: $id, transactionCode: $transactionCode, amount: $amount, type: $type, status: $status, slipType: $slipType, statusDescription: $statusDescription, bankSent: $bankSent, bankReceive: $bankReceive, requestTime: $requestTime, responseTime: $responseTime, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$TransactionCopyWith<$Res> implements $TransactionCopyWith<$Res> {
  factory _$TransactionCopyWith(_Transaction value, $Res Function(_Transaction) _then) = __$TransactionCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') int id,@JsonKey(name: 'transactionCode') String transactionCode,@JsonKey(name: 'amount') num amount,@JsonKey(name: 'type') int type,@JsonKey(name: 'status') int status,@JsonKey(name: 'slipType') int slipType,@JsonKey(name: 'statusDescription') String statusDescription,@JsonKey(name: 'bankSent') Bank bankSent,@JsonKey(name: 'bankReceive') Bank bankReceive,@JsonKey(name: 'requestTime') int requestTime,@JsonKey(name: 'responseTime') int responseTime,@JsonKey(name: 'notes') String? notes
});


@override $BankCopyWith<$Res> get bankSent;@override $BankCopyWith<$Res> get bankReceive;

}
/// @nodoc
class __$TransactionCopyWithImpl<$Res>
    implements _$TransactionCopyWith<$Res> {
  __$TransactionCopyWithImpl(this._self, this._then);

  final _Transaction _self;
  final $Res Function(_Transaction) _then;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? transactionCode = null,Object? amount = null,Object? type = null,Object? status = null,Object? slipType = null,Object? statusDescription = null,Object? bankSent = null,Object? bankReceive = null,Object? requestTime = null,Object? responseTime = null,Object? notes = freezed,}) {
  return _then(_Transaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,transactionCode: null == transactionCode ? _self.transactionCode : transactionCode // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as num,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,slipType: null == slipType ? _self.slipType : slipType // ignore: cast_nullable_to_non_nullable
as int,statusDescription: null == statusDescription ? _self.statusDescription : statusDescription // ignore: cast_nullable_to_non_nullable
as String,bankSent: null == bankSent ? _self.bankSent : bankSent // ignore: cast_nullable_to_non_nullable
as Bank,bankReceive: null == bankReceive ? _self.bankReceive : bankReceive // ignore: cast_nullable_to_non_nullable
as Bank,requestTime: null == requestTime ? _self.requestTime : requestTime // ignore: cast_nullable_to_non_nullable
as int,responseTime: null == responseTime ? _self.responseTime : responseTime // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BankCopyWith<$Res> get bankSent {
  
  return $BankCopyWith<$Res>(_self.bankSent, (value) {
    return _then(_self.copyWith(bankSent: value));
  });
}/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BankCopyWith<$Res> get bankReceive {
  
  return $BankCopyWith<$Res>(_self.bankReceive, (value) {
    return _then(_self.copyWith(bankReceive: value));
  });
}
}


/// @nodoc
mixin _$TransactionResponseData {

@JsonKey(name: 'count') int get count;@JsonKey(name: 'message') String get message;@JsonKey(name: 'items') List<Transaction> get items;
/// Create a copy of TransactionResponseData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionResponseDataCopyWith<TransactionResponseData> get copyWith => _$TransactionResponseDataCopyWithImpl<TransactionResponseData>(this as TransactionResponseData, _$identity);

  /// Serializes this TransactionResponseData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionResponseData&&(identical(other.count, count) || other.count == count)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count,message,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'TransactionResponseData(count: $count, message: $message, items: $items)';
}


}

/// @nodoc
abstract mixin class $TransactionResponseDataCopyWith<$Res>  {
  factory $TransactionResponseDataCopyWith(TransactionResponseData value, $Res Function(TransactionResponseData) _then) = _$TransactionResponseDataCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'count') int count,@JsonKey(name: 'message') String message,@JsonKey(name: 'items') List<Transaction> items
});




}
/// @nodoc
class _$TransactionResponseDataCopyWithImpl<$Res>
    implements $TransactionResponseDataCopyWith<$Res> {
  _$TransactionResponseDataCopyWithImpl(this._self, this._then);

  final TransactionResponseData _self;
  final $Res Function(TransactionResponseData) _then;

/// Create a copy of TransactionResponseData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? count = null,Object? message = null,Object? items = null,}) {
  return _then(_self.copyWith(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Transaction>,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionResponseData].
extension TransactionResponseDataPatterns on TransactionResponseData {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionResponseData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionResponseData() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionResponseData value)  $default,){
final _that = this;
switch (_that) {
case _TransactionResponseData():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionResponseData value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionResponseData() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'count')  int count, @JsonKey(name: 'message')  String message, @JsonKey(name: 'items')  List<Transaction> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionResponseData() when $default != null:
return $default(_that.count,_that.message,_that.items);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'count')  int count, @JsonKey(name: 'message')  String message, @JsonKey(name: 'items')  List<Transaction> items)  $default,) {final _that = this;
switch (_that) {
case _TransactionResponseData():
return $default(_that.count,_that.message,_that.items);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'count')  int count, @JsonKey(name: 'message')  String message, @JsonKey(name: 'items')  List<Transaction> items)?  $default,) {final _that = this;
switch (_that) {
case _TransactionResponseData() when $default != null:
return $default(_that.count,_that.message,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransactionResponseData implements TransactionResponseData {
  const _TransactionResponseData({@JsonKey(name: 'count') required this.count, @JsonKey(name: 'message') required this.message, @JsonKey(name: 'items') required final  List<Transaction> items}): _items = items;
  factory _TransactionResponseData.fromJson(Map<String, dynamic> json) => _$TransactionResponseDataFromJson(json);

@override@JsonKey(name: 'count') final  int count;
@override@JsonKey(name: 'message') final  String message;
 final  List<Transaction> _items;
@override@JsonKey(name: 'items') List<Transaction> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of TransactionResponseData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionResponseDataCopyWith<_TransactionResponseData> get copyWith => __$TransactionResponseDataCopyWithImpl<_TransactionResponseData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionResponseDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionResponseData&&(identical(other.count, count) || other.count == count)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count,message,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'TransactionResponseData(count: $count, message: $message, items: $items)';
}


}

/// @nodoc
abstract mixin class _$TransactionResponseDataCopyWith<$Res> implements $TransactionResponseDataCopyWith<$Res> {
  factory _$TransactionResponseDataCopyWith(_TransactionResponseData value, $Res Function(_TransactionResponseData) _then) = __$TransactionResponseDataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'count') int count,@JsonKey(name: 'message') String message,@JsonKey(name: 'items') List<Transaction> items
});




}
/// @nodoc
class __$TransactionResponseDataCopyWithImpl<$Res>
    implements _$TransactionResponseDataCopyWith<$Res> {
  __$TransactionResponseDataCopyWithImpl(this._self, this._then);

  final _TransactionResponseData _self;
  final $Res Function(_TransactionResponseData) _then;

/// Create a copy of TransactionResponseData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? count = null,Object? message = null,Object? items = null,}) {
  return _then(_TransactionResponseData(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Transaction>,
  ));
}


}

// dart format on
