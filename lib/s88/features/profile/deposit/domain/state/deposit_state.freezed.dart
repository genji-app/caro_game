// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deposit_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DepositSelectionState {

 PaymentMethod? get selectedMethod; bool get isContainerVisible;
/// Create a copy of DepositSelectionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DepositSelectionStateCopyWith<DepositSelectionState> get copyWith => _$DepositSelectionStateCopyWithImpl<DepositSelectionState>(this as DepositSelectionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DepositSelectionState&&(identical(other.selectedMethod, selectedMethod) || other.selectedMethod == selectedMethod)&&(identical(other.isContainerVisible, isContainerVisible) || other.isContainerVisible == isContainerVisible));
}


@override
int get hashCode => Object.hash(runtimeType,selectedMethod,isContainerVisible);

@override
String toString() {
  return 'DepositSelectionState(selectedMethod: $selectedMethod, isContainerVisible: $isContainerVisible)';
}


}

/// @nodoc
abstract mixin class $DepositSelectionStateCopyWith<$Res>  {
  factory $DepositSelectionStateCopyWith(DepositSelectionState value, $Res Function(DepositSelectionState) _then) = _$DepositSelectionStateCopyWithImpl;
@useResult
$Res call({
 PaymentMethod? selectedMethod, bool isContainerVisible
});




}
/// @nodoc
class _$DepositSelectionStateCopyWithImpl<$Res>
    implements $DepositSelectionStateCopyWith<$Res> {
  _$DepositSelectionStateCopyWithImpl(this._self, this._then);

  final DepositSelectionState _self;
  final $Res Function(DepositSelectionState) _then;

/// Create a copy of DepositSelectionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedMethod = freezed,Object? isContainerVisible = null,}) {
  return _then(_self.copyWith(
selectedMethod: freezed == selectedMethod ? _self.selectedMethod : selectedMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod?,isContainerVisible: null == isContainerVisible ? _self.isContainerVisible : isContainerVisible // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DepositSelectionState].
extension DepositSelectionStatePatterns on DepositSelectionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DepositSelectionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DepositSelectionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DepositSelectionState value)  $default,){
final _that = this;
switch (_that) {
case _DepositSelectionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DepositSelectionState value)?  $default,){
final _that = this;
switch (_that) {
case _DepositSelectionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PaymentMethod? selectedMethod,  bool isContainerVisible)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DepositSelectionState() when $default != null:
return $default(_that.selectedMethod,_that.isContainerVisible);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PaymentMethod? selectedMethod,  bool isContainerVisible)  $default,) {final _that = this;
switch (_that) {
case _DepositSelectionState():
return $default(_that.selectedMethod,_that.isContainerVisible);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PaymentMethod? selectedMethod,  bool isContainerVisible)?  $default,) {final _that = this;
switch (_that) {
case _DepositSelectionState() when $default != null:
return $default(_that.selectedMethod,_that.isContainerVisible);case _:
  return null;

}
}

}

/// @nodoc


class _DepositSelectionState implements DepositSelectionState {
  const _DepositSelectionState({this.selectedMethod, this.isContainerVisible = true});
  

@override final  PaymentMethod? selectedMethod;
@override@JsonKey() final  bool isContainerVisible;

/// Create a copy of DepositSelectionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DepositSelectionStateCopyWith<_DepositSelectionState> get copyWith => __$DepositSelectionStateCopyWithImpl<_DepositSelectionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DepositSelectionState&&(identical(other.selectedMethod, selectedMethod) || other.selectedMethod == selectedMethod)&&(identical(other.isContainerVisible, isContainerVisible) || other.isContainerVisible == isContainerVisible));
}


@override
int get hashCode => Object.hash(runtimeType,selectedMethod,isContainerVisible);

@override
String toString() {
  return 'DepositSelectionState(selectedMethod: $selectedMethod, isContainerVisible: $isContainerVisible)';
}


}

/// @nodoc
abstract mixin class _$DepositSelectionStateCopyWith<$Res> implements $DepositSelectionStateCopyWith<$Res> {
  factory _$DepositSelectionStateCopyWith(_DepositSelectionState value, $Res Function(_DepositSelectionState) _then) = __$DepositSelectionStateCopyWithImpl;
@override @useResult
$Res call({
 PaymentMethod? selectedMethod, bool isContainerVisible
});




}
/// @nodoc
class __$DepositSelectionStateCopyWithImpl<$Res>
    implements _$DepositSelectionStateCopyWith<$Res> {
  __$DepositSelectionStateCopyWithImpl(this._self, this._then);

  final _DepositSelectionState _self;
  final $Res Function(_DepositSelectionState) _then;

/// Create a copy of DepositSelectionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedMethod = freezed,Object? isContainerVisible = null,}) {
  return _then(_DepositSelectionState(
selectedMethod: freezed == selectedMethod ? _self.selectedMethod : selectedMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod?,isContainerVisible: null == isContainerVisible ? _self.isContainerVisible : isContainerVisible // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$BankFormState {

 String? get selectedBank; String get accountNumber; String get accountName; String get amount; String get senderName;// Tên người gửi (cho confirm form)
 String get note;// Ghi chú/mã giao dịch (cho confirm form)
 String? get bankError; String? get accountNumberError; String? get accountNameError; String? get amountError; String? get senderNameError; String? get noteError;
/// Create a copy of BankFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BankFormStateCopyWith<BankFormState> get copyWith => _$BankFormStateCopyWithImpl<BankFormState>(this as BankFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BankFormState&&(identical(other.selectedBank, selectedBank) || other.selectedBank == selectedBank)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.note, note) || other.note == note)&&(identical(other.bankError, bankError) || other.bankError == bankError)&&(identical(other.accountNumberError, accountNumberError) || other.accountNumberError == accountNumberError)&&(identical(other.accountNameError, accountNameError) || other.accountNameError == accountNameError)&&(identical(other.amountError, amountError) || other.amountError == amountError)&&(identical(other.senderNameError, senderNameError) || other.senderNameError == senderNameError)&&(identical(other.noteError, noteError) || other.noteError == noteError));
}


@override
int get hashCode => Object.hash(runtimeType,selectedBank,accountNumber,accountName,amount,senderName,note,bankError,accountNumberError,accountNameError,amountError,senderNameError,noteError);

@override
String toString() {
  return 'BankFormState(selectedBank: $selectedBank, accountNumber: $accountNumber, accountName: $accountName, amount: $amount, senderName: $senderName, note: $note, bankError: $bankError, accountNumberError: $accountNumberError, accountNameError: $accountNameError, amountError: $amountError, senderNameError: $senderNameError, noteError: $noteError)';
}


}

/// @nodoc
abstract mixin class $BankFormStateCopyWith<$Res>  {
  factory $BankFormStateCopyWith(BankFormState value, $Res Function(BankFormState) _then) = _$BankFormStateCopyWithImpl;
@useResult
$Res call({
 String? selectedBank, String accountNumber, String accountName, String amount, String senderName, String note, String? bankError, String? accountNumberError, String? accountNameError, String? amountError, String? senderNameError, String? noteError
});




}
/// @nodoc
class _$BankFormStateCopyWithImpl<$Res>
    implements $BankFormStateCopyWith<$Res> {
  _$BankFormStateCopyWithImpl(this._self, this._then);

  final BankFormState _self;
  final $Res Function(BankFormState) _then;

/// Create a copy of BankFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedBank = freezed,Object? accountNumber = null,Object? accountName = null,Object? amount = null,Object? senderName = null,Object? note = null,Object? bankError = freezed,Object? accountNumberError = freezed,Object? accountNameError = freezed,Object? amountError = freezed,Object? senderNameError = freezed,Object? noteError = freezed,}) {
  return _then(_self.copyWith(
selectedBank: freezed == selectedBank ? _self.selectedBank : selectedBank // ignore: cast_nullable_to_non_nullable
as String?,accountNumber: null == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String,accountName: null == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,bankError: freezed == bankError ? _self.bankError : bankError // ignore: cast_nullable_to_non_nullable
as String?,accountNumberError: freezed == accountNumberError ? _self.accountNumberError : accountNumberError // ignore: cast_nullable_to_non_nullable
as String?,accountNameError: freezed == accountNameError ? _self.accountNameError : accountNameError // ignore: cast_nullable_to_non_nullable
as String?,amountError: freezed == amountError ? _self.amountError : amountError // ignore: cast_nullable_to_non_nullable
as String?,senderNameError: freezed == senderNameError ? _self.senderNameError : senderNameError // ignore: cast_nullable_to_non_nullable
as String?,noteError: freezed == noteError ? _self.noteError : noteError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BankFormState].
extension BankFormStatePatterns on BankFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BankFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BankFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BankFormState value)  $default,){
final _that = this;
switch (_that) {
case _BankFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BankFormState value)?  $default,){
final _that = this;
switch (_that) {
case _BankFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? selectedBank,  String accountNumber,  String accountName,  String amount,  String senderName,  String note,  String? bankError,  String? accountNumberError,  String? accountNameError,  String? amountError,  String? senderNameError,  String? noteError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BankFormState() when $default != null:
return $default(_that.selectedBank,_that.accountNumber,_that.accountName,_that.amount,_that.senderName,_that.note,_that.bankError,_that.accountNumberError,_that.accountNameError,_that.amountError,_that.senderNameError,_that.noteError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? selectedBank,  String accountNumber,  String accountName,  String amount,  String senderName,  String note,  String? bankError,  String? accountNumberError,  String? accountNameError,  String? amountError,  String? senderNameError,  String? noteError)  $default,) {final _that = this;
switch (_that) {
case _BankFormState():
return $default(_that.selectedBank,_that.accountNumber,_that.accountName,_that.amount,_that.senderName,_that.note,_that.bankError,_that.accountNumberError,_that.accountNameError,_that.amountError,_that.senderNameError,_that.noteError);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? selectedBank,  String accountNumber,  String accountName,  String amount,  String senderName,  String note,  String? bankError,  String? accountNumberError,  String? accountNameError,  String? amountError,  String? senderNameError,  String? noteError)?  $default,) {final _that = this;
switch (_that) {
case _BankFormState() when $default != null:
return $default(_that.selectedBank,_that.accountNumber,_that.accountName,_that.amount,_that.senderName,_that.note,_that.bankError,_that.accountNumberError,_that.accountNameError,_that.amountError,_that.senderNameError,_that.noteError);case _:
  return null;

}
}

}

/// @nodoc


class _BankFormState implements BankFormState {
  const _BankFormState({this.selectedBank, this.accountNumber = '', this.accountName = '', this.amount = '', this.senderName = '', this.note = '', this.bankError, this.accountNumberError, this.accountNameError, this.amountError, this.senderNameError, this.noteError});
  

@override final  String? selectedBank;
@override@JsonKey() final  String accountNumber;
@override@JsonKey() final  String accountName;
@override@JsonKey() final  String amount;
@override@JsonKey() final  String senderName;
// Tên người gửi (cho confirm form)
@override@JsonKey() final  String note;
// Ghi chú/mã giao dịch (cho confirm form)
@override final  String? bankError;
@override final  String? accountNumberError;
@override final  String? accountNameError;
@override final  String? amountError;
@override final  String? senderNameError;
@override final  String? noteError;

/// Create a copy of BankFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BankFormStateCopyWith<_BankFormState> get copyWith => __$BankFormStateCopyWithImpl<_BankFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BankFormState&&(identical(other.selectedBank, selectedBank) || other.selectedBank == selectedBank)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.note, note) || other.note == note)&&(identical(other.bankError, bankError) || other.bankError == bankError)&&(identical(other.accountNumberError, accountNumberError) || other.accountNumberError == accountNumberError)&&(identical(other.accountNameError, accountNameError) || other.accountNameError == accountNameError)&&(identical(other.amountError, amountError) || other.amountError == amountError)&&(identical(other.senderNameError, senderNameError) || other.senderNameError == senderNameError)&&(identical(other.noteError, noteError) || other.noteError == noteError));
}


@override
int get hashCode => Object.hash(runtimeType,selectedBank,accountNumber,accountName,amount,senderName,note,bankError,accountNumberError,accountNameError,amountError,senderNameError,noteError);

@override
String toString() {
  return 'BankFormState(selectedBank: $selectedBank, accountNumber: $accountNumber, accountName: $accountName, amount: $amount, senderName: $senderName, note: $note, bankError: $bankError, accountNumberError: $accountNumberError, accountNameError: $accountNameError, amountError: $amountError, senderNameError: $senderNameError, noteError: $noteError)';
}


}

/// @nodoc
abstract mixin class _$BankFormStateCopyWith<$Res> implements $BankFormStateCopyWith<$Res> {
  factory _$BankFormStateCopyWith(_BankFormState value, $Res Function(_BankFormState) _then) = __$BankFormStateCopyWithImpl;
@override @useResult
$Res call({
 String? selectedBank, String accountNumber, String accountName, String amount, String senderName, String note, String? bankError, String? accountNumberError, String? accountNameError, String? amountError, String? senderNameError, String? noteError
});




}
/// @nodoc
class __$BankFormStateCopyWithImpl<$Res>
    implements _$BankFormStateCopyWith<$Res> {
  __$BankFormStateCopyWithImpl(this._self, this._then);

  final _BankFormState _self;
  final $Res Function(_BankFormState) _then;

/// Create a copy of BankFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedBank = freezed,Object? accountNumber = null,Object? accountName = null,Object? amount = null,Object? senderName = null,Object? note = null,Object? bankError = freezed,Object? accountNumberError = freezed,Object? accountNameError = freezed,Object? amountError = freezed,Object? senderNameError = freezed,Object? noteError = freezed,}) {
  return _then(_BankFormState(
selectedBank: freezed == selectedBank ? _self.selectedBank : selectedBank // ignore: cast_nullable_to_non_nullable
as String?,accountNumber: null == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String,accountName: null == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,bankError: freezed == bankError ? _self.bankError : bankError // ignore: cast_nullable_to_non_nullable
as String?,accountNumberError: freezed == accountNumberError ? _self.accountNumberError : accountNumberError // ignore: cast_nullable_to_non_nullable
as String?,accountNameError: freezed == accountNameError ? _self.accountNameError : accountNameError // ignore: cast_nullable_to_non_nullable
as String?,amountError: freezed == amountError ? _self.amountError : amountError // ignore: cast_nullable_to_non_nullable
as String?,senderNameError: freezed == senderNameError ? _self.senderNameError : senderNameError // ignore: cast_nullable_to_non_nullable
as String?,noteError: freezed == noteError ? _self.noteError : noteError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$BankSubmitState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BankSubmitState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BankSubmitState()';
}


}

/// @nodoc
class $BankSubmitStateCopyWith<$Res>  {
$BankSubmitStateCopyWith(BankSubmitState _, $Res Function(BankSubmitState) __);
}


/// Adds pattern-matching-related methods to [BankSubmitState].
extension BankSubmitStatePatterns on BankSubmitState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Idle value)?  idle,TResult Function( _Submitting value)?  submitting,TResult Function( _Success value)?  success,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Idle() when idle != null:
return idle(_that);case _Submitting() when submitting != null:
return submitting(_that);case _Success() when success != null:
return success(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Idle value)  idle,required TResult Function( _Submitting value)  submitting,required TResult Function( _Success value)  success,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Idle():
return idle(_that);case _Submitting():
return submitting(_that);case _Success():
return success(_that);case _Error():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Idle value)?  idle,TResult? Function( _Submitting value)?  submitting,TResult? Function( _Success value)?  success,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Idle() when idle != null:
return idle(_that);case _Submitting() when submitting != null:
return submitting(_that);case _Success() when success != null:
return success(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  submitting,TResult Function()?  success,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Idle() when idle != null:
return idle();case _Submitting() when submitting != null:
return submitting();case _Success() when success != null:
return success();case _Error() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  submitting,required TResult Function()  success,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Idle():
return idle();case _Submitting():
return submitting();case _Success():
return success();case _Error():
return error(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  submitting,TResult? Function()?  success,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Idle() when idle != null:
return idle();case _Submitting() when submitting != null:
return submitting();case _Success() when success != null:
return success();case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Idle implements BankSubmitState {
  const _Idle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Idle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BankSubmitState.idle()';
}


}




/// @nodoc


class _Submitting implements BankSubmitState {
  const _Submitting();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Submitting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BankSubmitState.submitting()';
}


}




/// @nodoc


class _Success implements BankSubmitState {
  const _Success();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Success);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BankSubmitState.success()';
}


}




/// @nodoc


class _Error implements BankSubmitState {
  const _Error(this.message);
  

 final  String message;

/// Create a copy of BankSubmitState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'BankSubmitState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $BankSubmitStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of BankSubmitState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$BankTransactionSlipState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BankTransactionSlipState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BankTransactionSlipState()';
}


}

/// @nodoc
class $BankTransactionSlipStateCopyWith<$Res>  {
$BankTransactionSlipStateCopyWith(BankTransactionSlipState _, $Res Function(BankTransactionSlipState) __);
}


/// Adds pattern-matching-related methods to [BankTransactionSlipState].
extension BankTransactionSlipStatePatterns on BankTransactionSlipState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _TransactionSlipIdle value)?  idle,TResult Function( _TransactionSlipSubmitting value)?  submitting,TResult Function( _TransactionSlipSuccess value)?  success,TResult Function( _TransactionSlipError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionSlipIdle() when idle != null:
return idle(_that);case _TransactionSlipSubmitting() when submitting != null:
return submitting(_that);case _TransactionSlipSuccess() when success != null:
return success(_that);case _TransactionSlipError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _TransactionSlipIdle value)  idle,required TResult Function( _TransactionSlipSubmitting value)  submitting,required TResult Function( _TransactionSlipSuccess value)  success,required TResult Function( _TransactionSlipError value)  error,}){
final _that = this;
switch (_that) {
case _TransactionSlipIdle():
return idle(_that);case _TransactionSlipSubmitting():
return submitting(_that);case _TransactionSlipSuccess():
return success(_that);case _TransactionSlipError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _TransactionSlipIdle value)?  idle,TResult? Function( _TransactionSlipSubmitting value)?  submitting,TResult? Function( _TransactionSlipSuccess value)?  success,TResult? Function( _TransactionSlipError value)?  error,}){
final _that = this;
switch (_that) {
case _TransactionSlipIdle() when idle != null:
return idle(_that);case _TransactionSlipSubmitting() when submitting != null:
return submitting(_that);case _TransactionSlipSuccess() when success != null:
return success(_that);case _TransactionSlipError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  submitting,TResult Function()?  success,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionSlipIdle() when idle != null:
return idle();case _TransactionSlipSubmitting() when submitting != null:
return submitting();case _TransactionSlipSuccess() when success != null:
return success();case _TransactionSlipError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  submitting,required TResult Function()  success,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _TransactionSlipIdle():
return idle();case _TransactionSlipSubmitting():
return submitting();case _TransactionSlipSuccess():
return success();case _TransactionSlipError():
return error(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  submitting,TResult? Function()?  success,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _TransactionSlipIdle() when idle != null:
return idle();case _TransactionSlipSubmitting() when submitting != null:
return submitting();case _TransactionSlipSuccess() when success != null:
return success();case _TransactionSlipError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _TransactionSlipIdle implements BankTransactionSlipState {
  const _TransactionSlipIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionSlipIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BankTransactionSlipState.idle()';
}


}




/// @nodoc


class _TransactionSlipSubmitting implements BankTransactionSlipState {
  const _TransactionSlipSubmitting();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionSlipSubmitting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BankTransactionSlipState.submitting()';
}


}




/// @nodoc


class _TransactionSlipSuccess implements BankTransactionSlipState {
  const _TransactionSlipSuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionSlipSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BankTransactionSlipState.success()';
}


}




/// @nodoc


class _TransactionSlipError implements BankTransactionSlipState {
  const _TransactionSlipError(this.message);
  

 final  String message;

/// Create a copy of BankTransactionSlipState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionSlipErrorCopyWith<_TransactionSlipError> get copyWith => __$TransactionSlipErrorCopyWithImpl<_TransactionSlipError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionSlipError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'BankTransactionSlipState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$TransactionSlipErrorCopyWith<$Res> implements $BankTransactionSlipStateCopyWith<$Res> {
  factory _$TransactionSlipErrorCopyWith(_TransactionSlipError value, $Res Function(_TransactionSlipError) _then) = __$TransactionSlipErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$TransactionSlipErrorCopyWithImpl<$Res>
    implements _$TransactionSlipErrorCopyWith<$Res> {
  __$TransactionSlipErrorCopyWithImpl(this._self, this._then);

  final _TransactionSlipError _self;
  final $Res Function(_TransactionSlipError) _then;

/// Create a copy of BankTransactionSlipState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_TransactionSlipError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$CodepayFormState {

 String? get selectedBank;// Bank ID
 String get amount; String? get bankError; String? get amountError;
/// Create a copy of CodepayFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CodepayFormStateCopyWith<CodepayFormState> get copyWith => _$CodepayFormStateCopyWithImpl<CodepayFormState>(this as CodepayFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CodepayFormState&&(identical(other.selectedBank, selectedBank) || other.selectedBank == selectedBank)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.bankError, bankError) || other.bankError == bankError)&&(identical(other.amountError, amountError) || other.amountError == amountError));
}


@override
int get hashCode => Object.hash(runtimeType,selectedBank,amount,bankError,amountError);

@override
String toString() {
  return 'CodepayFormState(selectedBank: $selectedBank, amount: $amount, bankError: $bankError, amountError: $amountError)';
}


}

/// @nodoc
abstract mixin class $CodepayFormStateCopyWith<$Res>  {
  factory $CodepayFormStateCopyWith(CodepayFormState value, $Res Function(CodepayFormState) _then) = _$CodepayFormStateCopyWithImpl;
@useResult
$Res call({
 String? selectedBank, String amount, String? bankError, String? amountError
});




}
/// @nodoc
class _$CodepayFormStateCopyWithImpl<$Res>
    implements $CodepayFormStateCopyWith<$Res> {
  _$CodepayFormStateCopyWithImpl(this._self, this._then);

  final CodepayFormState _self;
  final $Res Function(CodepayFormState) _then;

/// Create a copy of CodepayFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedBank = freezed,Object? amount = null,Object? bankError = freezed,Object? amountError = freezed,}) {
  return _then(_self.copyWith(
selectedBank: freezed == selectedBank ? _self.selectedBank : selectedBank // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,bankError: freezed == bankError ? _self.bankError : bankError // ignore: cast_nullable_to_non_nullable
as String?,amountError: freezed == amountError ? _self.amountError : amountError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CodepayFormState].
extension CodepayFormStatePatterns on CodepayFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CodepayFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CodepayFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CodepayFormState value)  $default,){
final _that = this;
switch (_that) {
case _CodepayFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CodepayFormState value)?  $default,){
final _that = this;
switch (_that) {
case _CodepayFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? selectedBank,  String amount,  String? bankError,  String? amountError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CodepayFormState() when $default != null:
return $default(_that.selectedBank,_that.amount,_that.bankError,_that.amountError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? selectedBank,  String amount,  String? bankError,  String? amountError)  $default,) {final _that = this;
switch (_that) {
case _CodepayFormState():
return $default(_that.selectedBank,_that.amount,_that.bankError,_that.amountError);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? selectedBank,  String amount,  String? bankError,  String? amountError)?  $default,) {final _that = this;
switch (_that) {
case _CodepayFormState() when $default != null:
return $default(_that.selectedBank,_that.amount,_that.bankError,_that.amountError);case _:
  return null;

}
}

}

/// @nodoc


class _CodepayFormState implements CodepayFormState {
  const _CodepayFormState({this.selectedBank, this.amount = '', this.bankError, this.amountError});
  

@override final  String? selectedBank;
// Bank ID
@override@JsonKey() final  String amount;
@override final  String? bankError;
@override final  String? amountError;

/// Create a copy of CodepayFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CodepayFormStateCopyWith<_CodepayFormState> get copyWith => __$CodepayFormStateCopyWithImpl<_CodepayFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CodepayFormState&&(identical(other.selectedBank, selectedBank) || other.selectedBank == selectedBank)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.bankError, bankError) || other.bankError == bankError)&&(identical(other.amountError, amountError) || other.amountError == amountError));
}


@override
int get hashCode => Object.hash(runtimeType,selectedBank,amount,bankError,amountError);

@override
String toString() {
  return 'CodepayFormState(selectedBank: $selectedBank, amount: $amount, bankError: $bankError, amountError: $amountError)';
}


}

/// @nodoc
abstract mixin class _$CodepayFormStateCopyWith<$Res> implements $CodepayFormStateCopyWith<$Res> {
  factory _$CodepayFormStateCopyWith(_CodepayFormState value, $Res Function(_CodepayFormState) _then) = __$CodepayFormStateCopyWithImpl;
@override @useResult
$Res call({
 String? selectedBank, String amount, String? bankError, String? amountError
});




}
/// @nodoc
class __$CodepayFormStateCopyWithImpl<$Res>
    implements _$CodepayFormStateCopyWith<$Res> {
  __$CodepayFormStateCopyWithImpl(this._self, this._then);

  final _CodepayFormState _self;
  final $Res Function(_CodepayFormState) _then;

/// Create a copy of CodepayFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedBank = freezed,Object? amount = null,Object? bankError = freezed,Object? amountError = freezed,}) {
  return _then(_CodepayFormState(
selectedBank: freezed == selectedBank ? _self.selectedBank : selectedBank // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,bankError: freezed == bankError ? _self.bankError : bankError // ignore: cast_nullable_to_non_nullable
as String?,amountError: freezed == amountError ? _self.amountError : amountError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$EWalletFormState {

 String? get selectedWallet;// Wallet name/ID
 String get amount; String? get walletError; String? get amountError;
/// Create a copy of EWalletFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EWalletFormStateCopyWith<EWalletFormState> get copyWith => _$EWalletFormStateCopyWithImpl<EWalletFormState>(this as EWalletFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EWalletFormState&&(identical(other.selectedWallet, selectedWallet) || other.selectedWallet == selectedWallet)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.walletError, walletError) || other.walletError == walletError)&&(identical(other.amountError, amountError) || other.amountError == amountError));
}


@override
int get hashCode => Object.hash(runtimeType,selectedWallet,amount,walletError,amountError);

@override
String toString() {
  return 'EWalletFormState(selectedWallet: $selectedWallet, amount: $amount, walletError: $walletError, amountError: $amountError)';
}


}

/// @nodoc
abstract mixin class $EWalletFormStateCopyWith<$Res>  {
  factory $EWalletFormStateCopyWith(EWalletFormState value, $Res Function(EWalletFormState) _then) = _$EWalletFormStateCopyWithImpl;
@useResult
$Res call({
 String? selectedWallet, String amount, String? walletError, String? amountError
});




}
/// @nodoc
class _$EWalletFormStateCopyWithImpl<$Res>
    implements $EWalletFormStateCopyWith<$Res> {
  _$EWalletFormStateCopyWithImpl(this._self, this._then);

  final EWalletFormState _self;
  final $Res Function(EWalletFormState) _then;

/// Create a copy of EWalletFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedWallet = freezed,Object? amount = null,Object? walletError = freezed,Object? amountError = freezed,}) {
  return _then(_self.copyWith(
selectedWallet: freezed == selectedWallet ? _self.selectedWallet : selectedWallet // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,walletError: freezed == walletError ? _self.walletError : walletError // ignore: cast_nullable_to_non_nullable
as String?,amountError: freezed == amountError ? _self.amountError : amountError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EWalletFormState].
extension EWalletFormStatePatterns on EWalletFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EWalletFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EWalletFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EWalletFormState value)  $default,){
final _that = this;
switch (_that) {
case _EWalletFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EWalletFormState value)?  $default,){
final _that = this;
switch (_that) {
case _EWalletFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? selectedWallet,  String amount,  String? walletError,  String? amountError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EWalletFormState() when $default != null:
return $default(_that.selectedWallet,_that.amount,_that.walletError,_that.amountError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? selectedWallet,  String amount,  String? walletError,  String? amountError)  $default,) {final _that = this;
switch (_that) {
case _EWalletFormState():
return $default(_that.selectedWallet,_that.amount,_that.walletError,_that.amountError);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? selectedWallet,  String amount,  String? walletError,  String? amountError)?  $default,) {final _that = this;
switch (_that) {
case _EWalletFormState() when $default != null:
return $default(_that.selectedWallet,_that.amount,_that.walletError,_that.amountError);case _:
  return null;

}
}

}

/// @nodoc


class _EWalletFormState implements EWalletFormState {
  const _EWalletFormState({this.selectedWallet, this.amount = '', this.walletError, this.amountError});
  

@override final  String? selectedWallet;
// Wallet name/ID
@override@JsonKey() final  String amount;
@override final  String? walletError;
@override final  String? amountError;

/// Create a copy of EWalletFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EWalletFormStateCopyWith<_EWalletFormState> get copyWith => __$EWalletFormStateCopyWithImpl<_EWalletFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EWalletFormState&&(identical(other.selectedWallet, selectedWallet) || other.selectedWallet == selectedWallet)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.walletError, walletError) || other.walletError == walletError)&&(identical(other.amountError, amountError) || other.amountError == amountError));
}


@override
int get hashCode => Object.hash(runtimeType,selectedWallet,amount,walletError,amountError);

@override
String toString() {
  return 'EWalletFormState(selectedWallet: $selectedWallet, amount: $amount, walletError: $walletError, amountError: $amountError)';
}


}

/// @nodoc
abstract mixin class _$EWalletFormStateCopyWith<$Res> implements $EWalletFormStateCopyWith<$Res> {
  factory _$EWalletFormStateCopyWith(_EWalletFormState value, $Res Function(_EWalletFormState) _then) = __$EWalletFormStateCopyWithImpl;
@override @useResult
$Res call({
 String? selectedWallet, String amount, String? walletError, String? amountError
});




}
/// @nodoc
class __$EWalletFormStateCopyWithImpl<$Res>
    implements _$EWalletFormStateCopyWith<$Res> {
  __$EWalletFormStateCopyWithImpl(this._self, this._then);

  final _EWalletFormState _self;
  final $Res Function(_EWalletFormState) _then;

/// Create a copy of EWalletFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedWallet = freezed,Object? amount = null,Object? walletError = freezed,Object? amountError = freezed,}) {
  return _then(_EWalletFormState(
selectedWallet: freezed == selectedWallet ? _self.selectedWallet : selectedWallet // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,walletError: freezed == walletError ? _self.walletError : walletError // ignore: cast_nullable_to_non_nullable
as String?,amountError: freezed == amountError ? _self.amountError : amountError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$CardFormState {

 String? get selectedCardType; String? get selectedDenomination; String get serialNumber; String get cardCode; String? get cardTypeError; String? get denominationError; String? get serialNumberError; String? get cardCodeError;
/// Create a copy of CardFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardFormStateCopyWith<CardFormState> get copyWith => _$CardFormStateCopyWithImpl<CardFormState>(this as CardFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardFormState&&(identical(other.selectedCardType, selectedCardType) || other.selectedCardType == selectedCardType)&&(identical(other.selectedDenomination, selectedDenomination) || other.selectedDenomination == selectedDenomination)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.cardCode, cardCode) || other.cardCode == cardCode)&&(identical(other.cardTypeError, cardTypeError) || other.cardTypeError == cardTypeError)&&(identical(other.denominationError, denominationError) || other.denominationError == denominationError)&&(identical(other.serialNumberError, serialNumberError) || other.serialNumberError == serialNumberError)&&(identical(other.cardCodeError, cardCodeError) || other.cardCodeError == cardCodeError));
}


@override
int get hashCode => Object.hash(runtimeType,selectedCardType,selectedDenomination,serialNumber,cardCode,cardTypeError,denominationError,serialNumberError,cardCodeError);

@override
String toString() {
  return 'CardFormState(selectedCardType: $selectedCardType, selectedDenomination: $selectedDenomination, serialNumber: $serialNumber, cardCode: $cardCode, cardTypeError: $cardTypeError, denominationError: $denominationError, serialNumberError: $serialNumberError, cardCodeError: $cardCodeError)';
}


}

/// @nodoc
abstract mixin class $CardFormStateCopyWith<$Res>  {
  factory $CardFormStateCopyWith(CardFormState value, $Res Function(CardFormState) _then) = _$CardFormStateCopyWithImpl;
@useResult
$Res call({
 String? selectedCardType, String? selectedDenomination, String serialNumber, String cardCode, String? cardTypeError, String? denominationError, String? serialNumberError, String? cardCodeError
});




}
/// @nodoc
class _$CardFormStateCopyWithImpl<$Res>
    implements $CardFormStateCopyWith<$Res> {
  _$CardFormStateCopyWithImpl(this._self, this._then);

  final CardFormState _self;
  final $Res Function(CardFormState) _then;

/// Create a copy of CardFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedCardType = freezed,Object? selectedDenomination = freezed,Object? serialNumber = null,Object? cardCode = null,Object? cardTypeError = freezed,Object? denominationError = freezed,Object? serialNumberError = freezed,Object? cardCodeError = freezed,}) {
  return _then(_self.copyWith(
selectedCardType: freezed == selectedCardType ? _self.selectedCardType : selectedCardType // ignore: cast_nullable_to_non_nullable
as String?,selectedDenomination: freezed == selectedDenomination ? _self.selectedDenomination : selectedDenomination // ignore: cast_nullable_to_non_nullable
as String?,serialNumber: null == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String,cardCode: null == cardCode ? _self.cardCode : cardCode // ignore: cast_nullable_to_non_nullable
as String,cardTypeError: freezed == cardTypeError ? _self.cardTypeError : cardTypeError // ignore: cast_nullable_to_non_nullable
as String?,denominationError: freezed == denominationError ? _self.denominationError : denominationError // ignore: cast_nullable_to_non_nullable
as String?,serialNumberError: freezed == serialNumberError ? _self.serialNumberError : serialNumberError // ignore: cast_nullable_to_non_nullable
as String?,cardCodeError: freezed == cardCodeError ? _self.cardCodeError : cardCodeError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CardFormState].
extension CardFormStatePatterns on CardFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardFormState value)  $default,){
final _that = this;
switch (_that) {
case _CardFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardFormState value)?  $default,){
final _that = this;
switch (_that) {
case _CardFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? selectedCardType,  String? selectedDenomination,  String serialNumber,  String cardCode,  String? cardTypeError,  String? denominationError,  String? serialNumberError,  String? cardCodeError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardFormState() when $default != null:
return $default(_that.selectedCardType,_that.selectedDenomination,_that.serialNumber,_that.cardCode,_that.cardTypeError,_that.denominationError,_that.serialNumberError,_that.cardCodeError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? selectedCardType,  String? selectedDenomination,  String serialNumber,  String cardCode,  String? cardTypeError,  String? denominationError,  String? serialNumberError,  String? cardCodeError)  $default,) {final _that = this;
switch (_that) {
case _CardFormState():
return $default(_that.selectedCardType,_that.selectedDenomination,_that.serialNumber,_that.cardCode,_that.cardTypeError,_that.denominationError,_that.serialNumberError,_that.cardCodeError);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? selectedCardType,  String? selectedDenomination,  String serialNumber,  String cardCode,  String? cardTypeError,  String? denominationError,  String? serialNumberError,  String? cardCodeError)?  $default,) {final _that = this;
switch (_that) {
case _CardFormState() when $default != null:
return $default(_that.selectedCardType,_that.selectedDenomination,_that.serialNumber,_that.cardCode,_that.cardTypeError,_that.denominationError,_that.serialNumberError,_that.cardCodeError);case _:
  return null;

}
}

}

/// @nodoc


class _CardFormState implements CardFormState {
  const _CardFormState({this.selectedCardType, this.selectedDenomination, this.serialNumber = '', this.cardCode = '', this.cardTypeError, this.denominationError, this.serialNumberError, this.cardCodeError});
  

@override final  String? selectedCardType;
@override final  String? selectedDenomination;
@override@JsonKey() final  String serialNumber;
@override@JsonKey() final  String cardCode;
@override final  String? cardTypeError;
@override final  String? denominationError;
@override final  String? serialNumberError;
@override final  String? cardCodeError;

/// Create a copy of CardFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardFormStateCopyWith<_CardFormState> get copyWith => __$CardFormStateCopyWithImpl<_CardFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardFormState&&(identical(other.selectedCardType, selectedCardType) || other.selectedCardType == selectedCardType)&&(identical(other.selectedDenomination, selectedDenomination) || other.selectedDenomination == selectedDenomination)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.cardCode, cardCode) || other.cardCode == cardCode)&&(identical(other.cardTypeError, cardTypeError) || other.cardTypeError == cardTypeError)&&(identical(other.denominationError, denominationError) || other.denominationError == denominationError)&&(identical(other.serialNumberError, serialNumberError) || other.serialNumberError == serialNumberError)&&(identical(other.cardCodeError, cardCodeError) || other.cardCodeError == cardCodeError));
}


@override
int get hashCode => Object.hash(runtimeType,selectedCardType,selectedDenomination,serialNumber,cardCode,cardTypeError,denominationError,serialNumberError,cardCodeError);

@override
String toString() {
  return 'CardFormState(selectedCardType: $selectedCardType, selectedDenomination: $selectedDenomination, serialNumber: $serialNumber, cardCode: $cardCode, cardTypeError: $cardTypeError, denominationError: $denominationError, serialNumberError: $serialNumberError, cardCodeError: $cardCodeError)';
}


}

/// @nodoc
abstract mixin class _$CardFormStateCopyWith<$Res> implements $CardFormStateCopyWith<$Res> {
  factory _$CardFormStateCopyWith(_CardFormState value, $Res Function(_CardFormState) _then) = __$CardFormStateCopyWithImpl;
@override @useResult
$Res call({
 String? selectedCardType, String? selectedDenomination, String serialNumber, String cardCode, String? cardTypeError, String? denominationError, String? serialNumberError, String? cardCodeError
});




}
/// @nodoc
class __$CardFormStateCopyWithImpl<$Res>
    implements _$CardFormStateCopyWith<$Res> {
  __$CardFormStateCopyWithImpl(this._self, this._then);

  final _CardFormState _self;
  final $Res Function(_CardFormState) _then;

/// Create a copy of CardFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedCardType = freezed,Object? selectedDenomination = freezed,Object? serialNumber = null,Object? cardCode = null,Object? cardTypeError = freezed,Object? denominationError = freezed,Object? serialNumberError = freezed,Object? cardCodeError = freezed,}) {
  return _then(_CardFormState(
selectedCardType: freezed == selectedCardType ? _self.selectedCardType : selectedCardType // ignore: cast_nullable_to_non_nullable
as String?,selectedDenomination: freezed == selectedDenomination ? _self.selectedDenomination : selectedDenomination // ignore: cast_nullable_to_non_nullable
as String?,serialNumber: null == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String,cardCode: null == cardCode ? _self.cardCode : cardCode // ignore: cast_nullable_to_non_nullable
as String,cardTypeError: freezed == cardTypeError ? _self.cardTypeError : cardTypeError // ignore: cast_nullable_to_non_nullable
as String?,denominationError: freezed == denominationError ? _self.denominationError : denominationError // ignore: cast_nullable_to_non_nullable
as String?,serialNumberError: freezed == serialNumberError ? _self.serialNumberError : serialNumberError // ignore: cast_nullable_to_non_nullable
as String?,cardCodeError: freezed == cardCodeError ? _self.cardCodeError : cardCodeError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$CryptoFormState {

 String? get selectedCrypto;// Crypto ID
 String? get cryptoError;
/// Create a copy of CryptoFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CryptoFormStateCopyWith<CryptoFormState> get copyWith => _$CryptoFormStateCopyWithImpl<CryptoFormState>(this as CryptoFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CryptoFormState&&(identical(other.selectedCrypto, selectedCrypto) || other.selectedCrypto == selectedCrypto)&&(identical(other.cryptoError, cryptoError) || other.cryptoError == cryptoError));
}


@override
int get hashCode => Object.hash(runtimeType,selectedCrypto,cryptoError);

@override
String toString() {
  return 'CryptoFormState(selectedCrypto: $selectedCrypto, cryptoError: $cryptoError)';
}


}

/// @nodoc
abstract mixin class $CryptoFormStateCopyWith<$Res>  {
  factory $CryptoFormStateCopyWith(CryptoFormState value, $Res Function(CryptoFormState) _then) = _$CryptoFormStateCopyWithImpl;
@useResult
$Res call({
 String? selectedCrypto, String? cryptoError
});




}
/// @nodoc
class _$CryptoFormStateCopyWithImpl<$Res>
    implements $CryptoFormStateCopyWith<$Res> {
  _$CryptoFormStateCopyWithImpl(this._self, this._then);

  final CryptoFormState _self;
  final $Res Function(CryptoFormState) _then;

/// Create a copy of CryptoFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedCrypto = freezed,Object? cryptoError = freezed,}) {
  return _then(_self.copyWith(
selectedCrypto: freezed == selectedCrypto ? _self.selectedCrypto : selectedCrypto // ignore: cast_nullable_to_non_nullable
as String?,cryptoError: freezed == cryptoError ? _self.cryptoError : cryptoError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CryptoFormState].
extension CryptoFormStatePatterns on CryptoFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CryptoFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CryptoFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CryptoFormState value)  $default,){
final _that = this;
switch (_that) {
case _CryptoFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CryptoFormState value)?  $default,){
final _that = this;
switch (_that) {
case _CryptoFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? selectedCrypto,  String? cryptoError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CryptoFormState() when $default != null:
return $default(_that.selectedCrypto,_that.cryptoError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? selectedCrypto,  String? cryptoError)  $default,) {final _that = this;
switch (_that) {
case _CryptoFormState():
return $default(_that.selectedCrypto,_that.cryptoError);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? selectedCrypto,  String? cryptoError)?  $default,) {final _that = this;
switch (_that) {
case _CryptoFormState() when $default != null:
return $default(_that.selectedCrypto,_that.cryptoError);case _:
  return null;

}
}

}

/// @nodoc


class _CryptoFormState implements CryptoFormState {
  const _CryptoFormState({this.selectedCrypto, this.cryptoError});
  

@override final  String? selectedCrypto;
// Crypto ID
@override final  String? cryptoError;

/// Create a copy of CryptoFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CryptoFormStateCopyWith<_CryptoFormState> get copyWith => __$CryptoFormStateCopyWithImpl<_CryptoFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CryptoFormState&&(identical(other.selectedCrypto, selectedCrypto) || other.selectedCrypto == selectedCrypto)&&(identical(other.cryptoError, cryptoError) || other.cryptoError == cryptoError));
}


@override
int get hashCode => Object.hash(runtimeType,selectedCrypto,cryptoError);

@override
String toString() {
  return 'CryptoFormState(selectedCrypto: $selectedCrypto, cryptoError: $cryptoError)';
}


}

/// @nodoc
abstract mixin class _$CryptoFormStateCopyWith<$Res> implements $CryptoFormStateCopyWith<$Res> {
  factory _$CryptoFormStateCopyWith(_CryptoFormState value, $Res Function(_CryptoFormState) _then) = __$CryptoFormStateCopyWithImpl;
@override @useResult
$Res call({
 String? selectedCrypto, String? cryptoError
});




}
/// @nodoc
class __$CryptoFormStateCopyWithImpl<$Res>
    implements _$CryptoFormStateCopyWith<$Res> {
  __$CryptoFormStateCopyWithImpl(this._self, this._then);

  final _CryptoFormState _self;
  final $Res Function(_CryptoFormState) _then;

/// Create a copy of CryptoFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedCrypto = freezed,Object? cryptoError = freezed,}) {
  return _then(_CryptoFormState(
selectedCrypto: freezed == selectedCrypto ? _self.selectedCrypto : selectedCrypto // ignore: cast_nullable_to_non_nullable
as String?,cryptoError: freezed == cryptoError ? _self.cryptoError : cryptoError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$GiftcodeFormState {

 String get giftCode; String? get giftCodeError;
/// Create a copy of GiftcodeFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GiftcodeFormStateCopyWith<GiftcodeFormState> get copyWith => _$GiftcodeFormStateCopyWithImpl<GiftcodeFormState>(this as GiftcodeFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GiftcodeFormState&&(identical(other.giftCode, giftCode) || other.giftCode == giftCode)&&(identical(other.giftCodeError, giftCodeError) || other.giftCodeError == giftCodeError));
}


@override
int get hashCode => Object.hash(runtimeType,giftCode,giftCodeError);

@override
String toString() {
  return 'GiftcodeFormState(giftCode: $giftCode, giftCodeError: $giftCodeError)';
}


}

/// @nodoc
abstract mixin class $GiftcodeFormStateCopyWith<$Res>  {
  factory $GiftcodeFormStateCopyWith(GiftcodeFormState value, $Res Function(GiftcodeFormState) _then) = _$GiftcodeFormStateCopyWithImpl;
@useResult
$Res call({
 String giftCode, String? giftCodeError
});




}
/// @nodoc
class _$GiftcodeFormStateCopyWithImpl<$Res>
    implements $GiftcodeFormStateCopyWith<$Res> {
  _$GiftcodeFormStateCopyWithImpl(this._self, this._then);

  final GiftcodeFormState _self;
  final $Res Function(GiftcodeFormState) _then;

/// Create a copy of GiftcodeFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? giftCode = null,Object? giftCodeError = freezed,}) {
  return _then(_self.copyWith(
giftCode: null == giftCode ? _self.giftCode : giftCode // ignore: cast_nullable_to_non_nullable
as String,giftCodeError: freezed == giftCodeError ? _self.giftCodeError : giftCodeError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [GiftcodeFormState].
extension GiftcodeFormStatePatterns on GiftcodeFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GiftcodeFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GiftcodeFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GiftcodeFormState value)  $default,){
final _that = this;
switch (_that) {
case _GiftcodeFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GiftcodeFormState value)?  $default,){
final _that = this;
switch (_that) {
case _GiftcodeFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String giftCode,  String? giftCodeError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GiftcodeFormState() when $default != null:
return $default(_that.giftCode,_that.giftCodeError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String giftCode,  String? giftCodeError)  $default,) {final _that = this;
switch (_that) {
case _GiftcodeFormState():
return $default(_that.giftCode,_that.giftCodeError);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String giftCode,  String? giftCodeError)?  $default,) {final _that = this;
switch (_that) {
case _GiftcodeFormState() when $default != null:
return $default(_that.giftCode,_that.giftCodeError);case _:
  return null;

}
}

}

/// @nodoc


class _GiftcodeFormState implements GiftcodeFormState {
  const _GiftcodeFormState({this.giftCode = '', this.giftCodeError});
  

@override@JsonKey() final  String giftCode;
@override final  String? giftCodeError;

/// Create a copy of GiftcodeFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GiftcodeFormStateCopyWith<_GiftcodeFormState> get copyWith => __$GiftcodeFormStateCopyWithImpl<_GiftcodeFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GiftcodeFormState&&(identical(other.giftCode, giftCode) || other.giftCode == giftCode)&&(identical(other.giftCodeError, giftCodeError) || other.giftCodeError == giftCodeError));
}


@override
int get hashCode => Object.hash(runtimeType,giftCode,giftCodeError);

@override
String toString() {
  return 'GiftcodeFormState(giftCode: $giftCode, giftCodeError: $giftCodeError)';
}


}

/// @nodoc
abstract mixin class _$GiftcodeFormStateCopyWith<$Res> implements $GiftcodeFormStateCopyWith<$Res> {
  factory _$GiftcodeFormStateCopyWith(_GiftcodeFormState value, $Res Function(_GiftcodeFormState) _then) = __$GiftcodeFormStateCopyWithImpl;
@override @useResult
$Res call({
 String giftCode, String? giftCodeError
});




}
/// @nodoc
class __$GiftcodeFormStateCopyWithImpl<$Res>
    implements _$GiftcodeFormStateCopyWith<$Res> {
  __$GiftcodeFormStateCopyWithImpl(this._self, this._then);

  final _GiftcodeFormState _self;
  final $Res Function(_GiftcodeFormState) _then;

/// Create a copy of GiftcodeFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? giftCode = null,Object? giftCodeError = freezed,}) {
  return _then(_GiftcodeFormState(
giftCode: null == giftCode ? _self.giftCode : giftCode // ignore: cast_nullable_to_non_nullable
as String,giftCodeError: freezed == giftCodeError ? _self.giftCodeError : giftCodeError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$CryptoSubmitState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CryptoSubmitState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CryptoSubmitState()';
}


}

/// @nodoc
class $CryptoSubmitStateCopyWith<$Res>  {
$CryptoSubmitStateCopyWith(CryptoSubmitState _, $Res Function(CryptoSubmitState) __);
}


/// Adds pattern-matching-related methods to [CryptoSubmitState].
extension CryptoSubmitStatePatterns on CryptoSubmitState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _CryptoIdle value)?  idle,TResult Function( _CryptoSubmitting value)?  submitting,TResult Function( _CryptoSuccess value)?  success,TResult Function( _CryptoError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CryptoIdle() when idle != null:
return idle(_that);case _CryptoSubmitting() when submitting != null:
return submitting(_that);case _CryptoSuccess() when success != null:
return success(_that);case _CryptoError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _CryptoIdle value)  idle,required TResult Function( _CryptoSubmitting value)  submitting,required TResult Function( _CryptoSuccess value)  success,required TResult Function( _CryptoError value)  error,}){
final _that = this;
switch (_that) {
case _CryptoIdle():
return idle(_that);case _CryptoSubmitting():
return submitting(_that);case _CryptoSuccess():
return success(_that);case _CryptoError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _CryptoIdle value)?  idle,TResult? Function( _CryptoSubmitting value)?  submitting,TResult? Function( _CryptoSuccess value)?  success,TResult? Function( _CryptoError value)?  error,}){
final _that = this;
switch (_that) {
case _CryptoIdle() when idle != null:
return idle(_that);case _CryptoSubmitting() when submitting != null:
return submitting(_that);case _CryptoSuccess() when success != null:
return success(_that);case _CryptoError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  submitting,TResult Function()?  success,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CryptoIdle() when idle != null:
return idle();case _CryptoSubmitting() when submitting != null:
return submitting();case _CryptoSuccess() when success != null:
return success();case _CryptoError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  submitting,required TResult Function()  success,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _CryptoIdle():
return idle();case _CryptoSubmitting():
return submitting();case _CryptoSuccess():
return success();case _CryptoError():
return error(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  submitting,TResult? Function()?  success,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _CryptoIdle() when idle != null:
return idle();case _CryptoSubmitting() when submitting != null:
return submitting();case _CryptoSuccess() when success != null:
return success();case _CryptoError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _CryptoIdle implements CryptoSubmitState {
  const _CryptoIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CryptoIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CryptoSubmitState.idle()';
}


}




/// @nodoc


class _CryptoSubmitting implements CryptoSubmitState {
  const _CryptoSubmitting();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CryptoSubmitting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CryptoSubmitState.submitting()';
}


}




/// @nodoc


class _CryptoSuccess implements CryptoSubmitState {
  const _CryptoSuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CryptoSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CryptoSubmitState.success()';
}


}




/// @nodoc


class _CryptoError implements CryptoSubmitState {
  const _CryptoError(this.message);
  

 final  String message;

/// Create a copy of CryptoSubmitState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CryptoErrorCopyWith<_CryptoError> get copyWith => __$CryptoErrorCopyWithImpl<_CryptoError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CryptoError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'CryptoSubmitState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$CryptoErrorCopyWith<$Res> implements $CryptoSubmitStateCopyWith<$Res> {
  factory _$CryptoErrorCopyWith(_CryptoError value, $Res Function(_CryptoError) _then) = __$CryptoErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$CryptoErrorCopyWithImpl<$Res>
    implements _$CryptoErrorCopyWith<$Res> {
  __$CryptoErrorCopyWithImpl(this._self, this._then);

  final _CryptoError _self;
  final $Res Function(_CryptoError) _then;

/// Create a copy of CryptoSubmitState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_CryptoError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$CodepaySubmitState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CodepaySubmitState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CodepaySubmitState()';
}


}

/// @nodoc
class $CodepaySubmitStateCopyWith<$Res>  {
$CodepaySubmitStateCopyWith(CodepaySubmitState _, $Res Function(CodepaySubmitState) __);
}


/// Adds pattern-matching-related methods to [CodepaySubmitState].
extension CodepaySubmitStatePatterns on CodepaySubmitState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _CodepayIdle value)?  idle,TResult Function( _CodepaySubmitting value)?  submitting,TResult Function( _CodepaySuccess value)?  success,TResult Function( _CodepayError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CodepayIdle() when idle != null:
return idle(_that);case _CodepaySubmitting() when submitting != null:
return submitting(_that);case _CodepaySuccess() when success != null:
return success(_that);case _CodepayError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _CodepayIdle value)  idle,required TResult Function( _CodepaySubmitting value)  submitting,required TResult Function( _CodepaySuccess value)  success,required TResult Function( _CodepayError value)  error,}){
final _that = this;
switch (_that) {
case _CodepayIdle():
return idle(_that);case _CodepaySubmitting():
return submitting(_that);case _CodepaySuccess():
return success(_that);case _CodepayError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _CodepayIdle value)?  idle,TResult? Function( _CodepaySubmitting value)?  submitting,TResult? Function( _CodepaySuccess value)?  success,TResult? Function( _CodepayError value)?  error,}){
final _that = this;
switch (_that) {
case _CodepayIdle() when idle != null:
return idle(_that);case _CodepaySubmitting() when submitting != null:
return submitting(_that);case _CodepaySuccess() when success != null:
return success(_that);case _CodepayError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  submitting,TResult Function()?  success,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CodepayIdle() when idle != null:
return idle();case _CodepaySubmitting() when submitting != null:
return submitting();case _CodepaySuccess() when success != null:
return success();case _CodepayError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  submitting,required TResult Function()  success,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _CodepayIdle():
return idle();case _CodepaySubmitting():
return submitting();case _CodepaySuccess():
return success();case _CodepayError():
return error(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  submitting,TResult? Function()?  success,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _CodepayIdle() when idle != null:
return idle();case _CodepaySubmitting() when submitting != null:
return submitting();case _CodepaySuccess() when success != null:
return success();case _CodepayError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _CodepayIdle implements CodepaySubmitState {
  const _CodepayIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CodepayIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CodepaySubmitState.idle()';
}


}




/// @nodoc


class _CodepaySubmitting implements CodepaySubmitState {
  const _CodepaySubmitting();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CodepaySubmitting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CodepaySubmitState.submitting()';
}


}




/// @nodoc


class _CodepaySuccess implements CodepaySubmitState {
  const _CodepaySuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CodepaySuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CodepaySubmitState.success()';
}


}




/// @nodoc


class _CodepayError implements CodepaySubmitState {
  const _CodepayError(this.message);
  

 final  String message;

/// Create a copy of CodepaySubmitState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CodepayErrorCopyWith<_CodepayError> get copyWith => __$CodepayErrorCopyWithImpl<_CodepayError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CodepayError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'CodepaySubmitState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$CodepayErrorCopyWith<$Res> implements $CodepaySubmitStateCopyWith<$Res> {
  factory _$CodepayErrorCopyWith(_CodepayError value, $Res Function(_CodepayError) _then) = __$CodepayErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$CodepayErrorCopyWithImpl<$Res>
    implements _$CodepayErrorCopyWith<$Res> {
  __$CodepayErrorCopyWithImpl(this._self, this._then);

  final _CodepayError _self;
  final $Res Function(_CodepayError) _then;

/// Create a copy of CodepaySubmitState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_CodepayError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$EWalletSubmitState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EWalletSubmitState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EWalletSubmitState()';
}


}

/// @nodoc
class $EWalletSubmitStateCopyWith<$Res>  {
$EWalletSubmitStateCopyWith(EWalletSubmitState _, $Res Function(EWalletSubmitState) __);
}


/// Adds pattern-matching-related methods to [EWalletSubmitState].
extension EWalletSubmitStatePatterns on EWalletSubmitState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _EWalletIdle value)?  idle,TResult Function( _EWalletSubmitting value)?  submitting,TResult Function( _EWalletSuccess value)?  success,TResult Function( _EWalletError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EWalletIdle() when idle != null:
return idle(_that);case _EWalletSubmitting() when submitting != null:
return submitting(_that);case _EWalletSuccess() when success != null:
return success(_that);case _EWalletError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _EWalletIdle value)  idle,required TResult Function( _EWalletSubmitting value)  submitting,required TResult Function( _EWalletSuccess value)  success,required TResult Function( _EWalletError value)  error,}){
final _that = this;
switch (_that) {
case _EWalletIdle():
return idle(_that);case _EWalletSubmitting():
return submitting(_that);case _EWalletSuccess():
return success(_that);case _EWalletError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _EWalletIdle value)?  idle,TResult? Function( _EWalletSubmitting value)?  submitting,TResult? Function( _EWalletSuccess value)?  success,TResult? Function( _EWalletError value)?  error,}){
final _that = this;
switch (_that) {
case _EWalletIdle() when idle != null:
return idle(_that);case _EWalletSubmitting() when submitting != null:
return submitting(_that);case _EWalletSuccess() when success != null:
return success(_that);case _EWalletError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  submitting,TResult Function()?  success,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EWalletIdle() when idle != null:
return idle();case _EWalletSubmitting() when submitting != null:
return submitting();case _EWalletSuccess() when success != null:
return success();case _EWalletError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  submitting,required TResult Function()  success,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _EWalletIdle():
return idle();case _EWalletSubmitting():
return submitting();case _EWalletSuccess():
return success();case _EWalletError():
return error(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  submitting,TResult? Function()?  success,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _EWalletIdle() when idle != null:
return idle();case _EWalletSubmitting() when submitting != null:
return submitting();case _EWalletSuccess() when success != null:
return success();case _EWalletError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _EWalletIdle implements EWalletSubmitState {
  const _EWalletIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EWalletIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EWalletSubmitState.idle()';
}


}




/// @nodoc


class _EWalletSubmitting implements EWalletSubmitState {
  const _EWalletSubmitting();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EWalletSubmitting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EWalletSubmitState.submitting()';
}


}




/// @nodoc


class _EWalletSuccess implements EWalletSubmitState {
  const _EWalletSuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EWalletSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EWalletSubmitState.success()';
}


}




/// @nodoc


class _EWalletError implements EWalletSubmitState {
  const _EWalletError(this.message);
  

 final  String message;

/// Create a copy of EWalletSubmitState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EWalletErrorCopyWith<_EWalletError> get copyWith => __$EWalletErrorCopyWithImpl<_EWalletError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EWalletError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'EWalletSubmitState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$EWalletErrorCopyWith<$Res> implements $EWalletSubmitStateCopyWith<$Res> {
  factory _$EWalletErrorCopyWith(_EWalletError value, $Res Function(_EWalletError) _then) = __$EWalletErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$EWalletErrorCopyWithImpl<$Res>
    implements _$EWalletErrorCopyWith<$Res> {
  __$EWalletErrorCopyWithImpl(this._self, this._then);

  final _EWalletError _self;
  final $Res Function(_EWalletError) _then;

/// Create a copy of EWalletSubmitState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_EWalletError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$CardSubmitState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardSubmitState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CardSubmitState()';
}


}

/// @nodoc
class $CardSubmitStateCopyWith<$Res>  {
$CardSubmitStateCopyWith(CardSubmitState _, $Res Function(CardSubmitState) __);
}


/// Adds pattern-matching-related methods to [CardSubmitState].
extension CardSubmitStatePatterns on CardSubmitState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _CardIdle value)?  idle,TResult Function( _CardSubmitting value)?  submitting,TResult Function( _CardSuccess value)?  success,TResult Function( _CardError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardIdle() when idle != null:
return idle(_that);case _CardSubmitting() when submitting != null:
return submitting(_that);case _CardSuccess() when success != null:
return success(_that);case _CardError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _CardIdle value)  idle,required TResult Function( _CardSubmitting value)  submitting,required TResult Function( _CardSuccess value)  success,required TResult Function( _CardError value)  error,}){
final _that = this;
switch (_that) {
case _CardIdle():
return idle(_that);case _CardSubmitting():
return submitting(_that);case _CardSuccess():
return success(_that);case _CardError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _CardIdle value)?  idle,TResult? Function( _CardSubmitting value)?  submitting,TResult? Function( _CardSuccess value)?  success,TResult? Function( _CardError value)?  error,}){
final _that = this;
switch (_that) {
case _CardIdle() when idle != null:
return idle(_that);case _CardSubmitting() when submitting != null:
return submitting(_that);case _CardSuccess() when success != null:
return success(_that);case _CardError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  submitting,TResult Function()?  success,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardIdle() when idle != null:
return idle();case _CardSubmitting() when submitting != null:
return submitting();case _CardSuccess() when success != null:
return success();case _CardError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  submitting,required TResult Function()  success,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _CardIdle():
return idle();case _CardSubmitting():
return submitting();case _CardSuccess():
return success();case _CardError():
return error(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  submitting,TResult? Function()?  success,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _CardIdle() when idle != null:
return idle();case _CardSubmitting() when submitting != null:
return submitting();case _CardSuccess() when success != null:
return success();case _CardError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _CardIdle implements CardSubmitState {
  const _CardIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CardSubmitState.idle()';
}


}




/// @nodoc


class _CardSubmitting implements CardSubmitState {
  const _CardSubmitting();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardSubmitting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CardSubmitState.submitting()';
}


}




/// @nodoc


class _CardSuccess implements CardSubmitState {
  const _CardSuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CardSubmitState.success()';
}


}




/// @nodoc


class _CardError implements CardSubmitState {
  const _CardError(this.message);
  

 final  String message;

/// Create a copy of CardSubmitState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardErrorCopyWith<_CardError> get copyWith => __$CardErrorCopyWithImpl<_CardError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'CardSubmitState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$CardErrorCopyWith<$Res> implements $CardSubmitStateCopyWith<$Res> {
  factory _$CardErrorCopyWith(_CardError value, $Res Function(_CardError) _then) = __$CardErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$CardErrorCopyWithImpl<$Res>
    implements _$CardErrorCopyWith<$Res> {
  __$CardErrorCopyWithImpl(this._self, this._then);

  final _CardError _self;
  final $Res Function(_CardError) _then;

/// Create a copy of CardSubmitState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_CardError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$GiftcodeSubmitState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GiftcodeSubmitState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GiftcodeSubmitState()';
}


}

/// @nodoc
class $GiftcodeSubmitStateCopyWith<$Res>  {
$GiftcodeSubmitStateCopyWith(GiftcodeSubmitState _, $Res Function(GiftcodeSubmitState) __);
}


/// Adds pattern-matching-related methods to [GiftcodeSubmitState].
extension GiftcodeSubmitStatePatterns on GiftcodeSubmitState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _GiftcodeIdle value)?  idle,TResult Function( _GiftcodeSubmitting value)?  submitting,TResult Function( _GiftcodeSuccess value)?  success,TResult Function( _GiftcodeError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GiftcodeIdle() when idle != null:
return idle(_that);case _GiftcodeSubmitting() when submitting != null:
return submitting(_that);case _GiftcodeSuccess() when success != null:
return success(_that);case _GiftcodeError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _GiftcodeIdle value)  idle,required TResult Function( _GiftcodeSubmitting value)  submitting,required TResult Function( _GiftcodeSuccess value)  success,required TResult Function( _GiftcodeError value)  error,}){
final _that = this;
switch (_that) {
case _GiftcodeIdle():
return idle(_that);case _GiftcodeSubmitting():
return submitting(_that);case _GiftcodeSuccess():
return success(_that);case _GiftcodeError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _GiftcodeIdle value)?  idle,TResult? Function( _GiftcodeSubmitting value)?  submitting,TResult? Function( _GiftcodeSuccess value)?  success,TResult? Function( _GiftcodeError value)?  error,}){
final _that = this;
switch (_that) {
case _GiftcodeIdle() when idle != null:
return idle(_that);case _GiftcodeSubmitting() when submitting != null:
return submitting(_that);case _GiftcodeSuccess() when success != null:
return success(_that);case _GiftcodeError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  submitting,TResult Function()?  success,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GiftcodeIdle() when idle != null:
return idle();case _GiftcodeSubmitting() when submitting != null:
return submitting();case _GiftcodeSuccess() when success != null:
return success();case _GiftcodeError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  submitting,required TResult Function()  success,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _GiftcodeIdle():
return idle();case _GiftcodeSubmitting():
return submitting();case _GiftcodeSuccess():
return success();case _GiftcodeError():
return error(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  submitting,TResult? Function()?  success,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _GiftcodeIdle() when idle != null:
return idle();case _GiftcodeSubmitting() when submitting != null:
return submitting();case _GiftcodeSuccess() when success != null:
return success();case _GiftcodeError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _GiftcodeIdle implements GiftcodeSubmitState {
  const _GiftcodeIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GiftcodeIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GiftcodeSubmitState.idle()';
}


}




/// @nodoc


class _GiftcodeSubmitting implements GiftcodeSubmitState {
  const _GiftcodeSubmitting();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GiftcodeSubmitting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GiftcodeSubmitState.submitting()';
}


}




/// @nodoc


class _GiftcodeSuccess implements GiftcodeSubmitState {
  const _GiftcodeSuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GiftcodeSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GiftcodeSubmitState.success()';
}


}




/// @nodoc


class _GiftcodeError implements GiftcodeSubmitState {
  const _GiftcodeError(this.message);
  

 final  String message;

/// Create a copy of GiftcodeSubmitState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GiftcodeErrorCopyWith<_GiftcodeError> get copyWith => __$GiftcodeErrorCopyWithImpl<_GiftcodeError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GiftcodeError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'GiftcodeSubmitState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$GiftcodeErrorCopyWith<$Res> implements $GiftcodeSubmitStateCopyWith<$Res> {
  factory _$GiftcodeErrorCopyWith(_GiftcodeError value, $Res Function(_GiftcodeError) _then) = __$GiftcodeErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$GiftcodeErrorCopyWithImpl<$Res>
    implements _$GiftcodeErrorCopyWith<$Res> {
  __$GiftcodeErrorCopyWithImpl(this._self, this._then);

  final _GiftcodeError _self;
  final $Res Function(_GiftcodeError) _then;

/// Create a copy of GiftcodeSubmitState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_GiftcodeError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$VerifyBankSubmitState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerifyBankSubmitState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VerifyBankSubmitState()';
}


}

/// @nodoc
class $VerifyBankSubmitStateCopyWith<$Res>  {
$VerifyBankSubmitStateCopyWith(VerifyBankSubmitState _, $Res Function(VerifyBankSubmitState) __);
}


/// Adds pattern-matching-related methods to [VerifyBankSubmitState].
extension VerifyBankSubmitStatePatterns on VerifyBankSubmitState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _VerifyBankSubmitIdle value)?  idle,TResult Function( _VerifyBankSubmitSubmitting value)?  submitting,TResult Function( _VerifyBankSubmitSuccess value)?  success,TResult Function( _VerifyBankSubmitError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerifyBankSubmitIdle() when idle != null:
return idle(_that);case _VerifyBankSubmitSubmitting() when submitting != null:
return submitting(_that);case _VerifyBankSubmitSuccess() when success != null:
return success(_that);case _VerifyBankSubmitError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _VerifyBankSubmitIdle value)  idle,required TResult Function( _VerifyBankSubmitSubmitting value)  submitting,required TResult Function( _VerifyBankSubmitSuccess value)  success,required TResult Function( _VerifyBankSubmitError value)  error,}){
final _that = this;
switch (_that) {
case _VerifyBankSubmitIdle():
return idle(_that);case _VerifyBankSubmitSubmitting():
return submitting(_that);case _VerifyBankSubmitSuccess():
return success(_that);case _VerifyBankSubmitError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _VerifyBankSubmitIdle value)?  idle,TResult? Function( _VerifyBankSubmitSubmitting value)?  submitting,TResult? Function( _VerifyBankSubmitSuccess value)?  success,TResult? Function( _VerifyBankSubmitError value)?  error,}){
final _that = this;
switch (_that) {
case _VerifyBankSubmitIdle() when idle != null:
return idle(_that);case _VerifyBankSubmitSubmitting() when submitting != null:
return submitting(_that);case _VerifyBankSubmitSuccess() when success != null:
return success(_that);case _VerifyBankSubmitError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  submitting,TResult Function()?  success,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerifyBankSubmitIdle() when idle != null:
return idle();case _VerifyBankSubmitSubmitting() when submitting != null:
return submitting();case _VerifyBankSubmitSuccess() when success != null:
return success();case _VerifyBankSubmitError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  submitting,required TResult Function()  success,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _VerifyBankSubmitIdle():
return idle();case _VerifyBankSubmitSubmitting():
return submitting();case _VerifyBankSubmitSuccess():
return success();case _VerifyBankSubmitError():
return error(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  submitting,TResult? Function()?  success,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _VerifyBankSubmitIdle() when idle != null:
return idle();case _VerifyBankSubmitSubmitting() when submitting != null:
return submitting();case _VerifyBankSubmitSuccess() when success != null:
return success();case _VerifyBankSubmitError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _VerifyBankSubmitIdle implements VerifyBankSubmitState {
  const _VerifyBankSubmitIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerifyBankSubmitIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VerifyBankSubmitState.idle()';
}


}




/// @nodoc


class _VerifyBankSubmitSubmitting implements VerifyBankSubmitState {
  const _VerifyBankSubmitSubmitting();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerifyBankSubmitSubmitting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VerifyBankSubmitState.submitting()';
}


}




/// @nodoc


class _VerifyBankSubmitSuccess implements VerifyBankSubmitState {
  const _VerifyBankSubmitSuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerifyBankSubmitSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VerifyBankSubmitState.success()';
}


}




/// @nodoc


class _VerifyBankSubmitError implements VerifyBankSubmitState {
  const _VerifyBankSubmitError(this.message);
  

 final  String message;

/// Create a copy of VerifyBankSubmitState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerifyBankSubmitErrorCopyWith<_VerifyBankSubmitError> get copyWith => __$VerifyBankSubmitErrorCopyWithImpl<_VerifyBankSubmitError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerifyBankSubmitError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'VerifyBankSubmitState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$VerifyBankSubmitErrorCopyWith<$Res> implements $VerifyBankSubmitStateCopyWith<$Res> {
  factory _$VerifyBankSubmitErrorCopyWith(_VerifyBankSubmitError value, $Res Function(_VerifyBankSubmitError) _then) = __$VerifyBankSubmitErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$VerifyBankSubmitErrorCopyWithImpl<$Res>
    implements _$VerifyBankSubmitErrorCopyWith<$Res> {
  __$VerifyBankSubmitErrorCopyWithImpl(this._self, this._then);

  final _VerifyBankSubmitError _self;
  final $Res Function(_VerifyBankSubmitError) _then;

/// Create a copy of VerifyBankSubmitState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_VerifyBankSubmitError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$VerifyBankFormState {

 String? get selectedBank; String get accountName; String get accountNumber; String? get bankError; String? get accountNameError; String? get accountNumberError;
/// Create a copy of VerifyBankFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerifyBankFormStateCopyWith<VerifyBankFormState> get copyWith => _$VerifyBankFormStateCopyWithImpl<VerifyBankFormState>(this as VerifyBankFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerifyBankFormState&&(identical(other.selectedBank, selectedBank) || other.selectedBank == selectedBank)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.bankError, bankError) || other.bankError == bankError)&&(identical(other.accountNameError, accountNameError) || other.accountNameError == accountNameError)&&(identical(other.accountNumberError, accountNumberError) || other.accountNumberError == accountNumberError));
}


@override
int get hashCode => Object.hash(runtimeType,selectedBank,accountName,accountNumber,bankError,accountNameError,accountNumberError);

@override
String toString() {
  return 'VerifyBankFormState(selectedBank: $selectedBank, accountName: $accountName, accountNumber: $accountNumber, bankError: $bankError, accountNameError: $accountNameError, accountNumberError: $accountNumberError)';
}


}

/// @nodoc
abstract mixin class $VerifyBankFormStateCopyWith<$Res>  {
  factory $VerifyBankFormStateCopyWith(VerifyBankFormState value, $Res Function(VerifyBankFormState) _then) = _$VerifyBankFormStateCopyWithImpl;
@useResult
$Res call({
 String? selectedBank, String accountName, String accountNumber, String? bankError, String? accountNameError, String? accountNumberError
});




}
/// @nodoc
class _$VerifyBankFormStateCopyWithImpl<$Res>
    implements $VerifyBankFormStateCopyWith<$Res> {
  _$VerifyBankFormStateCopyWithImpl(this._self, this._then);

  final VerifyBankFormState _self;
  final $Res Function(VerifyBankFormState) _then;

/// Create a copy of VerifyBankFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedBank = freezed,Object? accountName = null,Object? accountNumber = null,Object? bankError = freezed,Object? accountNameError = freezed,Object? accountNumberError = freezed,}) {
  return _then(_self.copyWith(
selectedBank: freezed == selectedBank ? _self.selectedBank : selectedBank // ignore: cast_nullable_to_non_nullable
as String?,accountName: null == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String,accountNumber: null == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String,bankError: freezed == bankError ? _self.bankError : bankError // ignore: cast_nullable_to_non_nullable
as String?,accountNameError: freezed == accountNameError ? _self.accountNameError : accountNameError // ignore: cast_nullable_to_non_nullable
as String?,accountNumberError: freezed == accountNumberError ? _self.accountNumberError : accountNumberError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VerifyBankFormState].
extension VerifyBankFormStatePatterns on VerifyBankFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerifyBankFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerifyBankFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerifyBankFormState value)  $default,){
final _that = this;
switch (_that) {
case _VerifyBankFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerifyBankFormState value)?  $default,){
final _that = this;
switch (_that) {
case _VerifyBankFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? selectedBank,  String accountName,  String accountNumber,  String? bankError,  String? accountNameError,  String? accountNumberError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerifyBankFormState() when $default != null:
return $default(_that.selectedBank,_that.accountName,_that.accountNumber,_that.bankError,_that.accountNameError,_that.accountNumberError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? selectedBank,  String accountName,  String accountNumber,  String? bankError,  String? accountNameError,  String? accountNumberError)  $default,) {final _that = this;
switch (_that) {
case _VerifyBankFormState():
return $default(_that.selectedBank,_that.accountName,_that.accountNumber,_that.bankError,_that.accountNameError,_that.accountNumberError);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? selectedBank,  String accountName,  String accountNumber,  String? bankError,  String? accountNameError,  String? accountNumberError)?  $default,) {final _that = this;
switch (_that) {
case _VerifyBankFormState() when $default != null:
return $default(_that.selectedBank,_that.accountName,_that.accountNumber,_that.bankError,_that.accountNameError,_that.accountNumberError);case _:
  return null;

}
}

}

/// @nodoc


class _VerifyBankFormState implements VerifyBankFormState {
  const _VerifyBankFormState({this.selectedBank, this.accountName = '', this.accountNumber = '', this.bankError, this.accountNameError, this.accountNumberError});
  

@override final  String? selectedBank;
@override@JsonKey() final  String accountName;
@override@JsonKey() final  String accountNumber;
@override final  String? bankError;
@override final  String? accountNameError;
@override final  String? accountNumberError;

/// Create a copy of VerifyBankFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerifyBankFormStateCopyWith<_VerifyBankFormState> get copyWith => __$VerifyBankFormStateCopyWithImpl<_VerifyBankFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerifyBankFormState&&(identical(other.selectedBank, selectedBank) || other.selectedBank == selectedBank)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.bankError, bankError) || other.bankError == bankError)&&(identical(other.accountNameError, accountNameError) || other.accountNameError == accountNameError)&&(identical(other.accountNumberError, accountNumberError) || other.accountNumberError == accountNumberError));
}


@override
int get hashCode => Object.hash(runtimeType,selectedBank,accountName,accountNumber,bankError,accountNameError,accountNumberError);

@override
String toString() {
  return 'VerifyBankFormState(selectedBank: $selectedBank, accountName: $accountName, accountNumber: $accountNumber, bankError: $bankError, accountNameError: $accountNameError, accountNumberError: $accountNumberError)';
}


}

/// @nodoc
abstract mixin class _$VerifyBankFormStateCopyWith<$Res> implements $VerifyBankFormStateCopyWith<$Res> {
  factory _$VerifyBankFormStateCopyWith(_VerifyBankFormState value, $Res Function(_VerifyBankFormState) _then) = __$VerifyBankFormStateCopyWithImpl;
@override @useResult
$Res call({
 String? selectedBank, String accountName, String accountNumber, String? bankError, String? accountNameError, String? accountNumberError
});




}
/// @nodoc
class __$VerifyBankFormStateCopyWithImpl<$Res>
    implements _$VerifyBankFormStateCopyWith<$Res> {
  __$VerifyBankFormStateCopyWithImpl(this._self, this._then);

  final _VerifyBankFormState _self;
  final $Res Function(_VerifyBankFormState) _then;

/// Create a copy of VerifyBankFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedBank = freezed,Object? accountName = null,Object? accountNumber = null,Object? bankError = freezed,Object? accountNameError = freezed,Object? accountNumberError = freezed,}) {
  return _then(_VerifyBankFormState(
selectedBank: freezed == selectedBank ? _self.selectedBank : selectedBank // ignore: cast_nullable_to_non_nullable
as String?,accountName: null == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String,accountNumber: null == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String,bankError: freezed == bankError ? _self.bankError : bankError // ignore: cast_nullable_to_non_nullable
as String?,accountNameError: freezed == accountNameError ? _self.accountNameError : accountNameError // ignore: cast_nullable_to_non_nullable
as String?,accountNumberError: freezed == accountNumberError ? _self.accountNumberError : accountNumberError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
